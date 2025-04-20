/**
 * Azure Function for user login and token management
 * @module getDevice
 */

const sql = require('mssql');
const config = {
    user: 'um1001admin',
    password: 'SQL&1001',
    server: 'sv-user-manager.database.windows.net',
    database: 'db-userManager',
    options: { encrypt: true, trustServerCertificate: false }
};

/**
 * Manages SQL connection pool for Azure Function
 * @returns {Promise<sql.ConnectionPool>} A promise that resolves to the SQL connection pool
 */
let poolPromise;
function getPool() {
    if (!poolPromise) {
        poolPromise = sql.connect(config);
    }
    return poolPromise;
}

/**
 * Retrieves the UserID for a given username
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {string} username - The username to look up
 * @returns {Promise<number>} The UserID
 * @throws {Error} If user is not found
 */
async function getUserID(pool, username) {
    const result = await pool.request()
        .input('UserName', sql.VarChar, username)
        .query(`
            SELECT UserID FROM PasswordHash WHERE UserName = @UserName
        `);

    if (result.recordset.length === 0) {
        throw new Error('User not found');
    }

    return result.recordset[0].UserID;
}

/**
 * Retrieves all devices owned by a specific user
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {number} userId - The ID of the user
 * @returns {Promise<Array>} Array of device objects containing DeviceID, DeviceName, DeviceTypeID, and OwnerID
 */
async function getUserDevices(pool, userId) {
    const result = await pool.request()
        .input('OwnerID', sql.Int, userId)
        .query(`
            SELECT DeviceID, DeviceName, DeviceTypeID, OwnerID
            FROM Devices
            WHERE OwnerID = @OwnerID
            ORDER BY DeviceName
        `);
    return result.recordset;
}

/**
 * Retrieves controls for a list of devices
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {Array<number>} deviceIds - Array of device IDs
 * @returns {Promise<Array>} Array of control objects containing ControlID, ControlName, ControlTypeID, and DeviceID
 */
async function getDeviceControls(pool, deviceIds) {
    const request = pool.request();

    // Add each deviceId as a separate input parameter
    deviceIds.forEach((id, index) => {
        request.input(`deviceId${index}`, sql.Int, id);
    });

    // Build dynamic IN clause
    const inClause = deviceIds.map((_, index) => `@deviceId${index}`).join(',');

    const query = `
        SELECT ControlID, ControlName, ControlTypeID, DeviceID
        FROM Controls
        WHERE DeviceID IN (${inClause})
        ORDER BY DeviceID, ControlName
    `;

    const result = await request.query(query);
    return result.recordset;
}

/**
 * Retrieves current states for all controls of a user's devices
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {number} userId - The ID of the user
 * @returns {Promise<Array>} Array of state objects containing ControlID and EventValue
 */
async function getCurrentStates(pool, userId) {
    const result = await pool.request()
        .input('OwnerID', sql.Int, userId)
        .query(`
            SELECT lvc.ControlID, lvc.EventValue
            FROM LatestValueChanges lvc
            JOIN Controls c ON lvc.ControlID = c.ControlID
            JOIN Devices d ON c.DeviceID = d.DeviceID
            WHERE d.OwnerID = @OwnerID
        `);
    return result.recordset;
}

/**
 * Retrieves all valid control values (excluding "Not Used" values)
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @returns {Promise<Array>} Array of control value objects containing ControlValueID, ControlValue, ActionText, ValueDescription, and ControlTypeID
 */
async function getValidControlValues(pool) {
    const result = await pool.request().query(`
        SELECT ControlValueID, ControlValue, ActionText, ValueDescription, ControlTypeID
        FROM ControlValues
        WHERE ActionText != 'Not Used' AND ValueDescription != 'Not Used'
        ORDER BY ControlTypeID, ControlValue
    `);
    return result.recordset;
}

/**
 * Retrieves the most recent valid token for a user
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {number} userID - The ID of the user
 * @param {number} tokenEventValueID - The EventValueID for valid tokens
 * @returns {Promise<Object|null>} The token event or null if none found
 */
