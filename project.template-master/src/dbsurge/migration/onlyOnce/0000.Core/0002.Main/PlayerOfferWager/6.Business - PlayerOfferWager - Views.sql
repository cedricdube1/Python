/************************************************************************
* Script     : 6.Business - PlayerOfferWager - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerOfferWager]
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
       [Det].[ClientID],
       [Det].[ModuleID],
       [G].[GameName],
       [PGB].[PlayerGroupBehaviourName],
       [Det].[TransactionUTCDateTime],
       [Det].[TransactionUTCDate],
       [Det].[UserTransnumber],
       [Det].[TotalBalance],
       [Det].[WagerAmount],  
       [Det].[PayoutAmount],
       [Det].[CashBalance],
       [Det].[BonusBalance],
       [Det].[TheoreticalPayoutPercentage],
       [Det].[BalanceAfterLastPositiveChange]
FROM [dbo].[HubPlayerOffer] [Hub]
INNER JOIN [dbo].[PlayerOfferWager] [Det]
  ON [Hub].[HubPlayerOfferID] = [Det].[HubPlayerOfferID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Game] [G]
  ON [G].[GameID] = [Det].[GameID]
LEFT JOIN [dbo].[PlayerGroupBehaviour] [PGB]
  ON [PGB].[PlayerGroupBehaviourID] = [Det].[PlayerGroupBehaviourID];
GO


/* End of File ********************************************************************************************************************/