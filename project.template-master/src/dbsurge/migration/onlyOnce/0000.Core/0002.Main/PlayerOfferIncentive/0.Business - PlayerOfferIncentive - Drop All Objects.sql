/************************************************************************
* Script     : 0.Business - PlayerOfferIncentive - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-06
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_PlayerOfferIncentive];
GO


-- Tables --
DROP TABLE IF EXISTS [dbo].[PlayerOfferIncentive];
DROP TABLE IF EXISTS [dbo].[HubPlayerOfferIncentive];
GO


/* End of File ********************************************************************************************************************/