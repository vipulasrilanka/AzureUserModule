-- Drop all views first
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_LatestEvents')
    DROP VIEW [dbo].[vw_LatestEvents];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_AllEvents')
    DROP VIEW [dbo].[vw_AllEvents];
GO

-- Drop all foreign key constraints first
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
FROM sys.foreign_keys;
EXEC sp_executesql @sql;
GO

-- Drop all tables in the correct order (child tables first)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Events]') AND type in (N'U'))
    DROP TABLE [dbo].[Events];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EventValues]') AND type in (N'U'))
    DROP TABLE [dbo].[EventValues];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EventTypes]') AND type in (N'U'))
    DROP TABLE [dbo].[EventTypes];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StateChangeTypes]') AND type in (N'U'))
    DROP TABLE [dbo].[StateChangeTypes];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Functions]') AND type in (N'U'))
    DROP TABLE [dbo].[Functions];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Devices]') AND type in (N'U'))
    DROP TABLE [dbo].[Devices];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeviceStates]') AND type in (N'U'))
    DROP TABLE [dbo].[DeviceStates];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeviceTypes]') AND type in (N'U'))
    DROP TABLE [dbo].[DeviceTypes];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND type in (N'U'))
    DROP TABLE [dbo].[Locations];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserPasswords]') AND type in (N'U'))
    DROP TABLE [dbo].[UserPasswords];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
    DROP TABLE [dbo].[Users];
GO