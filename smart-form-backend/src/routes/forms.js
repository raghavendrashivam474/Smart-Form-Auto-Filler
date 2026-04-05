const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const formController = require('../controllers/formController');

router.use(auth);

router.get('/', formController.getForms);
router.get('/:formId', formController.getFormById);
router.post('/', formController.createForm);

module.exports = router;