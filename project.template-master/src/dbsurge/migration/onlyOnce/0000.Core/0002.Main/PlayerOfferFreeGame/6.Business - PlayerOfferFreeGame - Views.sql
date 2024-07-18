/************************************************************************
* Script     : 6.Business - PlayerOfferFreeGame - Views.sql
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
CREATE VIEW [dbo].[vw_PlayerOfferFreeGame]
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
       [G].[GameName],
       [T].[TriggerName],
       [P].[PromotionTypename],
       [Det].[NumberOfSpins]
FROM [dbo].[HubPlayerOffer] [Hub]
INNER JOIN [dbo].[PlayerOfferFreeGame] [Det]
  ON [Hub].[HubPlayerOfferID] = [Det].[HubPlayerOfferID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Game] [G]
  ON [G].[GameID] = [Det].[GameID]
LEFT JOIN [dbo].[Trigger] [T]
  ON [T].[TriggerID] = [Det].[TriggerID]
LEFT JOIN [dbo].[PromotionType] [P]
  ON [P].[PromotionTypeID] = [Det].[PromotionTypeID];
GO

/* End of File ********************************************************************************************************************/