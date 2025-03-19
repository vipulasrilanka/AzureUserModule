// Azure Function endpoint
// Static token from userLogin.js
const VALID_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ";

// Static state data following the schema from statedb.json
const staticStates = [
    // Switch-bi-stable states (ON/OFF)
    { UniqueID: 1, StateID: "SWB__ON", StateName: "ON", DeviceType: "Switch-bi-stable", FunctionID: null },
    { UniqueID: 2, StateID: "SWB_OFF", StateName: "OFF", DeviceType: "Switch-bi-stable", FunctionID: null },
    
    // Temperature-control states
    { UniqueID: 3, StateID: "TMP_022", StateName: "22", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 4, StateID: "TMP_023", StateName: "23", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 5, StateID: "TMP_024", StateName: "24", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 6, StateID: "TMP_025", StateName: "25", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 7, StateID: "TMP_OFF", StateName: "OFF", DeviceType: "Temperature-control", FunctionID: null }
];

// Static device data following the schema from Query 1.json
const staticDevices = [
    {
        UniqueID: 1,
        DeviceID: "DEV001",
        DeviceName: "Main Door",
        DeviceDescription: "Main entrance door lock",
        DeviceType: "Switch-bi-stable",
        CreatedDate: "2024-03-18T10:00:00",
        CreatedUserID: "admin",
        LocationCode: "LOC001",
        Status: "LOCK",
        PortID: 1,
        LockPin: 1234,
        MacAddress: "00:11:22:33:44:55"
    },
    {
        UniqueID: 2,
        DeviceID: "DEV002",
        DeviceName: "Garage Gate",
        DeviceDescription: "Garage entrance gate",
        DeviceType: "Switch-bi-stable",
        CreatedDate: "2024-03-18T10:01:00",
        CreatedUserID: "admin",
        LocationCode: "LOC002",
        Status: "UNLOCK",
        PortID: 2,
        LockPin: 5678,
        MacAddress: "00:11:22:33:44:66"
    },
    {
        UniqueID: 3,
        DeviceID: "DEV003",
        DeviceName: "Bedroom AC",
        DeviceDescription: "Bedroom air conditioner",
        DeviceType: "Temperature-control",
        CreatedDate: "2024-03-18T10:02:00",
        CreatedUserID: "admin",
        LocationCode: "LOC003",
        Status: "23",
        PortID: 3,
        LockPin: null,
        MacAddress: "00:11:22:33:44:77"
    },
    {
        UniqueID: 4,
        DeviceID: "DEV004",
        DeviceName: "Garden Light",
        DeviceDescription: "Garden area lighting",
        DeviceType: "Switch-bi-stable",
        CreatedDate: "2024-03-18T10:03:00",
        CreatedUserID: "admin",
        LocationCode: "LOC004",
        Status: "OFF",
        PortID: 4,
        LockPin: null,
        MacAddress: "00:11:22:33:44:88"
    }
];

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    // Check for required fields
    if (!req.body || !req.body.CreatedUserID || !req.body.SessionToken) {
        context.res = {
            status: 400,
            body: {
                error: "Missing required fields",
                message: "CreatedUserID and SessionToken are required in the request body"
            }
        };
        return;
    }

    const { CreatedUserID, SessionToken, DeviceID, DeviceName } = req.body;

    // Validate session token
    if (SessionToken !== VALID_TOKEN) {
        context.res = {
            status: 401,
            body: {
                error: "Invalid session token",
                message: "The provided session token is invalid or expired"
            }
        };
        return;
    }

    // Filter devices based on CreatedUserID
    let userDevices = staticDevices.filter(device => device.CreatedUserID === CreatedUserID);

    // If no devices found for the user
    if (userDevices.length === 0) {
        context.res = {
            status: 404,
            body: {
                error: "No devices found",
                message: `No devices found for user ${CreatedUserID}`
            }
        };
        return;
    }

    // If device filters are provided, apply them
    if (DeviceID || DeviceName) {
        userDevices = userDevices.filter(device => {
            if (DeviceID && device.DeviceID === DeviceID) return true;
            if (DeviceName && device.DeviceName === DeviceName) return true;
            return false;
        });

        // If no matching devices found after filtering
        if (userDevices.length === 0) {
            context.res = {
                status: 404,
                body: {
                    error: "No matching devices found",
                    message: "No devices found matching the provided criteria"
                }
            };
            return;
        }
    }

    // Get unique device types from the filtered devices
    const deviceTypes = [...new Set(userDevices.map(device => device.DeviceType))];

    // Get applicable states for the device types
    const applicableStates = staticStates.filter(state => 
        deviceTypes.includes(state.DeviceType)
    );

    // Return the filtered devices and applicable states
    context.res = {
        status: 200,
        body: {
            devices: userDevices,
            count: userDevices.length,
            states: applicableStates
        }
    };
}
