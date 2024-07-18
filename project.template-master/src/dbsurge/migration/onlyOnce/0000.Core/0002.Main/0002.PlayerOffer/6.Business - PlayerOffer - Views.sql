/************************************************************************
* Script     : 6.Business - PlayerOffer - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerOffer]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerOfferID],
       [Hub].[SourceSystemID],
       [Hub].[PromoGUID],
       [Hub].[OfferGUID],
       [Hub].[UserID],
       [Hub].[GamingSystemID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [Det].[HubPlayerEligibilityID],
       [R].[RewardTypeName],
       [Det].[Coupon],
       [Det].[Percentage],
       [Det].[FreeSpins],
       [Det].[TierIndex]
FROM [dbo].[HubPlayerOffer] [Hub]
INNER JOIN [dbo].[PlayerOffer] [Det]
  ON [Hub].[HubPlayerOfferID] = [Det].[HubPlayerOfferID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[RewardType] [R]
  ON [R].[RewardTypeID] = [Det].[RewardTypeID];
GO
/* End of File ********************************************************************************************************************/