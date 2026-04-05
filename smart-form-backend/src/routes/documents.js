const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const {
  uploadDocument,
  createFormFromFields
} = require('../controllers/documentController');

// All routes require authentication
router.use(auth);

// Upload and process document
router.post('/upload', uploadDocument);

// Create form from detected fields
router.post('/create-form', createFormFromFields);

module.exports = router;