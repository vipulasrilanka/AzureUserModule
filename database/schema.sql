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

CREATE TABLE [dbo].[DeviceTypes] (
    DeviceTypeID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    TypeDescription NVARCHAR(MAX) NOT NULL,
);

CREATE TABLE [dbo].[EventTypes] (
    EventTypeID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    EventTypeName NVARCHAR(50) NOT NULL UNIQUE,
    EventTypeDescription NVARCHAR(MAX) NOT NULL,
);

CREATE TABLE [dbo].[EventValues] (
    EventValueID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    EventValue NVARCHAR(20) NOT NULL,
    EventValueDescription NVARCHAR(MAX) NOT NULL,
    EventTypeID INT NOT NULL,
    FOREIGN KEY (EventTypeID) REFERENCES [dbo].[EventTypes](EventTypeID)
);

CREATE TABLE [dbo].[StateTypes] (
    StateTypeID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    FriendlyName NVARCHAR(20) NOT NULL,
    NameText NVARCHAR(50) NOT NULL,
    StateSetTo NVARCHAR(50) NOT NULL,
    DeviceTypeID INT NOT NULL,
    FunctionID VARCHAR(20) NOT NULL,
    FOREIGN KEY (DeviceTypeID) REFERENCES [dbo].[DeviceTypes](DeviceTypeID)
);

CREATE TABLE [dbo].[Locations] (
    LocationID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    StreetAddress NVARCHAR(MAX) NOT NULL,
    GeoLocation NVARCHAR(100) NULL,  -- Store as "latitude,longitude"
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedByUserID INT NOT NULL,
    FOREIGN KEY (CreatedByUserID) REFERENCES [dbo].[Users](UserID)
);

