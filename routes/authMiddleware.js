const jwt = require('jsonwebtoken');

// Secrets and Keys from environment
const JWT_SECRET = process.env.JWT_SECRET || 'sltnoc-super-secure-jwt-secret-2026-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// Valid API Keys list
const DEFAULT_DEV_API_KEY = 'sltnoc-dev-secret-key-2026';
const configuredApiKeys = (process.env.API_KEY || process.env.SLTNOC_API_KEYS || DEFAULT_DEV_API_KEY)
  .split(',')
  .map(k => k.trim())
  .filter(Boolean);

/**
 * Generates a signed JWT for a given payload
 */
function generateToken(payload, expiresIn = JWT_EXPIRES_IN) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn });
}

/**
 * Verifies a JWT token
 */
function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (err) {
    return null;
  }
}

/**
 * Express Middleware to authenticate incoming requests via:
 * 1. Bearer JWT in Authorization header: `Authorization: Bearer <token>`
 * 2. API Key in X-API-Key header: `X-API-Key: <key>`
 * 3. API Key in Authorization header: `Authorization: ApiKey <key>`
 */
function authMiddleware(req, res, next) {
  // Allow health check and authentication endpoints to bypass
  const path = req.path || '';
  if (path === '/ai-health' || path === '/health' || path.startsWith('/auth/')) {
    return next();
  }

  // Check for disabled auth in development if explicitly configured
  if (process.env.REQUIRE_AUTH === 'false') {
    req.user = { id: 'anonymous-dev', role: 'dev' };
    return next();
  }

  // 1. Check for API Key in X-API-Key header or query
  const apiKeyHeader = req.header('X-API-Key') || req.query.apiKey;
  if (apiKeyHeader && configuredApiKeys.includes(apiKeyHeader.trim())) {
    req.auth = { type: 'apiKey', key: apiKeyHeader.trim() };
    req.user = { id: 'service-client', role: 'api-client' };
    return next();
  }

  // 2. Check Authorization Header
  const authHeader = req.header('Authorization');
  if (authHeader) {
    const parts = authHeader.trim().split(' ');
    if (parts.length === 2) {
      const scheme = parts[0].toLowerCase();
      const credentials = parts[1];

      // Bearer JWT Token
      if (scheme === 'bearer') {
        const decoded = verifyToken(credentials);
        if (decoded) {
          req.auth = { type: 'jwt', token: credentials };
          req.user = decoded;
          return next();
        } else {
          return res.status(401).json({
            success: false,
            error: 'Unauthorized',
            message: 'Invalid or expired JWT token.',
          });
        }
      }

      // ApiKey in Authorization header
      if (scheme === 'apikey') {
        if (configuredApiKeys.includes(credentials.trim())) {
          req.auth = { type: 'apiKey', key: credentials.trim() };
          req.user = { id: 'service-client', role: 'api-client' };
          return next();
        }
      }
    }
  }

  // No valid credentials provided
  return res.status(401).json({
    success: false,
    error: 'Unauthorized',
    message: 'Authentication required. Please provide a valid Authorization: Bearer <jwt> or X-API-Key header.',
  });
}

module.exports = {
  authMiddleware,
  generateToken,
  verifyToken,
  JWT_SECRET,
};
