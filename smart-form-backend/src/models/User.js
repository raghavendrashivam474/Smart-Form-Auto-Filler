const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true,
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