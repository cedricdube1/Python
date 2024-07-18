/************************************************************************
* Script     : 0.Business - PlayerOfferExperience - Drop All Objects.sql
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
DROP VIEW IF EXISTS [dbo].[vw_PlayerOfferExperience];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[PlayerOfferExperience];
GO


/* End of File ********************************************************************************************************************/