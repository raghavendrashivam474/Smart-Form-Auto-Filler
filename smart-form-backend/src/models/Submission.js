const mongoose = require('mongoose');

const submissionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  formId: {
    type: String,
    required: true,
  },
  formTitle: String,
  data: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
  },
  documents: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Document',
  }],
  pdfUrl: String,
  status: {
    type: String,
    enum: ['draft', 'submitted', 'completed'],
    default: 'submitted',
  },
}, {
  timestamps: true,
});

submissionSchema.index({ userId: 1, formId: 1 });

module.exports = mongoose.model('Submission', submissionSchema);
