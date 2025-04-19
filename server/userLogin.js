/**
 * Azure Function for user login and token management
 * @module userLogin
 */

const sql = require('mssql');

// SQL configuration
const config = {
    user: 'um1001admin',
    password: 'SQL&1001',
    server: 'sv-user-manager.database.windows.net',
    database: 'db-userManager',
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
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
 * Fetches the password hash for a given user from the database
 * @param {string} userName - The username to look up
 * @param {Object} context - Azure Function context object
 * @returns {Promise<Object>} An object containing error (if any) and passwordHash
 */
async function getPasswordHash(userName, context) {
    let returnValue = { error: null, passwordHash: null };
    try {
        const pool = await getPool();
        const result = await pool.request()
            .input('UserName', sql.VarChar, userName)
            .query('SELECT PasswordHash FROM [dbo].[PasswordHash] WHERE UserName = @UserName');

        if (result.recordset.length > 0) {
            returnValue.passwordHash = result.recordset[0].PasswordHash;
        } else {
            const err = new Error(`No records found for user '${userName}'`);
            err.name = "RecordNotFoundError";
            context.log.error(err.message);
            returnValue.error = err;
        }
    } catch (err) {
        context.log.error('Database query error:', err);
        returnValue.error = err;
    }
    return returnValue;
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
        .query(`SELECT UserID FROM Users WHERE UserName = @UserName`);

    if (result.recordset.length === 0) {
        throw new Error(`User ${username} not found`);
    }

    return result.recordset[0].UserID;
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
 * Invalidates an existing token
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {string} username - The username of the token owner
 * @param {number} userID - The ID of the user
 * @param {number} invalidateEventValueID - The EventValueID for token invalidation
 * @param {Object} lastEvent - The event record to invalidate
 * @returns {Promise<void>}
 */
async function invalidateToken(pool, username, userID, invalidateEventValueID, lastEvent) {
    const invalidateDescription = `TOKEN EXP USER=${username} (INVALIDATED)`;
    await pool.request()
        .input('EventValueID', sql.Int, invalidateEventValueID)
        .input('EventDescription', sql.VarChar, invalidateDescription)
        .input('EventData', sql.VarChar, lastEvent.EventData)
        .input('UserID', sql.Int, userID)
        .input('EventDateTime', sql.DateTime, new Date())
        .input('ControlID', sql.Int, null)
        .query(`
            INSERT INTO Events (EventValueID, EventDescription, EventData, CreatedUserID, EventDateTime, ControlID)
            VALUES (@EventValueID, @EventDescription, @EventData, @UserID, @EventDateTime, @ControlID)
        `);
}

/**
 * Creates a new token for a user
 * @param {sql.ConnectionPool} pool - SQL connection pool
 * @param {string} username - The username for whom the token is being created
 * @param {number} userID - The ID of the user
 * @param {number} tokenEventValueID - The EventValueID for token creation
 * @returns {Promise<string>} The new session key
 */
async function createNewToken(pool, username, userID, tokenEventValueID) {
    const sessionKey = `session-${Math.random().toString(36).substr(2)}-${Date.now()}`;
    const currentTime = new Date();
    const expireTime = new Date(currentTime.getTime() + 2 * 60 * 60 * 1000); // 2 hours

    const eventDescription = `TOKEN NEW USER=${username} EXP=${expireTime.toISOString()}`;

    await pool.request()
        .input('EventValueID', sql.Int, tokenEventValueID)
        .input('EventDescription', sql.VarChar, eventDescription)
        .input('EventData', sql.VarChar, sessionKey)
        .input('ControlID', sql.Int, null)
        .input('UserID', sql.Int, userID)
        .input('EventDateTime', sql.DateTime, currentTime)
        .input('EventExpireDateTime', sql.DateTime, expireTime)
        .query(`
            INSERT INTO Events (EventValueID, EventDescription, EventData, ControlID, CreatedUserID, EventDateTime, EventExpireDateTime)
            VALUES (@EventValueID, @EventDescription, @EventData, @ControlID, @UserID, @EventDateTime, @EventExpireDateTime)
        `);

    return sessionKey;
}

/**
 * Generates a new token for a user, invalidating any existing token
 * @param {string} userName - The username for whom the token is being generated
 * @param {Object} context - Azure Function context object
 * @returns {Promise<Object>} An object containing status and token/error information
 */
async function getNewToken(userName, context) {
    const pool = await getPool();  // assumes getPool() returns the connection pool

    try {
        const userID = await getUserID(pool, userName);
        const tokenEventValueID = await getEventValueID(pool, 'CREATE_TOKEN', 'ISSUED');
        const lastEvent = await getExistingValidToken(pool, userID, tokenEventValueID);

        if (lastEvent) {
            const invalidateEventValueID = await getEventValueID(pool, 'CREATE_TOKEN', 'EXPIRED');
            await invalidateToken(pool, userName, userID, invalidateEventValueID, lastEvent);
        }

        const sessionKey = await createNewToken(pool, userName, userID, tokenEventValueID);

        return {
            status: true,
            token: sessionKey
        };
    } catch (err) {
        context.log.error('Error generating token:', err);
        return {
            status: false,
            error: err.message
        };
    }
}

/**
 * Azure Function HTTP handler for user login
 * @param {Object} context - Azure Function context object
 * @param {Object} req - HTTP request object
 * @returns {Promise<void>}
 */
module.exports = async function (context, req) {
    context.log('Azure Function processing request...');

    // Reject GET method
    if (req.method === "GET") {
        context.res = {
            status: 404,
            body: "Forbidden"
        };
        return;
    }

    if (req.method === "POST") {
        const username = req.body?.username;
        const passwordHash = req.body?.passwordHash;

        if (!username || !passwordHash) {
            context.res = {
                status: 400,
                body: "Please provide both username and passwordHash in the request body"
            };
            return;
        }

        // Fetch stored password hash
        let value;
        try {
            value = await getPasswordHash(username, context);
        } catch (err) {
            context.res = {
                status: 500,
                body: "Internal Server Error"
            };
            return;
        }

        if (value.error) {
            context.log('[1] PasswordHash not found. ERROR =', value.error.message);
            context.res = {
                status: 401,
                body: "Invalid User ID"
            };
            return;
        }

        context.log('PasswordHash for user [', username, '] =', value.passwordHash);

        // Compare with submitted hash
        if (value.passwordHash === passwordHash) {
            // Placeholder token logic
            const newToken = await getNewToken(username, context);
            if (!newToken.status) {
                context.res = {
                    status: 500,
                    body: "Cannot get token. Internal Error."
                };
                return;
            }

            context.res = {
                status: 200,
                body: {
                    token: newToken.token,
                    message: "Authentication successful"
                }
            };
        } else {
            context.res = {
                status: 401,
                body: "Invalid credentials"
            };
        }
        return;
    }

    // Fallback for unsupported HTTP methods
    context.res = {
        status: 404,
        body: "Method not supported"
    };
};
