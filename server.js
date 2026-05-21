// Main file to call APIs when needed

const express = require('express');
const cors = require('cors');
const alarmsRoutes1 = require('./routes/alarms1');
const alarmsRoutes2 = require('./routes/alarms2');
const regionsRoutes1 = require('./routes/provinces');
const alarmsDetails1 = require('./routes/alarmsDetails1');
const nodeDetails = require('./routes/nodeDetails');

const app = express();

// CORS middleware
app.use(cors());

// Use routes
app.use('/api/alarms1', alarmsRoutes1);
app.use('/api/alarms2', alarmsRoutes2);
app.use('/api/provinces', regionsRoutes1);
app.use('/api/alarm-details', alarmsDetails1);
app.use('/api/node-details', nodeDetails);
// Additional routes can be added similarly

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
