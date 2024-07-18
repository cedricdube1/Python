/***********************************************************************************************************************************
* Script      : 7.Lookup - Procedures.sql                                                                                          *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-09-06                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE PROCEDURE [Lookup].[SetProvider] (
  @ProviderName VARCHAR(50),
  @ProviderCallerName VARCHAR(50),
  @Descriptor VARCHAR(150) = 'Unknown',
  @Operation CHAR(1) = 'I', -- I|U
  @SystemFromDate DATETIME2 = NULL,
  @SystemToDate DATETIME2 = NULL,
  @DefaultID SMALLINT = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Lookup].[SetProvider]
  -- Author: Cedric Dube
  -- Create date: 2021-09-06
  -- Description: Insert/Update Provider
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @NowTime DATETIME2 = SYSUTCDATETIME();
  IF @SystemFromDate IS NULL SET @SystemFromDate = @NowTime;
  IF @SystemToDate IS NULL SET @SystemToDate = CAST('9999-12-31 23:59:59.9999999' AS DATETIME2);
  -- UPDATE --
  IF EXISTS (SELECT 1 FROM [Lookup].[Provider] 
                  WHERE ProviderCallerName = @ProviderCallerName)
     AND @Operation = 'U' BEGIN;
     UPDATE [Lookup].[Provider]
        SET ProviderName = @ProviderName,
            SystemFromdate = @SystemFromDate,
            ProviderCallerName = @ProviderCallerName,
            Descriptor = @Descriptor
      WHERE ProviderCallerName = @ProviderCallerName;
  END;
  -- INSERT --
  IF NOT EXISTS (SELECT 1 FROM [Lookup].[Provider] 
                  WHERE ProviderCallerName = @ProviderCallerName)
     AND @Operation = 'I' BEGIN;
    IF @DefaultID IS NOT NULL BEGIN;
      SET IDENTITY_INSERT [Lookup].[Provider] ON;
      INSERT INTO [Lookup].[Provider] (ProviderID, ProviderName, ProviderCallerName, Descriptor, SystemFromDate, SystemToDate)
        VALUES (@DefaultID, @ProviderName, @ProviderCallerName, @Descriptor, @SystemFromDate, @SystemToDate);
      SET IDENTITY_INSERT [Lookup].[Provider] OFF;
    END; ELSE BEGIN;
      INSERT INTO [Lookup].[Provider] (ProviderName, ProviderCallerName, Descriptor, SystemFromDate, SystemToDate)
        VALUES ( @ProviderName, @ProviderCallerName, @Descriptor, @SystemFromDate, @SystemToDate);
      END;
  END;
  -- CHECK --
  SELECT ProviderName, ProviderCallerName, Descriptor
     FROM [Lookup].[Provider] 
    WHERE ProviderCallerName = @ProviderCallerName;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Lookup].[SetProviderSystem] (
  @ProviderCallerName VARCHAR(50),
  @ProviderExternalSystemID VARCHAR(150),
  @SystemFromDate DATETIME2 = NULL,
  @SystemToDate DATETIME2 = NULL,
  @DefaultID SMALLINT = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Lookup].[SetProviderSystem]
  -- Author: Cedric Dube
  -- Create date: 2021-09-06
  -- Description: Insert Source System
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @NowTime DATETIME2 = SYSUTCDATETIME();
  IF @SystemFromDate IS NULL SET @SystemFromDate = @NowTime;
  IF @SystemToDate IS NULL SET @SystemToDate = CAST('9999-12-31 23:59:59.9999999' AS DATETIME2);
  DECLARE @ProviderID SMALLINT = [Lookup].[GetProviderIDFromName] (@ProviderCallerName);
  -- INSERT --
  IF NOT EXISTS (SELECT 1 FROM [Lookup].[ProviderSystem] 
                  WHERE ProviderID = @ProviderID
                    AND ProviderExternalSystemID = @ProviderExternalSystemID) BEGIN;
    IF @DefaultID IS NOT NULL BEGIN;
      SET IDENTITY_INSERT [Lookup].[ProviderSystem] ON;
      INSERT INTO [Lookup].[ProviderSystem] (ProviderSystemID, ProviderID, ProviderExternalSystemID, SystemFromDate, SystemToDate)
        VALUES (@DefaultID, @ProviderID, @ProviderExternalSystemID, @SystemFromDate, @SystemToDate);
      SET IDENTITY_INSERT [Lookup].[ProviderSystem] OFF;
    END; ELSE BEGIN;
      INSERT INTO [Lookup].[ProviderSystem] (ProviderID, ProviderExternalSystemID, SystemFromDate, SystemToDate)
        VALUES ( @ProviderID, @ProviderExternalSystemID, @SystemFromDate, @SystemToDate);
      END;
  END;
  -- CHECK --
  SELECT ProviderSystemID, ProviderID, ProviderExternalSystemID
     FROM [Lookup].[ProviderSystem] 
    WHERE ProviderID = @ProviderID
      AND ProviderExternalSystemID = @ProviderExternalSystemID;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Lookup].[SetSourceSystem] (
  @ProviderCallerName VARCHAR(50),
  @CountryCode CHAR(2),
  @StateCode VARCHAR(3),
  @ProviderExternalSystemID VARCHAR(150),
  @SystemFromDate DATETIME2 = NULL,
  @SystemToDate DATETIME2 = NULL,
  @DefaultID SMALLINT = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Lookup].[SetSourceSystem]
  -- Author: Cedric Dube
  -- Create date: 2021-09-06
  -- Description: Insert Source System
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @NowTime DATETIME2 = SYSUTCDATETIME();
  IF @SystemFromDate IS NULL SET @SystemFromDate = @NowTime;
  IF @SystemToDate IS NULL SET @SystemToDate = CAST('9999-12-31 23:59:59.9999999' AS DATETIME2);
  DECLARE @ProviderID INT = [Lookup].[GetProviderIDFromName] (@ProviderCallerName);
  DECLARE @ProviderSystemID INT = [Lookup].[GetProviderSystemIDFromExternalID] (@ProviderID, @ProviderExternalSystemID); 
  -- INSERT --
  IF NOT EXISTS (SELECT 1 FROM [Lookup].[SourceSystem] 
                  WHERE ProviderID = @ProviderID
                    AND CountryCode = @CountryCode
                    AND StateCode = @StateCode
					AND ProviderSystemID = @ProviderSystemID) BEGIN;
    IF @DefaultID IS NOT NULL BEGIN;
      SET IDENTITY_INSERT [Lookup].[SourceSystem] ON;
      INSERT INTO [Lookup].[SourceSystem] (SourceSystemID, ProviderID, CountryCode, StateCode, ProviderSystemID, SystemFromDate, SystemToDate)
        VALUES (@DefaultID, @ProviderID, @CountryCode, @StateCode, @ProviderSystemID, @SystemFromDate, @SystemToDate);
      SET IDENTITY_INSERT [Lookup].[SourceSystem] OFF;
    END; ELSE BEGIN;
      INSERT INTO [Lookup].[SourceSystem] (ProviderID, CountryCode, StateCode, ProviderSystemID, SystemFromDate, SystemToDate)
        VALUES ( @ProviderID, @CountryCode, @StateCode, @ProviderSystemID, @SystemFromDate, @SystemToDate);
      END;
  END;
  -- CHECK --
  SELECT SourceSystemID, ProviderID, CountryCode, StateCode, ProviderSystemID
     FROM [Lookup].[SourceSystem] 
    WHERE ProviderID = @ProviderID
      AND CountryCode = @CountryCode
      AND StateCode = @StateCode
	  AND ProviderSystemID = @ProviderSystemID;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
/* End of File ********************************************************************************************************************/