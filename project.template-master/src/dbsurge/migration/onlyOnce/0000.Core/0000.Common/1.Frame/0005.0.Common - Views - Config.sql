/***********************************************************************************************************************************
* Script      : 5.Common - Views - Config.sql                                                                                     *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Config                                                                                                           *
***********************************************************************************************************************************/
USE [dbSurge]
GO
CREATE VIEW [Config].[vProcessTaskVariable]
  WITH SCHEMABINDING
AS
  SELECT [CG].[ConfigGroupName],
         [C].[ConfigName],
         [P].[ProcessID],
         [P].[ProcessName],
         [TC].[ProcessTaskID],
         [T].[TaskName],
         ISNULL([TC].[ConfigValue], [C].[ConfigDefaultValue]) AS [ConfigValue]
    FROM [Config].[VariableGroup] CG
   INNER JOIN [Config].[Variable] C
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
   INNER JOIN [Config].[ProcessTaskVariable] TC
      ON [C].[ConfigID] = [TC].[ConfigID]
   INNER JOIN [Config].[ProcessTask] PT
      ON [TC].[ProcessTaskID] = [PT].[ProcessTaskID]
   INNER JOIN [Config].[Task] T
      ON [PT].[TaskID] = [T].[TaskID]
   INNER JOIN [Config].[Process] P
      ON [PT].[ProcessID] = [P].[ProcessID];
GO
GO
CREATE VIEW [Config].[vProcessVariable]
  WITH SCHEMABINDING
AS
  SELECT [CG].[ConfigGroupName],
         [C].[ConfigName],
         [PC].[ProcessID],
         ISNULL([PC].[ConfigValue], [C].[ConfigDefaultValue]) AS [ConfigValue]
    FROM [Config].[VariableGroup] CG
   INNER JOIN [Config].[Variable] C
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
   INNER JOIN [Config].[ProcessVariable] PC
      ON [C].[ConfigID] = [PC].[ConfigID]
   WHERE CG.ConfigGroupName = 'Process';
GO
GO
CREATE VIEW [Config].[vJobVariable]
  WITH SCHEMABINDING
AS
  SELECT [CG].[ConfigGroupName],
         [C].[ConfigName],
         [JC].[JobID],
         ISNULL([JC].[ConfigValue], [C].[ConfigDefaultValue]) AS [ConfigValue]
    FROM [Config].[VariableGroup] CG
   INNER JOIN [Config].[Variable] C
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
   INNER JOIN [Config].[JobVariable] JC
      ON [C].[ConfigID] = [JC].[ConfigID]
   WHERE CG.ConfigGroupName = 'Job';
GO
GO
CREATE VIEW [Config].[vJobQueue]
  WITH SCHEMABINDING
AS
  SELECT [J].[JobID],
         [J].[JobName],
		 [JQ].[EarliestNextExecution],
		 [JQ].[CreatedDateTime] AS [LastEnqueue],
         [J].[JobCategory],
         [J].[JobOwner],
         [C].[ConfigName],
         ISNULL([JC].[ConfigValue], [C].[ConfigDefaultValue]) AS [ConfigValue]
    FROM [Config].[JobQueue] JQ WITH (NOLOCK)
    INNER JOIN [Config].[Job] J WITH (NOLOCK)
	  ON [JQ].[JobID] = [J].[JobID]
    LEFT JOIN [Config].[JobVariable] JC WITH (NOLOCK)
      ON [J].[JobID] = [JC].[JobID]
    LEFT JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [JC].[ConfigID] = [C].[ConfigID]
    LEFT JOIN [Config].[VariableGroup] CG WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID];
GO

GO
CREATE VIEW [Config].[vJob]
  WITH SCHEMABINDING
AS
  SELECT [J].[JobID],
         [J].[ProcessID],
         [P].[ProcessName],
         [J].[JobName],
         [J].[JobDescription],
         [J].[JobCategory],
         [J].[JobOwner],
         [J].[JobScheduleName],
         [J].[IsLoopJob],
         [J].[IsControllerJob],
         [J].[IsEnabled],
         [J].[CreatedDateTime],
         [JS].[JobStepOrdinal],
         [JS].[JobStepName],
         [JS].[DatabaseName],
         [JS].[Command],
         CASE WHEN [JS].[OnSuccessAction] = 1 OR [JS].[OnSuccessAction] IS NULL THEN 'Quit with success'
              WHEN [JS].[OnSuccessAction] = 2 THEN 'Quit with failure'
              WHEN [JS].[OnSuccessAction] = 3 THEN 'Go to next step'
              WHEN [JS].[OnSuccessAction] = 4 THEN 'Go to step ordinal OnSuccessOrdinal'
          END AS [OnSuccessAction],
         [JS].[OnSuccessOrdinal],
         [JS].[RetryAttempts],
         [JS].[RetryInterval],
         CASE WHEN [JS].[OnFailAction] = 1 THEN 'Quit with success'
              WHEN [JS].[OnFailAction] = 2 OR [JS].[OnFailAction] IS NULL THEN 'Quit with failure'
              WHEN [JS].[OnFailAction] = 3 THEN 'Go to next step'
              WHEN [JS].[OnFailAction] = 4 THEN 'Go to step ordinal OnFailOrdinal'
          END AS [OnFailAction],
         [JS].[OnFailOrdinal],
         [CG].[ConfigGroupName],
         [C].[ConfigName],
         ISNULL([JC].[ConfigValue], [C].[ConfigDefaultValue]) AS [ConfigValue]
    FROM [Config].[Job] J
    LEFT JOIN [Config].[Process] P
      ON [J].[ProcessID] = [P].[ProcessID]
    LEFT JOIN [Config].[JobStep] JS
      ON [J].[JobID] = [JS].[JobID]
    LEFT JOIN [Config].[JobVariable] JC
      ON [J].[JobID] = [JC].[JobID]
    LEFT JOIN [Config].[Variable] C
      ON [JC].[ConfigID] = [C].[ConfigID]
    LEFT JOIN [Config].[VariableGroup] CG
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID];
GO
-- Process --
GO
CREATE VIEW [Config].[vProcess]
  WITH SCHEMABINDING
