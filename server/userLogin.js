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

// Reuse the connection pool between Azure Function invocations
let poolPromise;
function getPool() {
    if (!poolPromise) {
        poolPromise = sql.connect(config);
    }
    return poolPromise;
}

// Placeholder for token generation
async function getNewToken(userName, context) {
    let returnValue = {
        status: true,
        token: "dummy-token" // Replace with real JWT later
    };
    context.log('[700]', returnValue);
    return returnValue;
}

// Fetch password hash for a given user
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

// Azure Function HTTP handler
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
            const newToken = await getNewTokenEx(username, context);
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

// Helper: Get UserID for a given username
async function getUserID(pool, username) {
    const result = await pool.request()
        .input('UserName', sql.VarChar, username)
        .query(`SELECT UserID FROM Users WHERE UserName = @UserName`);

    if (result.recordset.length === 0) {
        throw new Error(`User ${username} not found`);
    }

    return result.recordset[0].UserID;
}

// Helper: Get EventValueID for a given type and value
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

// Helper: Get latest token for a user
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

// Helper: Invalidate old token
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

// Helper: Create a new token
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

// Entry: getNewTokenEx for Azure Function use
async function getNewTokenEx(userName, context) {
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

