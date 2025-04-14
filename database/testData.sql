-- Insert test users
INSERT INTO [dbo].[Users] (UserName, Email, FirstName, LastName, NICNumber, Birthday)
VALUES 
('admin', 'admin@example.com', 'System', 'Administrator', 'NIC123456', '1990-01-01'),
('john_doe', 'john@example.com', 'John', 'Doe', 'NIC789012', '1985-05-15'),
('jane_smith', 'jane@example.com', 'Jane', 'Smith', 'NIC345678', '1992-08-20');

-- Insert user passwords (SHA-256 hashes)
INSERT INTO [dbo].[UserPasswords] (UserID, PasswordHash, ResetFunctionInput)
VALUES 
(1, '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'reset123'), -- admin/admin
(2, '96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e', 'reset456'), -- john/password123
(3, 'e6e061838856bf47e1de730719fb2609f2d63561bc7e644e288d6db3e9e53a54', 'reset789'); -- jane/password456

-- Insert device types
INSERT INTO [dbo].[DeviceTypes] (TypeName, TypeDescription)
VALUES 
('DOOR_LOCK', 'Smart Door Lock - Electronic lock with keypad and mobile app control'), -- ID = 01
('LIGHT_SWITCH', 'Smart Light Switch - WiFi-enabled light switch with dimming'), -- ID = 02
('THERMOSTAT', 'Smart Thermostat - Temperature control with scheduling'), -- ID = 03
('WATER_VALVE', 'Smart Water Valve - Remote water flow control'), -- ID = 04
('GAS_VALVE', 'Smart Gas Valve - Remote gas flow control'), -- ID = 05
('SMOKE_DETECTOR', 'Smart Smoke Detector - Connected smoke and carbon monoxide detector'), -- ID = 06
('MOTION_SENSOR', 'Motion Sensor - Wireless motion detection'), -- ID = 07
('CAMERA', 'Security Camera - IP camera with motion detection'), -- ID = 08
('DOOR_SENSOR', 'Door Sensor - Magnetic contact sensor for doors and windows'), -- ID = 09
('GARAGE_DOOR', 'Garage Door Controller - Smart garage door opener'); -- ID = 10

-- Insert event types
INSERT INTO [dbo].[EventTypes] (EventTypeName, EventTypeDescription)
VALUES 
('REGISTER', 'Register (True/False)'), -- ID = 01   
('ACTIVATE', 'Activate (True/False)'), -- ID = 02
('CREATE_TOKEN', 'Create a token (True/False)'), -- ID = 03
('ERROR', 'Error Condition'), -- ID = 04
('NOTE', 'Text Note'), -- ID = 05
('VALUE_CHANGE', 'Get ControlValueID'); -- ID = 06

-- Insert event values for each event type, This has a link to the ControlValues table,
-- Any new values beyond ID 31 must be added to the ControlValues table first.
INSERT INTO [dbo].[EventValues] (EventValue, EventValueDescription, EventTypeID)
VALUES 

-- Register values
('REGISTERED', 'Device is registered', 1), -- ID = 01
('UNREGISTERED', 'Device is unregistered', 1), -- ID = 02
('FUTURE_1', 'Not Used', 1), -- ID = 03
('FUTURE_2', 'Not Used', 1), -- ID = 04

-- Activate values
('ACTIVATED', 'Device is active', 2), -- ID = 05
('DEACTIVATED', 'Device is deactivated', 2), -- ID = 06
('FUTURE_1', 'Not Used', 2), -- ID = 07
('FUTURE_2', 'Not Used', 2), -- ID = 08

-- Create Token values
('ISSUED', 'Token Issued', 3), -- ID = 09
('EXPIRED', 'Token Expired', 3), -- ID = 10
('FUTURE_1', 'Not Used', 3), -- ID = 11
('FUTURE_2', 'Not Used', 3), -- ID = 12

-- Error values
('ERROR_LOW_BATTERY', 'Device battery is low', 4), -- ID = 13
('ERROR_CONNECTION', 'Device connection error', 4), -- ID = 14
('ERROR_SENSOR', 'Device sensor error', 4), -- ID = 15
('FUTURE_ERROR_1', 'Not Used', 4), -- ID = 16
('FUTURE_ERROR_2', 'Not Used', 4), -- ID = 17
('FUTURE_ERROR_3', 'Not Used', 4), -- ID = 18
('FUTURE_ERROR_4', 'Not Used', 4), -- ID = 19
('FUTURE_ERROR_5', 'Not Used', 4), -- ID = 20

-- Note values
('LOG_ENTRY', 'Log Entry', 5), -- ID = 21
('MAINTENANCE', 'Regular maintenance', 5), -- ID = 22
('NOTE_2', 'User note 02', 5), -- ID = 23
('NOTE_3', 'User note 03', 5), -- ID = 24
('NOTE_4', 'User note 04', 5), -- ID = 25
('NOTE_5', 'User note 05', 5), -- ID = 26
('NOTE_6', 'User note 06', 5), -- ID = 27
('NOTE_7', 'User note 07', 5), -- ID = 28
('NOTE_8', 'User note 08', 5), -- ID = 29
('NOTE_9', 'User note 09', 5), -- ID = 30

-- State Change values (ID = 31 onwards). They are all eveny type ID 6
('31', 'LOCKED', 6), -- ID = 31
('32', 'UNLOCKED', 6), -- ID = 32
('33', 'OPEN', 6), -- ID = 33
('34', 'CLOSED', 6), -- ID = 34
('35', 'OPEN', 6), -- ID = 35
('36', 'CLOSE', 6), -- ID = 36
('37', 'ENABLE', 6), -- ID = 37
('38', 'DISABLE', 6), -- ID = 38
('39', 'LOCKED', 6), -- ID = 39
('40', 'UNLOCKED', 6), -- ID = 40
('41', 'TEMP_GET_20', 6), -- ID = 41
('42', 'TEMP_GET_21', 6), -- ID = 42
('43', 'TEMP_GET_22', 6), -- ID = 43
('44', 'TEMP_GET_23', 6), -- ID = 44
('45', 'TEMP_GET_24', 6), -- ID = 45
('46', 'TEMP_GET_25', 6), -- ID = 46
('47', 'TEMP_GET_26', 6), -- ID = 47
('48', 'TEMP_GET_27', 6), -- ID = 48
('49', 'TEMP_SET_20', 6), -- ID = 49
('50', 'TEMP_SET_21', 6), -- ID = 50
('51', 'TEMP_SET_22', 6), -- ID = 51
('52', 'TEMP_SET_23', 6), -- ID = 52
('53', 'TEMP_SET_24', 6), -- ID = 53
('54', 'TEMP_SET_25', 6), -- ID = 54
('55', 'TEMP_SET_26', 6), -- ID = 55
('56', 'TEMP_SET_27', 6); -- ID = 56

-- Insert functions
INSERT INTO [dbo].[Functions] (FunctionName, FunctionDescription, InputCount)
VALUES 
('MASTER', 'Default', 1), -- ID = 01
('LOCK_DOOR', 'Lock a door device', 1), -- ID = 02 (true/false)
('OPEN_GAS_VALVE', 'Open a gas valve device', 1), -- ID = 03 (true/false)
('OPEN_WATER_VALVE', 'Open a water valve device', 1), -- ID = 04 (true/false)
('ENABLE_SMOKE_DETECTOR', 'Enable a smoke detector device', 1), -- ID = 05 (true/false)
('SET_TEMPERATURE', 'Set a temperature', 1), -- ID = 06 (int)
('GET_TEMPERATURE', 'Get a temperature', 0), -- ID = 07 (int)
('GET_LOCK_STATE', 'Get a lock state', 0); -- ID = 08 (int)

-- Insert locations
INSERT INTO [dbo].[Locations] (Name, StreetAddress, GeoLocation, CreatedByUserID)
VALUES 
('Home', '123 Main St, City', '6.9271,79.8612', 1),
('Office', '456 Business Ave, City', '6.9271,79.8612', 1),
('Garage', '789 Parking Rd, City', '6.9271,79.8612', 1);

-- Insert control types
INSERT INTO [dbo].[ControlTypes] (ControlTypeName, ControlTypeDescription, ControlFunctionID)
VALUES 
('MASTER', 'Default', 1), -- ID = 01
('SIMPLE_LOCK', 'Simple Lock', 2), -- ID = 02
('GAS_VALVE', 'Gas Valve', 3), -- ID = 03 
('WATER_VALVE', 'Water Valve', 4), -- ID = 04
('SMOKE_DETECTOR', 'Smoke Detector', 5), -- ID = 05
('LOCK_STATE', 'Lock State', 6 ), -- ID = 06
('TEMPERATURE_SENSOR', 'Temperature Sensor', 7), -- ID = 07
('TEMPERATURE_CONTROL', 'Temperature Control', 8); -- ID = 08

-- Insert control values
INSERT INTO [dbo].[ControlValues] (ControlValue, ActionText, Unit, ValueDescription, ControlTypeID)
VALUES 

-- master control values
('REGISTER', 'Register', NULL, 'Register the device', 1), -- ID = 01
('UNREGISTER', 'Unregister', NULL, 'Unregister the device', 1), -- ID = 02
-- reserved values
('RESERVED_1', 'Not Used', NULL, 'Not Used', 1), -- ID = 03
('RESERVED_2', 'Not Used', NULL, 'Not Used', 1), -- ID = 04
-- master control values
('ACTIVE', 'Activate', NULL, 'Activate the device', 1), -- ID = 05
('DEACTIVE', 'Deactivate', NULL, 'Deactivate the device', 1), -- ID = 06
-- reserved values
('RESERVED_3', 'Not Used', NULL, 'Not Used', 1), -- ID = 05
('RESERVED_4', 'Not Used', NULL, 'Not Used', 1), -- ID = 06
('RESERVED_5', 'Not Used', NULL, 'Not Used', 1), -- ID = 07
('RESERVED_6', 'Not Used', NULL, 'Not Used', 1), -- ID = 08
('RESERVED_7', 'Not Used', NULL, 'Not Used', 1), -- ID = 09
('RESERVED_8', 'Not Used', NULL, 'Not Used', 1), -- ID = 10
('RESERVED_9', 'Not Used', NULL, 'Not Used', 1), -- ID = 11
('RESERVED_10', 'Not Used', NULL, 'Not Used', 1), -- ID = 12
('RESERVED_11', 'Not Used', NULL, 'Not Used', 1), -- ID = 13
('RESERVED_12', 'Not Used', NULL, 'Not Used', 1), -- ID = 14
('RESERVED_13', 'Not Used', NULL, 'Not Used', 1), -- ID = 15
('RESERVED_14', 'Not Used', NULL, 'Not Used', 1), -- ID = 16
('RESERVED_15', 'Not Used', NULL, 'Not Used', 1), -- ID = 17
('RESERVED_16', 'Not Used', NULL, 'Not Used', 1), -- ID = 18
('RESERVED_17', 'Not Used', NULL, 'Not Used', 1), -- ID = 19
('RESERVED_18', 'Not Used', NULL, 'Not Used', 1), -- ID = 20
('RESERVED_19', 'Not Used', NULL, 'Not Used', 1), -- ID = 21
('RESERVED_20', 'Not Used', NULL, 'Not Used', 1), -- ID = 22
('RESERVED_21', 'Not Used', NULL, 'Not Used', 1), -- ID = 23
('RESERVED_22', 'Not Used', NULL, 'Not Used', 1), -- ID = 24
('RESERVED_23', 'Not Used', NULL, 'Not Used', 1), -- ID = 25
('RESERVED_24', 'Not Used', NULL, 'Not Used', 1), -- ID = 26
('RESERVED_25', 'Not Used', NULL, 'Not Used', 1), -- ID = 27
('RESERVED_26', 'Not Used', NULL, 'Not Used', 1), -- ID = 28
('RESERVED_27', 'Not Used', NULL, 'Not Used', 1), -- ID = 29
('RESERVED_28', 'Not Used', NULL, 'Not Used', 1), -- ID = 30

-- Door Lock Values
('LOCKED', 'LOCK', NULL, 'Lock the door', 2), -- ID = 31
('UNLOCKED', 'UNLOCK', NULL, 'Unlock the door', 2), -- ID = 32

-- Gas Valve Values
('OPEN', 'OPEN', NULL, 'Open the gas valve', 3), -- ID = 33
('CLOSED', 'CLOSE', NULL, 'Close the gas valve', 3), -- ID = 34

-- Water Valve Values
('OPEN', 'OPEN', NULL, 'Open the water valve', 4), -- ID = 35
('CLOSED', 'CLOSE', NULL, 'Close the water valve', 4), -- ID = 36

-- Smoke Detector Values
('ENABLED', 'ENABLE', NULL, 'Enable the smoke detector', 5), -- ID = 37
('DISABLED', 'DISABLE', NULL, 'Disable the smoke detector', 5), -- ID = 38

-- Lock State Values, this is a read only value, so no action text
('LOCKED', NULL, NULL, 'Lock the door', 6), -- ID = 39
('UNLOCKED', NULL, NULL, 'Unlock the door', 6), -- ID = 40

-- Temperature Sensor Values, read only
('20', NULL, 'deg C', 'Temperature', 7), -- ID = 41
('21', NULL, 'deg C', 'Temperature', 7), -- ID = 42
('22', NULL, 'deg C', 'Temperature', 7), -- ID = 43
('23', NULL, 'deg C', 'Temperature', 7), -- ID = 44
('24', NULL, 'deg C', 'Temperature', 7), -- ID = 45
('25', NULL, 'deg C', 'Temperature', 7), -- ID = 46
('26', NULL, 'deg C', 'Temperature', 7), -- ID = 47
('27', NULL, 'deg C', 'Temperature', 7), -- ID = 48

-- Temperature Control Values
('20', '20', 'deg C', 'Temperature', 8), -- ID = 49
('21', '21', 'deg C', 'Temperature', 8), -- ID = 50
('22', '22', 'deg C', 'Temperature', 8), -- ID = 51
('23', '23', 'deg C', 'Temperature', 8), -- ID = 52
('24', '24', 'deg C', 'Temperature', 8), -- ID = 53
('25', '25', 'deg C', 'Temperature', 8), -- ID = 54
('26', '26', 'deg C', 'Temperature', 8), -- ID = 55
('27', '27', 'deg C', 'Temperature', 8); -- ID = 56

-- Insert devices
INSERT INTO [dbo].[Devices] (SerialNumber, DeviceTypeID, DeviceName, DeviceDescription, CreatedUserID, OwnerID, LocationID, PortID, LockPin, MacAddress)
VALUES 
('DL001', 1, 'Front Door', 'Main entrance door lock', 1, 1, 1, 9000, 1234, '00:11:22:33:44:55'), -- ID = 01
('DL002', 1, 'Back Door', 'Back entrance door lock', 1, 1, 1, 9000, 5678, '00:11:22:33:44:66'), -- ID = 02 
('GV001', 5, 'Main Gas Valve', 'Main gas supply valve', 1, 1, 1, 9000, NULL, '00:11:22:33:44:77'), -- ID = 03  
('WV001', 4, 'Main Water Valve', 'Main water supply valve', 1, 1, 1, 9000, NULL, '00:11:22:33:44:88'), -- ID = 04  
('SD001', 6, 'Kitchen Smoke Detector', 'Kitchen area smoke detector', 1, 1, 1, 9000, NULL, '00:11:22:33:44:99'), -- ID = 05    
('TS001', 7, 'Living Room Temperature', 'Living room temperature Control', 1, 1, 1, 9000, NULL, '00:11:22:33:44:AA'), -- ID = 06 
('SC001', 8, 'Front Camera', 'Front door security camera', 1, 1, 1, 9000, NULL, '00:11:22:33:44:BB'), -- ID = 07   
('DS001', 9, 'Garage Door Sensor', 'Garage door magnetic sensor', 1, 1, 2, 9001, NULL, '00:11:22:33:44:CC'), -- ID = 08
('GD001', 10, 'Garage Door', 'Garage door controller', 1, 1, 2, 9001, 2876, '00:11:22:33:44:DD'); -- ID = 09

-- Insert controls
INSERT INTO [dbo].[Controls] (ControlName, ControlDescription, ControlTypeID, DeviceID)
VALUES 
-- Front Door
('MASTER', 'Master Lock', 1, 1), -- ID = 01
('SIMPLE_LOCK', 'Simple Lock', 2, 1), -- ID = 02
-- Back Door
('MASTER','Master Lock', 1, 2), -- ID = 03
('SIMPLE_LOCK', 'Simple Lock', 2, 2), -- ID = 04
-- Main Gas Valve
('MASTER','Master Gas Valve', 1, 3), -- ID = 05
('GAS_VALVE', 'Gas Valve', 3, 3), -- ID = 06
-- Main Water Valve
('MASTER','Master Water Valve', 1, 4), -- ID = 07
('WATER_VALVE', 'Water Valve', 4, 4), -- ID = 08
-- Kitchen Smoke Detector
('MASTER','Master Smoke Detector', 1, 5), -- ID = 09
('SMOKE_DETECTOR', 'Smoke Detector', 5, 5), -- ID = 10
-- Living Room Temperature Sensor 
('MASTER','Master Temperature Sensor', 1, 6), -- ID = 11
('TEMPERATURE_SENSOR', 'Temperature Sensor', 7, 6), -- ID = 12
('TEMPERATURE_CONTROL', 'Temperature Control', 8, 6); -- ID = 13

-- Insert events
INSERT INTO [dbo].[Events] (EventValueID, EventDescription, EventData, ControlID, CreatedUserID, EventDateTime)
VALUES 
-- State changes for Front Door
(1, 'Device registered by admin', NULL, 1, 1, DATEADD(DAY, -1, GETDATE())),
(5, 'Device activated by admin', NULL, 1, 1, DATEADD(MINUTE, 10, DATEADD(DAY, -1, GETDATE()))),
(31, 'Door locked by admin', NULL, 2, 1, DATEADD(MINUTE, 20, DATEADD(DAY, -1, GETDATE()))),
(32, 'Door unlocked by admin', NULL, 2, 1, DATEADD(MINUTE, 30, DATEADD(DAY, -1, GETDATE()))),

-- Gas Valve events
(1, 'Device registered by admin', NULL, 5, 1, DATEADD(MINUTE, 40, DATEADD(DAY, -1, GETDATE()))),
(5, 'Device activated by admin', NULL, 5, 1, DATEADD(MINUTE, 50, DATEADD(DAY, -1, GETDATE()))),
(33, 'Gas valve opened by admin', NULL, 6, 1, DATEADD(MINUTE, 60, DATEADD(DAY, -1, GETDATE()))),

-- Water Valve events
(1, 'Device registered by admin', NULL, 7, 1, DATEADD(MINUTE, 70, DATEADD(DAY, -1, GETDATE()))),
(5, 'Device activated by admin', NULL, 7, 1, DATEADD(MINUTE, 80, DATEADD(DAY, -1, GETDATE()))),
(35, 'Water valve opened by admin', NULL, 8, 1, DATEADD(MINUTE, 90, DATEADD(DAY, -1, GETDATE()))),
(36, 'Water valve closed by admin', NULL, 8, 1, DATEADD(MINUTE, 100, DATEADD(DAY, -1, GETDATE()))),
(6, 'Device deactivated by admin', NULL, 8, 1, DATEADD(MINUTE, 110, DATEADD(DAY, -1, GETDATE()))),

-- Smoke Detector events
(1, 'Device registered by admin', NULL, 9, 1, DATEADD(MINUTE, 120, DATEADD(DAY, -1, GETDATE()))),
(5, 'Device activated by admin', NULL, 9, 1, DATEADD(MINUTE, 130, DATEADD(DAY, -1, GETDATE()))),
(37, 'Smoke detector enabled by admin', NULL, 10, 1, DATEADD(MINUTE, 140, DATEADD(DAY, -1, GETDATE()))),
(13, 'Low battery warning', NULL, 10, 1, DATEADD(MINUTE, 150, DATEADD(DAY, -1, GETDATE()))),
(14, 'Connection error detected', NULL, 10, 1, DATEADD(MINUTE, 160, DATEADD(DAY, -1, GETDATE()))),

-- Living Room Temperature Sensor 
(1, 'Device registered by admin', NULL, 11, 1, DATEADD(MINUTE, 170, DATEADD(DAY, -1, GETDATE()))),
(5, 'Device activated by admin', NULL, 11, 1, DATEADD(MINUTE, 180, DATEADD(DAY, -1, GETDATE()))),
(13, 'Low battery warning', NULL, 12, 1, DATEADD(MINUTE, 190, DATEADD(DAY, -1, GETDATE()))),
(22, 'Regular maintenance completed', '9V Battery', 12, 1, DATEADD(MINUTE, 200, DATEADD(DAY, -1, GETDATE()))),
(37, 'Smoke detector Enabled by admin', NULL, 13, 1, DATEADD(MINUTE, 210, DATEADD(DAY, -1, GETDATE())));