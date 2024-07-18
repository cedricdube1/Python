/***********************************************************************************************************************************
* Script      : 0.Monitoring - Jobs - Drop All Objects.sql                                                                         *
* Created By  : Cedric Dube                                                                                          *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge];

GO

-- DROP PROCEDURE --
DROP PROCEDURE IF EXISTS [Monitoring].[Process_Jobs];
DROP PROCEDURE IF EXISTS [Monitoring].[ETL_JobFailures];
DROP PROCEDURE IF EXISTS [Monitoring].[Controller_JobDisabled];

-- DROP VIEW --
DROP VIEW IF EXISTS [Monitoring].[vSQLServerAgentFailedJob];
GO
DROP VIEW IF EXISTS [Monitoring].[vSQLServerAgentControllerJobState];
GO
DROP VIEW IF EXISTS [Monitoring].[vLatestSchedulerMonitorSystemHealth];
GO
-- DROP TABLE --
DROP TABLE IF EXISTS [Monitoring].[SQLServerAgentJobFailure];
DROP TABLE IF EXISTS [Monitoring].[SQLServerAgentControllerJobDisabled];
GO

/* End of File ********************************************************************************************************************/