// Dummy data for devices with current state
const devices = [
    { name: "Main Door", type: "door", currentState: "LOCK" },
    { name: "Garage Gate", type: "gate", currentState: "UNLOCK" },
    { name: "Bedroom AC", type: "ac", currentState: "23" },
    { name: "Garden Light", type: "light", currentState: "OFF" }
];

// Azure Function configuration
const config = {
    apiUrl: "{% AZURE_FUNCTION_URL %}",
    apiKey: "{% AZURE_FUNCTION_KEY %}"
};

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
        const response = await fetch(`${config.apiUrl}?code=${config.apiKey}`, {
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

// Function to load devices into the table
function loadDevices() {
    const tableBody = document.getElementById('device-data');
    tableBody.innerHTML = '';
    devices.forEach(device => {
        const row = document.createElement('tr');
        const stateOptions = getStateOptions(device.type);
        row.innerHTML = `
            <td>${device.name}</td>
            <td id="current-state-${device.name.replace(/\s+/g, '-').toLowerCase()}">${device.currentState}</td>
            <td>
                <select id="select-${device.name.replace(/\s+/g, '-').toLowerCase()}">${stateOptions}</select>
            </td>
            <td>
                <button onclick="setDeviceState('${device.name}', document.getElementById('select-${device.name.replace(/\s+/g, '-').toLowerCase()}').value)">Set</button>
            </td>
        `;
        tableBody.appendChild(row);
    });
}

function getStateOptions(type) {
    switch(type) {
        case 'light': return '<option>ON</option><option>OFF</option>';
        case 'door':
        case 'gate': return '<option>LOCK</option><option>UNLOCK</option>';
        case 'ac': return '<option>OFF</option><option>22</option><option>23</option><option>24</option><option>25</option>';
        default: return '';
    }
}

function setDeviceState(deviceName, state) {
    const device = devices.find(d => d.name === deviceName);
    if (device) {
        device.currentState = state;
        const currentStateElement = document.getElementById(`current-state-${deviceName.replace(/\s+/g, '-').toLowerCase()}`);
        if (currentStateElement) {
            currentStateElement.textContent = state;
        }
    }
}

// Make functions available globally
window.login = login;
window.setDeviceState = setDeviceState; 
