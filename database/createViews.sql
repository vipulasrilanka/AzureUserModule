-- Create view for all events with details
CREATE VIEW [dbo].[vw_AllEvents] AS
SELECT 
    e.EventID,
    e.EventDateTime,
    ev.EventValue,
    ev.EventValueDescription as EventValueDescription,
    e.EventDescription,
    d.DeviceName,
    d.SerialNumber as DeviceSerialNumber,
    dt.TypeName as DeviceType,
    l.Name as LocationName,
    u.UserName as CreatedByUser
FROM [dbo].[Events] e
INNER JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
INNER JOIN [dbo].[Users] u ON e.CreatedUserID = u.UserID
LEFT JOIN [dbo].[Devices] d ON e.DeviceID = d.DeviceID
LEFT JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
LEFT JOIN [dbo].[Locations] l ON d.LocationID = l.LocationID;
GO

-- view with last occured events for all devices.
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
    ev.EventValue as CurrentStatus,
    ev.EventValueDescription as EventValueDescription,
    e.EventDescription,
    d.DeviceID,
    d.DeviceName,
    d.CreatedUserID as DeviceOwner,
    d.SerialNumber as DeviceSerialNumber,
    dt.TypeName as DeviceType,
    dt.DeviceTypeID as TypeID,
    l.Name as LocationName,
    u.UserName as CreatedByUser
FROM LatestEvents le
INNER JOIN [dbo].[Events] e ON le.EventID = e.EventID
INNER JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
INNER JOIN [dbo].[Users] u ON e.CreatedUserID = u.UserID
LEFT JOIN [dbo].[Devices] d ON e.DeviceID = d.DeviceID
LEFT JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
LEFT JOIN [dbo].[Locations] l ON d.LocationID = l.LocationID
WHERE le.RowNum = 1;
GO


-- A view that has all the device, where the staus is active. 