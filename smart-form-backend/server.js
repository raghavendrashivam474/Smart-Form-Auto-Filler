require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/database');

const PORT = process.env.PORT || 5000;

// Connect Database
connectDB();

// 🔥 RESEND CHECK (Clean & Correct)
console.log('========================================');
console.log('📧 Email Mode: Resend API');
console.log('🔑 Resend Key:', process.env.RESEND_API_KEY ? 'Present ✅' : 'Missing ❌');
console.log('========================================');

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log('========================================');
  console.log('🚀 Smart Form Backend Server Started');
  console.log('========================================');
  console.log('📍 Port:', PORT);
  console.log('🌍 Environment:', process.env.NODE_ENV || 'development');
  console.log('========================================');
});