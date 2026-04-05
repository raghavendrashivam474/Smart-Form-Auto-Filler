const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const profileController = require('../controllers/profileController');

router.use(auth);

router.get('/', profileController.getProfile);
router.put('/', profileController.updateProfile);

module.exports = router;