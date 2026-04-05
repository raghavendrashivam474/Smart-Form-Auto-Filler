const mongoose = require('mongoose');

const fieldUsageSchema = new mongoose.Schema({
  fieldKey: {
    type: String,
    required: true,
    unique: true,
  },
  label: String,
  usageCount: {
    type: Number,
    default: 0,
  },
  lastUsed: Date,
  inOnboarding: {
    type: Boolean,
    default: false,
  },
  threshold: {
    type: Number,
    default: 100,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('FieldUsage', fieldUsageSchema);
