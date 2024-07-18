/***********************************************************************************************************************************
* Script      : 99.Common - Setup.sql                                                                                              *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Base Process                                                                                                   *
*             :  2. Base TaskType                                                                                                  *
*             :  3. Base ExtractType                                                                                               *
*             :  4. Base Task                                                                                                      *
*             :  5. Base ProcessTask                                                                                               *
*             :  6. Base ExtractSource                                                                                             *
*             :  7. Base TaskExtractSource                                                                                         *
*             :  8. Base VariableGroup                                                                                             *
*             :  9. Base Variable                                                                                                  *
*             : 10. Monitoring                                                                                                     *
***********************************************************************************************************************************/
USE [dbSurge]
GO

/***********************************************************************************************************************************
-- Process --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = 'Unknown') BEGIN;
  SET IDENTITY_INSERT [Config].[Process] ON;
  INSERT INTO [Config].[Process] ([ProcessID], [ProcessName], [ProcessDescription], [IsEnabled]) VALUES(-1, 'Unknown', 'Unknown Process', 0);
  SET IDENTITY_INSERT [Config].[Process] OFF;
END;
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = 'JobController_01') BEGIN;
  SET IDENTITY_INSERT [Config].[Process] ON;
  INSERT INTO [Config].[Process] ([ProcessID], [ProcessName], [ProcessDescription], [IsEnabled]) VALUES(-10, 'JobController_01', 'Job Controller proces for loop jobs', 1);
  SET IDENTITY_INSERT [Config].[Process] OFF;
END;
SELECT * FROM [Config].[Process];
/***********************************************************************************************************************************
-- Task Type --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'UNK') BEGIN;
  SET IDENTITY_INSERT [Config].[TaskType] ON;
  INSERT INTO [Config].[TaskType] ([TaskTypeID], [TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES(-1, 'UNK', 'Unknown', 'Unknown Task Type');
  SET IDENTITY_INSERT [Config].[TaskType] OFF;
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'EXT') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('EXT', 'Extract', 'Extract data');
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'STG') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('STG', 'Stage', 'Stage transformed data');
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'LOD') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('LOD', 'Load', 'Load data to target tables');
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'REV') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('REV', 'RaiseEvent', 'Raise events');
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'MOV') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('MOV', 'Move', 'Move dataset via partition switching or similar mechanism');
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'ETL') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('ETL', 'ETL', 'Extract, transform and load to target');
END;
IF NOT EXISTS (SELECT * FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'MTN') BEGIN;
  INSERT INTO [Config].[TaskType] ([TaskTypeCode], [TaskTypeName], [TaskTypeDescription]) VALUES('MTN', 'Maintain', 'Maintenance tasks e.g. Partition management');
END;
SELECT * FROM [Config].[TaskType];
/***********************************************************************************************************************************
-- Task --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'Unknown') BEGIN;
  SET IDENTITY_INSERT [Config].[Task] ON;
  INSERT INTO [Config].[Task] ([TaskID], [TaskTypeID], [Taskname], [TaskDescription]) VALUES(-1, -1, 'Unknown', 'Unknown Task');
  SET IDENTITY_INSERT [Config].[Task] OFF;
END;
DECLARE @TaskTypeID SMALLINT;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'EXT');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'Extract') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'Extract', 'Extract rows based on tracked range');
END;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'STG');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'StageData') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'StageData', 'Stage extracted data');
END;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'LOD');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'LoadData') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'LoadData', 'Load Staged data to target table(s)');
END;
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'JobFailures') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'JobFailures', 'Process Job Failures to table(s)');
END;
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'ControllerJobDisabled') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'ControllerJobDisabled', 'Process detection of Control jobs that are not running to table(s)');
END;
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'SourceMappingsMismatch') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'SourceMappingsMismatch', 'Process Mappings variances table(s)');
END;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'MTN');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'PartitionSplit') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'PartitionSplit', 'Split existing partition function and scheme');
END;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'MTN');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'PartitionMerge') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'PartitionMerge', 'Merge existing partition function and scheme');
END;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'MTN');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'PartitionSwitch') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'PartitionSwitch', 'Switch partition');
END;
SELECT * FROM [Config].[Task];
/***********************************************************************************************************************************
-- Process Task --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = -1 AND [TaskID] = -1) BEGIN;
  SET IDENTITY_INSERT [Config].[ProcessTask] ON;
  INSERT INTO [Config].[ProcessTask] ([ProcessTaskID], [ProcessID], [TaskID], [IsEnabled]) VALUES(-1, -1, -1, 0);
  SET IDENTITY_INSERT [Config].[ProcessTask] OFF;
END;
SELECT * FROM [Config].[ProcessTask];
/***********************************************************************************************************************************
-- Extract Type --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = 'UNK') BEGIN;
  SET IDENTITY_INSERT [Config].[ExtractType] ON;
  INSERT INTO [Config].[ExtractType] ([ExtractTypeID], [ExtractTypeCode], [ExtractTypeName], [ExtractTypeDescription]) VALUES(-1, 'UNK', 'Unknown', 'Unknown Task Type');
  SET IDENTITY_INSERT [Config].[ExtractType] OFF;
END;
IF NOT EXISTS (SELECT * FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = 'CDO') BEGIN;
  INSERT INTO [Config].[ExtractType] ([ExtractTypeCode], [ExtractTypeName], [ExtractTypeDescription]) VALUES('CDO', 'Change Data Object', 'Extract based on changes to tracked column value');
END;
IF NOT EXISTS (SELECT * FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = 'CDC') BEGIN;
  INSERT INTO [Config].[ExtractType] ([ExtractTypeCode], [ExtractTypeName], [ExtractTypeDescription]) VALUES('CDC', 'Change Data Capture', 'Extract based on automated log scraping by DB engine');
END;
IF NOT EXISTS (SELECT * FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = 'CT') BEGIN;
  INSERT INTO [Config].[ExtractType] ([ExtractTypeCode], [ExtractTypeName], [ExtractTypeDescription]) VALUES('CT', 'Change Tracking', 'Extract based on automated change tracking by DB engine');
END;
IF NOT EXISTS (SELECT * FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = 'BUL') BEGIN;
  INSERT INTO [Config].[ExtractType] ([ExtractTypeCode], [ExtractTypeName], [ExtractTypeDescription]) VALUES('BUL', 'Bulk Extract', 'Extract based on manually provided range values');
END;
IF NOT EXISTS (SELECT * FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = 'FUL') BEGIN;
  INSERT INTO [Config].[ExtractType] ([ExtractTypeCode], [ExtractTypeName], [ExtractTypeDescription]) VALUES('FUL', 'Full Extract', 'Extract full dataset');
END;
SELECT * FROM [Config].[ExtractType];
/***********************************************************************************************************************************
-- Extract Source --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[ExtractSource] WHERE [ExtractTypeID] = -1 AND [ExtractObject] = 'Unknown' AND [ExtractObject] = 'Unknown') BEGIN;
  SET IDENTITY_INSERT [Config].[ExtractSource] ON;
  INSERT INTO [Config].[ExtractSource] ([ExtractSourceID], [ExtractTypeID], [ExtractDatabase], [ExtractObject]) VALUES(-1, -1, 'Unknown', 'Unknown');
  SET IDENTITY_INSERT [Config].[ExtractSource] OFF;
END;
SELECT * FROM [Config].[ExtractSource];
/***********************************************************************************************************************************
-- Task Extract Source --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTaskExtractSource] WHERE [ProcessTaskID] = -1 AND  [ExtractSourceID] = -1) BEGIN;
  SET IDENTITY_INSERT [Config].[ProcessTaskExtractSource] ON;
  INSERT INTO [Config].[ProcessTaskExtractSource] ([TaskExtractSourceID], [ProcessTaskID], [ExtractSourceID]) VALUES(-1, -1, -1);
  SET IDENTITY_INSERT [Config].[ProcessTaskExtractSource] OFF;
END;
SELECT * FROM [Config].[ProcessTaskExtractSource];
/***********************************************************************************************************************************
-- Config Group --
***********************************************************************************************************************************/
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Extract')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Extract');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Stage')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Stage');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Load')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Load');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Held')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Held');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'AppLock')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('AppLock');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Logging')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Logging');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Job')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Job');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Integrity')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Integrity');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Monitoring')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Monitoring');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Notification')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Notification');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Maintenance')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Maintenance');
 IF NOT EXISTS (SELECT 1 FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Process')
   INSERT INTO [Config].[VariableGroup] ([ConfigGroupName]) VALUES ('Process');
SELECT * FROM [Config].[VariableGroup];
/***********************************************************************************************************************************
-- Config --
***********************************************************************************************************************************/
DECLARE @ConfigGroupID SMALLINT;
-- Extract --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Extract');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'BatchSize')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'BatchSize', 'INT', '1000000', 'The maximum number of rows to be processed per iteration');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Disabled')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Disabled', 'BIT', '0', 'If set to 1, DISABLE Extract');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'RebuildHoldingIndex')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'RebuildHoldingIndex', 'BIT', '0', 'If set to 1, REBUILD all indexes on holding table');

