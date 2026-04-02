const mongoose = require('mongoose');

const fieldSchema = new mongoose.Schema({
  id: { type: String, required: true },
  label: { type: String, required: true },
  type: { type: String, required: true },
  required: { type: Boolean, default: false },
  profileKey: { type: String, default: null }
}, { _id: false });

const formSchema = new mongoose.Schema({
  formId: {
    type: String,
    required: true,
    unique: true,
  },
  title: {
    type: String,
    required: true,
  },
  fields: [fieldSchema],
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Form', formSchema);
