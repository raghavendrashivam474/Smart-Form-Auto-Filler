const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  profile: {
    fullName: String,
    email: String,
    dateOfBirth: Date,
    address: {
      street: String,
      city: String,
      state: String,
      pincode: String,
    },
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('User', userSchema);
