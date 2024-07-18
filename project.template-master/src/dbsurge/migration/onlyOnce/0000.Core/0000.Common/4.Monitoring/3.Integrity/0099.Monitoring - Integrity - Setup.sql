/***********************************************************************************************************************************
* Script      : 99.Monitoring - Setup.sql                                                                                          *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-04-15                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. DailyIntegrity                                                                                                 *
***********************************************************************************************************************************/
--USE [dbSurge];
GO
DECLARE @ProcessID SMALLINT;
DECLARE @TaskID SMALLINT;
DECLARE @ProcessTaskID INT;
DECLARE @ProcessName NVARCHAR(128) = 'Monitoring|DailyIntegrity';
/***********************************************************************************************************************************
-- Process --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = @ProcessName) BEGIN;
  SET IDENTITY_INSERT [Config].[Process] ON;
  INSERT INTO [Config].[Process] ([ProcessID], [ProcessName], [ProcessDescription], [IsEnabled]) VALUES(-55, @ProcessName, 'Monitor Daily Integrity', 1);
  SET IDENTITY_INSERT [Config].[Process] OFF;
END;
  SET @ProcessID = [Config].[GetProcessIDByName](@ProcessName);
SELECT * FROM Config.Process WHERE ProcessID = @ProcessID;
/***********************************************************************************************************************************
-- Process Task --
***********************************************************************************************************************************/
DECLARE @TaskTypeID INT;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'ETL');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'Integrity') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'Integrity', 'Process Integrity Checks');
END;
-- SELECT * FROM [Config].[Task];
SET @TaskID = [Config].[GetTaskIDByName] ('Integrity');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
--DECLARE @TaskTypeID INT;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'ETL');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'JobFailures') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'JobFailures', 'Process Job Failures to table(s)');
END;
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'ControllerJobDisabled') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'ControllerJobDisabled', 'Process detection of Control jobs that are not running to table(s)');
END;
-- SELECT * FROM [Config].[Task];
SET @TaskID = [Config].[GetTaskIDByName] ('JobFailures');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
SET @TaskID = [Config].[GetTaskIDByName] ('ControllerJobDisabled');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
SELECT * FROM Config.vProcessTask WHERE ProcessID = @ProcessID;
/***********************************************************************************************************************************
-- Task Config --
***********************************************************************************************************************************/
DECLARE @ConfigGroupID SMALLINT;
-- Monitoring --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Monitoring');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'TimeWindow')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'TimeWindow', 'INT', '60', 'The number of minutes between subsequent monitoring records issues.');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'LowerDateBound')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'LowerDateBound', 'DATE', '2021-03-26', 'The earliest record date from which data shold be considered.');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'UpperDateBound')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'UpperDateBound', 'DATE', '2021-04-16', 'The latest record date from which data shold be considered.');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'LowerDateBoundDecrement')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'LowerDateBoundDecrement', 'SMALLINT', '2', 'Number of days to subtract from LowerDateBound when updating');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'UpperDateBoundDecrement')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'UpperDateBoundDecrement', 'SMALLINT', '0', 'Number of days to subtract from UpperDateBound when updating');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'SendType')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'SendType', 'VARCHAR(10)', 'EMail', 'The SendType of notifications.');

-- Initialise upper bound to today
DECLARE @UpperDateBound VARCHAR(10) = CONVERT(VARCHAR, SYSUTCDATETIME(), 121);
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, 'Integrity');
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Logging',
                                          @ConfigName = 'InfoDisabled',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Logging',
                                          @ConfigName = 'CaptureDisabled',
                                          @ConfigValue = 1,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'TimeWindow',
                                          @ConfigValue = 120,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'LowerDateBound',
                                          @ConfigValue = '2021-03-26',
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'UpperDateBound',
                                          @ConfigValue = @UpperDateBound,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'LowerDateBoundDecrement',
                                          @ConfigValue = '2',
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'UpperDateBoundDecrement',
                                          @ConfigValue = '0',
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'SendType',
                                          @ConfigValue = 'SMS',
                                          @Delete = 0;
SELECT * FROM Config.vProcessTaskVariable WHERE ProcessID = @ProcessID;
/***********************************************************************************************************************************/

/* End of File ********************************************************************************************************************/

