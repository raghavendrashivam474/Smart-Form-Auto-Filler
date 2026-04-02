require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/database');

const PORT = process.env.PORT || 5000;

// Connect to database
connectDB();

// Start server
app.listen(PORT, () => {
  console.log('========================================');
  console.log('🚀 Smart Form Backend Server Started');
  console.log('========================================');
  console.log('📍 Port:', PORT);
  console.log('🌍 Environment:', process.env.NODE_ENV);
  console.log('🔗 Health Check: http://localhost:' + PORT + '/health');
  console.log('========================================');
});
