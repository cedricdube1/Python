/************************************************************************
* Script     : 0.Business - TriggeringCondition - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2022-02-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Procedures --

-- Views --
DROP VIEW IF EXISTS [dbo].[vw_TriggeringCondition];
GO

-- Tables --
DROP TABLE IF EXISTS [dbo].[TriggeringCondition];
DROP TABLE IF EXISTS [dbo].[HubTriggeringCondition];
GO


/* End of File ********************************************************************************************************************/