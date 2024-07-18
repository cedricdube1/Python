/************************************************************************
* Script     : 0.Business - TournamentPlayer - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_TournamentPlayer];
DROP VIEW IF EXISTS [dbo].[vw_TournamentPlayer_History];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[TournamentPlayer];
DROP TABLE IF EXISTS [dbo].[HubTournamentPlayer];
GO


/* End of File ********************************************************************************************************************/