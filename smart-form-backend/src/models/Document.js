const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
    enum: ['income', 'academic', 'identity', 'caste', 'domicile', 'other'],
  },
  filename: {
    type: String,
    required: true,
  },
  path: {
    type: String,
    required: true,
  },
  mimeType: String,
  size: Number,
}, {
  timestamps: true,
});

documentSchema.index({ userId: 1, category: 1 });

module.exports = mongoose.model('Document', documentSchema);
