const { Client } = require('pg');
const client = new Client({
  connectionString: 'postgresql://neondb_owner:npg_2ZJXN7jLwSRx@ep-misty-morning-ans3gxc5-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require',
});
(async () => {
  try {
    await client.connect();
    const result = await client.query(
      "UPDATE usuarios SET role = 'admin', puede_crear_comunidad = true WHERE correo = 'u22247388@utp.edu.pe'"
    );
    console.log('Update successful:', result.rowCount, 'rows updated');
    await client.end();
  } catch (e) {
    console.error('Error:', e.message);
  }
})();
