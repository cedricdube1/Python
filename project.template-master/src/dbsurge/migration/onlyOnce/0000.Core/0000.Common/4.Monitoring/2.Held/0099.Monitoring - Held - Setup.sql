/***********************************************************************************************************************************
* Script      : 99.Monitoring - Setup.sql                                                                                          *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-04-08                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Held                                                                                                           *
***********************************************************************************************************************************/
USE [dbSurge];
GO
DECLARE @ProcessID SMALLINT;
DECLARE @TaskID SMALLINT;
DECLARE @ProcessTaskID INT;
DECLARE @ProcessName NVARCHAR(128) = 'Monitoring|Held';
/***********************************************************************************************************************************
-- Process --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = @ProcessName) BEGIN;
  SET IDENTITY_INSERT [Config].[Process] ON;
  INSERT INTO [Config].[Process] ([ProcessID], [ProcessName], [ProcessDescription], [IsEnabled]) VALUES(-53, @ProcessName, 'Monitor Held', 1);
  SET IDENTITY_INSERT [Config].[Process] OFF;
END;
  SET @ProcessID = [Config].[GetProcessIDByName](@ProcessName);
SELECT * FROM Config.Process WHERE ProcessID = @ProcessID;
/***********************************************************************************************************************************
-- Process Task --
***********************************************************************************************************************************/
DECLARE @TaskTypeID INT;
SET @TaskTypeID = (SELECT [TaskTypeID] FROM [Config].[TaskType] WHERE [TaskTypeCode] = 'ETL');
IF NOT EXISTS (SELECT * FROM [Config].[Task] WHERE [TaskName] = 'StagingHeld') BEGIN;
  INSERT INTO [Config].[Task] ([TaskTypeID], [Taskname], [TaskDescription]) VALUES(@TaskTypeID, 'StagingHeld', 'Process long-Held summary and notifications');
END;
-- SELECT * FROM [Config].[Task];
SET @TaskID = [Config].[GetTaskIDByName] ('StagingHeld');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
--SELECT * FROM Config.vProcessTask WHERE ProcessID = @ProcessID;
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
SELECT * FROM Config.vProcessTask WHERE ProcessID = @ProcessID
/***********************************************************************************************************************************
-- Task Config --
***********************************************************************************************************************************/
DECLARE @ConfigGroupID SMALLINT;
-- Monitoring --
SET @ConfigGroupID = (SELECT [ConfigGroupID] FROM [Config].[VariableGroup] WHERE [ConfigGroupName] = 'Monitoring');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'TimeWindow')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'TimeWindow', 'INT', '60', 'The number of minutes between subsequent monitoring records issues.');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'HeldTimeLimit')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'HeldTimeLimit', 'INT', '60', 'The number of minutes after which Held entries are monitored for notification.');
 IF NOT EXISTS (SELECT 1 FROM [Config].[Variable] WHERE [ConfigGroupID] = @ConfigGroupID AND [ConfigName] = 'SendType')
   INSERT INTO [Config].[Variable] ([ConfigGroupID], [ConfigName], [ConfigDataType], [ConfigDefaultValue], [Description])
     VALUES (@ConfigGroupID, 'SendType', 'VARCHAR(10)', 'EMail', 'The SendType of notifications.');

SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, 'StagingHeld');
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Logging',
                                          @ConfigName = 'InfoDisabled',
                                          @ConfigValue = 1,
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
                                          @ConfigName = 'HeldTimeLimit',
                                          @ConfigValue = 60,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = 'Monitoring',
                                          @ConfigName = 'SendType',
                                          @ConfigValue = 'SMS',
                                          @Delete = 0;
SELECT * FROM Config.vProcessTaskVariable WHERE ProcessID = @ProcessID;
/***********************************************************************************************************************************/

/* End of File ********************************************************************************************************************/

