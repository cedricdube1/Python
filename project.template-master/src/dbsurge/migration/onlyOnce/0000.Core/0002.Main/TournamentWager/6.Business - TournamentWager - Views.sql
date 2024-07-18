/************************************************************************
* Script     : 6.Business - TournamentWager - Views.sql
* Created By : Cedric Dube
* Created On : 2021-05-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_TournamentWager]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubTournamentWagerID],
       [Hub].[SourceSystemID],
       [Hub].[TournamentID],
       [Hub].[GamingSystemID],
       [Hub].[UserID],
       [Hub].[UserTransNumber],
       [Hub].[OriginSystemID], -- Part of Hub for Tournament
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubTournamentID],
       [Det].[HubPlayerID],
       [Det].[ModuleId], 
       [Det].[ClientId], 
       [Det].[CountryCode],
       [Det].[WagerUTCDateTime],
       [Det].[WagerUTCDate],
       [Det].[WagerAmount],
       [Det].[PayoutAmount],
       [Det].[CashBalance],
       [Det].[MinBetAmount],
       [Det].[MaxBetAmount]
FROM [dbo].[HubTournamentWager] [Hub]
INNER JOIN [dbo].[TournamentWager] [Det]
  ON [Hub].[HubTournamentWagerID] = [Det].[HubTournamentWagerID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID];
GO


/* End of File ********************************************************************************************************************/