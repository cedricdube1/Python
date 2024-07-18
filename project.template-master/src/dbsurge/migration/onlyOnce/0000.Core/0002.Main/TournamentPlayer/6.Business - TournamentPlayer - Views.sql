/************************************************************************
* Script     : 6.Business - TournamentPlayer - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_TournamentPlayer]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubTournamentPlayerID],
       [Hub].[SourceSystemID],
       [Hub].[TournamentID],
       [Hub].[GamingSystemID],
       [Hub].[UserID],
       [Hub].[OriginSystemID], 
	   [Det].[IsCurrent],
       [Det].[FromDate],
       [Det].[ToDate],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubTournamentID],
       [Det].[HubPlayerID],
       [Det].[SessionProductID],
       [S].[StatusName] [PlayerTournamentStatus],
       [Det].[CurrencyCode],
       [Det].[LeaderBoardPosition],
       [Det].[IsCompleteLeaderboard],
       [Det].[Score],
       [Det].[PrizeAmount]
FROM [dbo].[HubTournamentPlayer] [Hub]
INNER JOIN [dbo].[TournamentPlayer] [Det]
  ON [Hub].[HubTournamentPlayerID] = [Det].[HubTournamentPlayerID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Status] [S]
  ON [S].[StatusID] = [Det].[StatusID]
WHERE [Det].[IsCurrent] = 1;
GO

CREATE VIEW [dbo].[vw_TournamentPlayer_History]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubTournamentPlayerID],
       [Hub].[SourceSystemID],
       [Hub].[TournamentID],
       [Hub].[GamingSystemID],
       [Hub].[UserID],
       [Hub].[OriginSystemID], 
	   [Det].[IsCurrent],
       [Det].[FromDate],
       [Det].[ToDate],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubTournamentID],
       [Det].[HubPlayerID],
       [Det].[SessionProductID],
       [S].[Statusname] [PlayerTournamentStatus],
       [Det].[CurrencyCode],
       [Det].[LeaderBoardPosition],
       [Det].[IsCompleteLeaderboard],
       [Det].[Score],
       [Det].[PrizeAmount]
FROM [dbo].[HubTournamentPlayer] [Hub]
INNER JOIN [dbo].[TournamentPlayer] [Det]
  ON [Hub].[HubTournamentPlayerID] = [Det].[HubTournamentPlayerID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Status] [S]
  ON [S].[StatusID] = [Det].[StatusID];
GO

/* End of File ********************************************************************************************************************/