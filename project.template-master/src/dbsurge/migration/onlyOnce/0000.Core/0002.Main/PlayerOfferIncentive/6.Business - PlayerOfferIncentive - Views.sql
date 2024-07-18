/************************************************************************
* Script     : 6.Business - PlayerOfferIncentive - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-16
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerOfferIncentive]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerOfferIncentiveID],
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
       [Det].[HubPlayerOfferID],
       [Det].[HubPlayerID],
       [P].[PromotionTypeName],
       [R].[RewardTypeName],
       [V].[ValueSegmentName],
       [Det].[RewardUTCDateTime],
       [Det].[RewardUTCDate],
       [Det].[BinSum],
       [Det].[ReloadMax],
       [Det].[ReloadCount],
       [Det].[CouponValue],
       [Det].[PercentageMatch],
       [Det].[LevelFreeSpinCoupon]
FROM [dbo].[HubPlayerOfferIncentive] [Hub]
INNER JOIN [dbo].[PlayerOfferIncentive] [Det]
  ON [Hub].[HubPlayerOfferIncentiveID] = [Det].[HubPlayerOfferIncentiveID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[PromotionType] [P]
  ON [P].[PromotionTypeID] = [Det].[PromotionTypeID]
LEFT JOIN [dbo].[RewardType] [R]
  ON [R].[RewardTypeID] = [Det].[RewardTypeID]
LEFT JOIN [dbo].[ValueSegment] [V]
  ON [V].[ValueSegmentID] = [Det].[ValueSegmentID];
GO



/* End of File ********************************************************************************************************************/