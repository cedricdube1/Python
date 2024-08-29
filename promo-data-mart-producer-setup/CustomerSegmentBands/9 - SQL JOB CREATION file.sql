/*****************************************************************************************************************************************************
* Script     : Publish - dbo - Customer Segment Bands - 5 Job.sql                                                                             *
* Created By : Cedric Dube                                                                                                                        *
* Created On : 2024-08-01                                                                                                                           *                                                                                                                            *
* Execute On : Entire script once                                                                                                                    *
* Execute As : Manual                                                                                                                                *
* Execution  : As & when required                                                                                                                    *
* Steps **********************************************************************************************************************************************
* 1 Create Schedule : Only creates the Schedule if missing. This should not need to be changed.                                                 Done *
* 2 Drop & create Job/Steps : Recreates the Job/Steps every time it is run. This should not need to be changed.                                 Done *
* Final Notes ****************************************************************************************************************************************
* {GSB} : Not finalized & may still require future attention.                                                                                        *
* {X} Soft Setup : Make any changes in here, specifically to items marked with {X}.                                                                  *
* {C/O} Creator / Owner : Set JobCreator to the current user, ie who is actually running this script.                                                *
*                         Once the Job is created, the owner will be changed to relevant service account (FinalOwner).                               *
*****************************************************************************************************************************************************/

USE MSDB;
GO

/* SETUP {X} */
-- Category Name --
DECLARE @CategoryName SYSNAME = N'IGP - IN - Essential';
-- Creator / Owner --
DECLARE @JobCreator SYSNAME = N'CAPETOWN\Cedric.Dube';   -- Job Creating User {C/O}
DECLARE @FinalOwner SYSNAME = N'CAPETOWN\svc_PDMDataProc'; -- Service Account {C/O}

/* 1 Create Schedule ********************************************************************************************************************************/

/* SETUP {X} */

-- Schedule Name --
--DECLARE @ScheduleName SYSNAME = N'Publishing Schedule - Every 30 minutes';

/* CONSTANTS */

-- Enabled / NOT --
DECLARE @IsEnabled TINYINT = 1
       ,@IsNOTEnabled TINYINT = 0;
-- Frequency Type --
DECLARE @FTOnce           INT = 1
       ,@FTDaily          INT = 4
       ,@FTWeekly         INT = 8
       ,@FTMonthly        INT = 16
       ,@FTMonthlyWithFI  INT = 32
       ,@FTSQLAgentStarts INT = 64
       ,@FTComputerIsIdle INT = 128;
-- Frequency Interval --
DECLARE @FIUnused         INT = 1;
-- Weekly Frequency Interval --
DECLARE @WFISunday        INT = 1
       ,@WFIMonday        INT = 2
       ,@WFITuesday       INT = 4
       ,@WFIWednesday     INT = 8
       ,@WFIThursday      INT = 16
       ,@WFIFriday        INT = 32
       ,@WFISaturday      INT = 64;
-- Monthly With Frequency Interval --
DECLARE @MWFISunday       INT = 1
       ,@MWFIMonday       INT = 2
       ,@MWFITuesday      INT = 3
       ,@MWFIWednesday    INT = 4
       ,@MWFIThursday     INT = 5
       ,@MWFIFriday       INT = 6
       ,@MWFISaturday     INT = 7
       ,@MWFIDay          INT = 8
       ,@MWFIWeekDay      INT = 9
       ,@MWFIWeekendDay   INT = 10;
-- Frequency Subday Type --
DECLARE @FSTSpecifiedTime INT = 1
       ,@FSTSeconds       INT = 2
       ,@FSTMinutes       INT = 4
       ,@FSTHours         INT = 8;

/* VARIABLES */

--DECLARE @ScheduleId INT;

/* PROCESSOR */

/* Fetch Schedule Id */
--SELECT @ScheduleId = MAX(Schedule_Id)
--FROM DBO.sysschedules_localserver_view
--WHERE Name = @ScheduleName;

--SELECT *
--FROM DBO.sysschedules_localserver_view
--WHERE Name = N'Publishing Schedule - Every 30 minutes';

