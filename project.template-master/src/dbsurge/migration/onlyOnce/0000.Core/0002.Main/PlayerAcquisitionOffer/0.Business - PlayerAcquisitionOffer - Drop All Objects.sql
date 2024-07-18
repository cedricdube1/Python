/************************************************************************
* Script     : 0.Business - PlayerAcquisitionOffer - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_PlayerAcquisitionOffer];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[PlayerAcquisitionOffer];
GO


/* End of File ********************************************************************************************************************/