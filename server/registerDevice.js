const sql = require('mssql');

const config = {
    user: process.env.USER_FUNCTION_DB_USER,
    password: process.env.USER_FUNCTION_DB_PASSWORD,
    server: process.env.USER_FUNCTION_DB_SERVER,
    database: process.env.USER_FUNCTION_DEVICE_DB_NAME,
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};

const MAX_RETRIES = 3;  // Number of retries
const RETRY_DELAY = 5000;  // Delay between retries in milliseconds (5 seconds)
const TIME_MATCH_THRESHOLD = 2;


function minutesElapsedFromStartOfYearUTC() {
    // Get the current UTC date and time
    const currentDateUTC = new Date();

    // Create a new Date object for the start of the year in UTC (January 1st)
    const startOfYearUTC = new Date(Date.UTC(currentDateUTC.getUTCFullYear(), 0, 1));

    // Calculate the difference in milliseconds between the current date and start of the year
    const diffTime = currentDateUTC - startOfYearUTC;

    // Convert milliseconds to minutes
    const diffMinutes = Math.floor(diffTime / (1000 * 60)); // 1000 ms * 60 s
    
    return diffMinutes;
}

/** getSessionId(session)
 * convert the session text to session ID 
 */
function getSessionId(sessionText) {
  //check the size of the sesison variable
  if (sessionText.length < 13) {
    return { timeId: undefined, serialId: undefined };
  }
  let result = unshuffle(sessionText.substring(3, 13), sessionText.substring(0, 3));

  let timeId = result.substring(0, 5); // First 5 characters
  let serialId = result.substring(5, 10); // Last 5 characters
  return {timeId, serialId};
}

/** check if the time ID is within the safe zone
 * 
 */
function checkTimeID(timeId, timeElapsed, threshold) {
    return true;
    const timeIdInt = parseInt(timeId, 10);
    return Math.abs(timeElapsed - timeIdInt) <= threshold;
}

/** unshuffle the session ID
 */
function unshuffle(string, seed) {
  let order = parseInt(seed, 16).toString(2).padStart(12, '0'); // Convert mixerID from Hex to Binary (8-bit)
  let sourceArray = string.split("");
  let resultArray = [];
  //unshaffle logic
  for (let i = string.length - 1 ; i >= 0 ; i--) {
    if('1' === order[i]) {
      resultArray.unshift(sourceArray.shift());
    }
    else {
      resultArray.unshift(sourceArray.pop());
    }
  }
  return resultArray.join("");;
}

function sendResponse(context, statusCode, status, code, message, data = null) {
    context.res = {
        status: statusCode,
        headers: {
        "Content-Type": "application/json"
        },
        body: {
            status: status,
            code: code,
            message: message,
            ...(data && { data }) // Include data only if it's not null
        }
    };
}



module.exports = async function (context, req) {
    context.log('N1000 RegisteDevice()', req);

    const constDeviceId = req.query.id;
    const constDeviceType = req.query.type;
    const constMacAddress = req.query.mac;
    const constSessionId = req.query.session;
    const constUserName = req.query.username; // Add this line to define constUserName
    const { location, portId } = req.body || {};     // Extract JSON body
    context.log('N1001 RegisteDevice() with => ',constDeviceId, constDeviceType, constMacAddress, constSessionId, location, portId);


    // Validate input, more checks are needed <TO DO>
    if ((!constDeviceId) || (!constSessionId) || (!constDeviceType) ||(!constMacAddress )) {
        sendResponse(context, 400, "error", "E1001", "Missing Major variables to function");
        return;
    }

    //decode the constSessionId
    const hexRegex = /^[0-9A-Fa-f]+$/;
    if(!hexRegex.test(constSessionId)) {
        sendResponse(context, 400, "error", "E1002", "Invalid Session");
        return;
    }
    let sessionData = getSessionId(constSessionId);
    context.log("sessionData = ",sessionData);

    if((undefined === sessionData.serialId) || (null === sessionData.serialId)) {
        sendResponse(context, 400, "error", "E1003", "Invalid Session, Data Error");
        return;
    }

    if((sessionData.serialId.length < 5)) {
        sendResponse(context, 400, "error", "E1004", "Invalid Session, Data Error");
        return;
    }

    //check time validity
    let timeElapsed = minutesElapsedFromStartOfYearUTC();

    if(!checkTimeID(sessionData.timeId,timeElapsed, TIME_MATCH_THRESHOLD)) {
        sendResponse(context, 400, "error", "E1005", "Invalid Session, Check system Time");
        return;
    }

    sendResponse(context, 200, 'success', 'S1000', `Device registered at ${location} port ID ${portId}`, { sessionId: sessionData.serialId, deviceId: constDeviceId});
    return;
}