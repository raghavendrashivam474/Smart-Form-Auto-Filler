const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ MongoDB Connected:', conn.connection.host);
  } catch (error) {
    console.log('❌ MongoDB Connection Failed:', error.message);
    console.log('⚠️  Server will run without database for now');
  }
};

module.exports = connectDB;
