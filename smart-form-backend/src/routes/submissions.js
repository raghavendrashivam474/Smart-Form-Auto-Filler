const express = require('express');
const router = express.Router();
const {
  submitForm,
  getSubmissions,
  getSubmission,
  deleteSubmission,
  generatePDF,
  downloadPDF,
  getFieldStatistics,
} = require('../controllers/submissionController');
const { protect } = require('../middleware/auth');

router.post('/', protect, submitForm);
router.get('/', protect, getSubmissions);
router.get('/analytics/fields', protect, getFieldStatistics);
router.get('/:id', protect, getSubmission);
router.post('/:id/pdf', protect, generatePDF);
router.get('/:id/pdf/download', protect, downloadPDF);
router.delete('/:id', protect, deleteSubmission);

module.exports = router;
