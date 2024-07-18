/************************************************************************
* Script     : 6.Business - PlayerOfferConversion - Views.sql
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
CREATE VIEW [dbo].[vw_PlayerOfferConversion]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerOfferID],
       [Hub].[SourceSystemID],
       [Hub].[PromoGUID],
       [Hub].[OfferGUID],
       [Hub].[UserID],
       [Hub].[GamingSystemID],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [Det].[HubDepositID],
	   [Det].[HubPlayerBonusCreditID],
       [P].[PromotionTypeName],
       [Det].[ApplicationOnUTCDateTime],
       [Det].[ApplicationOnUTCDate],
       [Det].[TriggeredOnUTCDateTime],
       [Det].[TriggeredOnUTCDate],
       [Det].[DepositUTCDateTime],
       [Det].[DepositUTCDate],
       [Det].[DepositAmount],
       [Det].[BonusAmount]
FROM [dbo].[HubPlayerOffer] [Hub]
INNER JOIN [dbo].[PlayerOfferConversion] [Det]
  ON [Hub].[HubPlayerOfferID] = [Det].[HubPlayerOfferID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[PromotionType] [P]
  ON [P].[PromotionTypeID] = [Det].[PromotionTypeID];
GO




/* End of File ********************************************************************************************************************/