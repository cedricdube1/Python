/***********************************************************************************************************************************
* Script      : SQL Server Agent - Monitoring Jobs - Delayed.sql
* Created By  : Cedric Dube
* Created On  : 2021-04-08
* Execute On  : As required.
* Execute As  : N/A
* Execution   : Entire script once. 
* Version     : 1.0
***********************************************************************************************************************************/
USE [dbSurge]
GO
DECLARE @ProcessName VARCHAR(150) = 'Monitoring|DailyIntegrity';
DECLARE @ProcessID INT = [Config].[GetProcessIDByName] (@ProcessName);
DECLARE @ProcessJobSchema NVARCHAR(128) = N'Monitoring';
DECLARE @ProcessJobProcedure NVARCHAR(128) = N'Process_DailyIntegrity';
DECLARE @JobNameClass VARCHAR(30) = NULL;
DECLARE @JobCategoryClass VARCHAR(30) = 'Monitoring';
DECLARE @IsLoopJob BIT = 1;
DECLARE @IsControllerJob BIT = 1;
DECLARE @EnableJobLog BIT = 0;
DECLARE @WaitTime VARCHAR(9) = '12:00:00';
DECLARE @CheckServiceBroker BIT = 0;
DECLARE @DeleteExisting BIT = 0;
DECLARE @ProcedureParams NVARCHAR(1000) = NULL;
DECLARE @JobOwnerOverride NVARCHAR(128) = 'CAPETOWN\svc_PDMDataProc';
DECLARE @JobCategoryOverride  NVARCHAR(128) = 'IGP - IN - Operational';

DECLARE @Environment CHAR(3) = CASE WHEN @@SERVERNAME IN ('CPTDEVDB02','CPTDEVDB10') THEN 'DEV'
                                    WHEN @@SERVERNAME IN ('ANALYSIS01','CPTAOLSTN10','CPTAODB10A','CPTAODB10B') THEN 'PRD'
                               ELSE 'DEV' END;
-- Add a Process job --
EXEC [Config].[SetJob_StandardProcess] @ProcessName = @ProcessName,
                                       @Environment = @Environment,
                                       @JobNameClass = @JobNameClass, 
                                       @JobCategoryClass = @JobCategoryClass,
                                       @ProcessJobSchema = @ProcessJobSchema,
                                       @ProcessJobProcedure = @ProcessJobProcedure,
                                       @ProcedureParams = @ProcedureParams,
                                       @IsLoopJob = @IsLoopJob,
                                       @IsControllerJob = @IsControllerJob,
                                       @EnableJobLog = @EnableJobLog,
                                       @CheckServiceBroker = @CheckServiceBroker,
                                       @DeleteExisting = @DeleteExisting,
                                       @WaitTime = @WaitTime,
                                       @JobOwnerOverride = @JobOwnerOverride,
									   @JobCategoryOverride = @JobCategoryOverride;

-- Check results --
/*
SELECT * FROM [Config].[vJob] J
WHERE ProcessID = @ProcessID
  ORDER BY JobStepOrdinal ASC;
*/

-- Returns (PRINTs), for a specified JobID, a script which can be provided to DBA for job deployment --
DECLARE @JobID INT = (SELECT JobID FROM Config.Job WITH (NOLOCK) WHERE ProcessID = @ProcessID);
EXEC [Config].[GetJob_ServerAgentScript] @JobID = @JobID, 
@CreateAsEnabled = 0, -- DEFAULT = 0
@PrintFileHeader = 1, -- DEFAULT = 1
@PrintFileFooter = 1, --DEFAULT = 1
@EmailOperatorName = 'IG Insights';

/* End of File ********************************************************************************************************************/
