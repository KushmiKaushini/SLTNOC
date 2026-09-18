const express = require('express');
const fs = require('fs/promises');
const path = require('path');
const db = require('./db');

const router = express.Router();
const dataDir = path.join(__dirname, '..', 'data');
const dataFile = path.join(dataDir, 'manual_escalations.json');

async function readItems() {
  try {
    const content = await fs.readFile(dataFile, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    if (error.code === 'ENOENT') {
      return [];
    }
    throw error;
  }
}

async function writeItems(items) {
  await fs.mkdir(dataDir, { recursive: true });
  await fs.writeFile(dataFile, JSON.stringify(items, null, 2), 'utf8');
}

function clean(value) {
  return String(value || '').trim();
}

function itemId(item) {
  const value = item.id || item._id || item.Id || item.ID || item.manualEscalationId || item.manual_escalation_id;
  if (value && typeof value === 'object' && value.$oid) {
    return clean(value.$oid);
  }
  return clean(value);
}

router.get('/', async (req, res) => {
  try {
    const request = new db.Request();
    const result = await request.query(`
      SELECT id, escalationType, node, platform, severity, tag, description, startAt, reportingBy, responsibleOfficer, status, createdAt, updatedAt
      FROM MANUAL_ESCALATIONS
      WHERE status != 'CLOSED'
      ORDER BY createdAt DESC
    `);
    if (result && result.recordset && result.recordset.length > 0) {
      return res.json(result.recordset);
    }
    const items = await readItems();
    res.json(items.filter((item) => item.status !== 'CLOSED'));
  } catch (error) {
    console.warn('DB query failed for manual escalations, falling back to JSON store:', error.message);
    try {
      const items = await readItems();
      res.json(items.filter((item) => item.status !== 'CLOSED'));
    } catch (readErr) {
      console.error('Manual escalations read error:', readErr);
      res.status(500).json({ error: 'Unable to read manual escalations' });
    }
  }
});

router.get('/summary', async (req, res) => {
  try {
    const request = new db.Request();
    const result = await request.query(`
      SELECT COUNT(*) as activeCount
      FROM MANUAL_ESCALATIONS
      WHERE status != 'CLOSED'
    `);
    if (result && result.recordset && result.recordset.length > 0 && result.recordset[0].activeCount > 0) {
      const count = result.recordset[0].activeCount;
      return res.json({ activeCount: count, hasActive: count > 0 });
    }
    const items = await readItems();
    const activeCount = items.filter((item) => item.status !== 'CLOSED').length;
    res.json({ activeCount, hasActive: activeCount > 0 });
  } catch (error) {
    console.warn('DB query failed for manual escalations summary, falling back to JSON store:', error.message);
    try {
      const items = await readItems();
      const activeCount = items.filter((item) => item.status !== 'CLOSED').length;
      res.json({ activeCount, hasActive: activeCount > 0 });
    } catch (readErr) {
      console.error('Manual escalations summary error:', readErr);
      res.status(500).json({ error: 'Unable to read manual escalations summary' });
    }
  }
});

router.post('/', async (req, res) => {
  const escalationType = clean(req.body?.escalationType);
  const node = clean(req.body?.node);
  const platform = clean(req.body?.platform);
  const severity = clean(req.body?.severity);
  const tag = clean(req.body?.tag);
  const description = clean(req.body?.description);
  const startAt = clean(req.body?.startAt);
  const reportingBy = clean(req.body?.reportingBy);
  const responsibleOfficer = clean(req.body?.responsibleOfficer);

  if (!escalationType || !node || !platform || !severity || !description || !startAt || !reportingBy || !responsibleOfficer) {
    return res.status(400).json({
      error: 'Escalation type, node, platform, severity, description, start at, reporting by, and responsible officer are required',
    });
  }

  const parsedStartAt = new Date(startAt);
  if (Number.isNaN(parsedStartAt.getTime())) {
    return res.status(400).json({ error: 'Start at must be a valid date/time' });
  }

  const now = new Date().toISOString();
  const item = {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
    escalationType,
    node,
    platform,
    severity,
    tag,
    description,
    startAt: parsedStartAt.toISOString(),
    reportingBy,
    responsibleOfficer,
    status: 'OPEN',
    createdAt: now,
    updatedAt: now,
  };

  try {
    const request = new db.Request();
    request.input('id', db.VarChar, item.id);
    request.input('escalationType', db.VarChar, item.escalationType);
    request.input('node', db.VarChar, item.node);
    request.input('platform', db.VarChar, item.platform);
    request.input('severity', db.VarChar, item.severity);
    request.input('tag', db.VarChar, item.tag);
    request.input('description', db.NVarChar, item.description);
    request.input('startAt', db.DateTime, new Date(item.startAt));
    request.input('reportingBy', db.VarChar, item.reportingBy);
    request.input('responsibleOfficer', db.VarChar, item.responsibleOfficer);
    request.input('status', db.VarChar, item.status);
    request.input('createdAt', db.DateTime, new Date(item.createdAt));
    request.input('updatedAt', db.DateTime, new Date(item.updatedAt));

    await request.query(`
      INSERT INTO MANUAL_ESCALATIONS (id, escalationType, node, platform, severity, tag, description, startAt, reportingBy, responsibleOfficer, status, createdAt, updatedAt)
      VALUES (@id, @escalationType, @node, @platform, @severity, @tag, @description, @startAt, @reportingBy, @responsibleOfficer, @status, @createdAt, @updatedAt)
    `);
  } catch (dbErr) {
    console.warn('DB insert failed for manual escalation, persisting in JSON store:', dbErr.message);
  }

  try {
    const items = await readItems();
    items.unshift(item);
    await writeItems(items);
    res.status(201).json(item);
  } catch (error) {
    console.error('Manual escalations create error:', error);
    res.status(500).json({ error: 'Unable to create manual escalation' });
  }
});

router.delete('/:id', async (req, res) => {
  const id = clean(req.params.id);
  if (!id) {
    return res.status(400).json({ error: 'ID is required' });
  }

  try {
    const request = new db.Request();
    request.input('id', db.VarChar, id);
    await request.query(`
      UPDATE MANUAL_ESCALATIONS
      SET status = 'CLOSED', updatedAt = GETDATE()
      WHERE id = @id
    `);
  } catch (dbErr) {
    console.warn('DB delete/close failed for manual escalation:', dbErr.message);
  }

  try {
    const items = await readItems();
    const itemIndex = items.findIndex((item) => itemId(item) === id);

    if (itemIndex === -1) {
      return res.status(404).json({ error: 'Escalation not found' });
    }

    items.splice(itemIndex, 1);
    await writeItems(items);
    res.json({ message: 'Escalation deleted successfully' });
  } catch (error) {
    console.error('Manual escalations delete error:', error);
    res.status(500).json({ error: 'Unable to delete manual escalation' });
  }
});

module.exports = router;
