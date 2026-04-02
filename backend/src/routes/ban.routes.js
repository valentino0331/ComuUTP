const express = require('express');
const router = express.Router();
const banController = require('../controllers/ban.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.post('/', authMiddleware, banController.ban);

module.exports = router;
