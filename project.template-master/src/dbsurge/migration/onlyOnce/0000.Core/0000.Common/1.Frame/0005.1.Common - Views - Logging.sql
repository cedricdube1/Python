/***********************************************************************************************************************************
* Script      : 5.Common - Views - Logging.sql                                                                                    *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Logging                                                                                                           *
***********************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE VIEW [Logging].[vProcessTaskCaptureLatest]
  WITH SCHEMABINDING
AS
  SELECT [EffectedObject],
         [EffectedObjectType],
         [UTC_LatestCaptureDate],
         DATEDIFF(MINUTE, [UTC_LatestCaptureDate], SYSUTCDATETIME()) AS [UTC_MinutesSinceLastCapture]
    FROM ( SELECT TCL.[TargetObjectType] AS [EffectedObjectType],TCL.[TargetObject] AS [EffectedObject],
                  MAX(TCL.[CreatedDateTime]) AS [UTC_LatestCaptureDate]
             FROM [Config].[ProcessTask] PT WITH (NOLOCK)
            INNER JOIN [Logging].[ProcessTaskCapture] TCL WITH (NOLOCK)
               ON PT.ProcessTaskID = TCL.ProcessTaskID
            GROUP BY TCL.[TargetObjectType], TCL.[TargetObject]) QRY;
GO
GO
CREATE VIEW [Logging].[vProcessTaskCaptureSummary]
  WITH SCHEMABINDING
AS
  SELECT [ProcessID],
         [ProcessName],
		 [TaskName],
		 [EffectedObject],
         [EffectedObjectType],
		 [TotalRaiseCount],
		 [TotalMergeCount],
		 [TotalInsertCount],
		 [TotalUpdateCount],
		 [TotalDeleteCount],
		 [UTC_LatestCaptureDate],
		 DATEDIFF(MINUTE, [UTC_LatestCaptureDate], SYSUTCDATETIME()) AS [UTC_MinutesSinceLastCapture]
    FROM ( SELECT PT.[ProcessID]
                 ,PT.[ProcessName]
                 ,PT.[Taskname]
                 ,TCL.[TargetObject] AS [EffectedObject]
                 ,TCL.[TargetObjectType] AS [EffectedObjectType]
                 ,SUM(TCL.[RaiseCount]) AS [TotalRaiseCount]
                 ,SUM(TCL.[MergeCount]) AS [TotalMergeCount]
                 ,SUM(TCL.[InsertCount]) AS [TotalInsertCount]
                 ,SUM(TCL.[UpdateCount]) AS [TotalUpdateCount]
                 ,SUM(TCL.[DeleteCount]) AS [TotalDeleteCount]
                 ,MAX(TCL.[CreatedDateTime]) AS [UTC_LatestCaptureDate]
             FROM [Config].[vProcessTask] PT WITH (NOLOCK)
            INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
               ON PT.ProcessTaskID = PTL.ProcessTaskID
            INNER JOIN [Logging].[ProcessTaskCapture] TCL WITH (NOLOCK)
               ON PTL.ProcessLogID = TCL.ProcessLogID
              AND PTL.ProcessLogCreatedMonth = TCL.ProcessLogCreatedMonth
              AND PTL.ProcessTaskLogID = TCL.ProcessTaskLogID
            GROUP BY PT.[ProcessID]
                    ,PT.[ProcessName]
                    ,PT.[Taskname]
                    ,TCL.[TargetObjectType]
                    ,TCL.[TargetObject]) QRY;
GO
GO
CREATE VIEW [Logging].[vJob]
  WITH SCHEMABINDING
AS
  SELECT J.[JobID]
        ,P.[ProcessName]
        ,J.[JobName]
        ,J.[JobDescription]
        ,JL.[JobLogID]
        ,JL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN [StatusCode] = -1 THEN 'Ignored'
              WHEN [StatusCode] = 0 THEN 'Incomplete'
              WHEN [StatusCode] = 1 THEN 'Complete'
              WHEN [StatusCode] = 2 THEN 'Error'
              WHEN [StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)%(60)))),3)) 
         [Duration]
        ,[StartDateTime]
        ,[EndDateTime]
    FROM [Config].[Job] J WITH (NOLOCK)
   INNER JOIN [Logging].[Job] JL WITH (NOLOCK)
     ON  J.JobID = JL.JobID
    LEFT JOIN [Config].[Process] P WITH (NOLOCK)
     ON  J.ProcessID = P.ProcessID;
GO
-- Log --
GO
CREATE VIEW [Logging].[vProcess]
  WITH SCHEMABINDING
AS
  SELECT P.[ProcessID]
        ,P.[ProcessName]
        ,P.[ProcessDescription]
        ,PL.[ProcessLogID]
        ,PL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN [StatusCode] = -1 THEN 'Ignored'
              WHEN [StatusCode] = 0 THEN 'Incomplete'
              WHEN [StatusCode] = 1 THEN 'Complete'
              WHEN [StatusCode] = 2 THEN 'Error'
              WHEN [StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)%(60)))),3)) 
         [Duration]
        ,[StartDateTime]
        ,[EndDateTime]
    FROM [Config].[vProcess] P
   INNER JOIN [Logging].[Process] PL WITH (NOLOCK)
     ON  P.ProcessID = PL.ProcessID;
GO

GO
CREATE VIEW [Logging].[vProcessTrace]
  WITH SCHEMABINDING
AS
  SELECT P.[ProcessID]
        ,P.[ProcessName]
        ,P.[ProcessDescription]
        ,PL.[SourceProcessLogID]
        ,PL.[ProcessLogID]
        ,CASE WHEN PL.[StatusCode] = -1 THEN 'Ignored'
              WHEN PL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN PL.[StatusCode] = 1 THEN 'Complete'
              WHEN PL.[StatusCode] = 2 THEN 'Error'
              WHEN PL.[StatusCode] = 3 THEN 'Overridden'
         END AS [ProcessStatus]
        ,PL.[StartDateTime]
        ,PL.[EndDateTime]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, PL.[StartDateTime], PL.[EndDateTime]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PL.[StartDateTime], PL.[EndDateTime]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PL.[StartDateTime], PL.[EndDateTime]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PL.[StartDateTime], PL.[EndDateTime]) % (60*60)%(60)))),3)) 
         [ProcessDuration]
        ,PT.[ProcessTaskID]
        ,PT.[TaskName]
        ,PTL.[ProcessTaskLogID]
        ,CASE WHEN PTL.[StatusCode] IS NULL THEN 'Not Started'
              WHEN PTL.[StatusCode] = -1 THEN 'Ignored'
              WHEN PTL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN PTL.[StatusCode] = 1 THEN 'Complete'
              WHEN PTL.[StatusCode] = 2 THEN 'Error'
              WHEN PTL.[StatusCode] = 3 THEN 'Overridden'
         END AS [ProcessTaskStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, PTL.[StartDateTime], PTL.[EndDateTime]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PTL.[StartDateTime], PTL.[EndDateTime]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PTL.[StartDateTime], PTL.[EndDateTime]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PTL.[StartDateTime], PTL.[EndDateTime]) % (60*60)%(60)))),3)) 
         [ProcessTaskDuration]
        ,PTCL.[ProcessTaskCaptureLogID]
        ,PTCL.[InsertCount] + PTCL.[DeleteCount] + PTCL.[MergeCount] + PTCL.[UpdateCount] + PTCL.[RaiseCount] AS [CaptureCount]
        ,PTCL.[TargetObject] AS [EffectedObject]
        ,BELID.[BulkExtractByIDLogID]
        ,BELDD.[BulkExtractByDateLogID]
        ,CELID.[CDOExtractByIDLogID]
        ,CELDD.[CDOExtractByDateLogID]
        ,EL.[ErrorLine]
        ,EL.[ErrorNumber]
        ,EL.[ErrorProcedure]
        ,EL.[ErrorMessage]
    FROM [Config].[vProcess] P
   INNER JOIN [Logging].[Process] PL WITH (NOLOCK)
      ON P.ProcessID = PL.ProcessID
   LEFT JOIN [Config].[vProcesstask] PT WITH (NOLOCK)
      ON P.ProcessID = PT.ProcessID
   LEFT JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
      ON PL.ProcessLogID = PTL.ProcessLogID
     AND PL.ProcessLogCreatedMonth = PTL.ProcessLogCreatedMonth
     AND PT.ProcessTaskID = PTL.ProcessTaskID
   LEFT JOIN [Logging].[ProcessTaskCapture] PTCL WITH (NOLOCK)
      ON PL.ProcessLogID = PTCL.ProcessLogID
     AND PL.ProcessLogCreatedMonth = PTCL.ProcessLogCreatedMonth
     AND PT.ProcessTaskID = PTCL.ProcessTaskID
   LEFT JOIN [Logging].[BulkExtractByID] BELID WITH (NOLOCK)
      ON PL.ProcessLogID = BELID.ProcessLogID
     AND PL.ProcessLogCreatedMonth = BELID.ProcessLogCreatedMonth
     AND PT.ProcessTaskID = BELID.ProcessTaskID
   LEFT JOIN [Logging].[BulkExtractByDate] BELDD WITH (NOLOCK)
      ON PL.ProcessLogID = BELDD.ProcessLogID
     AND PL.ProcessLogCreatedMonth = BELDD.ProcessLogCreatedMonth
     AND PT.ProcessTaskID = BELDD.ProcessTaskID
   LEFT JOIN [Logging].[CDOExtractByID] CELID WITH (NOLOCK)
      ON PL.ProcessLogID = CELID.ProcessLogID
     AND PL.ProcessLogCreatedMonth = CELID.ProcessLogCreatedMonth
     AND PT.ProcessTaskID = CELID.ProcessTaskID
   LEFT JOIN [Logging].[CDOExtractByDate] CELDD WITH (NOLOCK)
      ON PL.ProcessLogID = CELDD.ProcessLogID
     AND PL.ProcessLogCreatedMonth = CELDD.ProcessLogCreatedMonth
     AND PT.ProcessTaskID = CELDD.ProcessTaskID
   LEFT JOIN [Logging].[Error] EL WITH (NOLOCK)
      ON PL.ProcessLogID = EL.ProcessLogID
     AND (PTL.ProcessTaskLogID = EL.ProcessTaskLogID OR EL.ProcessTaskLogID = -1);
GO


-- LogAverageDuration --
GO
CREATE VIEW [Logging].[vProcessAverageDuration]
  WITH SCHEMABINDING
AS
  SELECT [ProcessID]
        ,[ProcessName]
        ,[LogStatus]
        ,COUNT([ProcessLogID]) AS LogCount
          ,(RIGHT('00' + CONVERT(VARCHAR,(AVG([DurationS]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((AVG([DurationS]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((AVG([DurationS]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((AVG([DurationS]) % (60*60)%(60)))),3))          
         [AverageDuration]
         ,AVG([DurationS]) AS [AverageDuration(s)] FROM (
  SELECT [ProcessID]
        ,[ProcessName]
        ,[ProcessLogID]
        ,[LogCreatedDate]
        ,[LogStatus]
        ,DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) AS DurationS
        ,[StartDateTime]
        ,[EndDateTime]
    FROM [Logging].[vProcess] L WITH (NOLOCK) )QRY 
  GROUP BY [ProcessID]
          ,[ProcessName]
          ,[LogStatus];
GO


-- Log Incomplete --
GO
CREATE VIEW [Logging].[vProcessIncomplete]
  WITH SCHEMABINDING
AS
  SELECT [ProcessID]
        ,[ProcessName]
        ,[ProcessDescription]
        ,[ProcessLogID]
        ,[LogCreatedDate]
        ,[LogStatus]
        ,DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) AS DurationS
          ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) % (60*60)%(60)))),3)) 
         [Duration]
        ,[StartDateTime]
    FROM [Logging].[vProcess] L WITH (NOLOCK)
   WHERE [LogStatus] = 'Incomplete';
GO


-- Log --
GO
CREATE VIEW [Logging].[vProcessTask]
  WITH SCHEMABINDING
AS
  SELECT PT.ProcessID
        ,PT.ProcessName
        ,PT.ProcessTaskID
        ,PT.[TaskID]
        ,PT.[TaskName]
        ,PT.[TaskDescription]
        ,PTL.ProcessLogID
        ,PTL.[ProcessTaskLogID]
        ,PTL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN [StatusCode] = -1 THEN 'Ignored'
              WHEN [StatusCode] = 0 THEN 'Incomplete'
              WHEN [StatusCode] = 1 THEN 'Complete'
              WHEN [StatusCode] = 2 THEN 'Error'
              WHEN [StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) % (60*60)%(60)))),3)) 
         [Duration]
        ,[StartDateTime]
        ,[EndDateTime]
    FROM [Config].[vProcessTask] PT WITH (NOLOCK)
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
     ON  PT.ProcessTaskID = PTL.ProcessTaskID;
GO

-- Log Incomplete --
GO
CREATE VIEW [Logging].[vProcessTaskIncomplete]
  WITH SCHEMABINDING
AS
  SELECT [TaskID]
        ,[TaskName]
        ,[ProcessTaskLogID]
        ,[LogCreatedDate]
        ,[LogStatus]
        ,DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) AS DurationS
          ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, [StartDateTime], SYSUTCDATETIME()) % (60*60)%(60)))),3)) 
         [Duration]
        ,[StartDateTime]
    FROM [Logging].[vProcessTask] L WITH (NOLOCK)
   WHERE [LogStatus] = 'Incomplete';
GO

-- LogAverageDuration --
CREATE VIEW [Logging].[vProcessTaskAverageDuration]
  WITH SCHEMABINDING
AS
  SELECT [ProcessID]
        ,[ProcessName]
        ,[TaskID]
        ,[TaskName]
        ,[LogStatus]
        ,COUNT([ProcessTaskLogID]) AS LogCount
          ,(RIGHT('00' + CONVERT(VARCHAR,(AVG([DurationS]) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((AVG([DurationS]) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((AVG([DurationS]) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((AVG([DurationS]) % (60*60)%(60)))),3))          
         [AverageDuration]
         ,AVG([DurationS]) AS [AverageDuration(s)] FROM (
  SELECT [ProcessID]
        ,[ProcessName]
        ,[TaskID]
        ,[TaskName]
        ,[ProcessTaskLogID]
        ,[LogCreatedDate]
        ,[LogStatus]
        ,DATEDIFF(SECOND, [StartDateTime], [EndDateTime]) AS DurationS
        ,[StartDateTime]
        ,[EndDateTime]
    FROM [Logging].[vProcessTask] L WITH (NOLOCK) )QRY 
  GROUP BY [ProcessID]
          ,[ProcessName]
          ,[TaskID]
          ,[TaskName]
          ,[LogStatus];
GO
GO
CREATE VIEW [Logging].[vProcessTaskCapture]
  WITH SCHEMABINDING
AS
  SELECT PT.[ProcessID]
        ,PT.[ProcessName]
        ,PTL.[ProcessLogID]
        ,PTL.[ProcessTaskLogID]
        ,PT.[ProcessTaskID]
        ,PT.[Taskname]
        ,PT.[TaskTypeCode]
        ,TCL.[CreatedDateTime] AS LogCreatedDate
        ,TCL.[ProcessTaskCaptureLogID]
        ,TCL.[TargetObject] AS EffectedObject
        ,TCL.[TargetObjectType] AS EffectedObjectType
        ,TCL.[RaiseCount]
        ,TCL.[MergeCount]
        ,TCL.[InsertCount]
        ,TCL.[UpdateCount]
        ,TCL.[DeleteCount]
        ,PTL.[StartDateTime]
        ,PTL.[EndDateTime]
    FROM [Config].[vProcessTask] PT WITH (NOLOCK)
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
      ON PT.ProcessTaskID = PTL.ProcessTaskID
   INNER JOIN [Logging].[ProcessTaskCapture] TCL WITH (NOLOCK)
      ON PTL.ProcessLogID = TCL.ProcessLogID
     AND PTL.ProcessLogCreatedMonth = TCL.ProcessLogCreatedMonth
     AND PTL.ProcessTaskLogID = TCL.ProcessTaskLogID;
GO
GO
CREATE VIEW [Logging].[vExtract]
  WITH SCHEMABINDING
AS
  SELECT PL.[ProcessLogID]
        ,PTE.[ProcessID]
        ,PTE.[ProcessName]
        ,PTL.[ProcessTaskLogID]
        ,CEL.[ExtractLogTable]
        ,PTE.[ExtractTypeCode]
        ,PTE.[ExtractDatabase]
        ,PTE.[ExtractObject]
        ,PTE.[TrackedColumn]
        ,PL.[CreatedDateTime] AS [LogCreatedDate]
        ,CEL.[BulkExtractByIDLogID] AS [ExtractLogID]
        ,CASE WHEN PL.[StatusCode] = -1 THEN 'Ignored'
              WHEN PL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN PL.[StatusCode] = 1 THEN 'Complete'
              WHEN PL.[StatusCode] = 2 THEN 'Error'
              WHEN PL.[StatusCode] = 3 THEN 'Overridden'
         END AS [ProcessLogStatus]
        ,TCL.[TargetObject] AS [EffectedObject]
        ,TCL.[RaiseCount]
        ,TCL.[MergeCount]
        ,TCL.[InsertCount]
        ,TCL.[UpdateCount]
        ,TCL.[DeleteCount]
        ,PL.[StartDateTime] AS [ProcessStartDate]
        ,PL.[EndDateTime] AS [ProcessEndDate]
    FROM [Config].[vProcessTaskExtract] PTE WITH (NOLOCK)
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
      ON  PTE.ProcessTaskID = PTL.ProcessTaskID
   INNER JOIN [Logging].[Process] PL WITH (NOLOCK)
      ON  PTL.ProcessLogID = PL.ProcessLogID
     AND  PTL.ProcessLogCreatedMonth = PL.ProcessLogCreatedMonth
   INNER JOIN ( SELECT 'BulkExtractByID' AS ExtractLogTable, CEL.ProcessTaskID, CEL.TaskExtractSourceID, CEL.BulkExtractByIDLogID, CEL.ProcessTaskLogID
                 FROM [Logging].[BulkExtractByID] CEL WITH (NOLOCK)
                UNION ALL
                SELECT 'BulkExtractByDate' AS ExtractLogTable, CEL.ProcessTaskID, CEL.TaskExtractSourceID, CEL.BulkExtractByDateLogID, CEL.ProcessTaskLogID
                 FROM [Logging].[BulkExtractByDate] CEL WITH (NOLOCK)
                UNION ALL
                SELECT 'CDOExtractByID' AS ExtractLogTable, CEL.ProcessTaskID, CEL.TaskExtractSourceID, CEL.CDOExtractByIDLogID, CEL.ProcessTaskLogID
                 FROM [Logging].[CDOExtractByID] CEL WITH (NOLOCK)
                UNION ALL
                SELECT 'CDOExtractByDate' AS ExtractLogTable, CEL.ProcessTaskID, CEL.TaskExtractSourceID, CEL.CDOExtractByDateLogID, CEL.ProcessTaskLogID
                 FROM [Logging].[CDOExtractByDate] CEL WITH (NOLOCK) ) CEL
       ON  PTE.ProcessTaskID = CEL.ProcessTaskID
      AND  PTE.TaskExtractSourceID = CEL.TaskExtractSourceID 
      AND  PTL.ProcessTaskLogID = CEL.ProcessTaskLogID
     LEFT  JOIN [Logging].[ProcessTaskCapture] TCL WITH (NOLOCK)
       ON  PTL.ProcessLogID = TCL.ProcessLogID
      AND  PTL.ProcessLogCreatedMonth = TCL.ProcessLogCreatedMonth;
GO
-- BulkExtractLog --
GO
CREATE VIEW [Logging].[vBulkExtractByID]
  WITH SCHEMABINDING
AS
  SELECT PTE.[ProcessID]
        ,PTE.[ProcessName]
        ,PTE.[Taskname]
        ,PTE.[TaskTypeCode]
        ,PTE.[ExtractTypeCode]
        ,PTE.[ExtractDatabase]
        ,PTE.[ExtractObject]
        ,PTE.[TrackedColumn]
        ,PTL.[ProcessLogID]
        ,BEL.[ProcessTaskLogID]
        ,BEL.[BulkExtractByIDLogID] AS [ExtractLogID]
        ,BEL.[MinSourceTableID]
        ,BEL.[MaxSourceTableID]
        ,BEL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN BEL.[StatusCode] = -1 THEN 'Ignored'
              WHEN BEL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN BEL.[StatusCode] = 1 THEN 'Complete'
              WHEN BEL.[StatusCode] = 2 THEN 'Error'
              WHEN BEL.[StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),3)) 
         [Duration]
        ,BEL.[StartDateTime]
        ,BEL.[EndDateTime]
    FROM [Config].[vProcessTaskExtract] PTE WITH (NOLOCK)
   INNER JOIN [Logging].[BulkExtractByID] BEL WITH (NOLOCK)
     ON  PTE.ProcessTaskID = BEL.ProcessTaskID
    AND  PTE.TaskExtractSourceID = BEL.TaskExtractSourceID
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
     ON  BEL.ProcessLogID = PTL.ProcessLogID
    AND  BEL.ProcessLogCreatedMonth = PTL.ProcessLogCreatedMonth
    AND  BEL.ProcessTaskLogID = PTL.ProcessTaskLogID;
GO

GO
CREATE VIEW [Logging].[vBulkExtractByDate]
  WITH SCHEMABINDING
AS
  SELECT PTE.[ProcessID]
        ,PTE.[ProcessName]
        ,PTE.[Taskname]
        ,PTE.[TaskTypeCode]
        ,PTE.[ExtractTypeCode]
        ,PTE.[ExtractDatabase]
        ,PTE.[ExtractObject]
        ,PTE.[TrackedColumn]
        ,PTL.[ProcessLogID]
        ,BEL.[ProcessTaskLogID]
        ,BEL.[BulkExtractByDateLogID] AS [ExtractLogID]
        ,BEL.[MinSourceDateTime]
        ,BEL.[MaxSourceDateTime]
        ,BEL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN BEL.[StatusCode] = -1 THEN 'Ignored'
              WHEN BEL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN BEL.[StatusCode] = 1 THEN 'Complete'
              WHEN BEL.[StatusCode] = 2 THEN 'Error'
              WHEN BEL.[StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, BEL.[StartDateTime], ISNULL(BEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),3)) 
         [Duration]
        ,BEL.[StartDateTime]
        ,BEL.[EndDateTime]
    FROM [Config].[vProcessTaskExtract] PTE WITH (NOLOCK)
   INNER JOIN [Logging].[BulkExtractByDate] BEL WITH (NOLOCK)
     ON  PTE.ProcessTaskID = BEL.ProcessTaskID
    AND  PTE.TaskExtractSourceID = BEL.TaskExtractSourceID
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
     ON  BEL.ProcessLogID = PTL.ProcessLogID
    AND  BEL.ProcessLogCreatedMonth = PTL.ProcessLogCreatedMonth
    AND  BEL.ProcessTaskLogID = PTL.ProcessTaskLogID;
GO

-- CDOExtractLog --
GO
CREATE VIEW [Logging].[vCDOExtractByID]
  WITH SCHEMABINDING
AS
  SELECT PTE.[ProcessID]
        ,PTE.[ProcessName]
        ,PTE.[Taskname]
        ,PTE.[TaskTypeCode]
        ,PTE.[ExtractTypeCode]
        ,PTE.[ExtractDatabase]
        ,PTE.[ExtractObject]
        ,PTE.[TrackedColumn]
        ,PTL.[ProcessLogID]
        ,CEL.[ProcessTaskLogID]
        ,CEL.[CDOExtractByIDLogID] AS [ExtractLogID]
        ,CEL.[MinSourceTableID]
        ,CEL.[MaxSourceTableID]
        ,CEL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN CEL.[StatusCode] = -1 THEN 'Ignored'
              WHEN CEL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN CEL.[StatusCode] = 1 THEN 'Complete'
              WHEN CEL.[StatusCode] = 2 THEN 'Error'
              WHEN CEL.[StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),3)) 
         [Duration]
        ,CEL.[StartDateTime]
        ,CEL.[EndDateTime]
    FROM [Config].[vProcessTaskExtract] PTE WITH (NOLOCK)
   INNER JOIN [Logging].[CDOExtractByID] CEL WITH (NOLOCK)
     ON  PTE.ProcessTaskID = CEL.ProcessTaskID
    AND  PTE.TaskExtractSourceID = CEL.TaskExtractSourceID
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
     ON  CEL.ProcessLogID = PTL.ProcessLogID
    AND  CEL.ProcessLogCreatedMonth = PTL.ProcessLogCreatedMonth
    AND  CEL.ProcessTaskLogID = PTL.ProcessTaskLogID;
GO

GO
CREATE VIEW [Logging].[vCDOExtractByDate]
  WITH SCHEMABINDING
AS
  SELECT PTE.[ProcessID]
        ,PTE.[ProcessName]
        ,PTE.[Taskname]
        ,PTE.[TaskTypeCode]
        ,PTE.[ExtractTypeCode]
        ,PTE.[ExtractDatabase]
        ,PTE.[ExtractObject]
        ,PTE.[TrackedColumn]
        ,PTL.[ProcessLogID]
        ,CEL.[ProcessTaskLogID]
        ,CEL.[CDOExtractByDateLogID] AS [ExtractLogID]
        ,CEL.[MinSourceDateTime]
        ,CEL.[MaxSourceDateTime]
        ,CEL.[CreatedDateTime] AS [LogCreatedDate]
        ,CASE WHEN CEL.[StatusCode] = -1 THEN 'Ignored'
              WHEN CEL.[StatusCode] = 0 THEN 'Incomplete'
              WHEN CEL.[StatusCode] = 1 THEN 'Complete'
              WHEN CEL.[StatusCode] = 2 THEN 'Error'
              WHEN CEL.[StatusCode] = 3 THEN 'Overridden'
         END AS [LogStatus]
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, CEL.[StartDateTime], ISNULL(CEL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),3)) 
         [Duration]
        ,CEL.[StartDateTime]
        ,CEL.[EndDateTime]
    FROM [Config].[vProcessTaskExtract] PTE WITH (NOLOCK)
   INNER JOIN [Logging].[CDOExtractByDate] CEL WITH (NOLOCK)
     ON  PTE.ProcessTaskID = CEL.ProcessTaskID
    AND  PTE.TaskExtractSourceID = CEL.TaskExtractSourceID
   INNER JOIN [Logging].[ProcessTask] PTL WITH (NOLOCK)
     ON  CEL.ProcessLogID = PTL.ProcessLogID
    AND  CEL.ProcessLogCreatedMonth = PTL.ProcessLogCreatedMonth
    AND  CEL.ProcessTaskLogID = PTL.ProcessTaskLogID;
GO

-- TaskInfoLog --
GO
CREATE VIEW [Logging].[vProcessTaskInfo]
  WITH SCHEMABINDING
AS
  SELECT PT.[ProcessID]
        ,PT.[ProcessName]
        ,PT.[TaskName]
        ,PT.[TaskTypeCode]
        ,PTIL.[ProcessLogID]
        ,PTIL.[ProcessTaskLogID]
        ,PTIL.[ProcessTaskInfoLogID]
        ,PTIL.[CreatedDateTime] AS [LogCreatedDate]
        ,PTIL.Ordinal AS StepNumber
        ,PTIL.InfoMessage
           ,(RIGHT('00' + CONVERT(VARCHAR,(DATEDIFF(SECOND, PTIL.[StartDateTime], ISNULL(PTIL.[EndDateTime],SYSUTCDATETIME())) / (60*60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PTIL.[StartDateTime], ISNULL(PTIL.[EndDateTime],SYSUTCDATETIME())) % (60*60)) / (60))),2)
                 + ':' +
                 RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PTIL.[StartDateTime], ISNULL(PTIL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),2)
              + '.' +
              RIGHT('00' + CONVERT(VARCHAR,((DATEDIFF(SECOND, PTIL.[StartDateTime], ISNULL(PTIL.[EndDateTime],SYSUTCDATETIME())) % (60*60)%(60)))),3)) 
         [Duration]
        ,PTIL.[StartDateTime]
        ,PTIL.[EndDateTime]
    FROM [Config].[vProcessTask] PT
   INNER JOIN [Logging].[ProcessTaskInfo] PTIL WITH (NOLOCK)
     ON  PT.ProcessTaskID = PTIL.ProcessTaskID;
GO

-- ErrorLog --
GO
CREATE VIEW [Logging].[vError]
  WITH SCHEMABINDING
AS
  SELECT P.[ProcessID]
        ,P.[ProcessName]
        ,PL.[ProcessLogID]
        ,T.[TaskID]
        ,T.[TaskName]
        ,PT.[ProcessTaskLogID]
        ,EL.[ErrorLogID]
        ,EL.[CreatedDateTime] AS [ErrorDate]
        ,EL.[ErrorNumber]
        ,EL.[ErrorProcedure]
        ,EL.[ErrorLine]
        ,EL.[ErrorMessage]
    FROM [Logging].[Error] EL WITH (NOLOCK)
    LEFT JOIN [Config].[Process] P WITH (NOLOCK)
      ON EL.ProcessID = P.ProcessID
    LEFT JOIN [Config].[Task] T WITH (NOLOCK)
      ON EL.TaskID = T.TaskID
    LEFT JOIN [Logging].[Process] PL WITH (NOLOCK)
     ON  EL.ProcessLogID = PL.ProcessLogID
    LEFT JOIN [Logging].[ProcessTask] PT WITH (NOLOCK)
     ON  EL.ProcessTaskLogID = PT.ProcessTaskLogID;
GO

GO
CREATE VIEW [Logging].[vErrorPayloadXML]
  WITH SCHEMABINDING
AS
  SELECT P.[ProcessID]
        ,P.[ProcessName]
        ,PL.[ProcessLogID]
        ,T.[TaskID]
        ,T.[TaskName]
        ,PT.[ProcessTaskLogID]
        ,EL.[ErrorLogID]
        ,EL.[CreatedDateTime] AS [ErrorDate]
        ,EL.[ErrorNumber]
        ,EL.[ErrorProcedure]
        ,EL.[ErrorLine]
        ,EL.[ErrorMessage]
        ,EP.[ConversationHandle]
        ,EP.[ConversationID]
        ,EP.[ErrorPayload]
    FROM [Logging].[Error] EL WITH (NOLOCK)
   INNER JOIN [Logging].[ErrorPayloadXML] EP WITH (NOLOCK)
      ON EL.ErrorLogID = EP.ErrorLogID
    LEFT JOIN [Config].[Process] P WITH (NOLOCK)
      ON EL.ProcessID = P.ProcessID
    LEFT JOIN [Config].[Task] T WITH (NOLOCK)
      ON EL.TaskID = T.TaskID
    LEFT JOIN [Logging].[Process] PL WITH (NOLOCK)
     ON  EL.ProcessLogID = PL.ProcessLogID
    LEFT JOIN [Logging].[ProcessTask] PT WITH (NOLOCK)
     ON  EL.ProcessTaskLogID = PT.ProcessTaskLogID;
GO


/* End of File ********************************************************************************************************************/
