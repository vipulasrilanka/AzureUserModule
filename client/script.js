// Function to convert string to SHA-256 hash
async function sha256(message) {
    const msgBuffer = new TextEncoder().encode(message);                    
    const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    return hashHex;
}

// Function to handle login
async function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    if (!username || !password) {
        alert('Please enter both username and password');
        return;
    }

    try {
        const passwordHash = await sha256(password);
        const response = await fetch(`${window.APP_CONFIG.AZURE_FUNCTION_URL}?code=${window.APP_CONFIG.AZURE_FUNCTION_KEY}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                userName: username,
                passwordHash: passwordHash
            })
        });

        const data = await response.json();

        if (response.ok) {
            localStorage.setItem('authToken', data.token);
            localStorage.setItem('username', username);
            document.getElementById('login-page').style.display = 'none';
            document.getElementById('control-page').style.display = 'block';
            loadDevices();
        } else {
            alert(data.body || 'Login failed. Please check your credentials.');
        }
    } catch (error) {
        console.error('Login error:', error);
        alert('Login failed. Please try again.');
    }
}

// Function to load devices from the backend
async function loadDevices() {
    try {
        const username = localStorage.getItem('username');
        const sessionToken = localStorage.getItem('authToken');

        if (!username || !sessionToken) {
            alert('Session expired. Please login again.');
            document.getElementById('login-page').style.display = 'block';
            document.getElementById('control-page').style.display = 'none';
            return;
        }

        const response = await fetch(`${window.APP_CONFIG.GET_DEVICE_URL}?code=${window.APP_CONFIG.GET_DEVICE_KEY}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                userName: username,
                sessionToken: sessionToken
            })
        });

        const data = await response.json();

        if (response.ok) {
            const tableBody = document.getElementById('device-data');
            tableBody.innerHTML = '';
            
            // Group controls by device
            const deviceControls = {};
            data.devices.forEach(device => {
                if (!deviceControls[device.deviceName]) {
                    deviceControls[device.deviceName] = {
                        deviceId: device.deviceId,
                        controls: []
                    };
                }
                deviceControls[device.deviceName].controls.push({
                    controlName: device.controlName,
                    controlType: device.controlType,
                    currentState: device.deviceState,
                    stateOptions: getStateOptions(device.controlType, data.states)
                });
            });

            // Create rows for each device with its controls
            Object.entries(deviceControls).forEach(([deviceName, deviceData]) => {
                const row = document.createElement('tr');
                
                // Device name cell (spans all controls)
                const deviceCell = document.createElement('td');
                deviceCell.rowSpan = deviceData.controls.length;
                deviceCell.textContent = deviceName;
                row.appendChild(deviceCell);

                // First control
                const firstControl = deviceData.controls[0];
                row.innerHTML += `
                    <td>${firstControl.controlName}</td>
                    <td id="current-state-${deviceData.deviceId}-${firstControl.controlType}">${firstControl.currentState}</td>
                    <td>
                        <select id="select-${deviceData.deviceId}-${firstControl.controlType}">${firstControl.stateOptions}</select>
                    </td>
                    <td>
                        <button onclick="setDeviceState('${deviceData.deviceId}', '${firstControl.controlType}', document.getElementById('select-${deviceData.deviceId}-${firstControl.controlType}').value)">Set</button>
                    </td>
                `;
                tableBody.appendChild(row);

                // Additional controls for the same device
                deviceData.controls.slice(1).forEach(control => {
                    const controlRow = document.createElement('tr');
                    controlRow.innerHTML = `
                        <td>${control.controlName}</td>
                        <td id="current-state-${deviceData.deviceId}-${control.controlType}">${control.currentState}</td>
                        <td>
                            <select id="select-${deviceData.deviceId}-${control.controlType}">${control.stateOptions}</select>
                        </td>
                        <td>
                            <button onclick="setDeviceState('${deviceData.deviceId}', '${control.controlType}', document.getElementById('select-${deviceData.deviceId}-${control.controlType}').value)">Set</button>
                        </td>
                    `;
                    tableBody.appendChild(controlRow);
                });
            });
        } else {
            alert(data.message || 'Failed to load devices. Please try again.');
            if (response.status === 401) {
                // Session expired
                document.getElementById('login-page').style.display = 'block';
                document.getElementById('control-page').style.display = 'none';
            }
        }
    } catch (error) {
        console.error('Error loading devices:', error);
        alert('Failed to load devices. Please try again.');
    }
}

// Function to get state options for a control type
function getStateOptions(controlType, states) {
    // Filter states for the given control type
    const controlStates = states.filter(state => state.ControlType === controlType);
    
    // Create options from the filtered states
    return controlStates.map(state => 
        `<option value="${state.ControlValueID}">${state.ActionText || state.ValueDescription}</option>`
    ).join('');
}

// Function to show messages to the user
function showMessage(message, type = 'info') {
    const messageDiv = document.getElementById('message');
    if (messageDiv) {
        messageDiv.textContent = message;
        messageDiv.className = `message ${type}`;
        messageDiv.style.display = 'block';
        setTimeout(() => {
            messageDiv.style.display = 'none';
        }, 3000);
    } else {
        // Fallback to alert if message div doesn't exist
        alert(message);
    }
}

// Function to set device state
async function setDeviceState(deviceId, controlType, stateId) {
    try {
        const response = await fetch(`${window.APP_CONFIG.SET_DEVICE_URL}?code=${window.APP_CONFIG.SET_DEVICE_KEY}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                DeviceID: deviceId,
                ControlType: controlType,
                StateID: stateId,
                SessionToken: localStorage.getItem('authToken')
            })
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.message || 'Failed to set device state');
        }

        const data = await response.json();
        
        // Update the UI with the new device state
        const currentStateElement = document.getElementById(`current-state-${deviceId}-${controlType}`);
        if (currentStateElement) {
            currentStateElement.textContent = data.device.Status;
        }

        // Show success message
        showMessage('Device state updated successfully', 'success');
    } catch (error) {
        console.error('Error setting device state:', error);
        showMessage(error.message || 'Failed to set device state', 'error');
        
        // If the error is due to an invalid session token, redirect to login
        if (error.message.includes('session token')) {
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
        }
    }
}

// Function to display version information
function displayVersionInfo() {
    const versionText = document.getElementById('version-text');
    const deployTime = document.getElementById('deploy-time');
    
    if (window.APP_VERSION) {
        versionText.textContent = `Version: ${window.APP_VERSION}`;
    }
    
    if (window.DEPLOY_TIME) {
        deployTime.textContent = `Deployed: ${window.DEPLOY_TIME}`;
    }
}

// Call displayVersionInfo when the page loads
document.addEventListener('DOMContentLoaded', displayVersionInfo);

// Make functions available globally
window.login = login;
window.setDeviceState = setDeviceState; 
