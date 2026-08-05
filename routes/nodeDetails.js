const express = require('express');
const router = express.Router();
const sql = require('./db');
const dbConfig = require('./dbConfig'); // Importing the DB config file

function nodeTypeCase(column = 'NODE') {
    return `
    CASE
        WHEN UPPER(${column}) LIKE '%ENODEB%' THEN 'eNodeB'
        WHEN UPPER(${column}) LIKE '%NODEB%' THEN 'NodeB'
        WHEN UPPER(${column}) LIKE '%MSAN%' THEN 'MSAN'
        WHEN UPPER(${column}) LIKE '%OLT%' THEN 'OLT'
        WHEN UPPER(${column}) LIKE '%RNC%' THEN 'RNC'
        WHEN UPPER(${column}) LIKE '%BTS%' THEN 'BTS'
        WHEN UPPER(${column}) LIKE '%CEA%' THEN 'CEA'
        ELSE 'OTHER'
    END
`;
}

function addScopeFilters(request, filters, name, province, tablePrefix = '') {
    if (name !== '%') {
        request.input('name', sql.VarChar, name);
        filters.push(`${tablePrefix}NW_ENG = @name`);
    }
    if (province !== '%') {
        request.input('province', sql.VarChar, province);
        filters.push(`${tablePrefix}PROVINCE = @province`);
    }
}

// Get node types for a specific alarm type
router.get('/types/:alarmType/:name/:province', async (req, res) => {
    try {
        // Connect to MS SQL Server
        const pool = await sql.connect(dbConfig);

        // Extract parameters from the request
        let { alarmType, name, province } = req.params;
        
        // Handle "...ALL..." and "...All..." parameters
        if (name === '...ALL...') {
            name = '%'; // Match all NW_ENG values
        }
        if (province === '...All...') {
            province = '%'; // Match all provinces
        }

        const request = pool.request();
        request.input('alarmType', sql.VarChar, alarmType);

        const filters = [
            "FAULT_STATUS = 'OPEN'",
            'ALARM_TYPE = @alarmType',
        ];
        addScopeFilters(request, filters, name, province);

        const query = `
            SELECT NODE_TYPE AS NODE, COUNT(*) AS OpenAlarms
            FROM (
                SELECT ${nodeTypeCase()} AS NODE_TYPE
                FROM FAULTS
                WHERE ${filters.join(' AND ')}
            ) node_types
            GROUP BY NODE_TYPE
            ORDER BY
                CASE NODE_TYPE
                    WHEN 'MSAN' THEN 1
                    WHEN 'OLT' THEN 2
                    WHEN 'RNC' THEN 3
                    WHEN 'BTS' THEN 4
                    WHEN 'NodeB' THEN 5
                    WHEN 'eNodeB' THEN 6
                    WHEN 'CEA' THEN 7
                    ELSE 99
                END,
                NODE_TYPE
        `;

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

// Get detailed alarm information for a specific node type
router.get('/data/:alarmType/:name/:province/:nodeType', async (req, res) => {
    try {
        // Connect to MS SQL Server
        const pool = await sql.connect(dbConfig);

        // Extract parameters from the request
        let { alarmType, name, province, nodeType } = req.params;
        
        // Handle "...ALL..." and "...All..." parameters
        if (name === '...ALL...') {
            name = '%'; // Match all NW_ENG values
        }
        if (province === '...All...') {
            province = '%'; // Match all provinces
        }

        const request = pool.request();
        request.input('alarmType', sql.VarChar, alarmType);
        request.input('nodeType', sql.VarChar, nodeType);

        const filters = [
            "FAULTS.FAULT_STATUS = 'OPEN'",
            'FAULTS.ALARM_TYPE = @alarmType',
            `${nodeTypeCase('FAULTS.NODE')} = @nodeType`,
        ];
        addScopeFilters(request, filters, name, province, 'FAULTS.');

        const query = `
            SELECT
                FAULTS.NODE,
                FAULTS.NW_ENG,
                FAULTS.PROVINCE,
                FAULTS.FAULT,
                ESCALATIONS_AUTO.NAME,
                ESCALATIONS_AUTO.MOBILE
            FROM FAULTS
            LEFT JOIN ESCALATIONS_AUTO
                ON FAULTS.ID = ESCALATIONS_AUTO.FAULT_ID
                AND ESCALATIONS_AUTO.MESSAGE LIKE 'Initial%'
            WHERE ${filters.join(' AND ')}
            ORDER BY FAULTS.NODE
        `;

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
