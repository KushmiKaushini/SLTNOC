// Mock Database Data for SLTNOC project
// Provides offline capability when MS SQL server is not available on macOS.

const mockFaults = [
  // Western Province (Metro Region)
  {
    NODE: 'Colombo_MSAN_01',
    PROVINCE: 'Western',
    REGION: 'Metro',
    NW_ENG: 'WES-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 5).toISOString(), // 5 hours ago
    ALARM_TYPE: 'Power Failure',
    FAULT: 'AC Mains Failure at Colombo_MSAN_01'
  },
  {
    NODE: 'Colombo_MSAN_02',
    PROVINCE: 'Western',
    REGION: 'Metro',
    NW_ENG: 'WES-CSC-DATA',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 2).toISOString(), // 2 hours ago
    ALARM_TYPE: 'High Temperature',
    FAULT: 'High Temperature Alarm at Colombo_MSAN_02'
  },
  {
    NODE: 'Colombo_OLT_01',
    PROVINCE: 'Western',
    REGION: 'Metro',
    NW_ENG: 'WES-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 12).toISOString(),
    ALARM_TYPE: 'Link Down',
    FAULT: 'Uplink Interface Down'
  },
  {
    NODE: 'Colombo_ENODEB_03',
    PROVINCE: 'Western',
    REGION: 'Metro',
    NW_ENG: 'WES-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 8).toISOString(),
    ALARM_TYPE: 'Fiber Cut',
    FAULT: 'Optical Path Loss Alert'
  },
  {
    NODE: 'Colombo_CEA_01',
    PROVINCE: 'Western',
    REGION: 'Metro',
    NW_ENG: 'WES-CSC-CC',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 24).toISOString(),
    ALARM_TYPE: 'Card Failure',
    FAULT: 'Line Card 3 Communication Failure'
  },

  // Central Province (Region 2)
  {
    NODE: 'Kandy_MSAN_01',
    PROVINCE: 'Central',
    REGION: 'Region 2',
    NW_ENG: 'CEN-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 4).toISOString(),
    ALARM_TYPE: 'Power Failure',
    FAULT: 'DC low voltage warning'
  },
  {
    NODE: 'Kandy_ENODEB_02',
    PROVINCE: 'Central',
    REGION: 'Region 2',
    NW_ENG: 'CEN-CSC-DATA',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 1).toISOString(),
    ALARM_TYPE: 'Link Down',
    FAULT: 'S1 Connection Lost'
  },
  {
    NODE: 'Kandy_BTS_03',
    PROVINCE: 'Central',
    REGION: 'Region 2',
    NW_ENG: 'CEN-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 18).toISOString(),
    ALARM_TYPE: 'Fan Failure',
    FAULT: 'Cabinet fan 1 speed abnormal'
  },
  {
    NODE: 'Kandy_OLT_02',
    PROVINCE: 'Central',
    REGION: 'Region 2',
    NW_ENG: 'CEN-CSC-MS',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 3).toISOString(),
    ALARM_TYPE: 'Power Failure',
    FAULT: 'Power Rectifier module error'
  },

  // Southern Province (Region 1)
  {
    NODE: 'Galle_ENODEB_01',
    PROVINCE: 'Southern',
    REGION: 'Region 1',
    NW_ENG: 'SOU-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 9).toISOString(),
    ALARM_TYPE: 'Link Down',
    FAULT: 'Transmission link failure'
  },
  {
    NODE: 'Galle_MSAN_03',
    PROVINCE: 'Southern',
    REGION: 'Region 1',
    NW_ENG: 'SOU-CSC-DATA',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 15).toISOString(),
    ALARM_TYPE: 'High Temperature',
    FAULT: 'Main shelf temperature high'
  },
  {
    NODE: 'Matara_BTS_01',
    PROVINCE: 'Southern',
    REGION: 'Region 1',
    NW_ENG: 'SOU-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 7).toISOString(),
    ALARM_TYPE: 'Power Failure',
    FAULT: 'AC Mains Failure at Matara_BTS_01'
  },

  // Northern Province (Region 3)
  {
    NODE: 'Jaffna_NODEB_01',
    PROVINCE: 'Northern',
    REGION: 'Region 3',
    NW_ENG: 'NOR-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 30).toISOString(),
    ALARM_TYPE: 'Link Down',
    FAULT: 'Microwave link fade'
  },
  {
    NODE: 'Jaffna_MSAN_02',
    PROVINCE: 'Northern',
    REGION: 'Region 3',
    NW_ENG: 'NOR-CSC-DATA',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 3).toISOString(),
    ALARM_TYPE: 'Power Failure',
    FAULT: 'Battery discharging'
  },

  // Sabaragamuwa Province (Region 1)
  {
    NODE: 'Ratnapura_OLT_01',
    PROVINCE: 'Sabaragamuwa',
    REGION: 'Region 1',
    NW_ENG: 'SOU-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 2).toISOString(),
    ALARM_TYPE: 'Fiber Cut',
    FAULT: 'Fiber Break detected between Ratnapura and Eheliyagoda'
  },

  // North Western Province (Region 3)
  {
    NODE: 'Kurunegala_MSAN_01',
    PROVINCE: 'North Western',
    REGION: 'Region 3',
    NW_ENG: 'NOR-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 6).toISOString(),
    ALARM_TYPE: 'Power Failure',
    FAULT: 'AC Mains Failure'
  },

  // Eastern Province (Region 2)
  {
    NODE: 'Trinco_BTS_01',
    PROVINCE: 'Eastern',
    REGION: 'Region 2',
    NW_ENG: 'CEN-CSC-NW',
    FAULT_STATUS: 'OPEN',
    FAULT_TIME: new Date(Date.now() - 3600000 * 14).toISOString(),
    ALARM_TYPE: 'High Temperature',
    FAULT: 'Cabinet overtemp alarm'
  }
];

// Mock contacts for auto escalations
const mockEscalationsAuto = [
  { FAULT_ID: 1, NAME: 'Kamal Perera', MOBILE: '0712345678', MESSAGE: 'Initial escalation' },
  { FAULT_ID: 2, NAME: 'Nimal Silva', MOBILE: '0778765432', MESSAGE: 'Initial escalation' }
];

module.exports = { mockFaults, mockEscalationsAuto };
