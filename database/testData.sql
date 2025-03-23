-- Insert test users
INSERT INTO [dbo].[Users] (UserName, Email, FirstName, LastName, NICNumber, Birthday)
VALUES 
('admin', 'admin@example.com', 'System', 'Administrator', 'NIC123456', '1990-01-01'),
('john', 'john@example.com', 'John', 'Doe', 'NIC789012', '1992-05-15'),
('jane', 'jane@example.com', 'Jane', 'Smith', 'NIC345678', '1988-08-20');

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

-- Insert state types for DOOR_LOCK
INSERT INTO [dbo].[StateTypes] (FriendlyName, NameText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
('Locked', 'LOCK', 'LOCKED', 100000, 'FUNC001'),
('Unlocked', 'UNLOCK', 'UNLOCKED', 100000, 'FUNC002'),
('Auto-Lock Enabled', 'ENABLED', 'ENABLED', 100000, 'FUNC003'),
('Auto-Lock Disabled', 'DISABLED', 'DISABLED', 100000, 'FUNC004');

-- Insert state types for LIGHT_SWITCH
INSERT INTO [dbo].[StateTypes] (FriendlyName, NameText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
('LS_ON', 'ON', 'ON', 100001, 'GetLSValue'),
('LS_OFF', 'OFF', 'OFF', 100001, 'GetLSValue'),
('LS_DIM_25', '25%', '25%', 100001, 'GetLSValue'),
('LS_DIM_50', '50%', '50%', 100001, 'GetLSValue'),
('LS_DIM_75', '75%', '75%'  , 100001, 'GetLSValue'),
('LS_DIM_100', '90%', '90%', 100001, 'GetLSValue');

-- Insert state types for THERMOSTAT
INSERT INTO [dbo].[StateTypes] (FriendlyName, NameText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
('TH_HEAT', 'HEAT', 'HEAT', 100002, 'GetTHValue'),
('TH_COOL', 'COOL', 'COOL', 100002, 'GetTHValue'),
('TH_AUTO', 'AUTO', 'AUTO', 100002, 'GetTHValue'),
('TH_OFF', 'OFF', 'OFF', 100002, 'GetTHValue'),
('TH_FAN_ON', 'FAN ON', 'FAN ON', 100002, 'GetTHValue'),
('TH_FAN_AUTO', 'FAN AUTO', 'FAN AUTO', 100002, 'GetTHValue'),
('TH_TEMP_20', 'Set to 20', 'Set Temp = 20', 100002, 'GetTHValue'),
('TH_TEMP_22', 'Set to 22', 'Set Temp = 22', 100002, 'GetTHValue');

-- Insert state types for WATER_VALVE
INSERT INTO [dbo].[StateTypes] (FriendlyName, NameText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
('WV_OPEN', 'OPEN', 'OPEN', 100003, 'GetWVValue'),
('WV_CLOSED', 'CLOSE', 'CLOSED', 100003, 'GetWVValue'),
('WV_LEAK', 'LEAK', 'LEAK', 100003, 'GetWVValue');

-- Insert state types for GAS_VALVE
INSERT INTO [dbo].[StateTypes] (FriendlyName, NameText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
('GV_OPEN', 'OPEN', 'OPEN', 100004, 'GetGVValue'),
('GV_CLOSED', 'CLOSE', 'CLOSED', 100004, 'GetGVValue'),
('GV_GAS_LEAK', 'GAS_LEAK', 'LEAK', 100004, 'GetGVValue');

-- Insert state types for SMOKE_DETECTOR
INSERT INTO [dbo].[StateTypes] (FriendlyName, NameText, StateSetTo, DeviceTypeID, FunctionID)
VALUES 
('SD_DISARMED', 'DISARMED', 'DISARMED', 100005, 'GetSDValue'),
('SD_ARMED', 'ARMED', 'ARMED', 100005, 'GetSDValue'),
('SD_SMOKE', 'SMOKE', 'DETECTED', 100005, 'GetSDValue'),
('SD_NORMAL', 'NORMAL', 'NORMAL', 100005, 'GetSDValue');

-- Insert test locations
INSERT INTO [dbo].[Locations] (Name, StreetAddress, GeoLocation, CreatedByUserID)
VALUES 
('Main House', '123 Main Street, City', '6.9271,79.8612', 100000),
('Garage', '123 Main Street, City', '6.9271,79.8612', 100000),
('Backyard', '123 Main Street, City', '6.9271,79.8612', 100000),
('Kitchen', '123 Main Street, City', '6.9271,79.8612', 100000),
('Living Room', '123 Main Street, City', '6.9271,79.8612', 100000),
('Bedroom', '123 Main Street, City', '6.9271,79.8612', 100000);

-- Insert test devices
INSERT INTO [dbo].[Devices] (SerialNumber, DeviceName, DeviceDescription, DeviceTypeID, CreatedUserID, LocationID, DeviceStatus, PortID, LockPin, MacAddress)
VALUES 
-- Door Locks
('DL001', 'Front Door Lock', 'Main entrance smart lock', 100000, 100000, 100000, 'ACTIVE', 1, 1234, '00:1B:44:11:3A:B7'),
('DL002', 'Back Door Lock', 'Back entrance smart lock', 100000, 100000, 100000, 'ACTIVE', 2, 5678, '00:1B:44:11:3A:B8'),
('DL003', 'Garage Door Lock', 'Garage entrance smart lock', 100000, 100000, 100001, 'ACTIVE', 1, 9012, '00:1B:44:11:3A:B9'),

-- Light Switches
('LS001', 'Living Room Light', 'Main living room light switch', 100001, 100000, 100004, 'ACTIVE', 1, 0, '00:1B:44:11:3A:BA'),
('LS002', 'Kitchen Light', 'Kitchen area light switch', 100001, 100000, 100003, 'ACTIVE', 1, 0, '00:1B:44:11:3A:BB'),
('LS003', 'Bedroom Light', 'Master bedroom light switch', 100001, 100000, 100005, 'ACTIVE', 1, 0, '00:1B:44:11:3A:BC'),

-- Thermostats
('TH001', 'Main Thermostat', 'Central heating and cooling control', 100002, 100000, 100000, 'ACTIVE', 1, 0, '00:1B:44:11:3A:BD'),
('TH002', 'Bedroom Thermostat', 'Bedroom temperature control', 100002, 100000, 100005, 'ACTIVE', 1, 0, '00:1B:44:11:3A:BE'),

-- Water Valves
('WV001', 'Main Water Valve', 'Main water supply control', 100003, 100000, 100000, 'ACTIVE', 1, 0, '00:1B:44:11:3A:BF'),
('WV002', 'Garden Water Valve', 'Garden irrigation control', 100003, 100000, 100002, 'ACTIVE', 1, 0, '00:1B:44:11:3A:C0'),

-- Gas Valves
('GV001', 'Main Gas Valve', 'Main gas supply control', 100004, 100000, 100000, 'ACTIVE', 1, 0, '00:1B:44:11:3A:C1'),
('GV002', 'Kitchen Gas Valve', 'Kitchen gas supply control', 100004, 100000, 100003, 'ACTIVE', 1, 0, '00:1B:44:11:3A:C2');

-- Insert event values
INSERT INTO [dbo].[EventValues] (EventValue, EventValueDescription, EventTypeID)
VALUES 
-- STATE_CHANGE Events (100000)
('LOCKED', 'Locked', 100000),
('UNLOCKED', 'Unlocked', 100000),
('ON', 'On', 100000),
('OFF', 'Off', 100000),
('OPEN', 'Open', 100000),
('CLOSED', 'Closed', 100000),
('HEAT', 'Heat Mode', 100000),
('COOL', 'Cool Mode', 100000),
('AUTO', 'Auto Mode', 100000),
('25%', 'Dim Level 25%', 100000),
('50%', 'Dim Level 50%', 100000),
('75%', 'Dim Level 75%', 100000),
('90%', 'Dim Level 90%', 100000),

-- ACTIVATE Events (100001)
('TRUE', 'Activated', 100001),
('FALSE', 'Deactivated', 100001),

-- ERROR Events (100002)
('LOCK_JAMMED', 'Lock Jammed', 100002),
('NO_POWER', 'Power Outage', 100002),
('BATTERY_LOW', 'Battery Low', 100002),
('BATTERY_CRITICAL', 'Battery Critical', 100002),
('LOW_SIGNAL', 'Low Signal', 100002),
('GAS_LEAK', 'Gas Leak', 100002),
('WATER_LEAK', 'Water Leak', 100002),

-- REGISTER Events (100003)
('TRUE', 'Registered', 100003),
('FALSE', 'Unregistered', 100003),

-- NOTE Events (100004)
('USER_LOGIN', 'User Login', 100004),
('USER_LOGOUT', 'User Logout', 100004),
('USER_ADD', 'User Added', 100004),
('USER_DELETE', 'User Deleted', 100004),
('USER_UPDATE', 'User Updated', 100004),
('USER_RESET_PASSWORD', 'User Reset Password', 100004),
('USER_FORGOT_PASSWORD', 'User Forgot Password', 100004);

-- Insert test events
INSERT INTO [dbo].[Events] (EventTypeID, EventValueID, EventDescription, DeviceID, CreatedUserID)
VALUES 
-- Door Lock State Changes
(100000, 100000, 'Front door locked by admin', 100000, 100000),
(100000, 100001, 'Front door unlocked by john', 100000, 100001),
(100000, 100000, 'Back door locked by system', 100001, 100000),
(100000, 100001, 'Back door unlocked by jane', 100001, 100002),

-- Light Switch State Changes
(100000, 100002, 'Living room light turned on by admin', 100003, 100000),
(100000, 100003, 'Living room light turned off by john', 100003, 100001),
(100000, 100002, 'Kitchen light turned on by jane', 100004, 100002),
(100000, 100010, 'Kitchen light dimmed to 25%', 100004, 100002),

-- Thermostat State Changes
(100000, 100006, 'Main thermostat set to heat mode', 100006, 100000),
(100000, 100007, 'Main thermostat set to cool mode', 100006, 100000),
(100000, 100008, 'Main thermostat set to auto mode', 100006, 100000),
(100000, 100007, 'Bedroom thermostat set to cool mode', 100007, 100001),

-- Water Valve State Changes
(100000, 100004, 'Main water valve opened by admin', 100008, 100000),
(100000, 100005, 'Main water valve closed by system', 100008, 100000),
(100000, 100004, 'Garden water valve opened for irrigation', 100009, 100000),
(100000, 100005, 'Garden water valve closed after irrigation', 100009, 100000),

-- Error Events
(100002, 100012, 'Front door lock jammed', 100000, 100000),
(100002, 100013, 'Main thermostat power outage', 100006, 100000),
(100002, 100014, 'Back door lock battery low', 100001, 100000),
(100002, 100016, 'Kitchen gas valve leak detected', 100011, 100002),
(100002, 100017, 'Main water valve leak detected', 100008, 100000),

-- Activate Events
(100001, 100011, 'Main thermostat activated', 100006, 100000),
(100001, 100012, 'Bedroom thermostat deactivated', 100007, 100001),

-- Register Events
(100003, 100018, 'New device registered: Front Door Lock', 100000, 100000),
(100003, 100019, 'Device unregistered: Back Door Lock', 100001, 100000),

-- Note Events
(100004, 100020, 'User login: admin', 100000, 100000),
(100004, 100021, 'User logout: john', 100000, 100001),
(100004, 100026, 'User password reset: jane', 100000, 100002);

