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