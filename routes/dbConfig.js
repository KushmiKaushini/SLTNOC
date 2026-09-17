// Database Configuration file

module.exports = {
    user: process.env.DB_USER || 'sa', // MS SQL Server username
    password: process.env.DB_PASSWORD || '', // MS SQL Server password from environment
    server: process.env.DB_SERVER || 'localhost\\SQLEXPRESS', // MS SQL Server address
    database: process.env.DB_DATABASE || 'TMS', // MS SQL Server Database
    options: {
        trustedconnection: true,
        enableArithAbort: true,
        trustServerCertificate: true,
        instancename: process.env.DB_INSTANCE || 'SQLEXPRESS', // SQL Server instance name
        port: Number(process.env.DB_PORT || 1433), // MS SQL Server Port
    },
};
