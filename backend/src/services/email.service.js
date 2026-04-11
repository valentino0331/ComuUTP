const nodemailer = require('nodemailer');

// Configurar transporter de nodemailer
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Enviar email de verificación
 */
exports.sendVerificationEmail = async (email, nombre, token) => {
  const verificationLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/verify-email?token=${token}`;

  const mailOptions = {
    from: `"Comunidades UTP" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Verifica tu cuenta - Comunidades UTP',
    html: `
      <div style="font-family: 'Montserrat', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f9f9f9; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
        <div style="background: linear-gradient(135deg, #B21132 0%, #8B0D26 100%); padding: 40px 30px; text-align: center;">
          <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 600;">¡Bienvenido a Comunidades UTP!</h1>
          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 16px;">Verifica tu cuenta para empezar</p>
        </div>
        
        <div style="padding: 40px 30px; background: white;">
          <p style="color: #333; font-size: 16px; line-height: 1.6; margin-bottom: 25px;">
            Hola <strong>${nombre}</strong>,
          </p>
          
          <p style="color: #666; font-size: 15px; line-height: 1.6; margin-bottom: 30px;">
            Gracias por unirte a nuestra comunidad. Para completar tu registro y acceder a todas las funciones, verifica tu dirección de correo haciendo clic en el botón:
          </p>
          
          <div style="text-align: center; margin: 35px 0;">
            <a href="${verificationLink}" 
               style="display: inline-block; background: linear-gradient(135deg, #B21132 0%, #8B0D26 100%); 
                      color: white; text-decoration: none; padding: 15px 40px; 
                      border-radius: 30px; font-size: 16px; font-weight: 600;
                      box-shadow: 0 4px 15px rgba(178,17,50,0.3);">
              Verificar mi cuenta
            </a>
          </div>
          
          <p style="color: #888; font-size: 13px; text-align: center; margin-top: 30px;">
            Si el botón no funciona, copia y pega este enlace en tu navegador:<br>
            <a href="${verificationLink}" style="color: #B21132; word-break: break-all;">${verificationLink}</a>
          </p>
          
          <div style="border-top: 1px solid #eee; margin-top: 40px; padding-top: 25px;">
            <p style="color: #999; font-size: 12px; text-align: center; margin: 0;">
              Este enlace expirará en 24 horas. Si no realizaste este registro, ignora este mensaje.<br>
              <strong>Comunidades UTP</strong> - Conectando estudiantes
            </p>
          </div>
        </div>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`✅ Email de verificación enviado a ${email}`);
    return true;
  } catch (error) {
    console.error('❌ Error enviando email:', error);
    return false;
  }
};

/**
 * Enviar email de confirmación de verificación
 */
exports.sendWelcomeEmail = async (email, nombre) => {
  const mailOptions = {
    from: `"Comunidades UTP" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: '¡Tu cuenta ha sido verificada! 🎉',
    html: `
      <div style="font-family: 'Montserrat', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f9f9f9; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
        <div style="background: linear-gradient(135deg, #B21132 0%, #8B0D26 100%); padding: 40px 30px; text-align: center;">
          <h1 style="color: white; margin: 0; font-size: 32px; font-weight: 600;">¡Cuenta verificada!</h1>
          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 18px;">Bienvenido a la comunidad</p>
        </div>
        
        <div style="padding: 40px 30px; background: white; text-align: center;">
          <div style="font-size: 80px; margin: 20px 0;">✅</div>
          
          <p style="color: #333; font-size: 18px; line-height: 1.6; margin-bottom: 25px;">
            ¡Felicidades <strong>${nombre}</strong>!
          </p>
          
          <p style="color: #666; font-size: 15px; line-height: 1.6; margin-bottom: 30px;">
            Tu cuenta ha sido verificada exitosamente. Ahora puedes:<br><br>
            • Crear y unirte a comunidades<br>
            • Publicar y comentar<br>
            • Conectar con otros estudiantes UTP
          </p>
          
          <div style="text-align: center; margin: 35px 0;">
            <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}" 
               style="display: inline-block; background: linear-gradient(135deg, #B21132 0%, #8B0D26 100%); 
                      color: white; text-decoration: none; padding: 15px 40px; 
                      border-radius: 30px; font-size: 16px; font-weight: 600;">
              Ir a la app
            </a>
          </div>
          
          <div style="border-top: 1px solid #eee; margin-top: 40px; padding-top: 25px;">
            <p style="color: #999; font-size: 12px; text-align: center; margin: 0;">
              <strong>Comunidades UTP</strong> - Conectando estudiantes
            </p>
          </div>
        </div>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`✅ Email de bienvenida enviado a ${email}`);
    return true;
  } catch (error) {
    console.error('❌ Error enviando email:', error);
    return false;
  }
};