-- Stage --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Stage');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'BatchSize')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'BatchSize', 'INT', '250000', 'The maximum number of rows to be processed per iteration');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Disabled')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Disabled', 'BIT', '0', 'If set to 1, DISABLE Stage');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'RebuildHoldingIndex')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'RebuildHoldingIndex', 'BIT', '0', 'If set to 1, REBUILD all indexes on holding table');

-- Load --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Load');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'BatchSize')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'BatchSize', 'INT', '250000', 'The maximum number of rows to be processed per iteration');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Disabled')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Disabled', 'BIT', '0', 'If set to 1, DISABLE Load');

-- Held --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Held');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Ignore')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Ignore', 'BIT', '0', 'If set to 1, IGNORE entries that are Held when processing');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Disabled')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Disabled', 'BIT', '0', 'If set to 1, DISABLE capture of Held entries');

-- AppLock -- Retry
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Applock');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Retry')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Retry', 'INT', '5', 'The number of attempts made to acquire a lock using sp_GetAppLock');

-- AppLock -- Timeout
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Applock');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'Timeout')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'Timeout', 'INT', '1000', 'The timeout in milliseconds to acquire a lock using sp_GetAppLock');

-- Logging --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Logging');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'InfoDisabled')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'InfoDisabled', 'BIT', '1', 'If set to 1, DISABLE Info Logging when processing');
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Logging');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'CaptureDisabled')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'CaptureDisabled', 'BIT', '0', 'If set to 1, DISABLE Capture Logging when processing');
-- Job --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Job');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'WaitforDelay')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'WaitforDelay', 'CHAR(8)', '00:00:05', 'Wait interval between job executions');

