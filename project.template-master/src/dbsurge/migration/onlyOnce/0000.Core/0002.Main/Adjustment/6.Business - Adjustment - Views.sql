/************************************************************************
* Script     : 6.Business - Adjustment - Views.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_Adjustment]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubAdjustmentID],
       [Hub].[SourceSystemID],
       [Hub].[BalanceUpdateID],
       [Hub].[TransactionNumber],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [AET].[AdminEventTypeName],
       [AE].[AdminEventName],
       [DET].[ModuleID],
       [B].[BalanceTypeName],
       [Det].[PlayerCurrencyCode],
       [Det].[OperatorCurrencyCode],
       [Det].[TransactionUTCDateTime],
       [Det].[TransactionUTCDate],
       [Det].[PlayerToOperatorCurrencyExchangeRate],
       [Det].[BalanceAfterLastPositiveChange],
       [Det].[CashBalanceAfter],
       [Det].[BonusBalanceAfter],
       [Det].[CurrencyValue],
       [Det].[IsBonusEvent]
FROM [dbo].[HubAdjustment] [Hub]
INNER JOIN [dbo].[Adjustment] [Det]
  ON [Hub].[HubAdjustmentID] = [Det].[HubAdjustmentID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[AdminEventType] [AET]
  ON [AET].[AdminEventTypeID] = [Det].[AdminEventTypeID]
LEFT JOIN [dbo].[AdminEvent] [AE]
  ON [AE].[AdminEventID] = [Det].[AdminEventID]
LEFT JOIN [dbo].[BalanceType] [B]
  ON [B].[BalanceTypeID] = [Det].[BalanceTypeID];
GO


/* End of File ********************************************************************************************************************/