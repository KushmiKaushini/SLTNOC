// transparent DB wrapper for SLTNOC project
// Delegates to tedious/mssql, but automatically falls back to in-memory mock database
// if the connection fails or if SQL Server is not running.

require('dotenv').config();
const mssql = require('mssql');
const { mockFaults, mockEscalationsAuto } = require('./mockDbData');
const { getSqlCredentials } = require('./utils/keyVault');

let isConnected = false;
let useMock = false;
let activePool = null;

// Helper to determine node type from node name
function getNodeType(nodeName) {
  const upper = String(nodeName || '').toUpperCase();
  if (upper.includes('ENODEB')) return 'eNodeB';
  if (upper.includes('NODEB')) return 'NodeB';
  if (upper.includes('MSAN')) return 'MSAN';
  if (upper.includes('OLT')) return 'OLT';
  if (upper.includes('RNC')) return 'RNC';
  if (upper.includes('BTS')) return 'BTS';
  if (upper.includes('CEA')) return 'CEA';
  return 'OTHER';
}

// Calculate hours between fault time and now
function getDurationHours(faultTimeStr) {
  const faultTime = new Date(faultTimeStr);
  const diffMs = Date.now() - faultTime.getTime();
  return Math.max(0, Math.floor(diffMs / (1000 * 60 * 60)));
}


