/************************************************************************
* Script     : 6.Business - Tournament - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-04
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_Tournament]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubTournamentID],
       [Hub].[SourceSystemID],
       [Hub].[OriginSystemID], -- Part of Hub for Tournament
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
	   [Hub].[TournamentID],
	   [T].[TournamentGroupName] [SurgeTournamentId],
	   [TT].[TournamentTemplateName],
	   [TT].[TournamentTemplateDescription],
       [Det].[ProductID],
       [G].[GameName],
       [R].[RegionName],
       [O].[OperatorName],
       [S].[StatusName],     
       [Det].[CurrencyCode],
       [Det].[StartUTCDateTime],
       [Det].[StartUTCDate],
       [Det].[EndUTCDateTime],
       [Det].[EndUTCDate],
       [Det].[MinNumberOfPlayers],
       [Det].[MaxNumberOfPlayers],
       [Det].[CoinValue],
       [Det].[IsNetwork]
FROM [dbo].[HubTournament] [Hub]
INNER JOIN [dbo].[Tournament] [Det]
  ON [Hub].[HubTournamentID] = [Det].[HubTournamentID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Game] [G]
  ON [G].[GameID] = [Det].[GameID]
LEFT JOIN [dbo].[Region] [R]
  ON [R].[RegionID] = [Det].[RegionID]
LEFT JOIN [dbo].[Operator] [O]
  ON [O].[OperatorID] = [Det].[OperatorID]
LEFT JOIN [dbo].[Status] [S]
  ON [S].[StatusID] = [Det].[StatusID]
LEFT JOIN [dbo].[TournamentGroup] [T]
  ON [T].[TournamentGroupID] = [Det].[TournamentGroupID]
LEFT JOIN [dbo].[TournamentTemplate] [TT]
  ON [TT].[TournamentTemplateID] = [Det].[TournamentTemplateID];
GO


/* End of File ********************************************************************************************************************/