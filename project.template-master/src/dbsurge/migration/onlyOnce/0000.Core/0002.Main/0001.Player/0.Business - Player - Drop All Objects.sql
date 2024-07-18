/************************************************************************
* Script     : 0.Business - Player - Drop All Objects.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Functions --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_Player];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[Player];
DROP TABLE IF EXISTS [dbo].[HubPlayer];
GO

/* End of File ********************************************************************************************************************/