// Mock query processor
function processMockQuery(queryStr, inputs = {}) {
  const q = queryStr.replace(/\s+/g, ' ').trim();
  console.log(`[Mock DB Query]: ${q}`, JSON.stringify(inputs));

  // 1. SELECT DISTINCT(PROVINCE) FROM FAULTS WHERE REGION = '...'
  if (q.includes('DISTINCT(PROVINCE)')) {
    let region = inputs.region || '';
    if (!region) {
      const match = q.match(/REGION\s*=\s*'([^']+)'/i);
      if (match) region = match[1];
    }
    const provinces = mockFaults
      .filter(f => f.REGION.toLowerCase() === region.toLowerCase())
      .map(f => f.PROVINCE);
    const distinct = [...new Set(provinces)];
    return distinct.map(p => ({ PROVINCE: p }));
  }

  // 2. Query 1: Open alarms by Province (aiTools.js summary)
  if (q.includes('PROVINCE, COUNT(*)') && q.includes('GROUP BY PROVINCE')) {
    const counts = {};
    mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' && f.PROVINCE)
      .forEach(f => {
        counts[f.PROVINCE] = (counts[f.PROVINCE] || 0) + 1;
      });
    return Object.entries(counts)
      .map(([PROVINCE, OpenAlarms]) => ({ PROVINCE, OpenAlarms }))
      .sort((a, b) => b.OpenAlarms - a.OpenAlarms);
  }

  // 3. Query 2: Open alarms by Group (aiTools.js summary)
  if (q.includes('NW_ENG, COUNT(*)') && q.includes('GROUP BY NW_ENG')) {
    const counts = {};
    mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' && f.NW_ENG && f.NW_ENG !== 'Default')
      .forEach(f => {
        counts[f.NW_ENG] = (counts[f.NW_ENG] || 0) + 1;
      });
    return Object.entries(counts)
      .map(([NW_ENG, OpenAlarms]) => ({ NW_ENG, OpenAlarms }))
      .sort((a, b) => b.OpenAlarms - a.OpenAlarms);
  }

  // 4. SELECT NW_ENG, COUNT(*) as OpenAlarms FROM FAULTS WHERE PROVINCE = '${province}' AND FAULT_STATUS = 'OPEN' ...
  if (q.includes('NW_ENG, COUNT(*)') && q.includes('PROVINCE =')) {
    let province = inputs.province || '';
    if (!province) {
      const match = q.match(/PROVINCE\s*=\s*'([^']+)'/i);
      if (match) province = match[1];
    }
    const counts = {};
    mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' && f.PROVINCE.toLowerCase() === province.toLowerCase() && f.NW_ENG !== 'Default')
      .forEach(f => {
        counts[f.NW_ENG] = (counts[f.NW_ENG] || 0) + 1;
      });
    return Object.entries(counts).map(([NW_ENG, OpenAlarms]) => ({ NW_ENG, OpenAlarms }));
  }

  // 5. SELECT ALARM_TYPE, COUNT(*) as OpenAlarms FROM FAULTS WHERE FAULT_STATUS = 'OPEN' AND NW_ENG = ... AND PROVINCE = ...
  if (q.includes('ALARM_TYPE, COUNT(*)') && q.includes('GROUP BY ALARM_TYPE')) {
    let name = inputs.name || '';
    let province = inputs.province || '';
    if (!name || !province) {
      // Try mapping parameters from tag template parameters
      const nameMatch = q.match(/NW_ENG\s*=\s*'([^']+)'/i) || q.match(/NW_ENG\s*=\s*@\w+/i);
      const provMatch = q.match(/PROVINCE\s*=\s*'([^']+)'/i) || q.match(/PROVINCE\s*=\s*@\w+/i);
      if (nameMatch && typeof nameMatch[1] === 'string') name = nameMatch[1];
      if (provMatch && typeof provMatch[1] === 'string') province = provMatch[1];
    }

    const counts = {};
    mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' &&
                   (f.NW_ENG === name || name === '%' || !name) &&
                   (f.PROVINCE === province || province === '%' || !province))
      .forEach(f => {
        counts[f.ALARM_TYPE] = (counts[f.ALARM_TYPE] || 0) + 1;
      });
    return Object.entries(counts).map(([ALARM_TYPE, OpenAlarms]) => ({ ALARM_TYPE, OpenAlarms }));
  }

  // 6. SELECT NODE, DATEDIFF(hour, FAULT_TIME, GETDATE()) AS DURATION FROM FAULTS WHERE ALARM_TYPE = ...
  if (q.includes('DURATION') && q.includes('FAULT_TIME')) {
    let alarmType = inputs.alarmType || '';
    let name = inputs.name || '';
    let province = inputs.province || '';
    if (!alarmType) {
      const match = q.match(/ALARM_TYPE\s*=\s*'([^']+)'/i);
      if (match) alarmType = match[1];
    }
    if (!name) {
      const match = q.match(/NW_ENG\s*=\s*'([^']+)'/i);
      if (match) name = match[1];
    }
    if (!province) {
      const match = q.match(/PROVINCE\s*=\s*'([^']+)'/i);
      if (match) province = match[1];
    }

    return mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' &&
                   f.ALARM_TYPE === alarmType &&
                   f.NW_ENG === name &&
                   f.PROVINCE === province)
      .map(f => ({
        NODE: f.NODE,
        DURATION: getDurationHours(f.FAULT_TIME)
      }));
  }

  // 7. Node type counts: SELECT NODE_TYPE AS NODE, COUNT(*) AS OpenAlarms
  if (q.includes('NODE_TYPE AS NODE') || q.includes('CASE WHEN UPPER')) {
    let alarmType = inputs.alarmType || '';
    let name = inputs.name || '%';
    let province = inputs.province || '%';

    const counts = {};
    mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' &&
                   f.ALARM_TYPE === alarmType &&
                   (name === '%' || f.NW_ENG === name) &&
                   (province === '%' || f.PROVINCE === province))
      .forEach(f => {
        const type = getNodeType(f.NODE);
        counts[type] = (counts[type] || 0) + 1;
      });

    return Object.entries(counts).map(([NODE, OpenAlarms]) => ({ NODE, OpenAlarms }));
  }

  // 8. Node detailed alarms: SELECT FAULTS.NODE, FAULTS.NW_ENG, FAULTS.PROVINCE, FAULTS.FAULT, ESCALATIONS_AUTO.NAME, ESCALATIONS_AUTO.MOBILE
  if (q.includes('ESCALATIONS_AUTO') && q.includes('LEFT JOIN')) {
    let alarmType = inputs.alarmType || '';
    let name = inputs.name || '%';
    let province = inputs.province || '%';
    let nodeType = inputs.nodeType || '';

    const filteredFaults = mockFaults.filter(f => 
      f.FAULT_STATUS === 'OPEN' &&
      f.ALARM_TYPE === alarmType &&
      (name === '%' || f.NW_ENG === name) &&
      (province === '%' || f.PROVINCE === province) &&
      (getNodeType(f.NODE) === nodeType)
    );

    return filteredFaults.map(f => {
      // Find matching escalation auto if any
      const esc = mockEscalationsAuto.find(e => e.FAULT_ID === f.ID) || { NAME: 'Kamal Perera', MOBILE: '0712345678' };
      return {
        NODE: f.NODE,
        NW_ENG: f.NW_ENG,
        PROVINCE: f.PROVINCE,
        FAULT: f.FAULT,
        NAME: esc.NAME,
        MOBILE: esc.MOBILE
      };
    });
  }

  // 9. Node details query for specific node name
  if (q.includes('FROM FAULTS WHERE NODE =')) {
    let nodeName = inputs.node || '';
    if (!nodeName) {
      const match = q.match(/NODE\s*=\s*@\w+/i) || q.match(/NODE\s*=\s*'([^']+)'/i);
      if (match && match[1]) nodeName = match[1];
    }
    return mockFaults
      .filter(f => f.NODE.toLowerCase() === String(nodeName).toLowerCase())
      .map(f => ({
        ALARM_TYPE: f.ALARM_TYPE,
        FAULT_STATUS: f.FAULT_STATUS,
        FAULT_TIME: f.FAULT_TIME,
        DURATION_HOURS: getDurationHours(f.FAULT_TIME),
        PROVINCE: f.PROVINCE,
        NW_ENG: f.NW_ENG
      }));
  }

  // 10. General catch-all for province queries
  if (q.includes('PROVINCE = @province')) {
    let province = inputs.province || '';
    return mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' && f.PROVINCE.toLowerCase() === province.toLowerCase())
      .map(f => ({
        NODE: f.NODE,
        ALARM_TYPE: f.ALARM_TYPE,
        DURATION_HOURS: getDurationHours(f.FAULT_TIME),
        NW_ENG: f.NW_ENG
      }));
  }

  // 11. General catch-all for group queries
  if (q.includes('NW_ENG = @group')) {
    let group = inputs.group || '';
    return mockFaults
      .filter(f => f.FAULT_STATUS === 'OPEN' && f.NW_ENG.toLowerCase() === group.toLowerCase())
      .map(f => ({
        NODE: f.NODE,
        ALARM_TYPE: f.ALARM_TYPE,
        DURATION_HOURS: getDurationHours(f.FAULT_TIME),
        PROVINCE: f.PROVINCE
      }));
  }

  // 12. MANUAL_ESCALATIONS queries
  if (q.includes('MANUAL_ESCALATIONS')) {
    return [];
  }

  // Default fallback
  return [];
}