CREATE TABLE [dbo].[Devices] (
    DeviceID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    SerialNumber VARCHAR(20) NOT NULL,
    DeviceTypeID INT NOT NULL,
    DeviceName VARCHAR(32) NULL,
    DeviceDescription NVARCHAR(MAX) NULL,
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedUserID INT NULL,
    LocationID INT NULL,
    DeviceStatus VARCHAR(8) NULL,
    PortID INT NULL,
    LockPin INT NULL,
    MacAddress CHAR(17) NULL,
    FOREIGN KEY (CreatedUserID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (LocationID) REFERENCES [dbo].[Locations](LocationID),
    FOREIGN KEY (DeviceTypeID) REFERENCES [dbo].[DeviceTypes](DeviceTypeID)
);

CREATE TABLE [dbo].[Events] (
    EventID INT NOT NULL IDENTITY(100000,1) PRIMARY KEY,
    EventTypeID INT NOT NULL,
    EventValueID INT NOT NULL,
    EventDescription NVARCHAR(MAX) NULL,
    DeviceID INT NULL,
    CreatedUserID INT NOT NULL,
    EventDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (DeviceID) REFERENCES [dbo].[Devices](DeviceID),
    FOREIGN KEY (CreatedUserID) REFERENCES [dbo].[Users](UserID),
    FOREIGN KEY (EventTypeID) REFERENCES [dbo].[EventTypes](EventTypeID),
    FOREIGN KEY (EventValueID) REFERENCES [dbo].[EventValues](EventValueID)
);

CREATE TABLE [dbo].[DeviceStates] (
    DeviceStateID INT NOT NULL IDENTITY(100000, 1) PRIMARY KEY,
    DeviceID INT NOT NULL,
    StateValue NVARCHAR(20) NOT NULL,
    StateDescription NVARCHAR(MAX) NOT NULL,
    FOREIGN KEY (DeviceID) REFERENCES [dbo].[Devices](DeviceID),
);

-- Create view for devices with last ON status
CREATE VIEW [dbo].[vw_DevicesLastOffStatus] AS
WITH LastEvents AS (
    SELECT 
        DeviceID,
        EventValueID,
        EventDateTime,
        ROW_NUMBER() OVER (PARTITION BY DeviceID ORDER BY EventDateTime DESC) as RowNum
    FROM [dbo].[Events]
)
SELECT 
    d.DeviceID,
    d.SerialNumber,
    d.DeviceName,
    d.DeviceDescription,
    dt.TypeName as DeviceType,
    l.Name as LocationName,
    d.DeviceStatus,
    ev.EventValue as LastEventValue,
    e.EventDateTime as LastEventTime,
    u.UserName as LastEventUser
FROM [dbo].[Devices] d
INNER JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
INNER JOIN [dbo].[Locations] l ON d.LocationID = l.LocationID
LEFT JOIN LastEvents le ON d.DeviceID = le.DeviceID AND le.RowNum = 1
LEFT JOIN [dbo].[Events] e ON le.DeviceID = e.DeviceID AND le.EventDateTime = e.EventDateTime
LEFT JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
LEFT JOIN [dbo].[Users] u ON e.CreatedUserID = u.UserID
WHERE ev.EventValue = 'OFF';

-- Create view for all events with details
CREATE VIEW [dbo].[vw_AllEvents] AS
SELECT 
    e.EventID,
    e.EventDateTime,
    et.EventTypeName as EventName,
    ev.EventValue,
    ev.EventValueDescription as EventValueDescription,
    e.EventDescription,
    d.DeviceName,
    d.SerialNumber as DeviceSerialNumber,
    dt.TypeName as DeviceType,
    l.Name as LocationName,
    u.UserName as CreatedByUser
FROM [dbo].[Events] e
INNER JOIN [dbo].[EventTypes] et ON e.EventTypeID = et.EventTypeID
INNER JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
INNER JOIN [dbo].[Users] u ON e.CreatedUserID = u.UserID
LEFT JOIN [dbo].[Devices] d ON e.DeviceID = d.DeviceID
LEFT JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
LEFT JOIN [dbo].[Locations] l ON d.LocationID = l.LocationID

SELECT * FROM [dbo].[vw_AllEvents] ORDER BY EventDateTime DESC;

CREATE VIEW [dbo].[vw_LatestEvents] AS
WITH LatestEvents AS (
    SELECT 
        DeviceID,
        EventID,
        EventDateTime,
        ROW_NUMBER() OVER (PARTITION BY DeviceID ORDER BY EventDateTime DESC) as RowNum
    FROM [dbo].[Events]
    WHERE DeviceID IS NOT NULL
)
SELECT 
    e.EventID,
    e.EventDateTime,
    et.EventTypeName as EventName,
    ev.EventValue as CurrentStatus,
    ev.EventValueDescription as EventValueDescription,
    e.EventDescription,
    d.DeviceID,
    d.DeviceName,
    d.CreatedByUserID as DeviceOwner,
    d.SerialNumber as DeviceSerialNumber,
    dt.TypeName as DeviceType,
    dt.DeviceTypeID as TypeID,
    l.Name as LocationName,
    u.UserName as CreatedByUser
FROM LatestEvents le
INNER JOIN [dbo].[Events] e ON le.EventID = e.EventID
INNER JOIN [dbo].[EventTypes] et ON e.EventTypeID = et.EventTypeID
INNER JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
INNER JOIN [dbo].[Users] u ON e.CreatedUserID = u.UserID
LEFT JOIN [dbo].[Devices] d ON e.DeviceID = d.DeviceID
LEFT JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
LEFT JOIN [dbo].[Locations] l ON d.LocationID = l.LocationID
WHERE le.RowNum = 1;

-- Query for Sand Dance visualization
SELECT 
    -- Users table
    u.UserID,
    u.UserName,
    u.Email,
    u.FirstName,
    u.LastName,
    u.NICNumber,
    u.Birthday,
    u.CreatedDateTime as UserCreatedDate,
    
    -- Locations table
    l.LocationID,
    l.Name as LocationName,
    l.StreetAddress,
    l.GeoLocation,
    l.CreatedDateTime as LocationCreatedDate,
    
    -- DeviceTypes table
    dt.DeviceTypeID,
    dt.TypeName as DeviceTypeName,
    dt.TypeDescription as DeviceTypeDescription,
    
    -- Devices table
    d.DeviceID,
    d.SerialNumber,
    d.DeviceName,
    d.DeviceDescription,
    d.CreatedDateTime as DeviceCreatedDate,
    d.DeviceStatus,
    d.PortID,
    d.LockPin,
    d.MacAddress,
    
    -- EventTypes table
    et.EventTypeID,
    et.EventTypeName,
    et.EventTypeDescription,
    
    -- EventValues table
    ev.EventValueID,
    ev.EventValue,
    ev.EventValueDescription,
    
    -- Events table
    e.EventID,
    e.EventDateTime,
    e.EventDescription as EventDescription,
    
    -- StateTypes table
    st.StateTypeID,
    st.FriendlyName as StateName,
    st.NameText as StateText,
    st.StateSetTo,
    st.FunctionID,
    
    -- DeviceStates table
    ds.DeviceStateID,
    ds.StateValue,
    ds.StateDescription

FROM [dbo].[Users] u
INNER JOIN [dbo].[Locations] l ON u.UserID = l.CreatedByUserID
INNER JOIN [dbo].[Devices] d ON u.UserID = d.CreatedUserID
INNER JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
INNER JOIN [dbo].[Events] e ON d.DeviceID = e.DeviceID
INNER JOIN [dbo].[EventTypes] et ON e.EventTypeID = et.EventTypeID
INNER JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
INNER JOIN [dbo].[StateTypes] st ON dt.DeviceTypeID = st.DeviceTypeID
LEFT JOIN [dbo].[DeviceStates] ds ON d.DeviceID = ds.DeviceID
ORDER BY e.EventDateTime DESC;