// backend/src/services/pdf.service.js
// Servicio especializado para extracción de texto de PDFs con caching y reintentos

const fs = require('fs');
const path = require('path');
const pdfParse = require('pdf-parse');
const { logger } = require('../utils/logger');

// Directorio para caché de PDFs
const CACHE_DIR = path.join(__dirname, '../../cache/pdfs');
if (!fs.existsSync(CACHE_DIR)) {
  fs.mkdirSync(CACHE_DIR, { recursive: true });
}

// Cache en memoria (TTL: 1 hora)
const MEMORY_CACHE = new Map();
const CACHE_TTL = 60 * 60 * 1000; // 1 hora

class PDFService {
  
  /**
   * Descargar PDF desde URL (con reintentos)
   */
  async downloadPDF(fileUrl, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        logger.debug('PDF', `Downloading PDF (attempt ${attempt}/${maxRetries})`, { url: fileUrl });
        
        const response = await fetch(fileUrl, {
          timeout: 30000,
          headers: {
            'User-Agent': 'EstudIA-Backend/1.0'
          }
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        // Validar que sea PDF
        const contentType = response.headers.get('content-type');
        if (!contentType || !contentType.includes('application/pdf')) {
          logger.warn('PDF', 'Invalid content type', { contentType });
          // Continuar igualmente, algunos servidores tienen MIME types raros
        }

        const arrayBuffer = await response.arrayBuffer();
        const buffer = Buffer.from(arrayBuffer);

        if (buffer.length === 0) {
          throw new Error('PDF file is empty');
        }

        logger.info('PDF', 'Downloaded successfully', {
          url: fileUrl,
          size: buffer.length,
          attempt
        });

        return buffer;

      } catch (error) {
        logger.warn('PDF', `Download failed (attempt ${attempt}/${maxRetries})`, {
          url: fileUrl,
          error: error.message
        });

        if (attempt === maxRetries) {
          throw new Error(`Failed to download PDF after ${maxRetries} attempts: ${error.message}`);
        }

        // Esperar antes de reintentar (exponential backoff)
        await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
      }
    }
  }

  /**
   * Extraer texto de buffer PDF
   */
  async extractTextFromBuffer(pdfBuffer, options = {}) {
    try {
      const { maxLength = 20000 } = options;

      logger.debug('PDF', 'Extracting text from PDF buffer', { bufferSize: pdfBuffer.length });

      const data = await pdfParse(pdfBuffer);

      if (!data.text) {
        logger.warn('PDF', 'No text found in PDF');
        return '';
      }

      let text = data.text.trim();

      // Limpiar espacios en blanco excesivos
      text = text.replace(/\n\s*\n/g, '\n').replace(/\s+/g, ' ');

      // Limitar longitud
      if (text.length > maxLength) {
        logger.info('PDF', 'Text truncated', {
          original: text.length,
          truncated: maxLength
        });
        text = text.substring(0, maxLength) + '\n\n... [Documento truncado por extensión]';
      }

      logger.info('PDF', 'Text extracted successfully', {
        length: text.length,
        pages: data.numpages,
        metadata: data.info
      });

      return text;

    } catch (error) {
      logger.error('PDF', 'Error extracting text', {
        error: error.message,
        bufferSize: pdfBuffer.length
      });
      throw error;
    }
  }

  /**
   * Generar hash para caching
   */
  generateCacheKey(fileUrl) {
    const crypto = require('crypto');
    return crypto.createHash('md5').update(fileUrl).digest('hex');
  }

  /**
   * Guardar en caché de archivo
   */
  async saveToDiskCache(cacheKey, text) {
    try {
      const filePath = path.join(CACHE_DIR, `${cacheKey}.txt`);
      fs.writeFileSync(filePath, text, 'utf8');
      logger.debug('PDF', 'Saved to disk cache', { filePath, size: text.length });
      return true;
    } catch (error) {
      logger.warn('PDF', 'Failed to save disk cache', { error: error.message });
      return false;
    }
  }

