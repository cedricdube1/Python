/************************************************************************
* Script     : 0.Business - PlayerOfferWager - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_PlayerOfferWager];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[PlayerOfferWager];

/* End of File ********************************************************************************************************************/