const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const submissionController = require('../controllers/submissionController');

router.use(auth);

router.post('/', submissionController.submitForm);
router.get('/', submissionController.getSubmissions);
router.get('/:id', submissionController.getSubmission);
router.post('/:id/pdf', submissionController.generatePDF);
router.get('/:id/pdf/download', submissionController.downloadPDF);
router.delete('/:id', submissionController.deleteSubmission);

module.exports = router;