const express = require('express');
const router = express.Router();
const { generateToken, verifyToken } = require('./authMiddleware');

/**
 * POST /api/auth/token
 * Generate a JWT token given client credentials or API key
 */
router.post('/token', (req, res) => {
  const { username, serviceNo, apiKey } = req.body;

  const validApiKey = process.env.API_KEY || 'sltnoc-dev-secret-key-2026';

  // If apiKey is provided, verify it
  if (apiKey) {
    if (apiKey !== validApiKey) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid API Key provided.',
      });
    }

    const token = generateToken({
      sub: username || serviceNo || 'api-user',
      role: 'engineer',
      type: 'client-token',
    });

    return res.json({
      success: true,
      token,
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });
  }

  // If username/serviceNo is provided
  if (!username && !serviceNo) {
    return res.status(400).json({
      success: false,
      error: 'Bad Request',
      message: 'username or serviceNo is required to generate a token.',
    });
  }

  const token = generateToken({
    sub: username || serviceNo,
    role: 'engineer',
    iat: Math.floor(Date.now() / 1000),
  });

  return res.json({
    success: true,
    token,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
});

/**
 * GET /api/auth/verify
 * Checks validity of provided Bearer token
 */
router.get('/verify', (req, res) => {
  const authHeader = req.header('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      valid: false,
      message: 'Authorization header with Bearer token is required.',
    });
  }

  const token = authHeader.substring(7);
  const decoded = verifyToken(token);

  if (!decoded) {
    return res.status(401).json({
      success: false,
      valid: false,
      message: 'Invalid or expired token.',
    });
  }

  return res.json({
    success: true,
    valid: true,
    user: decoded,
  });
});

module.exports = router;
