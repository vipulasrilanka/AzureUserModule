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
                username: username,
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
                CreatedUserID: username,
                SessionToken: sessionToken
            })
        });

        const data = await response.json();

        if (response.ok) {
            const tableBody = document.getElementById('device-data');
            tableBody.innerHTML = '';
            
            data.devices.forEach(device => {
                const row = document.createElement('tr');
                const stateOptions = getStateOptions(device.DeviceType, data.states);
                row.innerHTML = `
                    <td>${device.DeviceName}</td>
                    <td id="current-state-${device.DeviceID}">${device.Status}</td>
                    <td>
                        <select id="select-${device.DeviceID}">${stateOptions}</select>
                    </td>
                    <td>
                        <button onclick="setDeviceState('${device.DeviceID}', document.getElementById('select-${device.DeviceID}').value)">Set</button>
                    </td>
                `;
                tableBody.appendChild(row);
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

function getStateOptions(deviceType, states) {
    // Filter states for the given device type
    const deviceStates = states.filter(state => state.DeviceType === deviceType);
    
    // Create options from the filtered states
    return deviceStates.map(state => 
        `<option value="${state.StateID}">${state.StateName}</option>`
    ).join('');
}

async function setDeviceState(deviceId, stateId) {
    try {
        const username = localStorage.getItem('username');
        const sessionToken = localStorage.getItem('authToken');

        if (!username || !sessionToken) {
            alert('Session expired. Please login again.');
            document.getElementById('login-page').style.display = 'block';
            document.getElementById('control-page').style.display = 'none';
            return;
        }

        // TODO: Implement the API call to update device state
        // For now, just update the UI
        const currentStateElement = document.getElementById(`current-state-${deviceId}`);
        if (currentStateElement) {
            // Find the state name from the states array
            const stateName = document.getElementById(`select-${deviceId}`).options[
                document.getElementById(`select-${deviceId}`).selectedIndex
            ].text;
            currentStateElement.textContent = stateName;
        }
    } catch (error) {
        console.error('Error setting device state:', error);
        alert('Failed to update device state. Please try again.');
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
