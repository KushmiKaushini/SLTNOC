const express = require('express');
const fs = require('fs/promises');
const path = require('path');

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
    const items = await readItems();
    res.json(items.filter((item) => item.status !== 'CLOSED'));
  } catch (error) {
    console.error('Manual escalations read error:', error);
    res.status(500).json({ error: 'Unable to read manual escalations' });
  }
});

router.get('/summary', async (req, res) => {
  try {
    const items = await readItems();
    const activeCount = items.filter((item) => item.status !== 'CLOSED').length;
    res.json({ activeCount, hasActive: activeCount > 0 });
  } catch (error) {
    console.error('Manual escalations summary error:', error);
    res.status(500).json({ error: 'Unable to read manual escalations summary' });
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

  try {
    const items = await readItems();
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

    items.unshift(item);
    await writeItems(items);
    res.status(201).json(item);
  } catch (error) {
    console.error('Manual escalations create error:', error);
    res.status(500).json({ error: 'Unable to create manual escalation' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const id = clean(req.params.id);
    if (!id) {
      return res.status(400).json({ error: 'ID is required' });
    }

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
