const express = require('express');
const router = express.Router();
const {
  uploadDocument,
  getDocuments,
  getDocument,
  deleteDocument,
  downloadDocument,
} = require('../controllers/documentController');
const { protect } = require('../middleware/auth');
const upload = require('../config/multer');

router.post('/upload', protect, upload.single('document'), uploadDocument);
router.get('/', protect, getDocuments);
router.get('/:id', protect, getDocument);
router.delete('/:id', protect, deleteDocument);
router.get('/:id/download', protect, downloadDocument);

module.exports = router;
