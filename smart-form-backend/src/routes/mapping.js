const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const mappingController = require('../controllers/mappingController');

router.use(auth);

router.post('/detect', mappingController.detectMapping);
router.post('/save', mappingController.saveMapping);
router.get('/user', mappingController.getUserMappings);

module.exports = router;