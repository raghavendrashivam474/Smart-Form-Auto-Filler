const mongoose = require('mongoose');

const formMappingSchema = new mongoose.Schema({
  formHash: {
    type: String,
    required: true,
    index: true, // ✅ REMOVED unique: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  formName: String,
  mapping: {
    type: Map,
    of: String, // fieldKey -> profileKey
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  lastUsed: {
    type: Date,
    default: Date.now,
  },
  usageCount: {
    type: Number,
    default: 1,
  },
});

// ✅ ADD COMPOUND UNIQUE INDEX (formHash + userId combination must be unique)
formMappingSchema.index({ formHash: 1, userId: 1 }, { unique: true });

module.exports = mongoose.model('FormMapping', formMappingSchema);