// API for the selected_metro_region.dart

const express = require('express');
const router = express.Router();
const sql = require('./db');
const dbConfig = require('./dbConfig');

router.get('/data/:province', async (req, res) => {
  try {
    // Connect to MS SQL Server
    const pool = await sql.connect(dbConfig);

    // Extract the province parameter from the request
    const province = req.params.province;

    const request = pool.request();
    request.input('province', sql.VarChar, province);

    // Execute parameterized SQL query with the provided province
    const query = `SELECT NW_ENG, COUNT(*) as OpenAlarms FROM FAULTS WHERE PROVINCE = @province AND FAULT_STATUS = 'OPEN' AND NW_ENG != 'Default' GROUP BY NW_ENG`;
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
