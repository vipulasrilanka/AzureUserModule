// Azure Function endpoint
// Static token from userLogin.js
const VALID_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ";

// Static state data following the schema from statedb.json
const staticStates = [
    // Switch-bi-stable states (ON/OFF)
    { UniqueID: 1, StateID: "SWB__ON", StateName: "ON", StateSetTo: "ON", DeviceType: "Switch-bi-stable", FunctionID: null },
    { UniqueID: 2, StateID: "SWB_OFF", StateName: "OFF", StateSetTo: "OFF", DeviceType: "Switch-bi-stable", FunctionID: null },
    
    // Temperature-control states
    { UniqueID: 3, StateID: "TMP_022", StateName: "22", StateSetTo: "T=22", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 4, StateID: "TMP_023", StateName: "23", StateSetTo: "T=23", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 5, StateID: "TMP_024", StateName: "24", StateSetTo: "T=24", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 6, StateID: "TMP_025", StateName: "25", StateSetTo: "T=25", DeviceType: "Temperature-control", FunctionID: null },
    { UniqueID: 7, StateID: "TMP_OFF", StateName: "OFF", StateSetTo: "OFF", DeviceType: "Temperature-control", FunctionID: null },

    { UniqueID: 8, StateID: "LCK__ON", StateName: "LOCK", StateSetTo: "LOCKED", DeviceType: "Lock-bi-stable", FunctionID: null },
    { UniqueID: 9, StateID: "LCK_OFF", StateName: "OPEN", StateSetTo: "OPEN", DeviceType: "Lock-bi-stable", FunctionID: null },

    { UniqueID: 8, StateID: "LCH__ON", StateName: "AUTO", StateSetTo: "WAITING", DeviceType: "Lock-Self-Latch", FunctionID: null },
    { UniqueID: 9, StateID: "LCH_REL", StateName: "RELEASE", StateSetTo: "OPEN", DeviceType: "Lock-Self-Latch", FunctionID: null }
];

// Static device data following the schema from Query 1.json
const staticDevices = [
    {
        UniqueID: 1,
        DeviceID: "DEV001",
        DeviceName: "Main Door",
        DeviceDescription: "Main entrance door lock",
        DeviceType: "Lock-bi-stable",
        CreatedDate: "2024-03-18T10:00:00",
        CreatedUserID: "admin",
        LocationCode: "LOC001",
        Status: "LOCKED",
        PortID: 1,
        LockPin: 1234,
        MacAddress: "00:11:22:3C:B4:BE"
    },
    {
        UniqueID: 2,
        DeviceID: "DEV002",
        DeviceName: "Garage Gate",
        DeviceDescription: "Garage entrance gate",
        DeviceType: "Lock-bi-stable",
        CreatedDate: "2024-03-18T10:01:00",
        CreatedUserID: "admin",
        LocationCode: "LOC002",
        Status: "OPEN",
        PortID: 2,
        LockPin: 5678,
        MacAddress: "00:F1:22:D3:44:66"
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
        Status: "T=23",
        PortID: 3,
        LockPin: null,
        MacAddress: "00:11:2D:33:4F:77"
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
        MacAddress: "00:11:A2:33:44:88"
    },
    {
        UniqueID: 5,
        DeviceID: "DEV005",
        DeviceName: "Letter Box",
        DeviceDescription: "Auto Letter Box",
        DeviceType: "Lock-Self-Latch",
        CreatedDate: "2024-03-18T10:01:00",
        CreatedUserID: "admin",
        LocationCode: "LOC002",
        Status: "LOCKED",
        PortID: 2,
        LockPin: 5678,
        MacAddress: "00:11:22:A3:44:DF"
    }
];

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    // Check for required fields
    if (!req.body || !req.body.DeviceID || !req.body.StateID || !req.body.SessionToken) {
        context.res = {
            status: 400,
            body: {
                error: "Missing required fields",
                message: "DeviceID, StateID, and SessionToken are required in the request body"
            }
        };
        return;
    }

    const { DeviceID, StateID, SessionToken } = req.body;

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

    // Find the device
    const deviceIndex = staticDevices.findIndex(device => device.DeviceID === DeviceID);
    if (deviceIndex === -1) {
        context.res = {
            status: 404,
            body: {
                error: "Device not found",
                message: `No device found with ID ${DeviceID}`
            }
        };
        return;
    }

    // Find the state
    const state = staticStates.find(s => s.StateID === StateID);
    if (!state) {
        context.res = {
            status: 404,
            body: {
                error: "State not found",
                message: `No state found with ID ${StateID}`
            }
        };
        return;
    }

    // Verify that the state is applicable to the device type
    if (state.DeviceType !== staticDevices[deviceIndex].DeviceType) {
        context.res = {
            status: 400,
            body: {
                error: "Invalid state for device type",
                message: `State ${StateID} is not applicable for device type ${staticDevices[deviceIndex].DeviceType}`
            }
        };
        return;
    }

    // Update the device status
    staticDevices[deviceIndex].Status = state.StateSetTo;

    // Return the updated device
    context.res = {
        status: 200,
        body: {
            message: "Device state updated successfully",
            device: staticDevices[deviceIndex]
        }
    };
}