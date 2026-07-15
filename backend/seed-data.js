/**
 * Script para crear datos de prueba
 * Crea una comunidad "comunidadUTP" y posts de prueba
 * 
 * Uso: node seed-data.js <uid_usuario>
 * El UID se obtiene de Firebase después de login
 */

const axios = require('axios');

const BACKEND_URL = 'https://comuutp-production.up.railway.app';
// O si estás en local: const BACKEND_URL = 'http://localhost:3000';

// Datos de prueba
const SEED_DATA = {
  community: {
    nombre: 'comunidadUTP',
    descripcion: 'Comunidad oficial de la Universidad Tecnológica del Perú',
    categoria: 'Universidad',
  },
  posts: [
    {
      contenido: '¡Bienvenidos a la comunidad UTP! 🎉 Este es nuestro espacio para conectar y compartir experiencias.',
    },
    {
      contenido: '¿Alguien interesado en organizar un café el próximo viernes? Estoy pensando en el área de ingeniería.',
    },
    {
      contenido: 'Les comparto los apuntes de la clase de hoy. Espero que les sirva para estudiar 📚',
    },
    {
      contenido: 'Se abre convocatoria para proyectos de investigación. ¡Participen! 🚀',
    },
    {
      contenido: 'Feliz viernes a todos! Que disfruten el fin de semana 😊',
    },
  ],
};

async function seedData(firebaseToken) {
  try {
    console.log('🌱 Iniciando seed de datos...\n');

    // Headers con token de Firebase
    const headers = {
      'Authorization': `Bearer ${firebaseToken}`,
      'Content-Type': 'application/json',
    };

    // 1. Crear comunidad
    console.log('📍 Creando comunidad "comunidadUTP"...');
    const communityRes = await axios.post(
      `${BACKEND_URL}/communities`,
      SEED_DATA.community,
      { headers }
    );

    const communityId = communityRes.data.id || communityRes.data.comunidadId;
    console.log(`✅ Comunidad creada con ID: ${communityId}\n`);

    // 2. Crear posts
    console.log('📝 Creando posts de prueba...');
    for (let i = 0; i < SEED_DATA.posts.length; i++) {
      const postData = {
        ...SEED_DATA.posts[i],
        comunidad_id: communityId,
      };

      const postRes = await axios.post(
        `${BACKEND_URL}/posts`,
        postData,
        { headers }
      );

      console.log(`  ✅ Post ${i + 1} creado`);
    }

    console.log(`\n✨ ¡Seed completado exitosamente!`);
    console.log(`📊 Resumen:`);
    console.log(`   - Comunidad: ${SEED_DATA.community.nombre}`);
    console.log(`   - Posts: ${SEED_DATA.posts.length}`);
    console.log(`\n🎯 Ahora abre tu app y verás todo en el feed!\n`);

  } catch (error) {
    console.error('❌ Error durante el seed:');
    if (error.response) {
      console.error(`   Status: ${error.response.status}`);
      console.error(`   Data: ${JSON.stringify(error.response.data, null, 2)}`);
    } else {
      console.error(`   ${error.message}`);
    }
    process.exit(1);
  }
}

// Obtener token de línea de comandos
const token = process.argv[2];

if (!token) {
  console.error('❌ Uso: node seed-data.js <firebase_token>');
  console.error('\nPasos:');
  console.error('1. Abre tu app y loguéate');
  console.error('2. Abre la consola del navegador (F12)');
  console.error('3. En la pestaña "Network", busca cualquier petición a tu backend');
  console.error('4. En "Authorization" header verás: "Bearer <tu_token>"');
  console.error('5. Copia ese token y ejecuta este script\n');
  process.exit(1);
}

seedData(token);
