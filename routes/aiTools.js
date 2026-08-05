const sql = require('./db');
const dbConfig = require('./dbConfig');
const fs = require('fs/promises');
const path = require('path');

const manualEscalationsFile = path.join(__dirname, '..', 'data', 'manual_escalations.json');

// Short in-memory cache (15 seconds TTL) to eliminate DB overhead on back-to-back chat queries
const cache = {
  summary: { data: null, timestamp: 0 },
  escalations: { data: null, timestamp: 0 },
  recurring: { data: null, timestamp: 0 }
};
const CACHE_TTL_MS = 15000;

async function getAlarmsSummary() {
  const now = Date.now();
  if (cache.summary.data && (now - cache.summary.timestamp < CACHE_TTL_MS)) {
    return cache.summary.data;
  }

  try {
    const pool = await sql.connect(dbConfig);
    
    // Query 1: Open alarms by Province
    const provinceQuery = `
      SELECT PROVINCE, COUNT(*) as OpenAlarms 
      FROM FAULTS 
      WHERE FAULT_STATUS = 'OPEN' AND PROVINCE IS NOT NULL AND PROVINCE != ''
      GROUP BY PROVINCE 
      ORDER BY OpenAlarms DESC
    `;
    const provinceResult = await pool.request().query(provinceQuery);

    // Query 2: Open alarms by Group (NW_ENG)
    const groupQuery = `
      SELECT NW_ENG, COUNT(*) as OpenAlarms 
      FROM FAULTS 
      WHERE FAULT_STATUS = 'OPEN' AND NW_ENG != 'Default' AND NW_ENG IS NOT NULL AND NW_ENG != ''
      GROUP BY NW_ENG 
      ORDER BY OpenAlarms DESC
    `;
    const groupResult = await pool.request().query(groupQuery);

    const data = {
      provinces: provinceResult.recordset,
      groups: groupResult.recordset
    };
    cache.summary = { data, timestamp: now };
    return data;
  } catch (error) {
    console.error('Error getting alarms summary:', error);
    return null;
  }
}

async function getAlarmsByProvince(province) {
  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();
    request.input('province', sql.VarChar, province);
    const query = `
      SELECT NODE, ALARM_TYPE, DATEDIFF(hour, FAULT_TIME, GETDATE()) AS DURATION_HOURS, NW_ENG 
      FROM FAULTS 
      WHERE PROVINCE = @province AND FAULT_STATUS = 'OPEN'
      ORDER BY DURATION_HOURS DESC
    `;
    const result = await request.query(query);
    return result.recordset;
  } catch (error) {
    console.error(`Error getting alarms for province ${province}:`, error);
    return null;
  }
}

async function getAlarmsByGroup(group) {
  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();
    request.input('group', sql.VarChar, group);
    const query = `
      SELECT NODE, ALARM_TYPE, DATEDIFF(hour, FAULT_TIME, GETDATE()) AS DURATION_HOURS, PROVINCE 
      FROM FAULTS 
      WHERE NW_ENG = @group AND FAULT_STATUS = 'OPEN'
      ORDER BY DURATION_HOURS DESC
    `;
    const result = await request.query(query);
    return result.recordset;
  } catch (error) {
    console.error(`Error getting alarms for group ${group}:`, error);
    return null;
  }
}

async function getNodeDetails(node) {
  try {
    const pool = await sql.connect(dbConfig);
    const request = pool.request();
    request.input('node', sql.VarChar, node);
    const query = `
      SELECT TOP 10 ALARM_TYPE, FAULT_STATUS, FAULT_TIME, DATEDIFF(hour, FAULT_TIME, GETDATE()) AS DURATION_HOURS, PROVINCE, NW_ENG 
      FROM FAULTS 
      WHERE NODE = @node
      ORDER BY FAULT_TIME DESC
    `;
    const result = await request.query(query);
    return result.recordset;
  } catch (error) {
    console.error(`Error getting details for node ${node}:`, error);
    return null;
  }
}

async function getManualEscalations() {
  const now = Date.now();
  if (cache.escalations.data && (now - cache.escalations.timestamp < CACHE_TTL_MS)) {
    return cache.escalations.data;
  }

  try {
    const content = await fs.readFile(manualEscalationsFile, 'utf8');
    const items = JSON.parse(content);
    const filtered = items.filter((item) => item.status !== 'CLOSED');
    cache.escalations = { data: filtered, timestamp: now };
    return filtered;
  } catch (error) {
    if (error.code === 'ENOENT') {
      return [];
    }
    console.error('Error reading manual escalations for AI:', error);
    return null;
  }
}

// Predictive Analytics: Get nodes with recurring or high-duration open faults
async function getRecurringFaultNodes() {
  const now = Date.now();
  if (cache.recurring.data && (now - cache.recurring.timestamp < CACHE_TTL_MS)) {
    return cache.recurring.data;
  }

  try {
    const pool = await sql.connect(dbConfig);
    const query = `
      SELECT NODE, PROVINCE, NW_ENG, COUNT(*) as FaultCount, MAX(DATEDIFF(hour, FAULT_TIME, GETDATE())) AS MaxDurationHours 
      FROM FAULTS 
      WHERE FAULT_STATUS = 'OPEN'
      GROUP BY NODE, PROVINCE, NW_ENG
      HAVING COUNT(*) > 1 OR MAX(DATEDIFF(hour, FAULT_TIME, GETDATE())) > 12
      ORDER BY MaxDurationHours DESC, FaultCount DESC
    `;
    const result = await pool.request().query(query);
    const data = result.recordset || [];
    cache.recurring = { data, timestamp: now };
    return data;
  } catch (error) {
    console.error('Error fetching recurring fault nodes:', error);
    return [];
  }
}

// Proactive Outage Alerts Check for critical alerts endpoint
async function getCriticalAlarmsAlert() {
  try {
    const summary = await getAlarmsSummary();
    const escalations = await getManualEscalations();
    const totalOpen = summary?.provinces?.reduce((acc, p) => acc + (p.OpenAlarms || 0), 0) || 0;
    const highPriorityEscalations = escalations ? escalations.length : 0;
    
    const isCritical = totalOpen >= 5 || highPriorityEscalations > 0;
    return {
      hasCriticalAlert: isCritical,
      totalOpenAlarms: totalOpen,
      activeEscalations: highPriorityEscalations,
      topProvince: summary?.provinces?.[0]?.PROVINCE || 'N/A',
      topProvinceCount: summary?.provinces?.[0]?.OpenAlarms || 0,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Error checking critical alerts:', error);
    return { hasCriticalAlert: false };
  }
}

module.exports = {
  getAlarmsSummary,
  getAlarmsByProvince,
  getAlarmsByGroup,
  getNodeDetails,
  getManualEscalations,
  getRecurringFaultNodes,
  getCriticalAlarmsAlert
};
