/************************************************************************
* Script     : 0.Business - Adjustment - Drop All Objects.sql
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

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_Adjustment];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[Adjustment];
DROP TABLE IF EXISTS [dbo].[HubAdjustment];
GO


/* End of File ********************************************************************************************************************/