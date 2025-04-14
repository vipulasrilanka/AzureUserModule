-- Drop all views first
IF EXISTS (SELECT * FROM sys.views WHERE name = 'LatestValueChanges' AND schema_id = SCHEMA_ID('dbo'))
    DROP VIEW [dbo].[LatestValueChanges];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'DeviceMasterStates' AND schema_id = SCHEMA_ID('dbo'))
    DROP VIEW [dbo].[DeviceMasterStates];
    
-- Drop existing tables in reverse dependency order
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Events' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[Events];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Controls' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[Controls];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Devices' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[Devices];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ControlValues' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[ControlValues];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EventValues' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[EventValues];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserPasswords' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[UserPasswords];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Locations' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[Locations];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ControlTypes' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[ControlTypes];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'EventTypes' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[EventTypes];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Functions' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[Functions];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'DeviceTypes' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[DeviceTypes];

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Users' AND schema_id = SCHEMA_ID('dbo'))
    DROP TABLE [dbo].[Users];

-- This file has all the details about the database
-- There are multiple tables, and views, and below are the explainaitons.

-- First create tables with no foreign key dependencies
-- Users, Table. This as the data about users. This does not have external links.
CREATE TABLE [dbo].[Users] (
    UserID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserName VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    FirstName VARCHAR(MAX) NOT NULL,
    LastName VARCHAR(MAX) NOT NULL,
    NICNumber VARCHAR(20) NOT NULL,
    Birthday DATE NOT NULL,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE()
);

-- Functions List of functions that can be called by controllers, when a value change 
-- happens. 
CREATE TABLE [dbo].[Functions] (
    FunctionID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FunctionName VARCHAR(50) NOT NULL UNIQUE, -- Increased from 20 to 50
    FunctionDescription VARCHAR(MAX) NOT NULL, -- what does this do
    InputCount INT NOT NULL, -- number of inputs it can take.
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE()
);

-- EventTypes, Controller value Change (comes from controller value change), 
-- Activate (true/false), Register (true/false), Error, Note (which can hold a custom text)
CREATE TABLE [dbo].[EventTypes] (
    EventTypeID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    EventTypeName VARCHAR(50) NOT NULL UNIQUE,
    EventTypeDescription VARCHAR(MAX) NOT NULL
);

-- DeviceTypes, Device types like Door lock, Gas Valve,..etc
CREATE TABLE [dbo].[DeviceTypes] (
    DeviceTypeID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL UNIQUE,
    TypeDescription VARCHAR(MAX) NOT NULL
);

-- Now create tables that depend on the above tables
-- UserPasswords, Table, This holds the password hash and other data related to login.
CREATE TABLE [dbo].[UserPasswords] (
    UserID INT NOT NULL PRIMARY KEY,
    PasswordHash VARCHAR(64) NOT NULL,  -- SHA-256 hash is 64 characters
    ResetFunctionInput VARCHAR(MAX) NOT NULL, -- excrypted input to the reset option
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES [dbo].[Users](UserID)
);

-- ControlTypes, Each control can have one type, like a toggle, linear, multi stage..etc.
CREATE TABLE [dbo].[ControlTypes] (
    ControlTypeID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ControlTypeName VARCHAR(50) NOT NULL UNIQUE,
    ControlTypeDescription VARCHAR(MAX) NOT NULL,
    ControlFunctionID INT NOT NULL,
    FOREIGN KEY (ControlFunctionID) REFERENCES [dbo].[Functions](FunctionID)
);

-- ControlValues, Each control can have one value at a time. Each control type will have
-- a list of values, that is supported by the control type. For an example, a switch can have on/off
-- and enable/disable values. 
CREATE TABLE [dbo].[ControlValues] (
    ControlValueID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ControlValue VARCHAR(50) NOT NULL,
    ActionText VARCHAR(50) NULL,
    Unit VARCHAR(20) NULL,
    ValueDescription VARCHAR(MAX) NULL,
    ControlTypeID INT NOT NULL,
    FOREIGN KEY (ControlTypeID) REFERENCES [dbo].[ControlTypes](ControlTypeID)
);

-- EventValues for each event type, there are multiple valid values. 
-- For value change, they come from Control values, but for Register..etc it can be limited to 
-- true/false. This table has the acceptable value list for all Event Types.
CREATE TABLE [dbo].[EventValues] (
    EventValueID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    EventValue VARCHAR(20) NOT NULL,
    EventValueDescription VARCHAR(MAX) NOT NULL,
    EventTypeID INT NOT NULL,
    FOREIGN KEY (EventTypeID) REFERENCES [dbo].[EventTypes](EventTypeID)
);

-- Locations location of the devices.
CREATE TABLE [dbo].[Locations] (
    LocationID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    StreetAddress VARCHAR(MAX) NOT NULL,
    GeoLocation VARCHAR(100) NULL,  -- Store as "latitude,longitude"
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedByUserID INT NOT NULL,
    FOREIGN KEY (CreatedByUserID) REFERENCES [dbo].[Users](UserID)
);

-- Devices List of devices
CREATE TABLE [dbo].[Devices] (
    DeviceID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    SerialNumber VARCHAR(20) NOT NULL,
    DeviceTypeID INT NOT NULL,
    DeviceName VARCHAR(32) NULL,
    DeviceDescription VARCHAR(MAX) NULL,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedUserID INT NULL,
    OwnerID INT NULL,
    LocationID INT NULL,
    PortID INT NULL,
    LockPin INT NULL,
    MacAddress VARCHAR(17) NULL,
    FOREIGN KEY (OwnerID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (CreatedUserID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (LocationID) REFERENCES [dbo].[Locations](LocationID),
    FOREIGN KEY (DeviceTypeID) REFERENCES [dbo].[DeviceTypes](DeviceTypeID)
);

-- Control, Each Device can have one or more controls. Controls are unique, so each control
-- will have a unique ID, and will be attached to one device. Each controller will have a value at 
-- given time. This is not a property of the control, so has to be derived from events. will not 
-- store it here.
CREATE TABLE [dbo].[Controls] (
    ControlID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ControlName VARCHAR(50) NOT NULL, -- name of the control, does not have to be unique
    ControlDescription VARCHAR(MAX) NOT NULL,
    ControlTypeID INT NOT NULL, -- which type of control this is
    DeviceID INT NOT NULL, -- which device this control belongs to
    FOREIGN KEY (DeviceID) REFERENCES [dbo].[Devices](DeviceID),
    FOREIGN KEY (ControlTypeID) REFERENCES [dbo].[ControlTypes](ControlTypeID)
);

-- Events List of all events. 
CREATE TABLE [dbo].[Events] (
    EventID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    EventValueID INT NOT NULL,
    EventDescription VARCHAR(MAX) NULL,
    EventData VARCHAR(MAX) NULL,
    ControlID INT NULL,
    CreatedUserID INT NOT NULL,
    EventDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    EventExpireDateTime DATETIME NULL,
    FOREIGN KEY (ControlID) REFERENCES [dbo].[Controls](ControlID),
    FOREIGN KEY (CreatedUserID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (EventValueID) REFERENCES [dbo].[EventValues](EventValueID)
);
