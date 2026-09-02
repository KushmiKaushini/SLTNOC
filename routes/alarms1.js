// const express = require('express');
// const router = express.Router();
// const sql = require('mssql');

// // MS SQL Server configuration
// const config = {
//     user: 'sa', // Add your SQL Server username
//     password: 'Madhuka@SLT1397',
//     server: 'localhost\\SQLEXPRESS', // Your MS SQL Server address
//     database: 'TMS',
//     options: {
//       trustedconnection: true,
//       enableArithAbort: true,
//       trustServerCertificate: true,
//       instancename:  'SQLEXPRESS',  // SQL Server instance name
//       port: 1433,
//     },
//   };

// router.get('/data', async (req, res) => {
//   try {
//     // Connect to MS SQL Server
//     await sql.connect(config);

//     // Execute SQL query
//     const result = await sql.query('SELECT NW_ENG, COUNT(*) as OpenAlarms FROM FAULTS WHERE FAULT_STATUS = \'OPEN\' AND NW_ENG != \'Default\' GROUP BY NW_ENG');

//     // Send the result as formatted JSON
//     const formattedJson = JSON.stringify(result.recordset, null, 2);
//     res.setHeader('Content-Type', 'application/json');
//     res.send(formattedJson);
//   } catch (error) {
//     console.error('Error:', error);
//     res.status(500).send('Internal Server Error');
//   } finally {
//     // Close the SQL connection
//     await sql.close();
//   }
// });

// module.exports = router;

// API for the selected_metro_region.dart

const express = require('express');
const router = express.Router();
const sql = require('./db');
const dbConfig = require('./dbConfig'); // Importing the DB config file

router.get('/data/:province', async (req, res) => {
  try {
      // Connect to MS SQL Server
      await sql.connect();

      // Extract the province parameter from the request
      const province = req.params.province;

      // Execute SQL query with the provided province
      const query = `SELECT NW_ENG, COUNT(*) as OpenAlarms FROM FAULTS WHERE PROVINCE = '${province}' AND FAULT_STATUS = 'OPEN' AND NW_ENG != 'Default' GROUP BY NW_ENG`;
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
