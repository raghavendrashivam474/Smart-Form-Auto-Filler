require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/database');

const PORT = process.env.PORT || 5000;

connectDB();

const smtpReady = Boolean(
  process.env.SMTP_HOST &&
  process.env.SMTP_USER &&
  process.env.SMTP_PASS
);

console.log('========================================');
console.log('🔐 OTP Mode:', process.env.SKIP_OTP_VERIFICATION === 'true' ? 'Development OTP (shown in app)' : 'SMTP email OTP');
console.log('✉️  SMTP Ready:', smtpReady ? 'yes' : 'no');
console.log('========================================');

app.listen(PORT, '0.0.0.0', () => {
  console.log('========================================');
  console.log('🚀 Smart Form Backend Server Started');
  console.log('========================================');
  console.log('📍 Port:', PORT);
  console.log('🌍 Environment:', process.env.NODE_ENV);
  console.log('========================================');
});