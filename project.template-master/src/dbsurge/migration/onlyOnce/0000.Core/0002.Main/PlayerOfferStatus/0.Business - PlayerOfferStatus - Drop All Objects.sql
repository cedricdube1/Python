/************************************************************************
* Script     : 0.Business - PlayerOfferStatus - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_PlayerOfferStatus];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[PlayerOfferStatus];
GO


/* End of File ********************************************************************************************************************/