/************************************************************************
* Script     : 6.Business - PlayerEligibility - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerEligibility]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerEligibilityID],
       [Hub].[SourceSystemID],
       [Hub].[PromoGUID],
       [Hub].[EligibilityGUID],
       [Hub].[UserID],
       [Hub].[GamingSystemID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [PT].[ProductTypeName],
       [P].[PromotionTypeName],
       [Det].[StartUTCDateTime],
       [Det].[StartUTCDate],
       [Det].[EndUTCDateTime],
       [Det].[EndUTCDate],
       [Det].[TriggeredOnUTCDateTime],
       [Det].[TriggeredOnUTCDate],
       [Det].[IsAutoOptIn],
       [Det].[TierCount]
FROM [dbo].[HubPlayerEligibility] [Hub]
INNER JOIN [dbo].[PlayerEligibility] [Det]
  ON [Hub].[HubPlayerEligibilityID] = [Det].[HubPlayerEligibilityID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[ProductType] [PT]
  ON [PT].[ProductTypeID] = [Det].[ProductTypeID]
LEFT JOIN [dbo].[PromotionType] [P]
  ON [P].[PromotionTypeID] = [Det].[PromotionTypeID];
GO


/* End of File ********************************************************************************************************************/