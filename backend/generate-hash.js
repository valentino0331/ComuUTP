const bcrypt = require('bcryptjs');

async function generateHash() {
  const password = 'password123';
  const hash = await bcrypt.hash(password, 10);
  console.log('Password:', password);
  console.log('Hash:', hash);
  
  // Verificar que funciona
  const isValid = await bcrypt.compare(password, hash);
  console.log('Validation:', isValid);
}

generateHash();