async function getExistingValidToken(pool, userID, tokenEventValueID) {
    const result = await pool.request()
        .input('UserID', sql.Int, userID)
        .input('EventValueID', sql.Int, tokenEventValueID)
        .query(`
            SELECT TOP 1 EventID, EventValueID, EventData, EventDateTime 
            FROM Events 
            WHERE CreatedUserID = @UserID AND EventValueID = @EventValueID
            ORDER BY EventID DESC
        `);

    return result.recordset[0] || null;
}

/**
 * Retrieves the EventValueID for a specific event type and value
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {string} eventTypeName - The name of the event type
 * @param {string} eventValue - The specific event value
 * @returns {Promise<number>} The EventValueID
 * @throws {Error} If event type or value is not found
 */
async function getEventValueID(pool, eventTypeName, eventValue) {
    const result = await pool.request()
        .input('EventTypeName', sql.VarChar, eventTypeName)
        .input('EventValue', sql.VarChar, eventValue)
        .query(`
            SELECT ev.EventValueID 
            FROM EventValues ev
            JOIN EventTypes et ON ev.EventTypeID = et.EventTypeID
            WHERE et.EventTypeName = @EventTypeName AND ev.EventValue = @EventValue
        `);

    if (result.recordset.length === 0) {
        throw new Error(`${eventTypeName} event type or value not found`);
    }

    return result.recordset[0].EventValueID;
}

/**
 * Azure Function HTTP handler for retrieving user devices and their states
 * @param {Object} context - Azure Function context object
 * @param {Object} req - HTTP request object containing userName and sessionToken
 * @returns {Promise<void>}
 */
module.exports = async function (context, req) {
    const { userName, sessionToken } = req.body;

    if (!userName) {
        context.res = { status: 400, body: { message: 'User ID is required' } };
        return;
    }

    context.log('[1] Processing getDevices request for user', userName, 'user Token', sessionToken);

    try {
        const pool = await getPool();
        const userId = await getUserID(pool, userName);

        const tokenEventValueID = await getEventValueID(pool, 'CREATE_TOKEN', 'ISSUED');
        var token = await getExistingValidToken(pool, userId, tokenEventValueID);

        if(token.length == 0) {
            context.res = { status: 400, body: { message: 'No valid session for user' } };
            return;
        }

        token = token.EventData;
        context.log('[2] Token for user ', userId, '=',token);

        if(token != sessionToken) {
            context.res = { status: 400, body: { message: 'No active session for this user. Please login again' } };
            return;
        }

        const devices = await getUserDevices(pool, userId);
        if (devices.length === 0) {
            context.res = { body: { devices: [], states: [] } };
            return;
        }

        const deviceIds = devices.map(d => d.DeviceID);
        const controls = await getDeviceControls(pool, deviceIds);
        const currentStates = await getCurrentStates(pool, userId);
        const controlValues = await getValidControlValues(pool);

        const processedDevices = devices.flatMap(device => {
            const deviceControls = controls.filter(c => c.DeviceID === device.DeviceID);
            return deviceControls.map(control => {
                const currentState = currentStates.find(s => s.ControlID === control.ControlID);
                const validValues = controlValues.filter(
                    v => v.ControlTypeID === control.ControlTypeID
                );

                return {
                    deviceId: device.DeviceID,
                    deviceName: device.DeviceName,
                    controlName: control.ControlName,
                    controlType: control.ControlTypeID,
                    deviceState: currentState ? currentState.EventValue : 'UNKNOWN',
                    stateOptions: validValues.map(v => ({
                        ControlValueID: v.ControlValueID,
                        ActionText: v.ActionText,
                        ValueDescription: v.ValueDescription
                    }))
                };
            });
        });

        context.res = {
            body: {
                devices: processedDevices,
                states: controlValues
            }
        };
    } catch (error) {
        context.log.error('Error processing getDevices:', error.message);
        context.res = {
            status: 500,
            body: { message: 'Internal server error', detail: error.message }
        };
    }
};
