/****************************************************************************************************************************
* Script      : 5.Monitoring - Views.sql                                                                                    *
* Created By  : Cedric Dube                                                                                   *
* Created On  : 2021-03-02                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO
CREATE VIEW [Monitoring].[vSQLServerAgentControllerJobState]
AS
  WITH CTE AS (
   SELECT JobName, JobID FROM [dbSurge].[Config].[Job] 
    WHERE IsEnabled = 1 AND IsRunnable = 1 AND IsLoopJob = 1 AND IsControllerJob = 1
  )
  SELECT SJOB.[Name] AS [JobName],
         SJOB.[Job_ID]  AS [SQLServerAgentJobID],
         CJ.[JobID] AS [ConfigJobID],
         SJOB.[Enabled] AS [IsEnabled],
         SJOBA.[Start_Execution_Date],
         SJOBA.[Stop_Execution_Date]
    FROM MSDB.dbo.SysJobs SJOB
   INNER JOIN CTE CJ
      ON SJOB.[Name] = CJ.[JobName]
   LEFT JOIN ( SELECT job_id,
                      run_date,
                      run_time,
                      run_status,
                      run_duration,
                      message,
                      ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY run_date DESC, run_time DESC) AS RowNumber
                FROM [MSDB].[dbo].SysJobHistory
                WHERE step_id = 0
             ) AS SJOBH
      ON SJOB.job_id = SJOBH.job_id
     AND SJOBH.RowNumber = 1
    LEFT JOIN MSDB.dbo.SysJobActivity SJOBA
      ON SJOB.Job_ID = SJOBA.Job_ID
     AND SJOBA.session_id = ( SELECT MAX(session_id) FROM [MSDB].[dbo].SysJobActivity);
GO
GO
CREATE VIEW [Monitoring].[vSQLServerAgentFailedJob]
AS
  SELECT SJOB.job_id AS [JobID],
         SJOB.name AS [JobName],
         SCAT.name AS [JobCategory],
         CASE WHEN SJOBH.run_date IS NULL OR SJOBH.run_time IS NULL 
              THEN NULL
              ELSE CAST(CAST(SJOBH.run_date AS CHAR(8)) 
                           + ' '
                           + STUFF(
                                      STUFF(RIGHT('000000' + CAST(SJOBH.run_time AS VARCHAR(6)), 6), 3, 0, ':'),
                                      6,
                                      0,
                                      ':'
                                  ) AS DATETIME)
         END AS [LastRunDateTime],
         CASE SJOBH.run_status 
              WHEN 0 THEN 'Failed'
              WHEN 1 THEN 'Succeeded'
              WHEN 2 THEN 'Retry'
              WHEN 3 THEN 'Canceled'
              WHEN 4 THEN 'Running' -- In Progress
         END AS [LastRunStatus],
         STUFF(STUFF(RIGHT('000000' + CAST(SJOBH.run_duration AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS [LastRunDuration (HH:MM:SS)],
         SJOBH.message AS [LastRunStatusMessage],
         CASE SJOBSCH.NextRunDate
               WHEN 0 THEN NULL
               ELSE CAST(CAST(SJOBSCH.NextRunDate AS CHAR(8)) 
                          + ' '
                          + STUFF(
                                     STUFF(RIGHT('000000' + CAST(SJOBSCH.NextRunTime AS VARCHAR(6)), 6), 3, 0, ':'),
                                     6,
                                     0,
                                     ':'
                                 ) AS DATETIME)
         END AS NextRunDateTime
    FROM [MSDB].[dbo].SysJobs AS SJOB
    LEFT JOIN ( SELECT job_id,
                       MIN(next_run_date) AS NextRunDate,
                       MIN(next_run_time) AS NextRunTime
                  FROM [MSDB].[dbo].SysJobSchedules
                  GROUP BY job_id
              ) AS SJOBSCH
       ON SJOB.job_id = SJOBSCH.job_id
     LEFT JOIN ( SELECT job_id,
                        run_date,
                        run_time,
                        run_status,
                        run_duration,
                        message,
                        ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY run_date DESC, run_time DESC) AS RowNumber
                  FROM [MSDB].[dbo].SysJobHistory
                  WHERE step_id = 0
               ) AS SJOBH
        ON SJOB.job_id = SJOBH.job_id
       AND SJOBH.RowNumber = 1
      LEFT JOIN [MSDB].[dbo].SySCATegories AS SCAT
        ON SJOB.category_id = SCAT.category_id
      LEFT JOIN [MSDB].[dbo].SysJobActivity ja
        ON SJOB.job_id = ja.job_id
       AND ja.session_id = ( SELECT MAX(session_id) FROM [MSDB].[dbo].SysJobActivity )
     WHERE SJOBH.run_status = 0
       AND JA.stop_execution_date IS NOT NULL;
GO
GO
CREATE VIEW [Monitoring].[vLatestSchedulerMonitorSystemHealth]
AS
SELECT TOP (1) CONVERT(VARCHAR(30), SYSUTCDATETIME(), 121) AS UTC_QueryExecutionTime,
       DATEADD(ms, QRY.[Record Time] - SI.ms_ticks, SYSUTCDATETIME()) AS UTC_NotificationTime,
	   QRY.ProcessUtilization AS [MSSQL CPU Usage %],
	   (100-QRY.ProcessUtilization-QRY.SystemIdle) AS [Non-MSSQL CPU Usage%],
	   QRY.SystemIdle AS [System Idle %],
	   QRY.UserModeTime,
	   QRY.KernelModeTime,
	   QRY.PageFaults,
	   QRY.WorkingSetDelta,
	   QRY.[MemoryUtilization (%workingset)]
  FROM ( SELECT x.value('(//Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [ProcessUtilization],   
                x.value('(//Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle],  
                x.value('(//Record/SchedulerMonitorEvent/SystemHealth/UserModeTime) [1]', 'bigint') AS [UserModeTime],  
                x.value('(//Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime) [1]', 'bigint') AS [KernelModeTime],   
                x.value('(//Record/SchedulerMonitorEvent/SystemHealth/PageFaults) [1]', 'bigint') AS [PageFaults],  
                x.value('(//Record/SchedulerMonitorEvent/SystemHealth/WorkingSetDelta) [1]', 'bigint')/1024 AS [WorkingSetDelta],  
                x.value('(//Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization) [1]', 'bigint') AS [MemoryUtilization (%workingset)],  
                x.value('(//Record/@time)[1]', 'bigint') AS [Record Time]  
           FROM (SELECT TOP (1) CAST (record as xml) 
                   FROM sys.dm_os_ring_buffers   
                  WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR' ORDER BY TimeStamp desc) AS R(x)
        ) QRY
   CROSS JOIN sys.dm_os_sys_info SI ORDER BY DATEADD (ms, QRY.[Record Time] - SI.ms_ticks, SYSUTCDATETIME());
GO

/* End of File ********************************************************************************************************************/