// Simulated user database - This can be replaced with actual database calls later
function validateCredentials(username, passwordHash) {
    // Hardcoded valid credentials for testing
    const validUsers = [
        { username: "admin", passwordHash: "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" }, // This is the hash for "password"
        { username: "user1", passwordHash: "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b" }  // This is the hash for "1"
    ];

    return validUsers.some(user => 
        user.username === username && user.passwordHash === passwordHash
    );
}

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    // Return 404 for GET requests
    if (req.method === "GET") {
        context.res = {
            status: 404,
            body: "Forbidden"
        };
        return;
    }

    // Handle POST requests
    if (req.method === "POST") {
        const username = req.body && req.body.username;
        const passwordHash = req.body && req.body.passwordHash;

        if (!username || !passwordHash) {
            context.res = {
                status: 400,
                body: "Please provide both username and passwordHash in the request body"
            };
            return;
        }

        // Validate credentials
        if (validateCredentials(username, passwordHash)) {
            // Return a fixed token for successful authentication
            // In a production environment, you would generate a proper JWT or other secure token
            context.res = {
                status: 200,
                body: {
                    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ",
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

    // Return 404 for all other HTTP methods
    context.res = {
        status: 404,
        body: "Method not supported"
    };
}