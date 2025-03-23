-- Insert test users
INSERT INTO [dbo].[Users] (UserName, Email, FirstName, LastName, NICNumber, Birthday)
VALUES 
('admin', 'admin@example.com', 'System', 'Administrator', 'NIC123456', '1990-01-01'),
('john_doe', 'john@example.com', 'John', 'Doe', 'NIC789012', '1985-05-15'),
('jane_smith', 'jane@example.com', 'Jane', 'Smith', 'NIC345678', '1992-08-20');

-- Insert user passwords (SHA-256 hashes)
INSERT INTO [dbo].[UserPasswords] (UserID, PasswordHash, ResetFunctionInput)
VALUES 
(100000, '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'reset123'), -- admin/admin
(100001, '96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e', 'reset456'), -- john/password123
(100002, 'e6e061838856bf47e1de730719fb2609f2d63561bc7e644e288d6db3e9e53a54', 'reset789'); -- jane/password456

-- Insert device types
INSERT INTO [dbo].[DeviceTypes] (TypeName, TypeDescription)
VALUES 
('DOOR_LOCK', 'Smart Door Lock - Electronic lock with keypad and mobile app control'),
('LIGHT_SWITCH', 'Smart Light Switch - WiFi-enabled light switch with dimming'),
('THERMOSTAT', 'Smart Thermostat - Temperature control with scheduling'),
('WATER_VALVE', 'Smart Water Valve - Remote water flow control'),
('GAS_VALVE', 'Smart Gas Valve - Remote gas flow control'),
('SMOKE_DETECTOR', 'Smart Smoke Detector - Connected smoke and carbon monoxide detector'),
('MOTION_SENSOR', 'Motion Sensor - Wireless motion detection'),
('CAMERA', 'Security Camera - IP camera with motion detection'),
('DOOR_SENSOR', 'Door Sensor - Magnetic contact sensor for doors and windows'),
('GARAGE_DOOR', 'Garage Door Controller - Smart garage door opener');

-- Insert event types
INSERT INTO [dbo].[EventTypes] (EventTypeName, EventTypeDescription)
VALUES 
('STATE_CHANGE', 'Device State Change'),
('ACTIVATE', 'Activate (True/False)'),
('ERROR', 'Error Condition'),
('REGISTER', 'Register (True/False)'),
('NOTE','Text Note');

-- Insert event values for each event type
INSERT INTO [dbo].[EventValues] (EventValue, EventValueDescription, EventTypeID)
VALUES 
-- State Change values
('LOCKED', 'Device is locked', 100000),
('UNLOCKED', 'Device is unlocked', 100000),
('OPEN', 'Device is open', 100000),
('CLOSED', 'Device is closed', 100000),
('ON', 'Device is turned on', 100000),
('OFF', 'Device is turned off', 100000),

-- Activate values
('ACTIVE', 'Device is active', 100001),
('INACTIVE', 'Device is inactive', 100001),

-- Register values
('REGISTERED', 'Device is registered', 100002),
('UNREGISTERED', 'Device is unregistered', 100002),

-- Error values
('ERROR_LOW_BATTERY', 'Device battery is low', 100003),
('ERROR_CONNECTION', 'Device connection error', 100003),
('ERROR_SENSOR', 'Device sensor error', 100003),

-- Note values (custom text)
('NOTE', 'User note', 100004);

-- Insert functions
INSERT INTO [dbo].[Functions] (FunctionName, FunctionDescription, InputCount)
VALUES 
('LOCK_DOOR', 'Lock a door device', 1),
('UNLOCK_DOOR', 'Unlock a door device', 1),
('OPEN_VALVE', 'Open a valve device', 1),
('CLOSE_VALVE', 'Close a valve device', 1),
('ENABLE_DEVICE', 'Enable a device', 1),
('DISABLE_DEVICE', 'Disable a device', 1);

-- Insert state change types for each device type
INSERT INTO [dbo].[StateChangeTypes] (StateChangeName, ActionText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
-- Door Lock states
('LOCK', 'Lock Door', 'LOCKED', 100000, 100000),
('UNLOCK', 'Unlock Door', 'UNLOCKED', 100000, 100001),

-- Gas Valve states
('OPEN', 'Open Gas Valve', 'OPEN', 100001, 100002),
('CLOSE', 'Close Gas Valve', 'CLOSED', 100001, 100003),

-- Water Valve states
('OPEN', 'Open Water Valve', 'OPEN', 100002, 100002),
('CLOSE', 'Close Water Valve', 'CLOSED', 100002, 100003),

-- Smoke Detector states
('ENABLE', 'Enable Smoke Detector', 'ON', 100003, 100004),
('DISABLE', 'Disable Smoke Detector', 'OFF', 100003, 100005);

-- Insert locations
INSERT INTO [dbo].[Locations] (Name, StreetAddress, GeoLocation, CreatedByUserID)
VALUES 
('Home', '123 Main St, City', '6.9271,79.8612', 100000),
('Office', '456 Business Ave, City', '6.9271,79.8612', 100000),
('Garage', '789 Parking Rd, City', '6.9271,79.8612', 100000);

-- Insert device states
INSERT INTO [dbo].[DeviceStates] (StateName, StateDescription)
VALUES 
('PENDING', 'Device is pending registration'),
('REGISTERED', 'Device is registered but not active'),
('ACTIVE', 'Device is active and operational'),
('DEACTIVATED', 'Device is temporarily deactivated'),
('REJECTED', 'Device registration was rejected');

-- Insert devices
INSERT INTO [dbo].[Devices] (SerialNumber, DeviceTypeID, DeviceName, DeviceDescription, CreatedUserID, LocationID, DeviceStatus, PortID, LockPin, MacAddress)
VALUES 
('DL001', 100000, 'Front Door', 'Main entrance door lock', 100000, 100000, 'ACTIVE', 1, 1234, '00:11:22:33:44:55'),
('DL002', 100000, 'Back Door', 'Back entrance door lock', 100000, 100000, 'ACTIVE', 2, 5678, '00:11:22:33:44:66'),
('GV001', 100001, 'Main Gas Valve', 'Main gas supply valve', 100000, 100000, 'ACTIVE', 3, NULL, '00:11:22:33:44:77'),
('WV001', 100002, 'Main Water Valve', 'Main water supply valve', 100000, 100000, 'ACTIVE', 4, NULL, '00:11:22:33:44:88'),
('SD001', 100003, 'Kitchen Smoke Detector', 'Kitchen area smoke detector', 100000, 100000, 'ACTIVE', 5, NULL, '00:11:22:33:44:99'),
('MS001', 100004, 'Living Room Motion', 'Living room motion sensor', 100000, 100000, 'ACTIVE', 6, NULL, '00:11:22:33:44:AA'),
('SC001', 100005, 'Front Camera', 'Front door security camera', 100000, 100000, 'ACTIVE', 7, NULL, '00:11:22:33:44:BB'),
('DS001', 100006, 'Garage Door Sensor', 'Garage door magnetic sensor', 100000, 100001, 'ACTIVE', 8, NULL, '00:11:22:33:44:CC'),
('GD001', 100007, 'Garage Door', 'Garage door controller', 100000, 100001, 'ACTIVE', 9, 9012, '00:11:22:33:44:DD');

-- Insert events
INSERT INTO [dbo].[Events] (EventTypeID, EventValueID, EventDescription, DeviceID, CreatedUserID)
VALUES 
-- State changes
(100000, 100000, 'Door locked by admin', 100000, 100000),
(100000, 100001, 'Door unlocked by admin', 100000, 100000),
(100000, 100002, 'Gas valve opened by admin', 100002, 100000),
(100000, 100003, 'Water valve closed by admin', 100003, 100000),

-- Activation events
(100001, 100005, 'Device activated by admin', 100000, 100000),
(100001, 100006, 'Device deactivated by admin', 100001, 100000),

-- Registration events
(100002, 100007, 'Device registered by admin', 100000, 100000),
(100002, 100008, 'Device unregistered by admin', 100001, 100000),

-- Error events
(100003, 100009, 'Low battery warning', 100004, 100000),
(100003, 100010, 'Connection error detected', 100005, 100000),

-- Notes
(100004, 100011, 'Regular maintenance completed', 100000, 100000),
(100004, 100011, 'Battery replaced', 100004, 100000);

