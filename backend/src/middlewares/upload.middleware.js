// backend/src/middlewares/upload.middleware.js
const multer = require('multer');
const path = require('path');

// Configuración de almacenamiento temporal
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'pdf-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Filtro para solo aceptar PDFs (incluye variaciones de mimetype)
const fileFilter = (req, file, cb) => {
  const allowedMimes = [
    'application/pdf',
    'application/x-pdf',
    'application/octet-stream', // Algunos navegadores envían esto
  ];
  const isPDF = allowedMimes.includes(file.mimetype) || 
                file.originalname.toLowerCase().endsWith('.pdf');
  
  if (isPDF) {
    cb(null, true);
  } else {
    console.log('Rejected file:', file.originalname, 'mimetype:', file.mimetype);
    cb(new Error('Solo se permiten archivos PDF'), false);
  }
};

// Configuración de multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB máximo
  }
});

module.exports = { upload };
