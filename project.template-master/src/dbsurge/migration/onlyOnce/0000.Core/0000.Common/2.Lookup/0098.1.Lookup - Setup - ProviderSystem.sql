/***********************************************************************************************************************************
* Script      : 99.Lookup -  Setup - ProviderSystem.sql                                                                            *
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
DECLARE @ProviderCallerName VARCHAR(50);
-- Specific
DECLARE @ProviderID INT,
        @ProviderExternalSystemID VARCHAR(150) = 'Unknown';

----------- Generic
-- INSERT --
SET @ProviderCallerName = 'Unknown';
EXEC [Lookup].[SetProviderSystem] @DefaultID = -1, @ProviderCallerName = @ProviderCallerName, @ProviderExternalSystemID = @ProviderExternalSystemID;
----------- Surge
-- INSERT --
SET @ProviderCallerName = 'Surge';
SET @ProviderExternalSystemID = 'Default'
EXEC [Lookup].[SetProviderSystem] @ProviderCallerName = @ProviderCallerName, @ProviderExternalSystemID = @ProviderExternalSystemID;

----------- Surge
-- INSERT --
SET @ProviderCallerName = 'Surge';
SET @ProviderExternalSystemID = 'MIT'
EXEC [Lookup].[SetProviderSystem] @ProviderCallerName = @ProviderCallerName, @ProviderExternalSystemID = @ProviderExternalSystemID;

----------- Surge
-- INSERT --
SET @ProviderCallerName = 'Surge';
SET @ProviderExternalSystemID = 'MLT'
EXEC [Lookup].[SetProviderSystem] @ProviderCallerName = @ProviderCallerName, @ProviderExternalSystemID = @ProviderExternalSystemID;


/* End of File ********************************************************************************************************************/


