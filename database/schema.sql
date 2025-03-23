-- This file has all the details about the database
-- There are multiple tables, and views, and below are the explainaitons.



-- [dbo].[Users], Table. This as the data about users. This does not have external links.
CREATE TABLE [dbo].[Users] (
    UserID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    UserName VARCHAR(20) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(MAX) NOT NULL,
    LastName NVARCHAR(MAX) NOT NULL,
    NICNumber VARCHAR(20) NOT NULL,
    Birthday DATE NOT NULL,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
);

-- [db0].[UserPasswords], Table, This holds the password hash and other data related to login.
CREATE TABLE [dbo].[UserPasswords] (
    UserID INT NOT NULL PRIMARY KEY,
    PasswordHash NVARCHAR(64) NOT NULL,  -- SHA-256 hash is 64 characters
    ResetFunctionInput NVARCHAR(MAX) NOT NULL, -- excrypted input to the reset option
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES [dbo].[Users](UserID)
);

-- [dbo].[DeviceTypes], Device types like Door lock, Gas Valve,..etc
CREATE TABLE [dbo].[DeviceTypes] (
    DeviceTypeID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    TypeDescription NVARCHAR(MAX) NOT NULL,
);

-- [dbo].[EventTypes], State Change (comes from device status), Activate (true/false), 
-- Register (true/false), Error, Note (which can hold a custom text)
CREATE TABLE [dbo].[EventTypes] (
    EventTypeID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    EventTypeName NVARCHAR(50) NOT NULL UNIQUE,
    EventTypeDescription NVARCHAR(MAX) NOT NULL,
);

-- [dbo].[EventValues] for each event type, there are multiple valid values. 
-- For State change, they come from Device status, but for Register..etc it can be limited to 
-- true/false. This table has the acceptable value list for all Event Types.
CREATE TABLE [dbo].[EventValues] (
    EventValueID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    EventValue NVARCHAR(20) NOT NULL,
    EventValueDescription NVARCHAR(MAX) NOT NULL,
    EventTypeID INT NOT NULL,
    FOREIGN KEY (EventTypeID) REFERENCES [dbo].[EventTypes](EventTypeID)
);

-- [dbo].[Functions] List of functions that can be called by devices, when a state change 
-- happens. 
CREATE TABLE [dbo].[Functions] (
    FunctionID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    FunctionName VARCHAR(20) NOT NULL UNIQUE,
    FunctionDescription NVARCHAR(MAX) NOT NULL, -- what does this do
    InputCount INT NOT NULL, -- number of inputs it can take.
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE()
);

-- [dbo].[StateChangeTypes] applicable State types for each device type. This will be 
-- the same that we record in events under normal STATE_CHANGE. For each device 
-- there will be a list of states, for example, a type DOOR_LOCK can have LOCK, 
-- UNLOCK, ENABLE and DISABLE. 
CREATE TABLE [dbo].[StateChangeTypes] (
    StateTypeID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    StateChangeName NVARCHAR(20) NOT NULL,
    ActionText NVARCHAR(30) NOT NULL,
    StateSetTo NVARCHAR(30) NOT NULL,
    DeviceTypeID INT NOT NULL,
    FunctionID INT NULL,
    FOREIGN KEY (DeviceTypeID) REFERENCES [dbo].[DeviceTypes](DeviceTypeID),
    FOREIGN KEY (FunctionID) REFERENCES [dbo].[Functions](FunctionID)
);


-- [dbo].[Locations] location of the devices.
CREATE TABLE [dbo].[Locations] (
    LocationID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    StreetAddress NVARCHAR(MAX) NOT NULL,
    GeoLocation NVARCHAR(100) NULL,  -- Store as "latitude,longitude"
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedByUserID INT NOT NULL,
    FOREIGN KEY (CreatedByUserID) REFERENCES [dbo].[Users](UserID)
);

-- [dbo].[DeviceStates] The sates a given device can be, These are "PENDING", "REGISTERD",
-- "ACTIVE", "DEACTIVATED", "REJECTED", .etc.
CREATE TABLE [dbo].[DeviceStates] (
    DeviceStateID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    StateName NVARCHAR(20) NOT NULL,
    StateDescription NVARCHAR(MAX) NOT NULL,
)

-- [dbo].[Devices] List of devices
CREATE TABLE [dbo].[Devices] (
    DeviceID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    SerialNumber VARCHAR(20) NOT NULL,
    DeviceTypeID INT NOT NULL,
    DeviceName VARCHAR(32) NULL,
    DeviceDescription NVARCHAR(MAX) NULL,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedUserID INT NULL,
    LocationID INT NULL,
    DeviceStateID INT NOT NULL,
    PortID INT NULL,
    LockPin INT NULL,
    MacAddress CHAR(17) NULL,
    FOREIGN KEY (CreatedUserID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (LocationID) REFERENCES [dbo].[Locations](LocationID),
    FOREIGN KEY (DeviceTypeID) REFERENCES [dbo].[DeviceTypes](DeviceTypeID),
    FOREIGN KEY (DeviceStateID) REFERENCES [dbo].[DeviceStates](DeviceStateID)
);

-- [dbo].[Events] List of all events. 
CREATE TABLE [dbo].[Events] (
    EventID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    EventValueID INT NOT NULL,
    EventDescription NVARCHAR(MAX) NULL,
    DeviceID INT NULL,
    CreatedUserID INT NOT NULL,
    EventDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (DeviceID) REFERENCES [dbo].[Devices](DeviceID),
    FOREIGN KEY (CreatedUserID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (EventValueID) REFERENCES [dbo].[EventValues](EventValueID)
);
