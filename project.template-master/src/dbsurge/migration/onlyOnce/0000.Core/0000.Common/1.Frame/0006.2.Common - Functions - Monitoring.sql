/***********************************************************************************************************************************
* Script      : 6.Common - Functions - Monitoring.sql                                                                              *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Monitoring                                                                                                     *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- Current Job State --
GO
CREATE FUNCTION [Monitoring].[GetCurrentJobState] (
  @JobName NVARCHAR(128)
) RETURNS @JobState TABLE (
   JobStatus VARCHAR(9) NOT NULL,
   JobEnabled TINYINT NOT NULL,
   CurrentStepName NVARCHAR(128) NOT NULL
  )
AS   
BEGIN;
  INSERT INTO @JobState (
    JobStatus,
	JobEnabled,
	CurrentStepName
  )
  SELECT TOP (1) JobStatus = ISNULL(CASE WHEN [SJA].[Start_Execution_Date] IS NOT NULL AND [SJA].[Stop_Execution_Date] IS NULL THEN 'Running'
                          ELSE 'Idle' END, 'Unknown'),
				 JobEnabled = ISNULL([SJ].[Enabled], 0),
                 CurrentStepName = ISNULL([SJS].[Step_Name], 'Unknown')
  FROM [MSDB].[DBO].[SysJobs] [SJ] WITH (NOLOCK)
  INNER JOIN [MSDB].[DBO].[SysJobActivity] [SJA] WITH (NOLOCK)
    ON  [SJ].[Job_Id] = [SJA].[Job_Id]
  INNER JOIN [MSDB].[DBO].[SysSessions] [SS] WITH (NOLOCK)
    ON  [SJA].[Session_Id] = [SS].[Session_Id]
  INNER JOIN (SELECT MAX([Agent_Start_Date]) [Agent_Start_Date]
              FROM [MSDB].[DBO].[SysSessions] WITH (NOLOCK)) [MSS]
    ON  [SS].[Agent_Start_Date] = [MSS].[Agent_Start_Date]
  LEFT  JOIN (SELECT [Job_Id],
                     [Session_Id],
                     MAX([Run_Requested_Date]) [Run_Requested_Date]
              FROM [MSDB].[DBO].[SysJobActivity] WITH (NOLOCK)
              GROUP BY [Job_Id],
                       [Session_Id]) [MSJA]
    ON  [SJ].[Job_Id] = [MSJA].[Job_Id]
   AND  [SS].[Session_Id] = [MSJA].[Session_Id]
   AND  [SJA].[Run_Requested_Date] = [MSJA].[Run_Requested_Date]
  INNER JOIN [MSDB].[DBO].[SysJobSteps] [SJS] WITH (NOLOCK)
    ON  [SJ].[Job_Id] = [SJS].[Job_Id]
   AND  [SJS].[Step_Id] > [SJA].[Last_Executed_Step_Id]
  WHERE [SJ].[Name] = @JobName;
  RETURN;
END;
GO
-- Last Job State --
GO
CREATE FUNCTION [Monitoring].[GetPreviousJobState] (@JobName NVARCHAR(128))
  RETURNS VARCHAR(9)
BEGIN;
  DECLARE @LastJobStatus VARCHAR(9);

  SELECT TOP (1) @LastJobStatus = CASE sJOBH.run_status
             WHEN 0 THEN 'Failed'
             WHEN 1 THEN 'Succeeded'
             WHEN 2 THEN 'Retry'
             WHEN 3 THEN 'Canceled'
             WHEN 4 THEN 'Running'
          END
   FROM [MSDB].[DBO].[SysJobs] [SJ] WITH (NOLOCK)
   LEFT  JOIN (SELECT Job_ID,
                     Run_Status,
                     ROW_NUMBER() OVER (PARTITION BY Job_ID ORDER BY Run_Date DESC, Run_Time DESC) AS RowNumber
                FROM [MSDB].[DBO].[SysJobHistory]
               WHERE Step_ID = 0) AS sJOBH
     ON  [SJ].job_id = [sJOBH].job_id
    AND  [sJOBH].RowNumber = 1
  WHERE [SJ].[Name] = @JobName;
  -- Default / Return --
  IF @LastJobStatus IS NULL SET @LastJobStatus = 'Unknown';
  RETURN @LastJobStatus;
END;
GO


-- Current Process Runtime --
GO
CREATE FUNCTION [Monitoring].[GetCurrentProcessRunTimeMinutes] (@ProcessID INT)
  RETURNS BIGINT
BEGIN;
  DECLARE @RunTime BIGINT;
  DECLARE @NowTime DATETIME = SYSUTCDATETIME();
  DECLARE @RunTimeLimitMinutes INT = [Config].[GetVariable_Process_RumtimeLimit](@ProcessID);
  
  SELECT @RunTime = MAX(DATEDIFF(MINUTE,StartDateTime,@NowTime))
   FROM [Logging].[Process] [EL]
  WHERE [ProcessID] = @ProcessID
    AND [StatusCode] = 0;
  -- Default / Return --
  IF @RunTime IS NULL OR @RunTime < @RunTimeLimitMinutes SET @RunTime = 0;
  RETURN @RunTime;
END;
GO
-- Held time limits --
GO
CREATE FUNCTION [Monitoring].[HeldTimeLimitMinutes]()
  RETURNS INT
BEGIN;
  -- TODO
  DECLARE @HeldTimeLimitAlert INT = 0
  -- Default / Return --
  RETURN @HeldTimeLimitAlert;
END;
GO