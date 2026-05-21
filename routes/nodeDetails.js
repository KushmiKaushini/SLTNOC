const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('./dbConfig'); // Importing the DB config file

router.get('/data/:alarmType/:name/:province/:nodeName', async (req, res) => {
    try {
        // Connect to MS SQL Server
        await sql.connect(dbConfig);

        // Extract parameters from the request
        const { alarmType, name, province, nodeName } = req.params;

        // Execute SQL query with the provided parameters
        const query = `SELECT NODE, NW_ENG, FAULT, NAME, MOBILE FROM FAULTS LEFT JOIN ESCALATIONS_AUTO ON FAULTS.ID = ESCALATIONS_AUTO.FAULT_ID WHERE PROVINCE = '${province}' and FAULT_STATUS = 'OPEN' AND NW_ENG = '${name}' AND ALARM_TYPE = '${alarmType}' AND NODE = '${nodeName}' AND ESCALATIONS_AUTO.MESSAGE LIKE 'Initial%'`;
        const result = await sql.query(query);

        // Send the result as formatted JSON
        const formattedJson = JSON.stringify(result.recordset, null, 2);
        res.setHeader('Content-Type', 'application/json');
        res.send(formattedJson);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    } finally {
        // Close the SQL connection
        await sql.close();
    }
});

module.exports = router;