/* Add Schedule (Every 30 minutes) */
--IF (@ScheduleId IS NULL) BEGIN;
--  -- Add Schedule --
--  EXEC SP_Add_Schedule @Schedule_Name = @ScheduleName
--                      ,@Enabled = @IsEnabled
--                      ,@Freq_Type = @FTDaily
--                      ,@Freq_Interval = @FIUnused
--                      ,@Freq_Subday_Type = @FSTMinutes
--                      ,@Freq_Subday_Interval = 30
--                      ,@Owner_Login_Name = @JobCreator
--                      ,@Schedule_Id = @ScheduleId OUT;
--  -- Update Owner --
--  EXEC SP_Update_Schedule @Schedule_Id = @ScheduleId
--                         ,@Owner_Login_Name = @FinalOwner;
--END;
--PRINT CONCAT('@ScheduleId = ', @ScheduleId); -- 240

/* 2 Drop & create Job/Steps ************************************************************************************************************************/

/* SETUP {X} */

DECLARE @Database SYSNAME = N'dbPublish'
       ,@TopicDesc SYSNAME = N'Customer Segment Bands'; -- {X}
DECLARE @TopicName SYSNAME = REPLACE(@TopicDesc, ' ', '')
       ,@ProcSchema SYSNAME = N'dbo'; -- {X}
-- Job Constants --
DECLARE @JobName SYSNAME = N'Publish @TopicDesc for Producer';
DECLARE @JobDescription NVARCHAR(512) = N'Pushes any @TopicDesc changes into @Database.@ProcSchema.@TopicName_Event for Producing onto Kafka';
DECLARE @processNmae NVARCHAR(512) = N'Pushes any @TopicDesc changes into @Database.@ProcSchema.@TopicName_Event for Producing onto Kafka';
DECLARE @ProcName NVARCHAR(512) = N'usp_@TopicName_Event';
-- Step 0 Constants --
-- Step 1 Constants --
DECLARE @Step1_Name SYSNAME = N'Execute Main Process'
       ,@Step1_Command NVARCHAR(MAX) =
N'IF (SELECT [dbIS_ControlToolBox].[Global].fnCheckForPrimaryNode())=1
BEGIN	
	EXEC @Database.@ProcSchema.@ProcNmae

END'
       ,@Step1_Database SYSNAME = 'Master';

-- SUBSTITUTE --
SET @JobName = REPLACE(@JobName, '@TopicDesc', @TopicDesc); -- PRINT @JobName;
SET @JobDescription = REPLACE(REPLACE(REPLACE(REPLACE(@JobDescription, '@Database', @Database), '@ProcSchema', @ProcSchema), '@TopicDesc', @TopicDesc), '@TopicName', @TopicName);  PRINT @JobDescription;
SET @Step1_Command = REPLACE(REPLACE(REPLACE(REPLACE(@Step1_Command, '@Database', @Database), '@ProcSchema', @ProcSchema), '@ProcNmae',@ProcName), '@TopicName', @TopicName);  PRINT @Step1_Command;
SET @ProcName = REPLACE(@ProcName, '@TopicName', @TopicName) ;  PRINT @ProcName;

/* CONSTANTS */

-- Failure / Success Action --
DECLARE @QuitWithSuccess TINYINT = 1
       ,@QuitWithFailure TINYINT = 2
       ,@GotoNextStep    TINYINT = 3
       ,@GotoStep        TINYINT = 4;
-- (No) Attempts / Interval --
DECLARE @NoAttempts INT = 0
       ,@NoInterval INT = 0
       ,@Attempts   INT = 2
       ,@Interval   INT = 1;
-- Failure/Success Step Ids --
DECLARE @NothingStep INT = 0
       ,@SuccessStep INT = 6
       ,@FailureStep INT = 7;
-- Notify & Other Constants --
DECLARE @NLEL INT = 2 -- On Failure
       ,@NLEM INT = 2 -- On Failure
       ,@NEON SYSNAME = N'iGaming Insights'
DECLARE @TSQL NVARCHAR(40) = N'TSQL';
DECLARE @ServerName SYSNAME = N'(LOCAL)';

