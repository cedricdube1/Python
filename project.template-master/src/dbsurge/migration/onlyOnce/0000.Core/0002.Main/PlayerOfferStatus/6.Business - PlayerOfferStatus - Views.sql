/************************************************************************
* Script     : 6.Business - PlayerOfferStatus - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerOfferStatus]
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
       [S].[StatusName],
       [P].[PromotionTypeName],
       [Det].[StatusUTCDateTime],
       [Det].[StatusUTCDate],
       [Det].[OfferEndUTCDateTime],
       [Det].[OfferEndUTCDate],
       [Det].[CurrentTier],
       [Det].[MaxTier]
FROM [dbo].[HubPlayerOffer] [Hub]
INNER JOIN [dbo].[PlayerOfferStatus] [Det]
  ON [Hub].[HubPlayerOfferID] = [Det].[HubPlayerOfferID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[PromotionType] [P]
  ON [P].[PromotionTypeID] = [Det].[PromotionTypeID]
LEFT JOIN [dbo].[Status] [S]
  ON [S].[StatusID] = [Det].[StatusID];
GO




/* End of File ********************************************************************************************************************/