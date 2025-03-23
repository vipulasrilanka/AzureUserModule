-- Disable foreign key constraints temporarily
SET NOCOUNT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    -- Declare variables for counts
    DECLARE @EventsCount INT;
    DECLARE @DevicesCount INT;
    DECLARE @LocationsCount INT;
    DECLARE @UsersCount INT;

    -- Log the start of cleanup
    PRINT 'Starting data cleanup...';

    -- Disable foreign key constraints
    EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
    PRINT 'Foreign key constraints disabled.';

    -- Get current record counts
    SELECT @EventsCount = COUNT(*) FROM [dbo].[Events];
    SELECT @DevicesCount = COUNT(*) FROM [dbo].[Devices];
    SELECT @LocationsCount = COUNT(*) FROM [dbo].[Locations];
    SELECT @UsersCount = COUNT(*) FROM [dbo].[Users];

    -- Log current record counts
    PRINT 'Current record counts:';
    PRINT 'Events: ' + CAST(@EventsCount AS VARCHAR(10));
    PRINT 'Devices: ' + CAST(@DevicesCount AS VARCHAR(10));
    PRINT 'Locations: ' + CAST(@LocationsCount AS VARCHAR(10));
    PRINT 'Users: ' + CAST(@UsersCount AS VARCHAR(10));

    -- Delete data from tables in correct order (respecting foreign key dependencies)
    DELETE FROM [dbo].[Events];
    DELETE FROM [dbo].[DeviceState];
    DELETE FROM [dbo].[Devices];
    DELETE FROM [dbo].[StateTypes];
    DELETE FROM [dbo].[Locations];
    DELETE FROM [dbo].[EventTypes];
    DELETE FROM [dbo].[EventValues];
    DELETE FROM [dbo].[DeviceType];
    DELETE FROM [dbo].[Users];

    -- Reset identity values to 99999 (next insert will be 100000)
    DBCC CHECKIDENT ('[dbo].[Events]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[DeviceState]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[Devices]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[StateTypes]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[Locations]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[EventTypes]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[EventValues]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[DeviceType]', RESEED, 99999);
    DBCC CHECKIDENT ('[dbo].[Users]', RESEED, 99999);

    -- Re-enable foreign key constraints
    EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";
    PRINT 'Foreign key constraints re-enabled.';

    -- Get final record counts
    SELECT @EventsCount = COUNT(*) FROM [dbo].[Events];
    SELECT @DevicesCount = COUNT(*) FROM [dbo].[Devices];
    SELECT @LocationsCount = COUNT(*) FROM [dbo].[Locations];
    SELECT @UsersCount = COUNT(*) FROM [dbo].[Users];

    -- Log final record counts
    PRINT 'Final record counts:';
    PRINT 'Events: ' + CAST(@EventsCount AS VARCHAR(10));
    PRINT 'Devices: ' + CAST(@DevicesCount AS VARCHAR(10));
    PRINT 'Locations: ' + CAST(@LocationsCount AS VARCHAR(10));
    PRINT 'Users: ' + CAST(@UsersCount AS VARCHAR(10));

    -- Commit the transaction
    COMMIT TRANSACTION;
    PRINT 'Data cleanup completed successfully.';
END TRY
BEGIN CATCH
    -- If there's an error, rollback the transaction
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    -- Print error information
    PRINT 'Error occurred during data cleanup:';
    PRINT ERROR_MESSAGE();
    PRINT ERROR_LINE();
    PRINT ERROR_PROCEDURE();
    PRINT ERROR_NUMBER();
END CATCH
SET NOCOUNT OFF;
