// API for the selected_metro_region.dart

const express = require('express');
const router = express.Router();
const sql = require('./db');
const dbConfig = require('./dbConfig');

router.get('/data/:region', async (req, res) => {
  try {
    // Connect to MS SQL Server
    const pool = await sql.connect(dbConfig);

    // Extract the region parameter from the request
    const region = req.params.region;

    const request = pool.request();
    request.input('region', sql.VarChar, region);

    // Execute parameterized SQL query with the provided region
    const query = `SELECT DISTINCT(PROVINCE) FROM FAULTS WHERE REGION = @region`;
    const result = await request.query(query);

    // Extract provinces from the result
    const provinces = result.recordset.map(record => record.PROVINCE);

    // Send the provinces as JSON response
    res.setHeader('Content-Type', 'application/json');
    res.send(JSON.stringify(provinces));
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send('Internal Server Error');
  } finally {
    // Close the SQL connection
    await sql.close();
  }
});

module.exports = router;
