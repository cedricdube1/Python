/************************************************************************
* Script     : 0.Business - Tournament - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-04
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_Tournament];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[Tournament];
DROP TABLE IF EXISTS [dbo].[HubTournament];
GO

/* End of File ********************************************************************************************************************/