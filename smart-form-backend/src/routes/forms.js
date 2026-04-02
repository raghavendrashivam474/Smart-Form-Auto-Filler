const express = require('express');
const router = express.Router();
const { getAllForms, getForm } = require('../controllers/formController');
const { protect } = require('../middleware/auth');

router.get('/', protect, getAllForms);
router.get('/:formId', protect, getForm);

module.exports = router;
