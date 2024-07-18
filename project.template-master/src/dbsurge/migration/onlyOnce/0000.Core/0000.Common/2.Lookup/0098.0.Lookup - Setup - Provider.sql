/***********************************************************************************************************************************
* Script      : 99.Lookup -  Setup -Provider.sql                                                                               *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-09-06                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script.                                                                                                     *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO
-- SET VARS --
-- Related
-- Specific
DECLARE @ProviderName VARCHAR(50),
        @ProviderCallerName VARCHAR(50),
        @Descriptor VARCHAR(150),
        @ProviderID SMALLINT;
-- Operations and Outputs
DECLARE @Operation CHAR(1);

----------- Generic
-- INSERT --
SET @Descriptor = 'Unknown provider';
SET @ProviderName = 'Unknown';
SET @ProviderCallerName = 'Unknown';
SET @Operation = 'I';
EXEC [Lookup].[SetProvider] @DefaultID = -1, @ProviderName = @ProviderName, @ProviderCallerName = @ProviderCallerName,
                            @Descriptor = @Descriptor, @Operation = @Operation;
----------- Surge
-- INSERT --
SET @Descriptor = 'Data provider';
SET @ProviderName = 'Surge';
SET @ProviderCallerName = 'Surge';
SET @Operation = 'I';
EXEC [Lookup].[SetProvider] @ProviderName = @ProviderName, @ProviderCallerName = @ProviderCallerName,
                            @Descriptor = @Descriptor, @Operation = @Operation;


/* End of File ********************************************************************************************************************/