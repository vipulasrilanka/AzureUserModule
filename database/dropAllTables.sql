-- Drop all foreign key constraints first
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
FROM sys.foreign_keys;
EXEC sp_executesql @sql;

-- Drop tables in correct order (respecting foreign key dependencies)
-- First drop tables that depend on other tables (child tables)
IF OBJECT_ID('[dbo].[Events]', 'U') IS NOT NULL
	DROP TABLE [dbo].[Events];

IF OBJECT_ID('[dbo].[DeviceStates]', 'U') IS NOT NULL
	DROP TABLE [dbo].[DeviceStates];

IF OBJECT_ID('[dbo].[Devices]', 'U') IS NOT NULL
	DROP TABLE [dbo].[Devices];

IF OBJECT_ID('[dbo].[StateTypes]', 'U') IS NOT NULL
	DROP TABLE [dbo].[StateTypes];

IF OBJECT_ID('[dbo].[Locations]', 'U') IS NOT NULL
	DROP TABLE [dbo].[Locations];

IF OBJECT_ID('[dbo].[EventValues]', 'U') IS NOT NULL
	DROP TABLE [dbo].[EventValues];

-- Then drop tables that are referenced by other tables (parent tables)
IF OBJECT_ID('[dbo].[DeviceTypes]', 'U') IS NOT NULL
	DROP TABLE [dbo].[DeviceTypes];

IF OBJECT_ID('[dbo].[EventTypes]', 'U') IS NOT NULL
	DROP TABLE [dbo].[EventTypes];

IF OBJECT_ID('[dbo].[Users]', 'U') IS NOT NULL
	DROP TABLE [dbo].[Users];