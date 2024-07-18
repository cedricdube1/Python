/************************************************************************
* Script     : 0.Business - TournamentWager - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-05-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_TournamentWager];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[TournamentWager];
DROP TABLE IF EXISTS [dbo].[HubTournamentWager];
GO


/* End of File ********************************************************************************************************************/