CREATE VIEW [dbo].[LatestValueChanges] AS
WITH LatestEvents AS (
    SELECT 
        e.ControlID,
        MAX(e.EventDateTime) as LatestEventTime
    FROM [dbo].[Events] e
    JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
    JOIN [dbo].[EventTypes] et ON ev.EventTypeID = et.EventTypeID
    WHERE et.EventTypeName = 'VALUE_CHANGE'
    GROUP BY e.ControlID
)
SELECT 
    d.DeviceID,
    d.SerialNumber,
    d.DeviceName,
    dt.TypeName as DeviceType,
    d.OwnerID as DeviceOwnerID,
    ou.UserName as DeviceOwnerName,
    c.ControlID,
    c.ControlName,
    c.ControlDescription,
    ct.ControlTypeName,
    e.EventID,
    e.EventDateTime,
    ev.EventValue,
    ev.EventValueDescription
FROM LatestEvents le
JOIN [dbo].[Events] e ON e.ControlID = le.ControlID AND e.EventDateTime = le.LatestEventTime
JOIN [dbo].[Controls] c ON e.ControlID = c.ControlID
JOIN [dbo].[Devices] d ON c.DeviceID = d.DeviceID
JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
JOIN [dbo].[ControlTypes] ct ON c.ControlTypeID = ct.ControlTypeID
JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
JOIN [dbo].[EventTypes] et ON ev.EventTypeID = et.EventTypeID
LEFT JOIN [dbo].[Users] ou ON d.OwnerID = ou.UserID
WHERE et.EventTypeName = 'VALUE_CHANGE';

GO

CREATE VIEW [dbo].[DeviceMasterStates] AS
WITH MasterControls AS (
    SELECT 
        c.ControlID,
        c.DeviceID,
        c.ControlName
    FROM [dbo].[Controls] c
    JOIN [dbo].[ControlTypes] ct ON c.ControlTypeID = ct.ControlTypeID
    WHERE ct.ControlTypeName = 'MASTER'
),
LatestMasterEvents AS (
    SELECT 
        mc.DeviceID,
        mc.ControlID,
        MAX(e.EventDateTime) as LatestEventTime
    FROM MasterControls mc
    JOIN [dbo].[Events] e ON mc.ControlID = e.ControlID
    GROUP BY mc.DeviceID, mc.ControlID
)
SELECT 
    d.DeviceID,
    d.SerialNumber,
    d.DeviceName,
    dt.TypeName as DeviceType,
    d.OwnerID as DeviceOwnerID,
    ou.UserName as DeviceOwnerName,
    mc.ControlID as MasterControlID,
    e.EventID,
    e.EventDateTime,
    ev.EventValue as MasterState,
    ev.EventValueDescription as StateDescription,
    u.UserName as LastUpdatedBy
FROM LatestMasterEvents lme
JOIN [dbo].[Events] e ON e.ControlID = lme.ControlID AND e.EventDateTime = lme.LatestEventTime
JOIN MasterControls mc ON e.ControlID = mc.ControlID
JOIN [dbo].[Devices] d ON mc.DeviceID = d.DeviceID
JOIN [dbo].[DeviceTypes] dt ON d.DeviceTypeID = dt.DeviceTypeID
JOIN [dbo].[EventValues] ev ON e.EventValueID = ev.EventValueID
JOIN [dbo].[Users] u ON e.CreatedUserID = u.UserID
LEFT JOIN [dbo].[Users] ou ON d.OwnerID = ou.UserID
WHERE e.ControlID IN (
    SELECT c.ControlID 
    FROM [dbo].[Controls] c 
    JOIN [dbo].[ControlTypes] ct ON c.ControlTypeID = ct.ControlTypeID 
    WHERE ct.ControlTypeName = 'MASTER'
);
