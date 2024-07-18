/***********************************************************************************************************************************
* Script      : 0.Monitoring - Integrity - Drop All Objects.sql                                                                    *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge];

GO

-- DROP PROCEDURE --
DROP PROCEDURE IF EXISTS [Monitoring].[SetIntegrityObject];
DROP PROCEDURE IF EXISTS [Monitoring].[SetIntegrityCompareObject];
DROP PROCEDURE IF EXISTS [Monitoring].[IntegrityObjectCheck];
DROP PROCEDURE IF EXISTS [Monitoring].[Process_DailyIntegrity];
GO

-- DROP VIEW --
DROP VIEW IF EXISTS [Monitoring].[vIntegrityAlert];
GO
DROP VIEW IF EXISTS [Monitoring].[vIntegrityObject];
GO
DROP VIEW IF EXISTS [Monitoring].[vIntegrityCompareObject];
GO

-- DROP TABLE --
DROP TABLE IF EXISTS [Monitoring].[Integrity];
DROP TABLE IF EXISTS [Monitoring].[IntegrityCompareObject];
DROP TABLE IF EXISTS [Monitoring].[IntegrityObjectColumn];
DROP TABLE IF EXISTS [Monitoring].[IntegrityObject];
GO

-- DROP TYPE --
DROP TYPE IF EXISTS [Monitoring].[IntegrityObjectColumnSet];
GO
DROP TYPE IF EXISTS [Monitoring].[IntegrityCompareObjectSet];
GO
/* End of File ********************************************************************************************************************/