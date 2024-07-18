/***********************************************************************************************************************************
* Script      : 7.Common - Procedures - Config.sql                                                                                *
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

GO
CREATE OR ALTER PROCEDURE [Config].[GetProcessStateByName] (
  @ProcessName VARCHAR(150),
  @ProcessID SMALLINT = -1 OUTPUT,
  @IsEnabled BIT = 0 OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  SELECT @ProcessID = [ProcessID],
         @IsEnabled = [IsEnabled]
   FROM [Config].[Process] WITH (NOLOCK)
  WHERE [ProcessName] = @ProcessName;
  -- Default / Return --
  SET @ProcessID = ISNULL(@ProcessID, -1);
  SET @IsEnabled = ISNULL(@isEnabled, 0);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[GetProcessTaskStateByName] (
  @ProcessID SMALLINT,
  @Taskname VARCHAR(150),
  @ProcessTaskID INT = -1 OUTPUT,
  @IsEnabled BIT = 0 OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  SELECT @ProcessTaskID = [PT].[ProcessTaskID],
         @IsEnabled = [PT].[IsEnabled]
   FROM [Config].[ProcessTask] PT WITH (NOLOCK)
  INNER JOIN [Config].[Task] T WITH (NOLOCK)
     ON [PT].[TaskID] = [T].[TaskID]
  WHERE [PT].[ProcessID] = @ProcessID
    AND [T].[Taskname] = @Taskname;
  -- Default / Return --
  SET @ProcessTaskID = ISNULL(@ProcessTaskID, -1);
  SET @IsEnabled = ISNULL(@isEnabled, 0);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[GetProcessTaskStateByID] (
  @ProcessID SMALLINT,
  @TaskID SMALLINT,
  @ProcessTaskID INT = -1 OUTPUT,
  @IsEnabled BIT = 0 OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  SELECT @ProcessTaskID = [PT].[ProcessTaskID],
         @IsEnabled = [PT].[IsEnabled]
   FROM [Config].[ProcessTask] PT WITH (NOLOCK)
  WHERE [PT].[ProcessID] = @ProcessID
    AND [PT].[TaskID] = @TaskID;
  -- Default / Return --
  SET @ProcessTaskID = ISNULL(@ProcessTaskID, -1);
  SET @IsEnabled = ISNULL(@isEnabled, 0);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[GetJob_ServerAgentScript] (
  @JobID SMALLINT,
  @CreateAsEnabled BIT = 0,
  @PrintFileHeader BIT = 1,
  @PrintFileFooter BIT = 1,
  @EmailOperatorName NVARCHAR(128) = 'PDM',
  @AddAlwaysOnCheckExclusion BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @SystemUser NVARCHAR(128) = SYSTEM_USER;
  DECLARE @JobStepCounter SMALLINT = 1;
  DECLARE @JobSteps SMALLINT = (SELECT MAX(JobStepOrdinal) FROM [Config].[JobStep] WITH (NOLOCK) WHERE JobID = @JobID);
  DECLARE @JobName VARCHAR(150) = (SELECT JobName FROM [Config].[Job] WITH (NOLOCK) WHERE JobID = @JobID);
  DECLARE @JobScheduleName NVARCHAR(128) = (SELECT JobScheduleName FROM [Config].[Job] WITH (NOLOCK) WHERE JobID = @JobID);
  DECLARE @FileHeader NVARCHAR(MAX) = 
'
/***********************************************************************************************************************************
* Script      : Server Agent - ' + @JobName + '.sql
* Created By  : ' + @SystemUser + '
* Created On  : ' + CONVERT(VARCHAR(10),GETDATE(), 121) + '
* Execute On  : As required.
* Execute As  : N/A
* Execution   : Entire script once. Will drop job if it exists.
* Version     : 1.0
***********************************************************************************************************************************/
';
  IF @PrintFileHeader = 1
   PRINT @FileHeader;
  DECLARE @JobVar NVARCHAR(MAX) = (SELECT
  '
  DECLARE @JobId UNIQUEIDENTIFIER;
  DECLARE @JobName NVARCHAR(128) = ' + '''' + JobName + '''' + ';
  DECLARE @JobOwner NVARCHAR(128) = ' + '''' + JobOwner + '''' + ';
  /* Delete */
  IF EXISTS(SELECT 1 FROM msdb.dbo.SysJobs WHERE Name = @JobName) BEGIN;
    -- Change Job Owner to current System User --
    EXEC [MSDB].[dbo].[sp_update_job_owner] @job_name = @JobName,
                                            @job_owner = ' + '''' + @SystemUser + '''' + ';
	-- Delete --
    EXEC[MSDB].[dbo].[sp_Delete_Job] @Job_Name = @JobName;
  END;
  /* Add Job */
  EXEC [MSDB].[dbo].[sp_Add_Job] @Job_Name = @JobName
                                ,@Enabled = ' + CAST(@CreateAsEnabled AS VARCHAR) + '
                                ,@Description = ' + '''' + JobDescription + '''' + '
                                ,@Category_Name = ' + '''' + JobCategory + '''' + '
                                ,@Owner_Login_Name = ' + '''' + @SystemUser + '''' + ' -- Set as current System User. Once created, owner will change to relevant owner account
                                ,@Notify_Level_Eventlog = 2
                                ,@Notify_Level_Email = 2
                                ,@Notify_Email_Operator_Name = '  + CASE WHEN @EmailOperatorName IS NULL THEN 'NULL' ELSE '''' + @EmailOperatorName  + '''' END + '
                                ,@Job_Id = @JobId OUTPUT;'
   FROM [Config].[Job] J WITH (NOLOCK) WHERE JobID = @JobID);
   PRINT @JobVar;
   WHILE @JobStepCounter <= @JobSteps BEGIN;
	 DECLARE @JobStepAddVar NVARCHAR(MAX) = (SELECT
	 '
     /* Add Job Step ' + CAST(@JobStepCounter AS VARCHAR) + ' */
     EXEC [MSDB].[dbo].[sp_Add_JobStep] @Job_Id = @JobId
                                       ,@Step_Name = ' + '''' + JobStepName + '''' + '
                                       ,@Database_Name = ' + '''' + DatabaseName + '''' + '
                                       ,@Subsystem = ''TSQL''
                                       ,@Command = ' + '''' + REPLACE(Command,'''','''''') + '''' + '
                                       ,@Retry_Attempts = ' + CAST(ISNULL(RetryAttempts,0) AS VARCHAR) + '
                                       ,@Retry_Interval = ' + CAST(ISNULL(RetryInterval,0) AS VARCHAR) + ';
	 ' FROM [Config].[JobStep] WHERE JobID = @JobID AND JobStepOrdinal = @JobStepCounter);
	 PRINT @JobStepAddVar;
	 SET @JobStepCounter = @JobStepCounter + 1;
   END;
   SET @JobStepCounter = 1;
   WHILE @JobStepCounter <= @JobSteps BEGIN;
	 DECLARE @JobStepUpdateVar NVARCHAR(MAX) = (SELECT
	 '
     /* Update Job Step ' + CAST(@JobStepCounter AS VARCHAR) + ' */
     EXEC [MSDB].[dbo].[sp_Update_JobStep] @Job_Id = @JobId
                                          ,@Step_ID = ' + CAST(@JobStepCounter AS VARCHAR) + '
                                          ,@On_Success_Action = ' + CAST(ISNULL(OnSuccessAction,3) AS VARCHAR) + '
                                          ,@On_Success_Step_Id = ' + CAST(ISNULL(OnSuccessOrdinal,0) AS VARCHAR) + '
                                          ,@On_Fail_Action = ' + CAST(ISNULL(OnFailAction,2) AS VARCHAR) + '
                                          ,@On_Fail_Step_Id = ' + CAST(ISNULL(OnFailOrdinal,0) AS VARCHAR) + ';
	 ' FROM [Config].[JobStep] WHERE JobID = @JobID AND JobStepOrdinal = @JobStepCounter);
	 PRINT @JobStepUpdateVar;
	 SET @JobStepCounter = @JobStepCounter + 1;
   END;
   SET @JobVar = 
   '
     /* Add Job Server */
     EXEC [MSDB].[dbo].[sp_add_jobserver] @job_id = @JobId,
                                          @server_name = N''(LOCAL)'';	
   ';
  PRINT @JobVar;
   SET @JobVar = 
   '
     /* Add Job Schedule */
     EXEC [MSDB].[dbo].[sp_attach_schedule] @job_id = @JobId,
                                            @schedule_name = N' + '''' + @JobScheduleName + '''' + ';	
   ';
  PRINT @JobVar;
   SET @JobVar = 
   '
    -- Change Job Owner to stored owner --
    EXEC [MSDB].[dbo].[sp_update_job_owner] @job_name = @JobName,
                                            @job_owner = @JobOwner;
   ';
  PRINT @JobVar;
  IF @AddAlwaysOnCheckExclusion = 1 BEGIN;
    IF SERVERPROPERTY ( 'IsHadrEnabled' ) = 1 BEGIN;
      SET @JobVar = 
      '
       -- Add AlwaysOn Check exclusion for DBA checks --
       EXEC [dbIS_ControlToolBox].[AlwaysOn].[usp_JobConfigChecksExclusions] @JobName=@JobName,
                                                                             @JobConfigCheck=''AlwaysOnCodedCheck'',
                                                                             @Action=''INSERT'';
      ';
      PRINT @JobVar;
    END;
  END;
  PRINT '
  GO
  '
  DECLARE @FileFooter NVARCHAR(MAX) = 
'/* End of File ********************************************************************************************************************/'
  IF @PrintFileFooter = 1
    PRINT @FileFooter;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[GetMultiJob_ServerAgentScript] (
  @JobIDList Config.JobID READONLY,
  @CreateAsEnabled BIT = 0,
  @PrintFileHeader BIT = 0,
  @PrintFileFooter BIT = 0,
  @EmailOperatorName NVARCHAR(128) = 'DPT',
  @AddAlwaysOnCheckExclusion BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
 DECLARE @JobID SMALLINT;
 DECLARE @JobActionList Config.JobID;
 INSERT INTO @JobActionList SELECT JobID FROM @JobIDList;

 WHILE EXISTS (SELECT * FROM @JobActionList) BEGIN;
   SET @JobID = NULL;
   SELECT TOP (1) @JobID = JobID FROM @JobActionList ORDER BY JobID ASC;
   EXEC [Config].[GetJob_ServerAgentScript] @JobID = @JobID,
                                            @CreateAsEnabled = @CreateAsEnabled,
                                            @PrintFileHeader = @PrintFileHeader,
                                            @PrintFileFooter = @PrintFileFooter,
                                            @EmailOperatorName  = @EmailOperatorName,
                                            @AddAlwaysOnCheckExclusion = @AddAlwaysOnCheckExclusion;
  DELETE FROM @JobActionList WHERE JobID = @JobID;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[SetJobStep] (
  @ReplaceExisting BIT = 0,
  @JobID SMALLINT,
  @JobStepOrdinal SMALLINT,
  @JobStepName VARCHAR(150),
  @DatabaseName NVARCHAR(128),
  @Command NVARCHAR(MAX),
  @OnSuccessAction INT,
  @OnSuccessOrdinal INT,
  @RetryAttempts INT,
  @RetryInterval INT,
  @OnFailAction INT,
  @OnFailOrdinal INT
) AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
  IF @ReplaceExisting = 1 BEGIN;
    DELETE [Config].[JobStep] WITH (ROWLOCK) WHERE JobID = @JobID AND JobStepOrdinal = @JobStepOrdinal;
  END;
  INSERT INTO [Config].[JobStep] (
    JobID,
    JobStepOrdinal,
    JobStepname,
    DatabaseName,
    Command,
    OnSuccessAction,
    OnSuccessOrdinal,
    RetryAttempts,
    RetryInterval,
    OnFailAction,
    OnFailOrdinal
  ) SELECT @JobID,
           @JobStepOrdinal,
           @JobStepname,
           @DatabaseName,
           @Command,
           @OnSuccessAction,
           @OnSuccessOrdinal,
           @RetryAttempts,
           @RetryInterval,
           @OnFailAction,
           @OnFailOrdinal WHERE NOT EXISTS (SELECT 1 FROM [Config].[JobStep] WHERE JobID = @JobID AND JobStepOrdinal = @JobStepOrdinal);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END
GO
CREATE OR ALTER PROCEDURE [Config].[SetJob_StandardProcess] (
  @ProcessName VARCHAR(150),
  @Environment CHAR(3),
  @JobNameClass VARCHAR(30) = 'Process',
  @JobCategoryClass VARCHAR(30) = 'Process',
  @ProcessJobSchema NVARCHAR(128),
  @ProcessJobProcedure NVARCHAR(128),
  @ProcedureParams NVARCHAR(1000) = NULL,
  @JobScheduleName NVARCHAR(128) = N'Raptor Auto Start',
  @JobNameOverride VARCHAR(150) = NULL,
  @IsLoopJob BIT = 1,
  @IsControllerJob BIT = 0,
  @DeleteExisting BIT = 0,
  @ReplaceExistingSteps BIT = 0,
  @CheckServiceBroker BIT = 0,
  @EnableJobLog BIT = 1,
  @WaitTime VARCHAR(12) = '00:00:05',
  @JobOwnerOverride NVARCHAR(128) = NULL,
  @JobCategoryOverride NVARCHAR(128) = NULL
) AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @ProcessID SMALLINT = [Config].[GetProcessIDByName](@ProcessName);
  IF @ProcessID IS NULL
    THROW 50000, 'Process does not exist. Terminating', 1;
  --IF @Environment NOT IN('DEV','UAT','PRD')
  --  THROW 50000, 'Environment must be one of : DEV, UAT, PRD. Terminating', 1;
  IF NOT EXISTS( SELECT * FROM sys.schemas WHERE [name] = @ProcessJobSchema)
    THROW 50000, 'Schema does not exist. Terminating', 1;
  IF NOT EXISTS( SELECT * FROM sys.procedures WHERE [name] = @ProcessJobProcedure and [schema_id] = (SELECT [schema_id] FROM sys.schemas WHERE [name] = @ProcessJobSchema))
    THROW 50000, 'Procedure does not exist. Terminating', 1;
  -------------------------------
  -- JOB VARS.
  -------------------------------
  DECLARE @JobID SMALLINT;
  DECLARE @DBName NVARCHAR(128) = DB_NAME();
  DECLARE @Layer NVARCHAR(120) = REPLACE(@DBName, 'db', '');
  --DECLARE @JobName VARCHAR(150) = 'Raptor ' + @Environment + ' ' + @Layer + ISNULL(' ' + @JobnameClass,'') + ' ' + REPLACE(@ProcessName,'|',' ');
  DECLARE @JobName VARCHAR(150) = 'IGBI Operational - SurgeETL' + ISNULL(' ' + @JobnameClass,'') + ' ' + REPLACE(@ProcessName,'|',' ');
  IF @JobNameOverride IS NOT NULL
    SET @JobName = @JobNameOverride;
  DECLARE @JobDescription VARCHAR(250) = (SELECT ProcessDescription FROM [Config].[Process] WITH (NOLOCK) WHERE ProcessID = @ProcessID);
  DECLARE @JobOwner NVARCHAR(128) = CASE WHEN @Environment = 'DEV' THEN N'CAPETOWN\svc_PDMDataProc'
                                         WHEN @Environment = 'UAT' THEN N'CAPETOWN\svc_PDMDataProc'
										 WHEN @Environment = 'PRD' THEN N'CAPETOWN\svc_PDMDataProc' END;
  IF @JobOwnerOverride IS NOT NULL
    SET @JobOwner = @JobOwnerOverride;
  DECLARE @MasterDBName NVARCHAR(128) = N'master';
  DECLARE @IsEnabled BIT = 1;
  DECLARE @JobCategory NVARCHAR(128) = N'Raptor ' + @Environment + ' ' + @JobCategoryClass + ' ' + 'Jobs';
  IF @JobCategoryOverride IS NOT NULL
    SET @JobCategory = @JobCategoryOverride;
  -- If this is a looping job but is not a controller, do not attach any job schedule as the controller manages execution --
  IF @IsLoopJob = 1 AND @IsControllerJob = 0
    SET @JobScheduleName = NULL;
  -------------------------------
  -- JOB STEP VARS.
  -------------------------------
  DECLARE @JobStepOrdinal SMALLINT,
          @JobStepName VARCHAR(150),
          @DatabaseName NVARCHAR(128),
          @Command NVARCHAR(MAX),
          @OnSuccessAction INT,
          @OnSuccessOrdinal INT,
          @RetryAttempts INT,
          @RetryInterval INT,
          @OnFailAction INT,
          @OnFailOrdinal INT;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  SET @JobID = (SELECT JobID FROM [Config].[Job] WITH (NOLOCK) WHERE JobName = @JobName);
  -------------------------------
  -- DELETE EXISTING IF REQUESTED
  -------------------------------
  IF @DeleteExisting = 1 BEGIN;
    DELETE FROM [Config].[JobCreationParameters] WITH (ROWLOCK)
    WHERE JobID = @JobID;
    DELETE FROM [Config].[JobVariable] WITH (ROWLOCK)
	  WHERE JobID = @JobID;
    DELETE FROM [Config].[JobStep] WITH (ROWLOCK)
	  WHERE JobID = @JobID;
    DELETE FROM [Config].[JobQueue] WITH (ROWLOCK)
	  WHERE JobID = @JobID;
    DELETE FROM [Logging].[Job] WITH (ROWLOCK)
	  WHERE JobID = @JobID;
    DELETE FROM [Config].[Job] WITH (ROWLOCK)
	  WHERE JobID = @JobID;
  END;
  -------------------------------
  -- FULL JOB ADD
  -------------------------------
  IF NOT EXISTS(SELECT 1 FROM [Config].[Job] WITH (NOLOCK) WHERE JobName = @JobName) BEGIN; -- BEGIN ADD JOB
  BEGIN TRANSACTION;
  -----------------------
  -- JOB
  -----------------------
    IF @JobID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Config].[Job] WITH (NOLOCK) WHERE JobID = @JobID) BEGIN;
      SET IDENTITY_INSERT [Config].[Job] ON;
	  INSERT INTO [Config].[Job] (
        JobID,
	    ProcessID,
	    JobName,
	    JobDescription,
	    JobCategory,
	    JobOwner,
        JobScheduleName,
        IsLoopJob,
        IsControllerJob
	  ) SELECT @JobID,
               @ProcessID,
               @JobName,
               @JobDescription,
               @JobCategory,
               @JobOwner,
               @JobScheduleName,
               @IsLoopJob,
               @IsControllerJob;
      SET IDENTITY_INSERT [Config].[Job] OFF;
    END; ELSE BEGIN;
	  INSERT INTO [Config].[Job] (
	    ProcessID,
	    JobName,
	    JobDescription,
	    JobCategory,
	    JobOwner,
        JobScheduleName,
        IsLoopJob,
        IsControllerJob
	  ) SELECT @ProcessID,
               @JobName,
               @JobDescription,
               @JobCategory,
               @JobOwner,
               @JobScheduleName,
               @IsLoopJob,
               @IsControllerJob;
      SET @JobID = @@IDENTITY;
    END;
  COMMIT;
  END; -- END ADD JOB
  -----------------------
  -- JOB CREATION PARAMETERS
  -----------------------
  DELETE FROM [Config].[JobCreationParameters] WITH (ROWLOCK)
    WHERE JobID = @JobID;
  INSERT INTO [Config].[JobCreationParameters] (JobID, Parameter, ParameterDataType, ParameterValue)
    VALUES(@JobID,'@ProcessName','VARCHAR(150)',@ProcessName),
          (@JobID,'@Environment','CHAR(3)',@Environment),
          (@JobID,'@JobNameClass','VARCHAR(30)',@JobNameClass),
          (@JobID,'@JobCategoryClass','VARCHAR(30)',@JobCategoryClass),
          (@JobID,'@ProcessJobSchema','NVARCHAR(128)',@ProcessJobSchema),
          (@JobID,'@ProcessJobProcedure','NVARCHAR(128)',@ProcessJobProcedure),
          (@JobID,'@ProcedureParams','NVARCHAR(1000)',@ProcedureParams),
          (@JobID,'@JobScheduleName','NVARCHAR(128)',@JobScheduleName),
          (@JobID,'@JobNameOverride','VARCHAR(150)',@JobNameOverride),
          (@JobID,'@IsLoopJob','BIT',CAST(@IsLoopJob AS VARCHAR)),
          (@JobID,'@IsControllerJob','BIT',CAST(@IsControllerJob AS VARCHAR)),
          (@JobID,'@CheckServiceBroker','BIT',CAST(@CheckServiceBroker AS VARCHAR)),
          (@JobID,'@EnableJobLog','BIT',CAST(@EnableJobLog AS VARCHAR)),
          (@JobID,'@WaitTime','VARCHAR(12)',@WaitTime);
  -----------------------
  -- JOB STEPS
  -----------------------
  -----------------
  -- CHECK REPLICA
  -----------------
  SELECT @JobStepOrdinal=NULL,@JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
         @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
  SET @JobStepOrdinal = 1;
  SET @DatabaseName = @MasterDBName
  SET @JobStepName = 'Check Primary Replica';
  SET @RetryAttempts = 0;
  SET @OnFailAction = 2; -- If we fail to check correctly, exit as a failure
  SET @OnSuccessAction = 3; -- If it is Primary node, continue to next step
  IF @IsLoopJob = 1 BEGIN;
    SET @Command =
      'DECLARE @IsPrimary BIT =  CASE WHEN CAST((SELECT SERVERPROPERTY ( ''IsHadrEnabled'' )) AS BIT) = 0 THEN 1 ELSE 0 END;
      WHILE @IsPrimary = 0
      BEGIN
        --SET @IsPrimary = [master].[sys].[fn_hadr_is_primary_replica] (' + '''' + @DBName + '''' + ');
        SET @IsPrimary = (SELECT [dbIS_ControlToolBox].[Global].fnCheckForPrimaryNode());
        IF @IsPrimary = 0 WAITFOR DELAY ''00:01:00'';
      END;'
  END; ELSE BEGIN;
    SET @OnFailAction = 1; -- If a scheduled job kicks off on Secondary, throw an error and exit succesfully
    SET @OnSuccessAction = 3; -- If it is Primary node, continue to next step
      SET @Command =
        'DECLARE @IsPrimary BIT =  CASE WHEN CAST((SELECT SERVERPROPERTY ( ''IsHadrEnabled'' )) AS BIT) = 0 THEN 1 ELSE 0 END;
         IF @IsPrimary = 0 BEGIN;
           --SET @IsPrimary = [master].[sys].[fn_hadr_is_primary_replica] (' + '''' + @DBName + '''' + ');
		   SET @IsPrimary = (SELECT [dbIS_ControlToolBox].[Global].fnCheckForPrimaryNode());
           IF @IsPrimary = 0
             THROW 50000, ''CANNOT EXECUTE ON SECONDARY. EXITING'', 1;
         END;'
  END;
  EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                             @JobID = @JobID,
                             @JobStepOrdinal = @JobStepOrdinal,
                             @JobStepName = @JobStepName,
                             @DatabaseName = @DatabaseName,
                             @Command = @Command,
                             @OnSuccessAction = @OnSuccessAction, 
                             @OnSuccessOrdinal = @OnSuccessOrdinal,
                             @RetryAttempts = @RetryAttempts,
                             @RetryInterval = @RetryInterval,
                             @OnFailAction = @OnFailAction,
                             @OnFailOrdinal = @OnFailOrdinal;
  -----------------
  -- START LOG
  -----------------
  IF @EnableJobLog = 1 BEGIN;
    SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
           @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
    SET @JobStepOrdinal = @JobStepOrdinal + 1;
    SET @DatabaseName = @DBName;
    SET @JobStepName = 'Log Job Start';
    SET @RetryAttempts = 3;
    SET @RetryInterval = 1;
    SET @OnFailAction = 2; --quit job, failure
    SET @OnSuccessAction = 3; -- go to next step
    SET @Command =
        'EXEC [Logging].[LogJobStart] @JobName = ' + '''' + @JobName + '''' + ';'
    EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                               @JobID = @JobID,
                               @JobStepOrdinal = @JobStepOrdinal,
                               @JobStepName = @JobStepName,
                               @DatabaseName = @DatabaseName,
                               @Command = @Command,
                               @OnSuccessAction = @OnSuccessAction, 
                               @OnSuccessOrdinal = @OnSuccessOrdinal,
                               @RetryAttempts = @RetryAttempts,
                               @RetryInterval = @RetryInterval,
                               @OnFailAction = @OnFailAction,
                               @OnFailOrdinal = @OnFailOrdinal;
  END;
  -----------------
  -- CHECK ENABLED
  -----------------
  SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
         @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
  SET @JobStepOrdinal = @JobStepOrdinal + 1;
  SET @DatabaseName = @DBName;
  SET @JobStepName = 'Check Job Enablement';
  SET @RetryAttempts = 0;
  SET @OnFailAction = CASE WHEN @EnableJobLog = 1 THEN 4 ELSE 2 END; -- go to specified @OnFailOrdinal
  SET @OnFailOrdinal = CASE WHEN @EnableJobLog = 1 THEN -1 ELSE 0 END; -- update post insert so we know which step is correct log end
  SET @OnSuccessAction = 3; --go to next step
  SET @Command =
    'IF [Config].[GetJobEnabledByName] (' +  '''' + @JobName + '''' + ') = 0
       THROW 50000, ''JOB DISABLED IN CONFIG. TERMINATING.'', 1;'
  EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                             @JobID = @JobID,
                             @JobStepOrdinal = @JobStepOrdinal,
                             @JobStepName = @JobStepName,
                             @DatabaseName = @DatabaseName,
                             @Command = @Command,
                             @OnSuccessAction = @OnSuccessAction, 
                             @OnSuccessOrdinal = @OnSuccessOrdinal,
                             @RetryAttempts = @RetryAttempts,
                             @RetryInterval = @RetryInterval,
                             @OnFailAction = @OnFailAction,
                             @OnFailOrdinal = @OnFailOrdinal;
  -----------------
  -- CHECK SB. QUEUE
  -----------------
  IF @CheckServiceBroker = 1 BEGIN;
    SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
           @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
    SET @JobStepOrdinal = @JobStepOrdinal + 1;
    SET @DatabaseName = @DBName;
    SET @JobStepName = 'Check Service Broker';
    SET @RetryAttempts = 0;
    SET @OnFailAction = CASE WHEN @EnableJobLog = 1 THEN 4 ELSE 2 END; -- go to specified @OnFailOrdinal
    SET @OnFailOrdinal = CASE WHEN @EnableJobLog = 1 THEN -1 ELSE 0 END; -- update post insert so we know which step is correct log end
    SET @OnSuccessAction = 3; -- go to next step
    SET @Command =
      'IF EXISTS (SELECT 1 FROM [Monitoring].[GetDisabledQueuesByLayerProcessID] (' + '''' + @Layer + '''' + ',[Config].[GetProcessIDByName] (' + '''' + @ProcessName + '''' + ')))
       THROW 50000, ''THERE ARE DISABLED QUEUES RELATED TO PROCESS. TERMINATING.'', 1;'
    EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                               @JobID = @JobID,
                               @JobStepOrdinal = @JobStepOrdinal,
                               @JobStepName = @JobStepName,
                               @DatabaseName = @DatabaseName,
                               @Command = @Command,
                               @OnSuccessAction = @OnSuccessAction, 
                               @OnSuccessOrdinal = @OnSuccessOrdinal,
                               @RetryAttempts = @RetryAttempts,
                               @RetryInterval = @RetryInterval,
                               @OnFailAction = @OnFailAction,
                               @OnFailOrdinal = @OnFailOrdinal;
  END;
  -----------------
  -- EXEC PROC.
  -----------------
  SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
         @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
  SET @JobStepOrdinal = @JobStepOrdinal + 1;
  SET @DatabaseName = @DBName;
  SET @JobStepName = 'Execute Process';
  SET @RetryAttempts = 3;
  SET @RetryInterval = 1;
  SET @OnFailAction = CASE WHEN @EnableJobLog = 1 THEN 4 ELSE 2 END; -- go to specified @OnFailOrdinal
  SET @OnFailOrdinal = CASE WHEN @EnableJobLog = 1 THEN -1 ELSE 0 END; -- update post insert so we know which step is correct log end
  -- IF THE JOB IS NOT LOOPING AND NOT CONTOLLER, THIS WOULD BE THE LAST STEP AND THUS LOG JOB END WITH SUCCESS. OTHERWISE, GO TO NEXT STEP --
  SET @OnSuccessAction = CASE WHEN @IsLoopJob = 0 THEN 4
                              WHEN @IsLoopJob = 1 AND @IsControllerJob = 0 THEN 4 ELSE 3 END;
  SET @OnSuccessOrdinal = CASE WHEN @IsLoopJob = 0 THEN -1
                               WHEN @IsLoopJob = 1 AND @IsControllerJob = 0 THEN -1 ELSE NULL END;
  SET @Command =
    'EXEC [' + @ProcessJobSchema + '].' + '[' + @ProcessJobProcedure + '] ' + CASE WHEN @ProcedureParams IS NOT NULL THEN @ProcedureParams ELSE '' END + ';'
  EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                             @JobID = @JobID,
                             @JobStepOrdinal = @JobStepOrdinal,
                             @JobStepName = @JobStepName,
                             @DatabaseName = @DatabaseName,
                             @Command = @Command,
                             @OnSuccessAction = @OnSuccessAction, 
                             @OnSuccessOrdinal = @OnSuccessOrdinal,
                             @RetryAttempts = @RetryAttempts,
                             @RetryInterval = @RetryInterval,
                             @OnFailAction = @OnFailAction,
                             @OnFailOrdinal = @OnFailOrdinal;
  -----------------
  -- WAIT
  -----------------
  -- CONTROLLER JOBS NEED TO HAVE WAIT TIMES. THE OTHER LOOP JOBS WILL ITERATE VIA CONTROLLER --
  IF @IsControllerJob = 1 AND @IsLoopJob = 1 BEGIN;
    SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
           @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
    SET @JobStepOrdinal = @JobStepOrdinal + 1;
    SET @DatabaseName = @DBName;
    SET @JobStepName = 'Wait';
    SET @RetryAttempts = 3;
    SET @RetryInterval = 1;
    SET @OnFailAction = CASE WHEN @EnableJobLog = 1 THEN 4 ELSE 2 END; -- go to specified @OnFailOrdinal
    SET @OnFailOrdinal = CASE WHEN @EnableJobLog = 1 THEN -1 ELSE 0 END; -- update post insert so we know which step is correct log end
    SET @OnSuccessAction = 4; --go to specified @OnSuccessOrdinal
    SET @OnSuccessOrdinal = 1; --loop, go back to step 1
    IF @EnableJobLog = 1 BEGIN;
      SET @Command =
        'EXEC [Logging].[LogJobEnd] @JobName = ' + '''' + @JobName + '''' + ', @StatusCode = 1; -- END LOG, SUCCESS
         DECLARE @WaitTime VARCHAR(12) = TRY_CAST([Config].[GetVariable_Job]([Config].[GetJobIDByName](' + '''' + @JobName + '''' + '), ''WaitforDelay'') AS VARCHAR(12));
         WAITFOR DELAY @WaitTime;'
    END; ELSE BEGIN;
      SET @Command =
        'DECLARE @WaitTime VARCHAR(12) = TRY_CAST([Config].[GetVariable_Job]([Config].[GetJobIDByName](' + '''' + @JobName + '''' + '), ''WaitforDelay'') AS VARCHAR(12));
         WAITFOR DELAY @WaitTime;'
    END;
    EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                               @JobID = @JobID,
                               @JobStepOrdinal = @JobStepOrdinal,
                               @JobStepName = @JobStepName,
                               @DatabaseName = @DatabaseName,
                               @Command = @Command,
                               @OnSuccessAction = @OnSuccessAction, 
                               @OnSuccessOrdinal = @OnSuccessOrdinal,
                               @RetryAttempts = @RetryAttempts,
                               @RetryInterval = @RetryInterval,
                               @OnFailAction = @OnFailAction,
                               @OnFailOrdinal = @OnFailOrdinal;
  END;
  -----------------
  -- LOG SUCCESS
  -----------------
  IF @EnableJobLog = 1 BEGIN;
    IF ((@IsLoopJob = 0) OR (@IsControllerJob = 0 AND @IsLoopJob = 1)) BEGIN;
      SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
             @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
      SET @JobStepOrdinal = @JobStepOrdinal + 1;
      SET @DatabaseName = @DBName;
      SET @JobStepName = 'Log Success Job End';
      SET @RetryAttempts = 3;
      SET @RetryInterval = 1;
      SET @OnFailAction = 4; -- go to specified @OnFailOrdinal
      SET @OnFailOrdinal = -1; -- update post insert so we know which step is correct log end
      SET @OnSuccessAction = 1; -- quit job, success
      SET @Command =
        'EXEC [Logging].[LogJobEnd] @JobName = ' + '''' + @JobName + '''' + ', @StatusCode = 1; -- END LOG, SUCCESS'
    EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                               @JobID = @JobID,
                               @JobStepOrdinal = @JobStepOrdinal,
                               @JobStepName = @JobStepName,
                               @DatabaseName = @DatabaseName,
                               @Command = @Command,
                               @OnSuccessAction = @OnSuccessAction, 
                               @OnSuccessOrdinal = @OnSuccessOrdinal,
                               @RetryAttempts = @RetryAttempts,
                               @RetryInterval = @RetryInterval,
                               @OnFailAction = @OnFailAction,
                               @OnFailOrdinal = @OnFailOrdinal;
    END;
  END;
  -----------------
  -- LOG FAILURE
  -----------------
  IF @EnableJobLog = 1 BEGIN;
    SELECT @JobStepName=NULL,@DatabaseName=NULL,@Command=NULL,@OnSuccessAction=NULL,@OnSuccessOrdinal=NULL,
           @RetryAttempts=NULL,@RetryInterval=NULL,@OnFailAction=NULL,@OnFailOrdinal=NULL;
    SET @JobStepOrdinal = @JobStepOrdinal + 1;
    SET @DatabaseName = @DBName;
    SET @JobStepName = 'Log Failure Job End';
    SET @RetryAttempts = 3;
    SET @RetryInterval = 1;
    SET @OnFailAction = 2; -- quit job, failure
    SET @OnSuccessAction = 2; -- quit job, failure
    SET @Command =
     'EXEC [Logging].[LogJobEnd] @JobName = ' + '''' + @JobName + '''' + ', @StatusCode = 2; -- END LOG, FAILURE'
    EXEC [Config].[SetJobStep] @ReplaceExisting = @ReplaceExistingSteps,
                               @JobID = @JobID,
                               @JobStepOrdinal = @JobStepOrdinal,
                               @JobStepName = @JobStepName,
                               @DatabaseName = @DatabaseName,
                               @Command = @Command,
                               @OnSuccessAction = @OnSuccessAction, 
                               @OnSuccessOrdinal = @OnSuccessOrdinal,
                               @RetryAttempts = @RetryAttempts,
                               @RetryInterval = @RetryInterval,
                               @OnFailAction = @OnFailAction,
                               @OnFailOrdinal = @OnFailOrdinal;
  END;
  IF @IsLoopJob = 1 BEGIN
  -----------------
  -- ADD CONFIG
  -----------------
    EXEC [Config].[SetVariable_Job] @JobID = @JobID, @ConfigGroupName = 'Job', @ConfigName = 'WaitForDelay', @ConfigValue = @WaitTime, @SelectOutput = 0;
  END;

  -------------------------------
  -- UPDATE JOB STEPS
  -------------------------------
  IF @EnableJobLog = 1 BEGIN;
    BEGIN TRANSACTION
      -- BEGIN UPDATES -- FAILURE STEP --
      UPDATE [Config].[JobStep] WITH (ROWLOCK)
        SET OnFailOrdinal = (SELECT JobStepOrdinal 
                                  FROM [Config].[JobStep] WITH (NOLOCK)
                                 WHERE JobID = @JobID
                                   AND JobStepName = 'Log Failure Job End')
      WHERE JobID = @JobID
        AND OnFailOrdinal = -1;
      -- BEGIN UPDATES -- SUCCESS STEP --
      UPDATE [Config].[JobStep] WITH (ROWLOCK)
        SET OnSuccessOrdinal = (SELECT JobStepOrdinal 
                                  FROM [Config].[JobStep] WITH (NOLOCK)
                                 WHERE JobID = @JobID
                                   AND JobStepName = 'Log Success Job End')
      WHERE JobID = @JobID
        AND OnSuccessOrdinal = -1;
    COMMIT;
  END;