AS
 SELECT [ProcessID]
       ,[ProcessName]
       ,[ProcessDescription]
       ,[CreatedDateTime]
   FROM [Config].[Process] WITH (NOLOCK);
GO
-- Task --
GO
CREATE VIEW [Config].[vProcessTask]
  WITH SCHEMABINDING
AS
 SELECT P.[ProcessID]
       ,P.[ProcessName]
       ,P.[ProcessDescription]
       ,P.[IsEnabled] AS [IsProcessEnabled]
       ,P.[CreatedDateTime] AS [ProcessCreatedDate]
       ,PT.[ProcessTaskID]
       ,TT.[TaskTypeCode]
       ,TT.[TaskTypeName]
       ,T.[TaskID]
       ,T.[Taskname]
       ,T.[TaskDescription]
       ,PT.[IsEnabled] AS [IsProcessTaskEnabled]
   FROM [Config].[Process] P WITH (NOLOCK)
   LEFT JOIN [Config].[ProcessTask] PT WITH (NOLOCK)
     ON P.[ProcessID] = PT.[ProcessID]
   LEFT JOIN [Config].[Task] T WITH (NOLOCK)
    ON  PT.[TaskID] = T.[TaskID]
   LEFT JOIN [Config].[TaskType] TT WITH (NOLOCK)
    ON  T.[TaskTypeID] = TT.[TaskTypeID];
GO

GO
CREATE VIEW [Config].[vProcessTaskExtract]
  WITH SCHEMABINDING
AS
 SELECT P.[ProcessID]
       ,P.[ProcessName]
       ,P.[ProcessDescription]
       ,P.[IsEnabled] AS [IsProcessEnabled]
       ,P.[CreatedDateTime] AS [ProcessCreatedDate]
       ,PT.[ProcessTaskID]
       ,TT.[TaskTypeCode]
       ,TT.[TaskTypeName]
       ,T.[TaskID]
       ,T.[Taskname]
       ,T.[TaskDescription]
       ,PT.[IsEnabled] AS [IsProcessTaskEnabled]
       ,TS.[TaskExtractSourceID]
       ,ET.[ExtractTypeCode]
       ,ET.[ExtractTypeName]
       ,ES.[ExtractSourceID]
       ,ES.[ExtractDatabase]
       ,ES.[ExtractObject]
       ,ES.[TrackedColumn]
   FROM [Config].[Process] P WITH (NOLOCK)
   LEFT JOIN [Config].[ProcessTask] PT WITH (NOLOCK)
     ON P.[ProcessID] = PT.[ProcessID]
   LEFT JOIN [Config].[Task] T WITH (NOLOCK)
    ON  PT.[TaskID] = T.[TaskID]
   LEFT JOIN [Config].[TaskType] TT WITH (NOLOCK)
    ON  T.[TaskTypeID] = TT.[TaskTypeID]
   LEFT JOIN [Config].[ProcessTaskExtractSource] TS WITH (NOLOCK)
     ON  PT.[ProcessTaskID] = TS.[ProcessTaskID]
   LEFT JOIN [Config].[ExtractSource] ES WITH (NOLOCK)
    ON  TS.[ExtractSourceID] = ES.[ExtractSourceID]
   LEFT JOIN [Config].[ExtractType] ET WITH (NOLOCK)
    ON  ES.[ExtractTypeID] = ET.[ExtractTypeID];
GO
-- Config --
GO
CREATE VIEW [Config].[vGroupVariable]
  WITH SCHEMABINDING
AS
 SELECT  CG.[ConfigGroupID]
        ,CG.[ConfigGroupName]
        ,C.[ConfigID]
        ,C.[ConfigName]
        ,C.[ConfigDefaultValue]
        ,C.[Description]
   FROM [Config].[VariableGroup] CG WITH (NOLOCK)
   LEFT JOIN [Config].[Variable] C WITH (NOLOCK)
     ON CG.[ConfigGroupID] = C.[ConfigGroupID];
GO


/* End of File ********************************************************************************************************************/
