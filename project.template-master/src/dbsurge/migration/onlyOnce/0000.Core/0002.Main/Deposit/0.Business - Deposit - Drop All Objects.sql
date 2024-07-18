/************************************************************************
* Script     : 0.Business - Deposit - Drop All Objects.sql
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
DROP VIEW IF EXISTS [dbo].[vw_Deposit];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[Deposit];
DROP TABLE IF EXISTS [dbo].[HubDeposit];
GO


/* End of File ********************************************************************************************************************/