  /**
   * Leer desde caché de archivo
   */
  async readFromDiskCache(cacheKey) {
    try {
      const filePath = path.join(CACHE_DIR, `${cacheKey}.txt`);
      if (fs.existsSync(filePath)) {
        const text = fs.readFileSync(filePath, 'utf8');
        logger.debug('PDF', 'Read from disk cache', { filePath, size: text.length });
        return text;
      }
      return null;
    } catch (error) {
      logger.warn('PDF', 'Failed to read disk cache', { error: error.message });
      return null;
    }
  }

  /**
   * Guardar en caché en memoria
   */
  saveToMemoryCache(cacheKey, text) {
    MEMORY_CACHE.set(cacheKey, {
      text,
      timestamp: Date.now()
    });
    logger.debug('PDF', 'Saved to memory cache', { cacheKey, size: text.length });
  }

  /**
   * Leer desde caché en memoria
   */
  readFromMemoryCache(cacheKey) {
    const cached = MEMORY_CACHE.get(cacheKey);
    if (!cached) return null;

    // Verificar TTL
    if (Date.now() - cached.timestamp > CACHE_TTL) {
      MEMORY_CACHE.delete(cacheKey);
      logger.debug('PDF', 'Memory cache expired', { cacheKey });
      return null;
    }

    logger.debug('PDF', 'Read from memory cache', { cacheKey });
    return cached.text;
  }

  /**
   * MÉTODO PRINCIPAL: Extraer texto de URL con caché y reintentos
   */
  async extractTextFromURL(fileUrl, options = {}) {
    const { maxRetries = 3, useCache = true } = options;

    logger.info('PDF', 'Starting text extraction', {
      url: fileUrl.substring(0, 100),
      useCache
    });

    try {
      // Validar URL
      if (!fileUrl || typeof fileUrl !== 'string') {
        throw new Error('Invalid file URL');
      }

      const cacheKey = this.generateCacheKey(fileUrl);

      // 1️⃣ Intentar caché en memoria primero
      if (useCache) {
        const memCached = this.readFromMemoryCache(cacheKey);
        if (memCached) {
          logger.info('PDF', 'Using cached text (memory)', { cacheKey });
          return memCached;
        }

        // 2️⃣ Intentar caché en disco
        const diskCached = await this.readFromDiskCache(cacheKey);
        if (diskCached) {
          logger.info('PDF', 'Using cached text (disk)', { cacheKey });
          this.saveToMemoryCache(cacheKey, diskCached); // Recargar a memoria
          return diskCached;
        }
      }

      // 3️⃣ Descargar PDF
      const pdfBuffer = await this.downloadPDF(fileUrl, maxRetries);

      // 4️⃣ Extraer texto
      const text = await this.extractTextFromBuffer(pdfBuffer, options);

      // 5️⃣ Cachear resultado
      if (useCache && text && text.length > 0) {
        this.saveToMemoryCache(cacheKey, text);
        await this.saveToDiskCache(cacheKey, text);
      }

      logger.info('PDF', 'Text extraction completed successfully', {
        cacheKey,
        textLength: text.length
      });

      return text;

    } catch (error) {
      logger.error('PDF', 'Text extraction failed', {
        url: fileUrl.substring(0, 100),
        error: error.message
      });
      
      // Devolver cadena vacía en lugar de fallar
      return '';
    }
  }

  /**
   * Limpiar caché de archivo
   */
  clearDiskCache() {
    try {
      if (fs.existsSync(CACHE_DIR)) {
        fs.rmSync(CACHE_DIR, { recursive: true, force: true });
        fs.mkdirSync(CACHE_DIR, { recursive: true });
        logger.info('PDF', 'Disk cache cleared');
      }
    } catch (error) {
      logger.warn('PDF', 'Failed to clear disk cache', { error: error.message });
    }
  }

  /**
   * Limpiar caché en memoria
   */
  clearMemoryCache() {
    MEMORY_CACHE.clear();
    logger.info('PDF', 'Memory cache cleared');
  }

  /**
   * Obtener estadísticas de caché
   */
  getCacheStats() {
    const cacheFiles = fs.existsSync(CACHE_DIR)
      ? fs.readdirSync(CACHE_DIR).length
      : 0;

    return {
      memoryCache: MEMORY_CACHE.size,
      diskCache: cacheFiles,
      cacheDir: CACHE_DIR,
      ttl: CACHE_TTL
    };
  }
}

module.exports = new PDFService();