// Request class wrapper
class MockRequest {
  constructor(pool) {
    this.pool = pool;
    this.inputs = {};
  }

  input(name, type, value) {
    this.inputs[name] = value;
    return this;
  }

  async query(queryStr) {
    let finalQuery = queryStr;
    // Handle tagged template literal inputs
    if (Array.isArray(queryStr)) {
      finalQuery = queryStr.join('?');
    }

    if (useMock) {
      const recordset = processMockQuery(finalQuery, this.inputs);
      return { recordset };
    }

    try {
      return await this.pool.realRequest.query(queryStr);
    } catch (err) {
      console.warn(`[Real DB Query Failed, falling back to mock]: ${err.message}`);
      useMock = true;
      const recordset = processMockQuery(finalQuery, this.inputs);
      return { recordset };
    }
  }
}

// Pool wrapper
class PoolWrapper {
  constructor(realPool) {
    this.realPool = realPool;
  }

  request() {
    const req = new MockRequest(this);
    if (!useMock && this.realPool) {
      req.realRequest = this.realPool.request();
    }
    return req;
  }

  async query(queryStr, ...args) {
    if (useMock) {
      return processMockQuery(queryStr);
    }
    try {
      return await this.realPool.query(queryStr, ...args);
    } catch (err) {
      console.warn(`[Real DB Query Failed, falling back to mock]: ${err.message}`);
      useMock = true;
      return { recordset: processMockQuery(queryStr) };
    }
  }
}

// Wrapper main exports
const dbWrapper = {
  ...mssql,

  async connect(config) {
    if (isConnected && activePool) {
      return activePool;
    }

    try {
      console.log('🔌 Connecting to MS SQL Server database...');

      // Fetch SQL Server credentials from Azure Key Vault or environment variables
      const sqlCredentials = config || (await getSqlCredentials());

      // Connect using the fetched credentials
      const realPool = await mssql.connect(sqlCredentials);
      isConnected = true;
      useMock = false;
      activePool = new PoolWrapper(realPool);
      console.log('✅ MS SQL Server connected successfully!');
      return activePool;
    } catch (err) {
      console.warn(`⚠️ MS SQL Server connection failed: ${err.message}`);
      console.warn('⚡ Initializing SLTNOC transparent Mock Database fallback.');
      isConnected = true;
      useMock = true;
      activePool = new PoolWrapper(null);
      return activePool;
    }
  },

  async close() {
    if (!useMock) {
      try {
        await mssql.close();
      } catch (_) {}
    }
    isConnected = false;
    activePool = null;
  },

  // Export Request class
  Request: MockRequest,

  // Direct query runner
  async query(queryStr, ...args) {
    if (activePool) {
      return activePool.query(queryStr, ...args);
    }
    if (useMock) {
      return { recordset: processMockQuery(queryStr) };
    }
    try {
      // Fetch SQL Server credentials from Azure Key Vault or environment variables
      const sqlCredentials = await getSqlCredentials();
      return await mssql.query(sqlCredentials, queryStr, ...args);
    } catch (err) {
      console.warn(`[Real DB Query Failed, falling back to mock]: ${err.message}`);
      useMock = true;
      return { recordset: processMockQuery(queryStr) };
    }
  }
};

module.exports = dbWrapper;
