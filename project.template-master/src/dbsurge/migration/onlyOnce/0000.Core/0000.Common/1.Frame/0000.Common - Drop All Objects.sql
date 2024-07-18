/***********************************************************************************************************************************
* Script      : 0.Common - Drop All Objects.sql                                                                                   *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- Config --
GO
DROP PROCEDURE IF EXISTS [Config].[SetJobStep];
DROP PROCEDURE IF EXISTS [Config].[SetJob_StandardProcess];
DROP PROCEDURE IF EXISTS [Config].[GetMultiJob_ServerAgentScript];
DROP PROCEDURE IF EXISTS [Config].[GetJob_ServerAgentScript];
DROP PROCEDURE IF EXISTS [Config].[SetRunnable_JobList];
DROP PROCEDURE IF EXISTS [Config].[GetProcessStateByName];
DROP PROCEDURE IF EXISTS [Config].[GetProcessTaskStateByName];
DROP PROCEDURE IF EXISTS [Config].[GetProcessTaskStateByID];
DROP PROCEDURE IF EXISTS [Config].[SetVariable_Process];
DROP PROCEDURE IF EXISTS [Config].[SetVariable_ProcessTask];
DROP PROCEDURE IF EXISTS [Config].[SetVariable_Job];
DROP PROCEDURE IF EXISTS [Config].[SetVariable_AppLock];
GO
-- Function helpers --
DROP PROCEDURE IF EXISTS [Helper].[FunctionSchemaBinding_Comment];
DROP PROCEDURE IF EXISTS [Helper].[FunctionSchemaBinding_UnComment];
GO
-- View helpers --
DROP PROCEDURE IF EXISTS [Helper].[ViewSchemaBinding_Remove];
DROP PROCEDURE IF EXISTS [Helper].[ViewSchemaBinding_Add];
-- Extended Property
DROP PROCEDURE IF EXISTS [Helper].[ExtendedProperty_Add_Classification_PII];
DROP PROCEDURE IF EXISTS [Helper].[ExtendedProperty_Add];
DROP PROCEDURE IF EXISTS [Helper].[ExtendedProperty_Update];
DROP PROCEDURE IF EXISTS [Helper].[ExtendedProperty_Set];
DROP PROCEDURE IF EXISTS [Helper].[ExtendedProperty_Remove];
DROP PROCEDURE IF EXISTS [Helper].[ExtendedProperty_ListAll];
-- Object setup helpers --
DROP PROCEDURE IF EXISTS [Helper].[HashCreationGuide];
DROP PROCEDURE IF EXISTS [Helper].[ObjectSchemaSummary];
GO
-- Index/Table helpers --
DROP PROCEDURE IF EXISTS [Helper].[IndexScript_RowStore];
DROP PROCEDURE IF EXISTS [Helper].[IndexScript_ColumnStore];
DROP PROCEDURE IF EXISTS [Helper].[TableStorage];
DROP PROCEDURE IF EXISTS [Helper].[GetTablesWithColumn];
DROP FUNCTION IF EXISTS [Helper].[CreateHTMLTable_FromXMLRAW];
GO
-- Monitoring --
DROP FUNCTION IF EXISTS [Monitoring].[GetCurrentProcessRunTimeMinutes];
DROP FUNCTION IF EXISTS [Monitoring].[GetCurrentJobState];
DROP FUNCTION IF EXISTS [Monitoring].[GetPreviousJobState];
DROP FUNCTION IF EXISTS [Monitoring].[HeldTimeLimitMinutes];
GO


-- Extended Property --
DROP FUNCTION IF EXISTS [Helper].[ExtendedProperty_Validate_Level0_Type];
DROP FUNCTION IF EXISTS [Helper].[ExtendedProperty_Validate_Level1_Type];
DROP FUNCTION IF EXISTS [Helper].[ExtendedProperty_Validate_Level2_Type];
GO

-- Job
DROP PROCEDURE IF EXISTS [Logging].[LogJobStart];
DROP PROCEDURE IF EXISTS [Logging].[LogJobEnd];
DROP PROCEDURE IF EXISTS [DataFlow].[JobController];
DROP PROCEDURE IF EXISTS [DataFlow].[QueueJob];
DROP PROCEDURE IF EXISTS [DataFlow].[QueueJobList];
GO
-- Process
DROP PROCEDURE IF EXISTS [Logging].[LogProcessStart];
DROP PROCEDURE IF EXISTS [Logging].[LogProcessEnd];
-- Process Task
DROP PROCEDURE IF EXISTS [Logging].[LogProcessTaskStart];
DROP PROCEDURE IF EXISTS [Logging].[LogProcessTaskEnd];
DROP PROCEDURE IF EXISTS [Logging].[LogProcessTaskCapture];
DROP PROCEDURE IF EXISTS [Logging].[LogProcessTaskInfo];
DROP PROCEDURE IF EXISTS [Logging].[LogProcessTaskInfoStart];
DROP PROCEDURE IF EXISTS [Logging].[LogProcessTaskInfoEnd];
GO
-- Extract
DROP PROCEDURE IF EXISTS [Logging].[LogBulkExtractByIDStart];
DROP PROCEDURE IF EXISTS [Logging].[LogBulkExtractByDateStart];
DROP PROCEDURE IF EXISTS [Logging].[LogBulkExtractEnd];
DROP PROCEDURE IF EXISTS [Logging].[LogCDOExtractByIDStart];
DROP PROCEDURE IF EXISTS [Logging].[LogCDOExtractByDateStart];
DROP PROCEDURE IF EXISTS [Logging].[LogCDOExtractEnd];
DROP PROCEDURE IF EXISTS [Logging].[LogExtractEnd];
GO
-- Error
DROP PROCEDURE IF EXISTS [Logging].[LogError];
GO

GO
-- Functions --
-- Config --
DROP FUNCTION IF EXISTS [Config].[GetEarliestNextExecution_JobLoop];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Maintenance];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Monitoring];
DROP FUNCTION IF EXISTS [Config].[GetVariable_AppLock];
DROP FUNCTION IF EXISTS [Config].[GetVariable_Process];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Extract];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_RaiseEvent];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Stage];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Load];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Held];
DROP FUNCTION IF EXISTS [Config].[GetVariable_ProcessTask_Logging];
DROP FUNCTION IF EXISTS [Config].[GetVariable_Job];
DROP FUNCTION IF EXISTS [Config].[GetVariableIDByname];
DROP FUNCTION IF EXISTS [Config].[GetProcessIDByName];
DROP FUNCTION IF EXISTS [Config].[GetJobIDByName];
DROP FUNCTION IF EXISTS [Config].[GetJobEnabledByName];
DROP FUNCTION IF EXISTS [Config].[GetJobEnabledByID];
DROP FUNCTION IF EXISTS [Config].[GetTaskIDByName];
DROP FUNCTION IF EXISTS [Config].[GetProcessTaskByName];
DROP FUNCTION IF EXISTS [Config].[GetProcessTaskByID];
DROP FUNCTION IF EXISTS [Config].[GetProcessTaskExtractSourceID];
GO
-- Logging --
DROP FUNCTION IF EXISTS [Logging].[GetProcessLogStatus];
DROP FUNCTION IF EXISTS [Logging].[GetLastCompletedProcessLog];
DROP FUNCTION IF EXISTS [Logging].[GetProcessTaskLogStatus];
DROP FUNCTION IF EXISTS [Logging].[GetProcessLogCreatedMonth];
DROP FUNCTION IF EXISTS [Logging].[GetLogArchivePartition];
GO
-- Helper --
DROP FUNCTION IF EXISTS [Helper].[ExtendedProperty_Check];
DROP FUNCTION IF EXISTS [Helper].[Conversion_BigIntToDateTime2];
DROP FUNCTION IF EXISTS [Helper].[Conversion_DateTime2ToBigInt];
GO
-- Views --
-- Maintenance --
DROP VIEW IF EXISTS [Maintenance].[vPartitionSummary];
GO
-- Task info
DROP VIEW IF EXISTS [Logging].[vProcessTaskInfo];
GO
-- Error
DROP VIEW IF EXISTS [Logging].[vError];
DROP VIEW IF EXISTS [Logging].[vErrorPayloadXML];
GO
-- Process execution
DROP VIEW IF EXISTS [Logging].[vProcessIncomplete];
DROP VIEW IF EXISTS [Logging].[vProcessAverageDuration];
DROP VIEW IF EXISTS [Logging].[vProcessTrace];
DROP VIEW IF EXISTS [Logging].[vProcess];
DROP VIEW IF EXISTS [Logging].[vJob];
DROP VIEW IF EXISTS [Config].[vJobQueue];
GO
-- Task execution
DROP VIEW IF EXISTS [Logging].[vProcessTaskCaptureSummary];
DROP VIEW IF EXISTS [Logging].[vProcessTaskCaptureLatest];
DROP VIEW IF EXISTS [Logging].[vExtract];
DROP VIEW IF EXISTS [Logging].[vProcessTaskCapture];
DROP VIEW IF EXISTS [Logging].[vBulkExtractByID];
DROP VIEW IF EXISTS [Logging].[vBulkExtractByDate];
DROP VIEW IF EXISTS [Logging].[vCDOExtractByID];
DROP VIEW IF EXISTS [Logging].[vCDOExtractByDate];
DROP VIEW IF EXISTS [Logging].[vProcessTaskIncomplete];
DROP VIEW IF EXISTS [Logging].[vProcessTaskAverageDuration];
DROP VIEW IF EXISTS [Logging].[vProcessTask];
GO

-- Configuration
DROP VIEW IF EXISTS [Config].[vProcess];
DROP VIEW IF EXISTS [Config].[vProcessTask];
DROP VIEW IF EXISTS [Config].[vProcessTaskExtract];
DROP VIEW IF EXISTS [Config].[vGroupVariable];
GO
DROP VIEW IF EXISTS [Config].[vJobVariable];
DROP VIEW IF EXISTS [Config].[vJob];
DROP VIEW IF EXISTS [Config].[vProcessVariable];
DROP VIEW IF EXISTS [Config].[vProcessTaskVariable];
GO
-- TABLES --    
-- Logging --
DROP TABLE IF EXISTS [Logging].[BulkExtractByID];
DROP TABLE IF EXISTS [Logging].[BulkExtractByDate];
DROP TABLE IF EXISTS [Logging].[CDOExtractByID];
DROP TABLE IF EXISTS [Logging].[CDOExtractByDate];
DROP TABLE IF EXISTS [Logging].[ProcessTaskCapture];
DROP TABLE IF EXISTS [Logging].[ProcessTaskInfo];
DROP TABLE IF EXISTS [Logging].[ErrorPayloadXML];
DROP TABLE IF EXISTS [Logging].[ErrorPayloadJSON];
DROP TABLE IF EXISTS [Logging].[Error];            
DROP TABLE IF EXISTS [Logging].[ProcessTask];
DROP TABLE IF EXISTS [Logging].[Process];
DROP TABLE IF EXISTS [Logging].[Job];
GO
-- Config --
DROP TABLE IF EXISTS [Config].[ProcessVariable];
DROP TABLE IF EXISTS [Config].[ProcessTaskVariable];
DROP TABLE IF EXISTS [Config].[JobVariable];
DROP TABLE IF EXISTS [Config].[JobQueue];
DROP TABLE IF EXISTS [Config].[AppLockVariable];                    
DROP TABLE IF EXISTS [Config].[Variable];
DROP TABLE IF EXISTS [Config].[VariableGroup];

DROP TABLE IF EXISTS [Config].[ExtractSource];
DROP TABLE IF EXISTS [Config].[ExtractType];
DROP TABLE IF EXISTS [Config].[Task];
DROP TABLE IF EXISTS [Config].[TaskType];
DROP TABLE IF EXISTS [Config].[ProcessTaskExtractSource];
DROP TABLE IF EXISTS [Config].[ProcessTask];
DROP TABLE IF EXISTS [Config].[JobStep];
DROP TABLE IF EXISTS [Config].[JobCreationParameters];
DROP TABLE IF EXISTS [Config].[Job];
DROP TABLE IF EXISTS [Config].[Process];

GO
-- Monitoring --
DROP TABLE IF EXISTS [Monitoring].[ExcludedQueue];
GO


-- Table Types --
DROP TYPE IF EXISTS [DataFlow].[Payload];
DROP TYPE IF EXISTS [DataFlow].[PayloadID];
DROP TYPE IF EXISTS [DataFlow].[PayloadDate];
DROP TYPE IF EXISTS [DataFlow].[CaptureLogID];
DROP TYPE IF EXISTS [Config].[JobID];
DROP TYPE IF EXISTS [DataFlow].[JobQueueList];
GO
    
-- Partitions --
-- Partition Schemes --
IF EXISTS (SELECT * FROM Sys.Partition_Schemes WHERE Name = N'PartScheme_Logging_MonthNumber')
DROP PARTITION SCHEME [PartScheme_Logging_MonthNumber];
IF EXISTS (SELECT * FROM Sys.Partition_Schemes WHERE Name = N'PartScheme_Surge_Year')
DROP PARTITION SCHEME [PartScheme_Surge_Year];
GO
-- Partition functions --
IF EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_Month')
	DROP PARTITION FUNCTION [PartFunc_Month];
IF EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_Year')
	DROP PARTITION FUNCTION [PartFunc_Year];
IF EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_MonthNumber')
	DROP PARTITION FUNCTION [PartFunc_MonthNumber];
IF EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_Date')
	DROP PARTITION FUNCTION [PartFunc_Date];
IF EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_SourceSystemID')
	DROP PARTITION FUNCTION [PartFunc_SourceSystemID];
GO
-- Procedures --
DROP PROCEDURE IF EXISTS [Maintenance].[AppendPartitions_Date];
DROP PROCEDURE IF EXISTS [Maintenance].[AppendPartitions_Month];
DROP PROCEDURE IF EXISTS [Maintenance].[AppendPartitions_Year];
DROP PROCEDURE IF EXISTS [Maintenance].[AppendPartitions_SourceSystem];
GO
DROP PROCEDURE IF EXISTS [Maintenance].[MergePartitions_Date];
DROP PROCEDURE IF EXISTS [Maintenance].[MergePartitions_Month];
DROP PROCEDURE IF EXISTS [Maintenance].[MergePartitions_Year];
GO
DROP PROCEDURE IF EXISTS [Maintenance].[SwitchPartition];
DROP PROCEDURE IF EXISTS [Maintenance].[GetPartitionNumberFromDATE];
DROP PROCEDURE IF EXISTS [Maintenance].[GetPartitionNumberFromINT];
GO

-- Schemas --
/*

DROP SCHEMA [DataFlow];
GO

DROP SCHEMA [Config];
GO

DROP SCHEMA [Logging];
GO

DROP SCHEMA [Maintenance]
GO

DROP SCHEMA [DataCheck];
GO

DROP SCHEMA [Monitoring];
GO

DROP SCHEMA [Notification];
GO

DROP SCHEMA [Archive];
GO 

DROP SCHEMA [Helper];
GO 

DROP SCHEMA [Lookup];
GO

DROP SCHEMA [Publish];
GO
*/
/* End of File ********************************************************************************************************************/