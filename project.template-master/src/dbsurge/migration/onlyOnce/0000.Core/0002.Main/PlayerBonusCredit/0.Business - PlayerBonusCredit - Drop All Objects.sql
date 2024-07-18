/************************************************************************
* Script     : 0.Business - PlayerBonusCredit - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2022-02-02
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_PlayerBonusCredit];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[PlayerBonusCredit];
DROP TABLE IF EXISTS [dbo].[HubPlayerBonusCredit];
GO


/* End of File ********************************************************************************************************************/