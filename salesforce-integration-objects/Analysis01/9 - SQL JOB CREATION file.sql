/*****************************************************************************************************************************************************
* Script     : Subscribe IU - Enterprise Platform - Player - 1 Source - 2 Process - 5 Job.sql                                                  *
* Created By : Cedric Dube                                                                                                                            *
* Created On : 2023-03-06                                                                                                                            *
* Updated By : Cedric Dube                                                                                                                             *
* Updated On : 2023-03-06                                                                                                                            *
* Execute On : PROD Environment                                                                                                                      *
* Execute As : Manual                                                                                                                                *
* Execution  : As & when required                                                                                                                    *
* Steps **********************************************************************************************************************************************
* 1 Create Schedule : Only creates the Schedule if missing. This should not need to be changed.                                                 Done *
* 2 Drop & create Job/Steps : Recreates the Job/Steps every time it is run. This should not need to be changed.                                 Done *
* Final Notes ****************************************************************************************************************************************
* {X} Soft Setup : Make any changes in here, specifically to items marked with {X}.                                                                  *
* {C/O} Creator / Owner : Set JobCreator to the current user, ie who is actually running this script.                                                *
*                         Once the Job is created, the owner will be changed to relevant service account (FinalOwner).                               *
*****************************************************************************************************************************************************/

USE MSDB;
GO

/* SETUP {X} */
-- Category Name --
DECLARE @CategoryName SYSNAME = N'IGP - IN - Operational';
-- Creator / Owner --
DECLARE @JobCreator SYSNAME = N'CAPETOWN\Cedric.Dube';   -- Job Creating User {C/O}
--DECLARE @FinalOwner SYSNAME = N'CAPETOWN\svc???'; -- Service Account / IGP {C/O}

/* 1 Create Schedule ********************************************************************************************************************************/

/* SETUP {X} */
-- Schedule Name --
DECLARE @ScheduleName SYSNAME = N'Streams Source to Staging - Every 30 minutes';

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
DECLARE @ScheduleId INT;

/* Fetch Schedule Id */
SELECT @ScheduleId = Schedule_Id
FROM DBO.sysschedules_localserver_view
WHERE Name = @ScheduleName;
PRINT CONCAT('@ScheduleId = ', @ScheduleId);


--Add Schedule (Every 30 minutes) :
IF (@ScheduleId IS NULL) BEGIN;
  -- Add Schedule --
  EXEC SP_Add_Schedule @Schedule_Name = @ScheduleName
                      ,@Enabled = @IsEnabled
                      ,@Freq_Type = @FTDaily
                      ,@Freq_Interval = @FIUnused
                      ,@Freq_Subday_Type = @FSTMinutes
                      ,@Freq_Subday_Interval = 30
                      ,@Owner_Login_Name = @JobCreator
                      ,@Schedule_Id = @ScheduleId OUT;
  -- Update Owner -- ???
--EXEC SP_Update_Schedule @Schedule_Id = @ScheduleId
--                       ,@Owner_Login_Name = @FinalOwner;
END;
PRINT CONCAT('@ScheduleId = ', @ScheduleId); -- 62


/* 2 Drop & create Job/Steps ************************************************************************************************************************/

/* SETUP {X} */
DECLARE @Layer SYSNAME = N'Source'
       ,@Database SYSNAME = N'dbSource'
       ,@TopicDesc SYSNAME = N'Player'; -- {X}
DECLARE @TopicName SYSNAME = REPLACE(@TopicDesc, ' ', '')
       ,@ProcSchema SYSNAME = N'EnterprisePlatform'; -- {X}
DECLARE @ProcessName SYSNAME = '@ProcSchema|@TopicName|StreamEvents';
-- Job Constants --
DECLARE @JobName SYSNAME = N'Source - @TopicDesc - Streams changes to Staging';
DECLARE @JobDescription NVARCHAR(512) = N'Streams any @TopicDesc changes from @Database.@ProcSchema.@TopicName_Streams into dbStaging.dbo.@TopicName';
-- Step #1 Constants --
DECLARE @Step1_Name SYSNAME = N'Is Primary Replica?'
       ,@Step1_Command NVARCHAR(MAX) =
N'DECLARE @IsPrimary BIT = CASE WHEN CAST((SELECT SERVERPROPERTY (''IsHADREnabled'')) AS BIT) = 0 THEN 1 ELSE 0 END;
WHILE @IsPrimary = 0 BEGIN;
  SET @IsPrimary = Sys.fn_HADR_Is_Primary_Replica (''@Database'');
  IF @IsPrimary = 0 WAITFOR DELAY ''00:01:00'';
END;'
       ,@Step1_Database SYSNAME = N'Master';
-- Step #2 Constants --
DECLARE @Step2_Name SYSNAME = N'Execute Main Process'
       ,@Step2_Command NVARCHAR(MAX) =
