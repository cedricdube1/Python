/***********************************************************************************************************************************
* Script      : 5.Lookup - Views.sql                                                                                               *
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
CREATE VIEW [Lookup].[vProvider]
  WITH SCHEMABINDING
AS
SELECT P.[ProviderID]
      ,P.[SystemFromDate]
      ,P.[SystemToDate]
      ,P.[ProviderName]
      ,P.[ProviderCallerName]
      ,P.[Descriptor]
  FROM [Lookup].[Provider] P;
GO

GO
CREATE VIEW [Lookup].[vCountryStateTimeZone]
  WITH SCHEMABINDING
AS
  SELECT CSTZ.CountryCode,
         CSTZ.StateCode,
		 TZ.TimeZone,
         TZ.UTC_OffsetHours,
         TZ.UTC_OffsetHours_DaylightSavings,
		 ISNULL(DS.DaylightSavingsStart, CAST('9999-12-31' AS DATETIME2)) AS DaylightSavingsStart,
		 ISNULL(DS.DaylightSavingsEnd, CAST('9999-12-31' AS DATETIME2)) AS DaylightSavingsEnd
    FROM [Lookup].[CountryStateTimeZone] CSTZ
   INNER JOIN [Lookup].[TimeZone] TZ
     ON CSTZ.TimeZone = TZ.TimeZone
   LEFT JOIN [Lookup].[DaylightSavings] DS
     ON CSTZ.TimeZone = DS.TimeZone;       
GO
GO
CREATE VIEW [Lookup].[vSourceSystem]
  WITH SCHEMABINDING
AS
SELECT P.[ProviderID]
      ,P.[SystemFromDate]
      ,P.[SystemToDate]
      ,P.[ProviderName]
      ,P.[ProviderCallerName]
      ,P.[Descriptor]
	  ,COALESCE(SSM.MasterSourceSystemID,SS.SourceSystemID) AS [MasterSourceSystemID]
	  ,SS.[SourceSystemID]
      ,C.[CountryCode]
      ,C.[ShortnameEnglish] AS [Country]
      ,CS.[StateCode]
	  ,CS.[StateName]
      ,SS.[ProviderSystemID]
      ,PS.[ProviderExternalSystemID]
  FROM [Lookup].[Provider] P
 INNER JOIN [Lookup].[SourceSystem] SS
    ON P.[ProviderID] = SS.[ProviderID]
 INNER JOIN [Lookup].[ProviderSystem] PS
    ON SS.[ProviderSystemID] = PS.[ProviderSystemID]
 INNER JOIN [Lookup].[Country] C
    ON SS.[CountryCode] = C.[CountryCode]
 INNER JOIN [Lookup].[CountryState] CS
    ON SS.[CountryCode] = CS.[CountryCode]
   AND SS.[StateCode] = CS.[StateCode]
  LEFT JOIN [Lookup].[SourceSystemMaster] SSM
    ON SS.[SourceSystemID] = SSM.[SourceSystemID];
GO
GO
/* End of File ********************************************************************************************************************/