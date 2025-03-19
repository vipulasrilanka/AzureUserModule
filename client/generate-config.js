const fs = require('fs');
const path = require('path');

// Get version from package.json
const packageJson = require('../package.json');
const version = packageJson.version;

// Get deployment time
const deployTime = new Date().toISOString();

// Create config object with environment variables
const config = {
    AZURE_FUNCTION_URL: process.env.AZURE_FUNCTION_URL || 'http://localhost:7071/api/userLogin',
    AZURE_FUNCTION_KEY: process.env.AZURE_FUNCTION_KEY || 'local-development-key',
    GET_DEVICE_URL: process.env.GET_DEVICE_URL || 'http://localhost:7071/api/getDevice',
    GET_DEVICE_KEY: process.env.GET_DEVICE_KEY || 'local-development-key',
    SET_DEVICE_URL: process.env.SET_DEVICE_URL || 'http://localhost:7071/api/setDevice',
    SET_DEVICE_KEY: process.env.SET_DEVICE_KEY || 'local-development-key'
};

// Create version info
const versionInfo = `
window.APP_VERSION = '${version}';
window.DEPLOY_TIME = '${deployTime}';
`;

// Create config file content
const configContent = `
window.APP_CONFIG = ${JSON.stringify(config, null, 2)};
`;

// Write files
fs.writeFileSync(path.join(__dirname, 'version.js'), versionInfo);
fs.writeFileSync(path.join(__dirname, 'config.js'), configContent);

console.log('Configuration files generated successfully'); 