N'DECLARE @NoData BIT;
EXEC @ProcSchema.@TopicName_StreamEvents
  -- REQUIRED --
  @ParentBaseID    = NULL
 ,@ParentBaseDate  = NULL
 ,@ParentProcessID = NULL
  -- PARTIALS --
 ,@DatabaseName    = ''@@Database''
 ,@LayerName       = ''@@Layer''
  -- STANDARD --
 ,@ChecksOutput    = 0
 ,@DebugProcess    = 0
  -- OUTPUTED --
 ,@NoDataReturn    = @NoData OUT;
IF (@NoData = 1) RAISERROR (''No data was generated by this iteration of the process.'', 0, 1) WITH NOWAIT;'
       ,@Step2_Database SYSNAME = @Database;

/* VARIABLES */
SET @ProcessName = REPLACE(REPLACE(@ProcessName, N'@ProcSchema', @ProcSchema), N'@TopicName', @TopicName); -- PRINT @ProcessName;
-- Job Variables --
SET @JobName = REPLACE(@JobName, '@TopicDesc', @TopicDesc); -- PRINT @JobName;
SET @JobDescription = REPLACE(REPLACE(REPLACE(REPLACE(@JobDescription, '@Database', @Database), '@ProcSchema', @ProcSchema), '@TopicDesc', @TopicDesc), '@TopicName', @TopicName); -- PRINT @JobDescription;
-- Step #1 Variables --
SET @Step1_Command = REPLACE(@Step1_Command, '@Database', @Database); -- PRINT @Step1_Command;
-- Step #2 Variables --
SET @Step2_Command = REPLACE(REPLACE(REPLACE(REPLACE(@Step2_Command, '@@Database', @Database), '@@Layer', @Layer), '@ProcSchema', @ProcSchema), '@TopicName', @TopicName); -- PRINT @Step2_Command;

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
-- Notify & Other Constants -- ???
DECLARE @NLEL INT = 2 -- On Failure
       ,@NLEM INT = 2 -- On Failure
       ,@NEON SYSNAME = N'DPT';
DECLARE @TSQL NVARCHAR(40) = N'TSQL';
DECLARE @ServerName SYSNAME = N'(LOCAL)';

/* VARIABLES */
-- Job Variables --
DECLARE @JobId UNIQUEIDENTIFIER;

/* Remove Job (if exists) */
--IF EXISTS(SELECT 1 FROM DBO.SysJobs WHERE Name = @JobName) BEGIN;
  -- Update Job Owner --
--EXEC SP_Update_Job_Owner @Job_Name = @JobName
--                        ,@Job_Owner = @JobCreator;
  -- Delete Job --
--  EXEC SP_Delete_Job @Job_Name = @JobName;
--END;

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
PRINT CONCAT('@JobId = ', CAST(@JobId AS VARCHAR(36))); -- B89AF771-FF11-4EFC-9B34-752E8B5F9A86

/* Add Steps */
-- Step #1 : Is Primary Replica? --
EXEC SP_Add_JobStep @Job_Id = @JobId
                   ,@Step_Name = @Step1_Name
                   ,@Database_Name = @Step1_Database
                   ,@SubSystem = @TSQL
                   ,@Command = @Step1_Command
                   ,@On_Success_Action = @GotoNextStep
                   ,@On_Success_Step_Id = @NothingStep
                   ,@On_Fail_Action = @QuitWithFailure
                   ,@On_Fail_Step_Id = @NothingStep
                   ,@Retry_Attempts = @NoAttempts
                   ,@Retry_Interval = @NoInterval;
-- Step #2 : Execute Main Process --
EXEC SP_Add_JobStep @Job_Id = @JobId
                   ,@Step_Name = @Step2_Name
                   ,@Database_Name = @Step2_Database
                   ,@SubSystem = @TSQL
                   ,@Command = @Step2_Command
                   ,@On_Success_Action = @QuitWithSuccess
                   ,@On_Success_Step_Id = @NothingStep
                   ,@On_Fail_Action = @QuitWithFailure
                   ,@On_Fail_Step_Id = @NothingStep
                   ,@Retry_Attempts = @Attempts
                   ,@Retry_Interval = @Interval;

/* Add Job to the Server */
EXEC SP_Add_JobServer @Job_Id = @JobId
                     ,@Server_Name = @ServerName;

/* Attach Job to Schedule */
EXEC SP_Attach_Schedule @Job_Id = @JobId
                       ,@Schedule_Name = @ScheduleName;

/* Update Final Owner {UFO} ??? */
--EXEC SP_Update_Job_Owner @Job_Name = @JobName
--                        ,@Job_Owner = @FinalOwner;

/* End of File **************************************************************************************************************************************/
