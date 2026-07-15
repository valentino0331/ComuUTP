const express = require('express');
const router = express.Router();
const banController = require('../controllers/ban.controller');
const { authenticate } = require('../middlewares/auth.middleware');

router.post('/', authenticate, banController.ban);

module.exports = router;
