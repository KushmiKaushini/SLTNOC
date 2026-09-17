// API for the selected_metro_region.dart

const express = require('express');
const router = express.Router();
const sql = require('./db');
const dbConfig = require('./dbConfig');

router.get('/data/:alarmType/:name/:province', async (req, res) => {
    try {
        // Connect to MS SQL Server
        const pool = await sql.connect(dbConfig);

        // Extract parameters from the request
        const { alarmType, name, province } = req.params;

        const request = pool.request();
        request.input('alarmType', sql.VarChar, alarmType);
        request.input('name', sql.VarChar, name);
        request.input('province', sql.VarChar, province);

        // Execute parameterized SQL query with the provided parameters
        const query = `SELECT NODE, DATEDIFF(hour, FAULT_TIME, GETDATE()) AS DURATION FROM FAULTS WHERE ALARM_TYPE = @alarmType AND NW_ENG = @name AND PROVINCE = @province`;
        const result = await request.query(query);

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
