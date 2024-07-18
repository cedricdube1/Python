/************************************************************************
* Script     : 1000.Common - Clear SourceSystem.sql
* Created By : Hector Prakke
* Created On : 2021-09-23
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
* Steps      : 1. Clear out all Frame configurations for a SourceSystem
************************************************************************/
USE [dbSurge]
GO
-- Setup
DECLARE @NamePart VARCHAR(150) = 'Surge'
DECLARE @SSID INT = [Lookup].[GetSourceSystemID] ('Surge', 'ZA', 'WC', 'Default');
DECLARE @SSID_MLT INT = [Lookup].[GetSourceSystemID] ('Surge', 'ZA', 'WC', 'MLT');
DECLARE @SSID_MIT INT = [Lookup].[GetSourceSystemID] ('Surge', 'ZA', 'WC', 'MIT');

-- trash logs
DELETE dbSurge.Logging.Job WHERE JobID IN (SELECT JobID FROM dbSurge.Config.Job WHERE JobName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Logging.Error WHERE TaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Logging.CDOExtractByID WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Logging.BulkExtractByID WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Logging.ProcessTaskCapture WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Logging.ProcessTask WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Logging.ProcessTaskInfo WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Logging.Error WHERE ProcessID in (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Logging.Process WHERE ProcessID in (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%')


-- trash config
/*
DELETE dbSurge.Config.JobVariable WHERE JobID IN (SELECT JobID FROM dbSurge.Config.Job WHERE JobName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Config.JobStep WHERE JobID IN (SELECT JobID FROM dbSurge.Config.Job WHERE JobName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Config.JobCreationParameters WHERE JobID IN (SELECT JobID FROM dbSurge.Config.Job WHERE JobName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Config.Job WHERE JobID IN (SELECT JobID FROM dbSurge.Config.Job WHERE JobName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Config.ProcessTaskExtractSource WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Config.ProcessTaskVariable WHERE ProcessTaskID in (select ProcessTaskID FROM dbSurge.Config.ProcessTask WHERE ProcessID IN (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%'))
DELETE dbSurge.Config.ProcessTask WHERE ProcessID in (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Config.Processvariable WHERE ProcessID in (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%')
DELETE dbSurge.Config.Process WHERE ProcessID in (SELECT ProcessID FROM dbSurge.Config.Process WHERE ProcessName LIKE '%' + @NamePart + '%')
*/
-- trash Source system
/*
DELETE dbSurge.lookup.SourceSystemMaster WHERE SourceSystemID IN (@SSID, @SSID_MLT, @SSID_MIT)
DELETE dbSurge.lookup.SourceSystem WHERE SourceSystemID IN (@SSID, @SSID_MLT, @SSID_MIT)
*/
/* End of File ********************************************************************************************************************/
