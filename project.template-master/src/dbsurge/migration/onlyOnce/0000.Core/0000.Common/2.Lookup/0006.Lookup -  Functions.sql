/***********************************************************************************************************************************
* Script      : 6.Lookup - Functions.sql                                                                                           *
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
CREATE FUNCTION [Lookup].[GetProviderIDFromName] (
  @ProviderCallerName VARCHAR(50)
) RETURNS INT
  WITH SCHEMABINDING
AS   
BEGIN

  DECLARE @ProviderID INT;
  SELECT @ProviderID = ProviderID
     FROM [Lookup].[Provider] WITH (NOLOCK)
    WHERE ProviderCallerName = @ProviderCallerName;

  RETURN ISNULL(@ProviderID, -1)
END;
GO

GO
CREATE FUNCTION [Lookup].[GetProviderSystemIDFromExternalID] (
  @ProviderID INT,
  @ProviderExternalSystemID VARCHAR(150)
) RETURNS INT
  WITH SCHEMABINDING
AS   
BEGIN

  DECLARE @ProviderSystemID INT;
  SELECT @ProviderSystemID = ProviderSystemID
     FROM [Lookup].[ProviderSystem] WITH (NOLOCK)
    WHERE ProviderID = @ProviderID
	  AND ProviderExternalSystemID = @ProviderExternalSystemID;

  RETURN ISNULL(@ProviderSystemID, -1)
END;
GO
GO
CREATE FUNCTION [Lookup].[GetSourceSystemID] (
  @ProviderCallerName VARCHAR(50),
  @CountryCode CHAR(2),
  @StateCode VARCHAR(3),
  @ProviderExternalSystemID VARCHAR(150)
) RETURNS INT
  WITH SCHEMABINDING
AS   
BEGIN

  DECLARE @ProviderID INT = [Lookup].[GetProviderIDFromName] (@ProviderCallerName);
  DECLARE @ProviderSystemID INT = [Lookup].[GetProviderSystemIDFromExternalID] (@ProviderID, @ProviderExternalSystemID);

  DECLARE @SourceSystemID INT;
  SELECT @SourceSystemID = SourceSystemID
     FROM [Lookup].[SourceSystem] WITH (NOLOCK)
    WHERE ProviderID = @ProviderID
	  AND CountryCode = @CountryCode
      AND StateCode = @StateCode
      AND ProviderSystemID = @ProviderSystemID;

  RETURN ISNULL(@SourceSystemID, -1)
END;
GO
GO
CREATE FUNCTION [Lookup].[GetMasterSourceSystemID] (
  @ProviderCallerName VARCHAR(50),
  @CountryCode CHAR(2),
  @StateCode VARCHAR(3),
  @ProviderExternalSystemID VARCHAR(150)
) RETURNS INT
  WITH SCHEMABINDING
AS   
BEGIN

  DECLARE @ProviderID INT = [Lookup].[GetProviderIDFromName] (@ProviderCallerName);
  DECLARE @ProviderSystemID INT = [Lookup].[GetProviderSystemIDFromExternalID] (@ProviderID, @ProviderExternalSystemID);

  DECLARE @SourceSystemID INT;
  SELECT @SourceSystemID = MasterSourceSystemID
     FROM [Lookup].[vSourceSystem] WITH (NOLOCK)
    WHERE ProviderID = @ProviderID
	  AND CountryCode = @CountryCode
      AND StateCode = @StateCode
      AND ProviderSystemID = @ProviderSystemID;

  RETURN ISNULL(@SourceSystemID, -1)
END;
GO

GO
CREATE FUNCTION [Lookup].[GetRegionalDateFromUTC](
  @CountryCode CHAR(2),
  @StateCode VARCHAR(3),
  @Date DATETIME2
) RETURNS DATETIME2
  WITH SCHEMABINDING
AS   
BEGIN
  DECLARE @RegionalDate DATETIME2;
  SELECT TOP 1 @RegionalDate = CASE WHEN @Date BETWEEN DaylightSavingsStart AND DaylightSavingsEnd 
                                   THEN DATEADD(HOUR, UTC_OffsetHours_DaylightSavings, @Date)
                              ELSE DATEADD(HOUR, UTC_OffsetHours, @Date) END
     FROM [Lookup].[CountryStateTimeZone] CSTZ WITH (NOLOCK)
    INNER JOIN [Lookup].[TimeZone] TZ WITH (NOLOCK)
       ON CSTZ.TimeZone = TZ.TimeZone
     LEFT JOIN [Lookup].[DaylightSavings] DS WITH (NOLOCK)
       ON CSTZ.TimeZone = DS.TimeZone
      AND @Date BETWEEN DaylightSavingsStart AND DaylightSavingsEnd
    WHERE CSTZ.CountryCode = @CountryCode
	  AND CSTZ.StateCode = @StateCode;
  RETURN ISNULL(@RegionalDate, @Date);
END;
GO

/* End of File ********************************************************************************************************************/