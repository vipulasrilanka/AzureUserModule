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