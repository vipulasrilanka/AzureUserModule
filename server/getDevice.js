const sql = require('mssql');

const config = {
    user: process.env.USER_FUNCTION_DB_USER,
    password: process.env.USER_FUNCTION_DB_PASSWORD,
    server: process.env.USER_FUNCTION_DB_SERVER,
    database: process.env.USER_FUNCTION_DB_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};

const MAX_RETRIES = 3;  // Number of retries
const RETRY_DELAY = 5000;  // Delay between retries in milliseconds (5 seconds)
const TIME_MATCH_THRESHOLD = 2;

// Azure Function endpoint
// Static token from userLogin.js
const VALID_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ";

const timestamp = new Date().toISOString();
var logText = `[${timestamp}][INIT] OK `;

function addLog(logMessage, level = 'INFO') {
    const timestamp = new Date().toISOString();
    logText = logText + `,[${timestamp}][${level}] ${logMessage}`; 
}

function getLog() {
    const currentLog = logText;
    const newTimestamp = new Date().toISOString();
    logText = `[${newTimestamp}][INIT] OK `;
    return currentLog;
}

async function getDevicesFromDB(pool, CreatedUserID, DeviceID) {
    addLog(`Fetching devices for UserID: ${CreatedUserID}, DeviceID: ${DeviceID || 'all'}`);
    
    let query = `
        SELECT 
            DeviceID,
            DeviceName,
            DeviceType,
            DeviceOwner,
            CurrentStatus
        FROM [dbo].[vw_LatestEvents]
        WHERE DeviceOwner = @CreatedUserID
    `;

    if (DeviceID) {
        query += ' AND DeviceID = @DeviceID';
    }

    const request = pool.request()
        .input('CreatedUserID', sql.Int, CreatedUserID);

    if (DeviceID) {
        request.input('DeviceID', sql.Int, DeviceID);
    }

    const result = await request.query(query);
    addLog(`Found ${result.recordset.length} devices`);
    return result.recordset;
}

async function getStatesFromDB(pool, deviceTypes) {
    addLog(`Fetching states for device types: ${deviceTypes.join(', ')}`);

    if (!deviceTypes || deviceTypes.length === 0) {
        addLog('No device types provided, returning empty states array', 'WARN');
        return [];
    }

    // Create a comma-separated list of parameters
    const params = deviceTypes.map((_, index) => `@type${index}`);
    const query = `
        SELECT 
            st.StateTypeID as UniqueID,
            CONCAT(st.DeviceTypeID, '_', st.StateSetTo) as StateID,
            st.FriendlyName as StateName,
            st.StateSetTo,
            dt.TypeName as DeviceType,
            st.FunctionID
        FROM [dbo].[StateTypes] st
        INNER JOIN [dbo].[DeviceTypes] dt ON st.DeviceTypeID = dt.DeviceTypeID
        WHERE dt.TypeName IN (${params.join(',')})
    `;

    const request = pool.request();
    deviceTypes.forEach((type, index) => {
        request.input(`type${index}`, sql.NVarChar, type);
    });

    const result = await request.query(query);
    addLog(`Found ${result.recordset.length} states`);
    return result.recordset;
}

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    context.log('req = ', req);

    // Check for required fields
    if (!req.body || !req.body.CreatedUserID || !req.body.SessionToken) {
        addLog('Missing required fields', 'ERROR');
        context.res = {
            status: 400,
            body: {
                error: "Missing required fields",
                message: "CreatedUserID and SessionToken are required in the request body",
                log: getLog()
            }
        };
        return;
    }

    const { CreatedUserID, SessionToken, DeviceID } = req.body;
    context.log("Print variables =", CreatedUserID, SessionToken, DeviceID);

    // Validate session token
    if (SessionToken !== VALID_TOKEN) {
        addLog('Invalid session token', 'ERROR');
        context.res = {
            status: 401,
            body: {
                error: "Invalid session token",
                message: "The provided session token is invalid or expired",
                log: getLog()
            }
        };
        return;
    }


    try {
        // Create connection pool
        context.log("await sql.connect(config)", config);
        const pool = await sql.connect(config);
        context.log("getDevicesFromDB", pool);

        // Get devices from database
        const userDevices = await getDevicesFromDB(pool, CreatedUserID, DeviceID);
        context.log("Return : getDevicesFromDB", userDevices);

        // If no devices found for the user
        if (userDevices.length === 0) {
            addLog(`No devices found for user ${CreatedUserID}`, 'WARN');
            context.res = {
                status: 404,
                body: {
                    error: "No devices found",
                    message: `No devices found for user ${CreatedUserID}`,
                    log: getLog()
                }
            };
            return;
        }

        // Get unique device types from the filtered devices
        const deviceTypes = [...new Set(userDevices.map(device => device.DeviceType))];

        // Get applicable states from database
        const applicableStates = await getStatesFromDB(pool, deviceTypes);

        // Return the filtered devices and applicable states
        context.res = {
            status: 200,
            body: {
                devices: userDevices,
                count: userDevices.length,
                states: applicableStates
            }
        };

    } catch (err) {
        addLog(`Database error: ${err.message}`, 'ERROR');
        context.log.error('Database error:', err);
        context.res = {
            status: 500,
            body: {
                error: "Database error",
                message: "An error occurred while fetching data from the database",
                log: getLog()
            }
        };
    }
}