END TRY
BEGIN CATCH
  /*
    -- XACT_STATE:
     1 = Active transactions, CAN be committed or rolled back. Because of error, we rollback
     0 = NO Active transactions, CANNOT be committed or rolled back.
    -1 = Active transactions, CANNOT be committed but CAN be rolled back. Because of error, we rollback
  */
  IF XACT_STATE() <> 0
    ROLLBACK;
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[SetVariable_Process] (
  @ProcessID SMALLINT,
  @ConfigGroupName VARCHAR(150),
  @ConfigName VARCHAR(150),
  @ConfigValue VARCHAR(150),
  @SelectOutput BIT = 1,
  @Delete BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @ConfigID INT = [Config].[GetVariableIDByname](@ConfigGroupName, @ConfigName);
  IF @Delete = 1 BEGIN;
    DELETE FROM [Config].[ProcessVariable] WHERE [ProcessID] = @ProcessID AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'DELETED: Config for ProcessID: ' + CAST(@ProcessID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName;
    RETURN;
  END;
  IF NOT EXISTS (SELECT 1 FROM [Config].[ProcessVariable] WITH (NOLOCK) WHERE [ProcessID] = @ProcessID AND [ConfigID] = @ConfigID) BEGIN;
    INSERT INTO [Config].[ProcessVariable] ([ProcessID], [ConfigID], [ConfigValue])
      VALUES (@ProcessID, @ConfigID, @ConfigValue);
    IF @SelectOutput = 1 SELECT 'INSERTED: Config for ProcessID: ' + CAST(@ProcessID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName + ' ; ConfigValue: ' + @ConfigValue;
    RETURN;
  END; ELSE BEGIN;
    UPDATE [Config].[ProcessVariable] WITH (ROWLOCK)
       SET [ConfigValue] = @ConfigValue
     WHERE [ProcessID] = @ProcessID
       AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'UPDATED: Config for ProcessID: ' + CAST(@ProcessID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName + ' ; ConfigValue: ' + @ConfigValue;
    RETURN;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [Config].[SetVariable_ProcessTask] (
  @ProcessTaskID INT,
  @ConfigGroupName VARCHAR(150),
  @ConfigName VARCHAR(150),
  @ConfigValue VARCHAR(150),
  @SelectOutput BIT = 1,
  @Delete BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @ConfigID INT = [Config].[GetVariableIDByname](@ConfigGroupName, @ConfigName);
  IF @Delete = 1 BEGIN;
    DELETE FROM [Config].[ProcessTaskVariable] WHERE [ProcessTaskID] = @ProcessTaskID AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'DELETED: Config for ProcessTaskID: ' + CAST(@ProcessTaskID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName;
    RETURN;
  END;
  IF NOT EXISTS (SELECT 1 FROM [Config].[ProcessTaskVariable] WITH (NOLOCK) WHERE [ProcessTaskID] = @ProcessTaskID AND [ConfigID] = @ConfigID) BEGIN;
    INSERT INTO [Config].[ProcessTaskVariable] ([ProcessTaskID], [ConfigID], [ConfigValue])
      VALUES (@ProcessTaskID, @ConfigID, @ConfigValue);
    IF @SelectOutput = 1 SELECT 'INSERTED: Config for ProcessTaskID: ' + CAST(@ProcessTaskID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName;
    RETURN;
  END; ELSE BEGIN;
    UPDATE [Config].[ProcessTaskVariable] WITH (ROWLOCK)
       SET [ConfigValue] = @ConfigValue
     WHERE [ProcessTaskID] = @ProcessTaskID
       AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'UPDATED: Config for ProcessTaskID: ' + CAST(@ProcessTaskID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName;
    RETURN;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [Config].[SetRunnable_JobList] (
 @JobList Config.JobID READONLY,
 @IsRunnable BIT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  UPDATE J WITH (ROWLOCK, READPAST)
    SET [IsRunnable] = @IsRunnable
   FROM @JobList JL
  INNER JOIN [Config].[Job] J
     ON JL.JobID = J.JobID;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [Config].[SetVariable_Job] (
  @JobID SMALLINT,
  @ConfigGroupName VARCHAR(150),
  @ConfigName VARCHAR(150),
  @ConfigValue VARCHAR(150),
  @SelectOutput BIT = 1,
  @Delete BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @ConfigID INT = [Config].[GetVariableIDByname](@ConfigGroupName, @ConfigName);
  IF @Delete = 1 BEGIN;
    DELETE FROM [Config].[JobVariable] WHERE [JobID] = @JobID AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'DELETED: Config for JobID: ' + CAST(@JobID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName;
    RETURN;
  END;
  IF NOT EXISTS (SELECT 1 FROM [Config].[JobVariable] WITH (NOLOCK) WHERE [JobID] = @JobID AND [ConfigID] = @ConfigID) BEGIN;
    INSERT INTO [Config].[JobVariable] ([JobID], [ConfigID], [ConfigValue])
      VALUES (@JobID, @ConfigID, @ConfigValue);
    IF @SelectOutput = 1 SELECT 'INSERTED: Config for JobID: ' + CAST(@JobID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName + ' ; ConfigValue: ' + @ConfigValue;
    RETURN;
  END; ELSE BEGIN;
    UPDATE [Config].[JobVariable] WITH (ROWLOCK)
       SET [ConfigValue] = @ConfigValue
     WHERE [JobID] = @JobID
       AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'UPDATED: Config for JobID: ' + CAST(@JobID AS VARCHAR) + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName + ' ; ConfigValue: ' + @ConfigValue;
    RETURN;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO



GO
CREATE OR ALTER PROCEDURE [Config].[SetVariable_AppLock] (
  @ConfigGroupName VARCHAR(150) = 'AppLock',
  @ConfigName VARCHAR(150),
  @ObjectName NVARCHAR(128),
  @ConfigValue VARCHAR(150),
  @SelectOutput BIT = 0,
  @Delete BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @ConfigID INT = [Config].[GetVariableIDByname](@ConfigGroupName, @ConfigName);
  IF @Delete = 1 BEGIN;
    DELETE FROM [Config].[AppLockVariable] WHERE [ObjectName] = @ObjectName AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'DELETED: Config for ObjectName: ' + @ObjectName + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName;
    RETURN;
  END;
  IF NOT EXISTS (SELECT 1 FROM [Config].[AppLockVariable] WITH (NOLOCK) WHERE [ObjectName] = @ObjectName AND [ConfigID] = @ConfigID) BEGIN;
    INSERT INTO [Config].[AppLockVariable] ([ObjectName], [ConfigID], [ConfigValue])
      VALUES (@ObjectName, @ConfigID, @ConfigValue);
    IF @SelectOutput = 1 SELECT 'INSERTED: Config for ObjectName: ' + @ObjectName + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName + ' ; ConfigValue: ' + @ConfigValue;
    RETURN;
  END; ELSE BEGIN;
    UPDATE [Config].[AppLockVariable] WITH (ROWLOCK)
       SET [ConfigValue] = @ConfigValue
     WHERE [ObjectName] = @ObjectName
       AND [ConfigID] = @ConfigID;
    IF @SelectOutput = 1 SELECT 'UPDATED: Config for ObjectName: ' + @ObjectName + ' ; ConfigID: ' + CAST(@ConfigID AS VARCHAR) + ' ; ConfigGroup: ' + @ConfigGroupName + ' ; ConfigName: ' + @ConfigName + ' ; ConfigValue: ' + @ConfigValue;
    RETURN;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO


/* End of File ********************************************************************************************************************/