-- Maintenance --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Maintenance');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'LockTimeout')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'LockTimeout', 'INT', '30000', 'Wait interval (ms) to acquire an object lock for LOCK_TIMEOUT');
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Maintenance');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'PartitionIncreaseCount')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'PartitionIncreaseCount', 'INT', '1', 'Number of partitions to add when performing SPLIT');
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Maintenance');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'PartitionRetainCount')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'PartitionRetainCount', 'INT', '14', 'Number of partitions to retain in current when performing SWITCH');
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Maintenance');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'TruncateTarget')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'TruncateTarget', 'BIT', '0', 'If set to 1, ENABLE truncation of target partition');

-- Process --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Process');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'JobControllerIteration')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'JobControllerIteration', 'SMALLINT', '10', 'The maximum number of jobs to be started per controller iteration');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'JobControllerActiveJobLimit')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'JobControllerActiveJobLimit', 'SMALLINT', '150', 'The maximum number of jobs that can be concurrently active');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'JobControllerExecutionStyle')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'JobControllerExecutionStyle', 'VARCHAR(30)', 'Limit', 'Specify whether controller works on Iterate or Limit method.');
SELECT * FROM [Config].[Variable]
/***********************************************************************************************************************************
-- Monitoring --
***********************************************************************************************************************************/
-- NONE --
/***********************************************************************************************************************************
-- Notification --
***********************************************************************************************************************************/
-- NONE --

/***********************************************************************************************************************************
-- Maintenance --
***********************************************************************************************************************************/
/***********************************************************************************************************************************
-- Process Config --
***********************************************************************************************************************************/
DECLARE @ProcessID SMALLINT;
SET @ProcessID = [Config].[GetProcessIDByName] ('JobController_01');
EXEC [Config].[SetVariable_Process]   @ProcessID = @ProcessID,
                                      @ConfigGroupName = 'Process',
                                      @ConfigName = 'JobControllerIteration',
                                      @ConfigValue = 30,
                                      @Delete = 0;
EXEC [Config].[SetVariable_Process]   @ProcessID = @ProcessID,
                                      @ConfigGroupName = 'Process',
                                      @ConfigName = 'JobControllerActiveJobLimit',
                                      @ConfigValue = 150,
                                      @Delete = 0;
EXEC [Config].[SetVariable_Process]   @ProcessID = @ProcessID,
                                      @ConfigGroupName = 'Process',
                                      @ConfigName = 'JobControllerExecutionStyle',
                                      @ConfigValue = 'Limit',
                                      @Delete = 0;
/* End of File ********************************************************************************************************************/