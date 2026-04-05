const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    sparse: true,
  },
  phoneNumber: {
    type: String,
    trim: true,
    default: null,
    sparse: true,
  },
  profile: {
    type: mongoose.Schema.Types.Mixed,
    default: {},
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
  strict: false,
});

module.exports = mongoose.model('User', userSchema);