/* VARIABLES */

-- Job Variables --
DECLARE @JobId UNIQUEIDENTIFIER;

/* PROCESSOR */

/* Remove Job (if exists) */
IF EXISTS(SELECT 1 FROM DBO.SysJobs WHERE Name = @JobName) BEGIN;
  -- Update Job Owner --
  EXEC SP_Update_Job_Owner @Job_Name = @JobName
                          ,@Job_Owner = @JobCreator;
  -- Delete Job --
  EXEC SP_Delete_Job @Job_Name = @JobName;
END;

/* Add Job */
EXEC SP_Add_Job @Job_Name = @JobName
               ,@Enabled = @IsNOTEnabled -- {X}
               ,@Description = @JobDescription
               ,@Category_Name = @CategoryName
               ,@Owner_Login_Name = @JobCreator
--             ,@Notify_Level_Eventlog = @NLEL
--             ,@Notify_Level_Email = @NLEM
--             ,@Notify_Email_Operator_Name = @NEON
               ,@Job_Id = @JobId OUTPUT;
PRINT CONCAT('@JobId = ', CAST(@JobId AS VARCHAR(36)));

/* Add Steps */
-- #1 : Execute Main Process --
EXEC SP_Add_JobStep @Job_Id = @JobId
                   ,@Step_Name = @Step1_Name
                   ,@Database_Name = @Step1_Database
                   ,@SubSystem = @TSQL
                   ,@Command = @Step1_Command
                   ,@On_Success_Action = @QuitWithSuccess
                   ,@On_Success_Step_Id = @NothingStep
                   ,@On_Fail_Action = @QuitWithFailure
                   ,@On_Fail_Step_Id = @NothingStep
                   ,@Retry_Attempts = @NoAttempts
                   ,@Retry_Interval = @NoInterval;


/* Add Job to the Server */
EXEC SP_Add_JobServer @Job_Id = @JobId
                     ,@Server_Name = @ServerName;

/* Attach Job to Schedule */
--EXEC SP_Attach_Schedule @Job_Id = @JobId
--                       ,@Schedule_Name = @ScheduleName;

/* Update Final Owner {UFO} */
EXEC SP_Update_Job_Owner @Job_Name = @JobName
                        ,@Job_Owner = @FinalOwner;


DECLARE @IsPrimary BIT = Sys.fn_HADR_Is_Primary_Replica ('dbPublish');
--SELECT @IsPrimary

IF @IsPrimary = 1
BEGIN
	IF  (SELECT COUNT(1) FROM dbstaging.lookup.lupprocess WITH (NOLOCK) WHERE Job_ID = @JobName) < 1 
	BEGIN
		DECLARE @ID INT = (SELECT max(ID) FROM dbstaging.lookup.lupprocess WITH (NOLOCK) WHERE id < 997) + 1
		
		INSERT INTO dbstaging.lookup.lupProcess (ID, ProcessName, LastRunDate, NextRunDate, LastRunOutcome, Enabled, RunFrequency, Job_ID, ExecutionType, Information, Category)
		SELECT @ID, @ProcName, GETDATE(), GETDATE(), 1, 1, '00:30:00', @JobName, 'Job',
		'--==================================================================================================
		--=---------[PURPOSE]: Pushes any CustomerSegmentBands changes into dbPublish.dbo.CustomerSegmentBands_Event for Producing onto Kafka
		--=----------[SERVER]: CPTAOLSTN10
		--=--------[DATABASE]: dbPublish
		--=-------[ETL LEVEL]: ETL
		--=[STORED PROCEDURE]: usp_CustomerSegmentBands_Event
		--=-----------[TABLE]: CustomerSegmentBands_Event
		--=-------------[JOB]: Publish CustomerSegmentBands for Producer
		--=-----[DESCRIPTION]: Pushes any CustomerSegmentBands changes into dbPublish.dbo.CustomerSegmentBands_Event for Producing onto Kafka
		--==================================================================================================',
		'PUBLISH'

		SELECT * FROM dbstaging.lookup.lupprocess WITH (NOLOCK) WHERE ProcessName = @ProcName
	END
END



