// API for the selected_metro_region.dart

const express = require('express');
const router = express.Router();
const sql = require('mssql');
const dbConfig = require('./dbConfig'); // Importing the DB config file

router.get('/data/:name/:province', async (req, res) => {
  try {
    // Connect to MS SQL Server
    await sql.connect(dbConfig);

    // Extract the name and province parameters from the request
    const name = req.params.name;
    const province = req.params.province;

    // Execute SQL query with the provided name and province
    const result = await sql.query`SELECT ALARM_TYPE, COUNT(*) as OpenAlarms 
                                    FROM FAULTS 
                                    WHERE FAULT_STATUS = 'OPEN' 
                                    AND NW_ENG = ${name} 
                                    AND PROVINCE = ${province}  -- Filter by province
                                    GROUP BY ALARM_TYPE`;

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
