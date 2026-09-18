const test = require('node:test');
const assert = require('node:assert');
const { authMiddleware, generateToken, verifyToken } = require('../../routes/authMiddleware');
const manualEscalationsRouter = require('../../routes/manualEscalations');

test('Backend Security & Middleware Tests', async (t) => {
  await t.test('JWT token generation and verification', () => {
    const payload = { userId: 'SLT1001', role: 'admin' };
    const token = generateToken(payload, '1h');
    assert.ok(token && typeof token === 'string');

    const decoded = verifyToken(token);
    assert.ok(decoded);
    assert.strictEqual(decoded.userId, 'SLT1001');
    assert.strictEqual(decoded.role, 'admin');

    const invalid = verifyToken('invalid.token.signature');
    assert.strictEqual(invalid, null);
  });

  await t.test('Auth middleware blocks unauthorized requests', () => {
    const req = {
      path: '/api/alarms1',
      header: () => null,
      query: {},
    };

    let statusCalled = null;
    let jsonCalled = null;
    const res = {
      status(code) {
        statusCalled = code;
        return {
          json(data) {
            jsonCalled = data;
          }
        };
      }
    };

    let nextCalled = false;
    authMiddleware(req, res, () => {
      nextCalled = true;
    });

    assert.strictEqual(nextCalled, false);
    assert.strictEqual(statusCalled, 401);
    assert.ok(jsonCalled && jsonCalled.error === 'Unauthorized');
  });

  await t.test('Auth middleware accepts valid API key', () => {
    const req = {
      path: '/api/alarms1',
      header(name) {
        if (name === 'X-API-Key') return 'sltnoc-dev-secret-key-2026';
        return null;
      },
      query: {},
    };

    const res = {};
    let nextCalled = false;
    authMiddleware(req, res, () => {
      nextCalled = true;
    });

    assert.strictEqual(nextCalled, true);
    assert.ok(req.user && req.auth.type === 'apiKey');
  });

  await t.test('Auth middleware accepts valid Bearer JWT', () => {
    const token = generateToken({ user: 'operator1' }, '1h');
    const req = {
      path: '/api/chat',
      header(name) {
        if (name === 'Authorization') return `Bearer ${token}`;
        return null;
      },
      query: {},
    };

    const res = {};
    let nextCalled = false;
    authMiddleware(req, res, () => {
      nextCalled = true;
    });

    assert.strictEqual(nextCalled, true);
    assert.ok(req.user && req.auth.type === 'jwt');
  });

  await t.test('Manual escalations router is a valid Express Router instance', () => {
    assert.strictEqual(typeof manualEscalationsRouter, 'function');
    assert.ok(Array.isArray(manualEscalationsRouter.stack));
  });
});
