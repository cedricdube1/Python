/************************************************************************
* Script     : 6.Business - Player - Views.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO


CREATE OR ALTER VIEW [dbo].[vw_Player]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerID],
       [Hub].[SourceSystemID],
       [Hub].[GamingSystemID],
       [Hub].[UserID],
       -- Det. Capture Cols. --
       --[Det].[OriginSystemID],
       --[Det].[CaptureLogID],
       --[Det].[Operation],
       --[Det].[ModifiedDate],
       -- Specific Cols. --
       -- Relationships --
       [Det].[ProductID] [CasinoID],
       --[Det].[SessionProductID],
       [C].[ShortNameEnglish] [Country],
       REPLACE(ISNULL([CS].[StateName], [Det].[StateCode]),'---','Unknown') [State],
       [B].[BrandName],
       [Det].[CurrencyCode],
       -- Dates --
       [Det].[RegistrationUTCDateTime],
       [Det].[RegistrationUTCDate],
       -- Others --
       [Det].[IPAddress]
FROM [dbo].[HubPlayer] [Hub] WITH (NOLOCK)
INNER JOIN [dbo].[Player] [Det] WITH (NOLOCK)
  ON [Hub].[HubPlayerID] = [Det].[HubPlayerID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Brand] [B] WITH (NOLOCK)
  ON [B].[BrandID] = [Det].[BrandID]
LEFT JOIN [Lookup].[Country] [C] WITH (NOLOCK) 
  ON [C].[Alpha3ISOCode] = [Det].[CountryLongCode]
LEFT JOIN [Lookup].[CountryState] [CS] WITH (NOLOCK) 
  ON [Det].[StateCode] = [CS].[StateCode]
 AND [C].[CountryCode] = CS.CountryCode

GO

/* End of File ********************************************************************************************************************/