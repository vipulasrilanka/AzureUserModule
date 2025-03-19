// Script to generate configuration file with environment variables
const fs = require('fs');

// Read environment variables or fallback to defaults
const config = {
  AZURE_FUNCTION_URL: process.env.AZURE_FUNCTION_URL || 'http://localhost:7071/api/userLogin',
  AZURE_FUNCTION_KEY: process.env.AZURE_FUNCTION_KEY || 'local-development-key'
};

// Write the configuration to a file
fs.writeFileSync('client/config.js', `
// This file is auto-generated. Do not edit directly.
window.APP_CONFIG = ${JSON.stringify(config, null, 2)};
`);

console.log('Configuration file generated successfully.'); 