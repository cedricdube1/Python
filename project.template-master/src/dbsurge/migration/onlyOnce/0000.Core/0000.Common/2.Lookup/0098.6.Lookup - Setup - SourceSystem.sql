/***********************************************************************************************************************************
* Script      : 99.Lookup -  Setup - SourceSystem.sql                                                                              *
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
DECLARE @SystemFromDate DATETIME2 = SYSUTCDATETIME(),
        @SystemToDate DATETIME2 = CAST('9999-12-31 23:59:59.9999999' AS DATETIME2);
-- Related
DECLARE @ProviderCallerName VARCHAR(50);
-- Specific
DECLARE @ProviderID INT,
        @CountryCode CHAR(2) = '--',
		@StateCode VARCHAR(3) = '---',
        @ProviderExternalSystemID VARCHAR(150) = 'Unknown';

----------- Generic
-- INSERT --
SET @ProviderCallerName = 'Unknown';
EXEC [Lookup].[SetSourceSystem] @DefaultID = -1, @ProviderCallerName = @ProviderCallerName, @CountryCode = @CountryCode, @StateCode = @StateCode, @ProviderExternalSystemID = @ProviderExternalSystemID;
-------------------------------------SourceSystemMaster
IF NOT EXISTS( SELECT * FROM [Lookup].[SourceSystemMaster]
                WHERE SourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID)
                  AND MasterSourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID)) BEGIN;
  INSERT INTO [Lookup].[SourceSystemMaster] (
     SourceSystemID,
     MasterSourceSystemID,
     SystemFromDate,
     SystemToDate
   ) SELECT [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID),
            [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID),
            @SystemFromDate,
            @SystemToDate;
END;

----------- Surge - Default
-- INSERT --
SET @ProviderCallerName = 'Surge';
SET @CountryCode = 'ZA';
SET @StateCode = 'WC';
SET @ProviderExternalSystemID  = 'Default';
EXEC [Lookup].[SetSourceSystem] @DefaultID = 1, @ProviderCallerName = @ProviderCallerName, @CountryCode = @CountryCode, @StateCode = @StateCode, @ProviderExternalSystemID = @ProviderExternalSystemID;
-------------------------------------SourceSystemMaster
IF NOT EXISTS( SELECT * FROM [Lookup].[SourceSystemMaster]
                WHERE SourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID)
                  AND MasterSourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID)) BEGIN;
  INSERT INTO [Lookup].[SourceSystemMaster] (
     SourceSystemID,
     MasterSourceSystemID,
     SystemFromDate,
     SystemToDate
   ) SELECT [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID),
            [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID),
            @SystemFromDate,
            @SystemToDate;;
END;

----------- Surge - MIT
-- INSERT --
SET @ProviderCallerName = 'Surge';
SET @CountryCode = 'ZA';
SET @StateCode = 'WC';
SET @ProviderExternalSystemID  = 'MIT';
EXEC [Lookup].[SetSourceSystem] @DefaultID = 2, @ProviderCallerName = @ProviderCallerName, @CountryCode = @CountryCode, @StateCode = @StateCode, @ProviderExternalSystemID = @ProviderExternalSystemID;
-------------------------------------SourceSystemMaster
IF NOT EXISTS( SELECT * FROM [Lookup].[SourceSystemMaster]
                WHERE SourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID)
                  AND MasterSourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, 'Default')) BEGIN;
  INSERT INTO [Lookup].[SourceSystemMaster] (
     SourceSystemID,
     MasterSourceSystemID,
     SystemFromDate,
     SystemToDate
   ) SELECT [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID),
            [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, 'Default'),
            @SystemFromDate,
            @SystemToDate;;
END;

----------- Surge - MIT
-- INSERT --
SET @ProviderCallerName = 'Surge';
SET @CountryCode = 'ZA';
SET @StateCode = 'WC';
SET @ProviderExternalSystemID  = 'MLT';
EXEC [Lookup].[SetSourceSystem] @DefaultID = 3, @ProviderCallerName = @ProviderCallerName, @CountryCode = @CountryCode, @StateCode = @StateCode, @ProviderExternalSystemID = @ProviderExternalSystemID;
-------------------------------------SourceSystemMaster
IF NOT EXISTS( SELECT * FROM [Lookup].[SourceSystemMaster]
                WHERE SourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID)
                  AND MasterSourceSystemID = [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, 'Default')) BEGIN;
  INSERT INTO [Lookup].[SourceSystemMaster] (
     SourceSystemID,
     MasterSourceSystemID,
     SystemFromDate,
     SystemToDate
   ) SELECT [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, @ProviderExternalSystemID),
            [Lookup].[GetSourceSystemID] (@ProviderCallerName, @CountryCode, @StateCode, 'Default'),
            @SystemFromDate,
            @SystemToDate;;
END;


GO

SELECT * FROM [Lookup].[vSourceSystem];
GO
/* End of File ********************************************************************************************************************/


