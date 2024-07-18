/************************************************************************
* Script     : 6.Business - Deposit - Views.sql
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
CREATE VIEW [dbo].[vw_Deposit]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubDepositID],
       [Hub].[SourceSystemID],
       [Hub].[GamingSystemID],
       [Hub].[UserID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [DT].[DepositTypeName],
       [DM].[DepositMethodName],
       [S].[StatusName] [TransactionStatus],
       [Det].[PlayerCurrencyCode],
       [Det].[OperatorCurrencyCode],
       [Det].[TransactionID], --??
       [Det].[TransactionUTCDateTime],
       [Det].[TransactionUTCDate],
       [Det].[IsSuccess],
       [Det].[PlayerToOperatorCurrencyExchangeRate],
       [Det].[CurrencyValue]
FROM [dbo].[HubDeposit] [Hub]
INNER JOIN [dbo].[Deposit] [Det]
  ON [Hub].[HubDepositID] = [Det].[HubDepositID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[DepositType] [DT]
  ON [DT].[DepositTypeID] = [Det].[DepositTypeID]
LEFT JOIN [dbo].[DepositMethod] [DM]
  ON [DM].[DepositMethodID] = [Det].[DepositMethodID]
LEFT JOIN [dbo].[Status] [S]
  ON [S].[StatusID] = [Det].[TransactionStatusID];
GO


/* End of File ********************************************************************************************************************/