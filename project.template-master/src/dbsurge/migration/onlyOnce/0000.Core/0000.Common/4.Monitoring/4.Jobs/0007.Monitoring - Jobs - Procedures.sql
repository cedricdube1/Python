/***********************************************************************************************************************************
* Script      : 7.Notification - Procedures.sql                                                                                    *
* Created By  : Cedric Dube                                                                                          *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. [ETL_JobFailures]                                                                                              *
*             :  2. [Controller_JobDisabled]                                                                                       *
*             :  3. [Process_Jobs]                                                                                                 *
***********************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE PROCEDURE [Monitoring].[ETL_JobFailures] (
  @ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-03-08
  -- Description: Monitor failed Jobs.
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------    
  DECLARE @Taskname NVARCHAR(128) = 'JobFailures';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, 'InfoDisabled') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, 'CaptureDisabled') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
 DECLARE @RunEnvironment CHAR(3) = CASE WHEN @@SERVERNAME IN ('CPTDEVDB02','CPTDEVDB10') THEN 'DEV'
                                         WHEN @@SERVERNAME IN ('ANALYSIS01','CPTAOLSTN10','CPTAODB10A','CPTAODB10B') THEN 'PRD'
                                    ELSE 'DEV' END;
  -------------------------------
  -- NOTIFICATION VARS.
  -------------------------------
  DECLARE @MessageTime CHAR(5) = CONVERT(VARCHAR(5), SYSDATETIME(), 108);
  DECLARE @SendType VARCHAR(10) = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'SendType') AS VARCHAR(10));
  DECLARE @RecCountFail INT = 0;
  DECLARE @AlertType VARCHAR(10),
          @ProfileName NVARCHAR(128),
          @DefaultSubject NVARCHAR(128);
  DECLARE @AlertMessageHeader NVARCHAR(140),
          @AlertMessage NVARCHAR(MAX),
          @AlertQuery NVARCHAR(MAX),
          @AlertBodyOrder NVARCHAR(MAX);
  DECLARE @ToNumbers_Fail VARCHAR(8000) = [Notification].[GetRecipientList](@SendType);
  DECLARE @AlertFormat VARCHAR(20) = CASE WHEN @SendType = 'EMail' THEN 'HTML'
                                          WHEN @SendType = 'SMS' THEN 'TEXT'
                                     ELSE 'DEV' END;
  SELECT TOP (1) @AlertType = SendType,
                 @ProfileName = ProfileName,
                 @DefaultSubject = DefaultSubject
    FROM [Notification].[SendProfile] WITH (NOLOCK)
   WHERE ProfileType = 'DEFAULT' AND SendType = @SendType;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  EXEC [Logging].[LogProcessTaskStart] @IsEnabled = @IsProcessTaskEnabled, @ProcessLogID = @ProcessLogID,
                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                       @ProcessTaskID = @ProcessTaskID,
                                       @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;
  
  SET @InfoMessage = 'Task for ' + @Taskname + ' started.';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;
  -- IsEnabled = 0 --
  IF @IsProcessTaskEnabled = 0 BEGIN;
      IF @ProcessTaskLogID IS NULL SET @ProcessTaskLogID = -1;
    -- Info Log Start --
    SET @InfoMessage = 'Task for ' + @Taskname + ' is DISABLED in Config.Task. Exiting.';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  ------------------------
  -- TEMP. TABLES -- 
  ------------------------
  IF OBJECT_ID('TempDB..#Failure') IS NOT NULL 
    DROP TABLE #Failure;
  CREATE TABLE #Failure (
    [JobID] UNIQUEIDENTIFIER NOT NULL,
    [JobName] NVARCHAR(128) NOT NULL,
    [Category] NVARCHAR(128) NOT NULL,
    [LastRunDateTime] DATETIME2(7) NULL,
    [LastRunStatus] VARCHAR(20)NULL,
    [LastRunDuration (HH:MM:SS)] VARCHAR(30) NULL,
    [LastRunStatusMessage] NVARCHAR(4000) NULL,
    [NextRunDateTime] DATETIME2(7) NULL,
    [AlertID] [INT] NULL,
    [InsertDate] DATETIME2(7) NULL
  );
  ------------------------
  -- COLLECT FAILED JOBS
  ------------------------
  INSERT INTO #Failure (
    JobID,
    JobName,
    Category,
    LastRunDateTime,
    LastRunStatus,
    [LastRunDuration (HH:MM:SS)],
    LastRunStatusMessage,
    NextRunDateTime,
    AlertID,
    InsertDate
  ) SELECT JobID,
           JobName,
           JobCategory,
           LastRunDateTime,
           LastRunStatus,
           [LastRunDuration (HH:MM:SS)],
           LastRunStatusMessage,
           NextRunDateTime,
           0,
           @NowTime
     FROM [Monitoring].[vSQLServerAgentFailedJob] WITH (NOLOCK)
        WHERE [JobName] LIKE '%SurgeETL%';
  ------------------------
  -- WRITE TO MONITORING
  ------------------------
  BEGIN TRANSACTION;
    INSERT INTO [Monitoring].[SQLServerAgentJobFailure] (
      JobID,
      JobName,
      Category,
      LastRunDateTime,
      LastRunStatus,
      [LastRunDuration (HH:MM:SS)],
      LastRunStatusMessage,
      NextRunDateTime,
      AlertID,
      InsertDate
    ) SELECT Src.JobID,
             Src.JobName,
             Src.Category,
             Src.LastRunDateTime,
             Src.LastRunStatus,
             Src.[LastRunDuration (HH:MM:SS)],
             Src.LastRunStatusMessage,
             Src.NextRunDateTime,
             Src.AlertID,
             Src.InsertDate
        FROM #Failure SRC
        LEFT JOIN [Monitoring].[SQLServerAgentJobFailure] TRG
          ON SRC.JobID = TRG.JobID
         AND SRC.LastRunDateTime = TRG.LastRunDateTime
       WHERE TRG.JobID IS NULL;
    SET @RecCountFail = @@ROWCOUNT;
  COMMIT;
  ------------------------
  -- BUILD NOTIFICATIONS
  ------------------------
  IF @RecCountFail > 0
  BEGIN;
    DECLARE @AlertID INT;
    SET @AlertMessageHeader = N'(' + @MessageTime + N') CPT IG - Insights ' + @RunEnvironment + N' ETL Jobs - ('
                          + CAST(@RecCountFail AS VARCHAR(5)) + N') failures detected!';
  ---------------
  -- EMAIL
  ---------------
    IF @SendType = 'EMail' BEGIN;
      SET @AlertQuery= '
      SELECT [JobName],
             [Category],
             CONVERT(VARCHAR(30), [LastRunDateTime], 121) AS [LastRunDateTime],
             [LastRunStatusMessage]
      FROM [Monitoring].[SQLServerAgentJobFailure]
      WHERE [AlertID] = 0';
      SET @AlertBodyOrder = ' ORDER BY JobName ASC';
	  
      EXEC [Notification].[Convert_SQLQuery_ToHtml] @query = @AlertQuery,
                                                    @orderBy = @AlertBodyOrder,
                                                    @html = @AlertMessage OUTPUT;
	  
      SET @AlertMessage = @AlertMessageHeader + CHAR(10) + CHAR(13) + @AlertMessage;
    END;
  ---------------
  -- SMS
  ---------------
    IF @SendType = 'SMS' BEGIN;
      SET @AlertMessage = @AlertMessageHeader;
    END;
    BEGIN TRANSACTION;
      -- Set Notification --
      EXEC [Notification].[SetNotification]   @AlertDateTime = @NowTime,
                                              @Alertprocedure = @ProcedureName,
                                              @AlertType = @AlertType,
                                              @AlertRecipients = @ToNumbers_Fail,
                                              @AlertProfile = @ProfileName,
                                              @AlertFormat = @AlertFormat,
                                              @AlertSubject = @DefaultSubject,
                                              @AlertMessage = @AlertMessage,
                                              @AlertID = @AlertID OUTPUT;
       --Set all records as AlertID = @AlertID --
      UPDATE [Monitoring].[SQLServerAgentJobFailure] WITH (ROWLOCK, READPAST)
        SET AlertID = @AlertID
        WHERE AlertID = 0 AND @AlertID IS NOT NULL;
    COMMIT;
  END;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  Finalize:
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Task --
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 1;
  -- Info --
  SET @StepID = @StepID +1;
  SET @InfoMessage = 'Task for ' + @Taskname + ' Completed.';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;

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
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  
  ------------------------
  -- COMPLETE INFO LOG
  ------------------------
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
  ------------------------
  -- COMPLETE LOG -- ERROR
  ------------------------
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 2;
  THROW; 
END CATCH;
END
GO
GO
CREATE PROCEDURE [Monitoring].[Controller_JobDisabled] (
  @ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-03-08
  -- Description: Monitor Controlled Jobs running state.
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------    
  DECLARE @Taskname NVARCHAR(128) = 'ControllerJobDisabled';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, 'InfoDisabled') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, 'CaptureDisabled') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
 DECLARE @RunEnvironment CHAR(3) = CASE WHEN @@SERVERNAME IN ('CPTDEVDB02','CPTDEVDB10') THEN 'DEV'
                                         WHEN @@SERVERNAME IN ('ANALYSIS01','CPTAOLSTN10','CPTAODB10A','CPTAODB10B') THEN 'PRD'
                                    ELSE 'DEV' END;
  -------------------------------
  -- NOTIFICATION VARS.
  -------------------------------
  DECLARE @MessageTime CHAR(5) = CONVERT(VARCHAR(5), SYSDATETIME(), 108);
  DECLARE @SendType VARCHAR(10) = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'SendType') AS VARCHAR(10));
  DECLARE @RecCountFail INT = 0;
  DECLARE @AlertType VARCHAR(10),
          @ProfileName NVARCHAR(128),
          @DefaultSubject NVARCHAR(128);
  DECLARE @AlertMessageHeader NVARCHAR(140),
          @AlertMessage NVARCHAR(MAX),
          @AlertQuery NVARCHAR(MAX),
          @AlertBodyOrder NVARCHAR(MAX);
  DECLARE @ToNumbers_Fail VARCHAR(8000) = [Notification].[GetRecipientList](@SendType);
  DECLARE @AlertFormat VARCHAR(20) = CASE WHEN @SendType = 'EMail' THEN 'HTML'
                                          WHEN @SendType = 'SMS' THEN 'TEXT'
                                     ELSE 'DEV' END;
  SELECT TOP (1) @AlertType = SendType,
                 @ProfileName = ProfileName,
                 @DefaultSubject = DefaultSubject
    FROM [Notification].[SendProfile] WITH (NOLOCK)
   WHERE ProfileType = 'DEFAULT' AND SendType = @SendType;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  EXEC [Logging].[LogProcessTaskStart] @IsEnabled = @IsProcessTaskEnabled, @ProcessLogID = @ProcessLogID,
                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                       @ProcessTaskID = @ProcessTaskID,
                                       @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;
  
  SET @InfoMessage = 'Task for ' + @Taskname + ' started.';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;
  -- IsEnabled = 0 --
  IF @IsProcessTaskEnabled = 0 BEGIN;
      IF @ProcessTaskLogID IS NULL SET @ProcessTaskLogID = -1;
    -- Info Log Start --
    SET @InfoMessage = 'Task for ' + @Taskname + ' is DISABLED in Config.Task. Exiting.';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  ------------------------
  -- TEMP. TABLES -- 
  ------------------------
  IF OBJECT_ID('TempDB..#Failure') IS NOT NULL 
    DROP TABLE #Failure;
  CREATE TABLE #Failure (
    [SQLServerAgentJobID] UNIQUEIDENTIFIER NOT NULL,
    [ConfigJobID] SMALLINT NOT NULL,
    [JobName] NVARCHAR(128) NOT NULL,
    [LastRunStartDateTime] DATETIME2(7) NULL,
    [LastRunEndDateTime] DATETIME2(7) NULL,
    [AlertID] [INT] NULL,
    [InsertDate] DATETIME2(7) NULL
  );
  ------------------------
  -- COLLECT PROBLEM JOBS
  ------------------------
  INSERT INTO #Failure (
    SQLServerAgentJobID,
    ConfigJobID,
    JobName,
    LastRunStartDateTime,
    LastRunEndDateTime,
    AlertID,
    InsertDate
  ) SELECT SQLServerAgentJobID,
           ConfigJobID,
           JobName,
           [Start_Execution_Date],
           [Stop_Execution_Date],
           0,
           @NowTime
     FROM [Monitoring].[vSQLServerAgentControllerJobState] WITH (NOLOCK)
        WHERE [Stop_Execution_Date] IS NOT NULL;
  ------------------------
  -- WRITE TO MONITORING
  ------------------------
  BEGIN TRANSACTION;
    INSERT INTO [Monitoring].[SQLServerAgentControllerJobDisabled] (
      SQLServerAgentJobID,
      ConfigJobID,
      JobName,
      LastRunStartDateTime,
      LastRunEndDateTime,
      AlertID,
      InsertDate
    ) SELECT Src.SQLServerAgentJobID,
             Src.ConfigJobID,
             Src.JobName,
             Src.LastRunStartDateTime,
             Src.LastRunEndDateTime,
             Src.AlertID,
             Src.InsertDate
        FROM #Failure SRC
        LEFT JOIN [Monitoring].[SQLServerAgentControllerJobDisabled] TRG
          ON SRC.ConfigJobID = TRG.ConfigJobID
         AND SRC.LastRunEndDateTime = TRG.LastRunEndDateTime
       WHERE TRG.ConfigJobID IS NULL;
    SET @RecCountFail = @@ROWCOUNT;
  COMMIT;
  ------------------------
  -- BUILD NOTIFICATIONS
  ------------------------
  IF @RecCountFail > 0
  BEGIN;
    DECLARE @AlertID INT;
    SET @AlertMessageHeader = N'(' + @MessageTime + N') SurgeETL IG - Insights ' + @RunEnvironment + N' Control Jobs - ('
                          + CAST(@RecCountFail AS VARCHAR(5)) + N') not running detected!';
  ---------------
  -- EMAIL
  ---------------
    IF @SendType = 'EMail' BEGIN;
      SET @AlertQuery= '
      SELECT [JobName],
             CONVERT(VARCHAR(30), [LastRunStartDateTime], 121) AS [LastRunStartDateTime],
             CONVERT(VARCHAR(30), [LastRunEndDateTime], 121) AS [LastRunEndDateTime]
      FROM [Monitoring].[SQLServerAgentControllerJobDisabled]
      WHERE [AlertID] = 0';
      SET @AlertBodyOrder = ' ORDER BY JobName ASC';
	  
      EXEC [Notification].[Convert_SQLQuery_ToHtml] @query = @AlertQuery,
                                                    @orderBy = @AlertBodyOrder,
                                                    @html = @AlertMessage OUTPUT;
	  
      SET @AlertMessage = @AlertMessageHeader + CHAR(10) + CHAR(13) + @AlertMessage;
    END;
  ---------------
  -- SMS
  ---------------
    IF @SendType = 'SMS' BEGIN;
      SET @AlertMessage = @AlertMessageHeader;
    END;
    BEGIN TRANSACTION;
      -- Set Notification --
      EXEC [Notification].[SetNotification]   @AlertDateTime = @NowTime,
                                              @Alertprocedure = @ProcedureName,
                                              @AlertType = @AlertType,
                                              @AlertRecipients = @ToNumbers_Fail,
                                              @AlertProfile = @ProfileName,
                                              @AlertFormat = @AlertFormat,
                                              @AlertSubject = @DefaultSubject,
                                              @AlertMessage = @AlertMessage,
                                              @AlertID = @AlertID OUTPUT;
       --Set all records as AlertID = @AlertID --
      UPDATE [Monitoring].[SQLServerAgentControllerJobDisabled] WITH (ROWLOCK, READPAST)
        SET AlertID = @AlertID
        WHERE AlertID = 0 AND @AlertID IS NOT NULL;
    COMMIT;
  END;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  Finalize:
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Task --
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 1;
  -- Info --
  SET @StepID = @StepID +1;
  SET @InfoMessage = 'Task for ' + @Taskname + ' Completed.';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;

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
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  
  ------------------------
  -- COMPLETE INFO LOG
  ------------------------
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
  ------------------------
  -- COMPLETE LOG -- ERROR
  ------------------------
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 2;
  THROW; 
END CATCH;
END
GO
GO
CREATE PROCEDURE [Monitoring].[Process_Jobs] AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-03-02
  -- Description: Monitor Jobs.
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @NowTime DATETIME2(7) = SYSUTCDATETIME();
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- CONFIG VARS.
  -------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @ProcessName VARCHAR(150) = 'Monitoring|Jobs',
          @ProcessLogID BIGINT,
          @ProcessLogCreatedMonth TINYINT;
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @ProcessID SMALLINT,
          @IsProcessEnabled BIT;
  EXEC [Config].[GetProcessStateByName] @ProcessName = @ProcessName, @ProcessID = @ProcessID OUTPUT, @IsEnabled = @IsProcessEnabled OUTPUT;
  -- IsEnabled = 0 --
  IF @IsProcessEnabled = 0
    RETURN; -- Nothing to do
  -------------------------------
  -- TASK OUTPUT VARS.
  -------------------------------
  -- PROCESS TASK --
  DECLARE @TaskID SMALLINT,
          @ProcessTaskLogID BIGINT;
  ------------------------
  -- CREATE LOG
  ------------------------
  EXEC [Logging].[LogProcessStart] @IsEnabled = @IsProcessEnabled, @ProcessID = @ProcessID,
                                   @ReuseOpenLog = 1,
                                   @ProcessLogID = @ProcessLogID OUTPUT,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth OUTPUT;
  -- No Log --
  IF @ProcessLogID IS NULL BEGIN;
    SET @ProcessLogID = -1;
    SET @InfoMessage = 'No ProcessLogID was returned from [Logging].[LogProcessStart]. Procedure ' + @ProcedureName + ' terminated.';
    THROW 50000, @InfoMessage, 0;
  END;
  -------------------------------------------------------------------------------------------------
  -- PROCESS - JOB FAILURES --
  -------------------------------------------------------------------------------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Monitoring].[ETL_JobFailures] @ProcessID = @ProcessID,
                                      @ProcessLogID = @ProcessLogID,
                                      @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                      @TaskID = @TaskID OUTPUT,
                                      @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;  
  -------------------------------------------------------------------------------------------------
  -- PROCESS - CONTROLLER JOB DISABLED --
  -------------------------------------------------------------------------------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Monitoring].[Controller_JobDisabled] @ProcessID = @ProcessID,
                                             @ProcessLogID = @ProcessLogID,
                                             @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                             @TaskID = @TaskID OUTPUT,
                                             @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;  
  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Process
  EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @StatusCode = 1;
  
  END TRY
  BEGIN CATCH
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    -- CREATE ERROR LOG ENTRIES
    DECLARE @ErrorNumber INTEGER = ERROR_NUMBER(),
            @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
            @ErrorLine INTEGER = ERROR_LINE(),
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    ------------------------
    -- COMPLETE LOG -- ERROR
    ------------------------
    -- PROCESS --
    EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                   @StatusCode = 2;
    -- LOG ERROR --
    EXEC [Logging].[LogError] @ProcessID = @ProcessID,
                              @ProcessLogID = @ProcessLogID,
                              @ErrorNumber = @ErrorNumber,
                              @ErrorProcedure = @ErrorProcedure,
                              @ErrorLine = @ErrorLine,
                              @ErrorMessage = @ErrorMessage;
    THROW;
  END CATCH;
END;
GO
GO

/* End of File ********************************************************************************************************************/