// Database Configuration file

module.exports = {
    user: 'sa', // MS SQL Server username
    password: 'Madhuka@SLT1397', // MS SQL Server password
    server: 'localhost\\SQLEXPRESS', // MS SQL Server address
    database: 'TMS', // MS SQL Server Database
    options: {
        trustedconnection: true,
        enableArithAbort: true,
        trustServerCertificate: true,
        instancename: 'SQLEXPRESS', // SQL Server instance name
        port: 1433, // MS SQL Server Port
    },
};
