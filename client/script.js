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
            
            // Process each device
            data.devices.forEach(device => {
                // Create a row for each control in the device
                device.controls.forEach((control, index) => {
                    const row = document.createElement('tr');
                    
                    // Only add device name cell for the first control
                    if (index === 0) {
                        const deviceCell = document.createElement('td');
                        deviceCell.rowSpan = device.controls.length;
                        deviceCell.textContent = device.deviceName;
                        row.appendChild(deviceCell);
                    }
                    
                    // Add control information
                    row.innerHTML += `
                        <td>${control.controlName}</td>
                        <td id="current-state-${device.deviceId}-${control.controlType}">${control.currentState}</td>
                        <td>
                            <select id="select-${device.deviceId}-${control.controlType}">
                                ${control.stateOptions.map(option => 
                                    `<option value="${option.ControlValueID}">${option.ActionText}</option>`
                                ).join('')}
                            </select>
                        </td>
                        <td>
                            <button onclick="setDeviceState('${device.deviceId}', '${control.controlType}', document.getElementById('select-${device.deviceId}-${control.controlType}').value)">Set</button>
                        </td>
                    `;
                    
                    tableBody.appendChild(row);
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

// Add countdown timer functionality
let timeLeft = 50; // 50 seconds
let countdownTimer;

function updateCountdown() {
    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    const display = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    document.getElementById('countdown-timer').textContent = display;
    
    if (timeLeft <= 0) {
        clearInterval(countdownTimer);
        showServiceUnavailable();
    }
    timeLeft--;
}

function showServiceUnavailable() {
    const loadingText = document.querySelector('.loading-text');
    const countdownTimer = document.getElementById('countdown-timer');
    const retryButton = document.getElementById('retry-button');
    
    loadingText.textContent = 'Service Unavailable';
    countdownTimer.style.display = 'none';
    retryButton.style.display = 'block';
}

// Service state check function
async function checkServiceAvailability() {
    try {
        const response = await fetch(`${window.APP_CONFIG.GET_SERVICE_STATE_URL}?code=${window.APP_CONFIG.GET_SERVICE_STATE_KEY}`);
        if (response.status === 200) {
            clearInterval(countdownTimer);
            document.getElementById('loading-screen').style.display = 'none';
            document.getElementById('login-page').style.display = 'flex';
        } else {
            if (timeLeft > 0) {
                setTimeout(checkServiceAvailability, 2000);
            }
        }
    } catch (error) {
        console.error('Service check failed:', error);
        if (timeLeft > 0) {
            setTimeout(checkServiceAvailability, 2000);
        }
    }
}

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
    // Hide login page initially
    document.getElementById('login-page').style.display = 'none';
    // Start countdown timer
    countdownTimer = setInterval(updateCountdown, 1000);
    // Start checking service availability
    checkServiceAvailability();
    // Display version info
    displayVersionInfo();
});

// Make functions available globally
window.login = login;
window.setDeviceState = setDeviceState;
