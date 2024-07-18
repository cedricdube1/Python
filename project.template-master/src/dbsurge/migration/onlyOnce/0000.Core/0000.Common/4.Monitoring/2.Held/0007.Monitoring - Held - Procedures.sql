/***********************************************************************************************************************************
* Script      : 7.Held - Procedures.sql                                                                                            *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-04-08                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. [StagingHeld]                                                                                                   *
*             :  2. [Process_Held]                                                                                                 * 
***********************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE PROCEDURE [Monitoring].[StagingHeld] (
  @ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-04-08
  -- Description: Check for Source Held entries
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
  DECLARE @Taskname NVARCHAR(128) = 'StagingHeld';
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
  DECLARE @MonitoringTime DATETIME2 = SYSDATETIME();
  DECLARE @TimeWindow INT = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'TimeWindow') AS INT);
  DECLARE @HeldTimeLimit INT = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'HeldTimeLimit') AS INT);
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
                                     ELSE 'UNK' END;
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
  IF OBJECT_ID('TempDB..#HeldTables') IS NOT NULL 
    DROP TABLE #HeldTables;
  CREATE TABLE #HeldTables (
    DatabaseName NVARCHAR(128) NOT NULL,
    SchemaName NVARCHAR(128) NOT NULL,
    TableName NVARCHAR(128) NOT NULL,
    PartitionNumber INT NULL,
    [FileGroup]NVARCHAR(128) NULL,
    Display_RowCount VARCHAR(150) NULL,
    Diplay_Used_MB VARCHAR(150) NULL,
    Diplay_Unused_MB VARCHAR(150) NULL,
    Diplay_Total_MB VARCHAR(150) NULL,
    [RowCount] INT NOT NULL,
    Used_MB INT NULL,
    Unused_MB INT NULL,
    Total_MB INT NULL
  );
  IF OBJECT_ID('TempDB..#Failure') IS NOT NULL 
    DROP TABLE #Failure;
  CREATE TABLE #Failure (
    HeldDatabase NVARCHAR(128) NOT NULL,
    HeldTableSchema NVARCHAR(128) NOT NULL,
    HeldTableName NVARCHAR(128) NOT NULL,
    HeldView NVARCHAR(255) NULL,
    HeldCount INT NOT NULL DEFAULT (0),
    EarliestHeldDate DATETIME2 NOT NULL,
    LatestHeldDate DATETIME2 NOT NULL
  );

  ------------------------
  -- COLLECT TABLES WITH ROWS
  ------------------------
  INSERT INTO #HeldTables
    EXEC [dbSurge].[Helper].[TableStorage] @TableNamePattern = 'Held', @TableNamePatternPosition = 'R', @IncludeEmptyTables = 0;
  ------------------------
  -- COLLECT DIFFERENCES
  ------------------------
  WHILE EXISTS (SELECT 1 FROM #HeldTables) BEGIN;
    DECLARE @Command NVARCHAR(MAX);
    DECLARE @HeldDatabase NVARCHAR(128),
            @HeldTableSchema NVARCHAR(128),
            @HeldTableName NVARCHAR(128),
            @HeldView NVARCHAR(255),
            @HeldCount INT = 0,
            @EarliestHeldDate DATETIME2 = '1753-01-01',
            @LatestHeldDate DATETIME2 = '9999-12-31';
    SELECT TOP (1) @HeldDatabase = 'dbSurge',
                   @HeldTableSchema = REPLACE(REPLACE(SchemaName,'[',''),']',''),
                   @HeldTableName = REPLACE(REPLACE(TableName,'[',''),']',''),
                   @HeldView = REPLACE(REPLACE(SchemaName,'[',''),']','') + '.v' + REPLACE(REPLACE(TableName,'[',''),']','') + 'Detail'
              FROM #HeldTables;

    SET @Command = N'
        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
          SELECT @HeldCount = COUNT(1), @EarliestHeldDate = MIN(InsertedDate), @LatestHeldDate = MAX(InsertedDate)
            FROM [' + @HeldDatabase + '].[' + @HeldTableSchema + '].[' + @HeldTableName + ']
          WHERE Processed = 0
            AND InsertedDate < DATEADD(MINUTE, -@HeldTimeLimit, SYSUTCDATETIME());
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    ';
    EXEC SP_ExecuteSQL @Command,
                       N'@HeldCount INT OUTPUT, @EarliestHeldDate DATETIME2 OUTPUT, @LatestHeldDate DATETIME2 OUTPUT, @HeldTimeLimit INT',
                       @HeldTimeLimit = @HeldTimeLimit,
                       @HeldCount = @HeldCount OUTPUT,
                       @EarliestHeldDate = @EarliestHeldDate OUTPUT,
                       @LatestHeldDate = @LatestHeldDate OUTPUT;

    IF @HeldCount > 0 BEGIN;
      INSERT INTO #Failure (
        HeldDatabase,
        HeldTableSchema,
        HeldTableName,
        HeldView,
        HeldCount,
        EarliestHeldDate,
        LatestHeldDate
      ) VALUES (@HeldDatabase, @HeldTableSchema, @HeldTableName, @HeldView, @HeldCount, ISNULL(@EarliestHeldDate, '1753-01-01'), ISNULL(@LatestHeldDate, '9999-12-31'));
    END;
    DELETE FROM #HeldTables 
     WHERE SchemaName = @HeldTableSchema
       AND TableName = @HeldTableName
  END;

  ------------------------
  -- WRITE TO MONITORING
  ------------------------
  INSERT INTO [Monitoring].[Held] (
    HeldDatabase,
    HeldTableSchema,
    HeldTableName,
    HeldView,
    HeldCount,
    EarliestHeldDate,
    LatestHeldDate,
    AlertID,
    InsertDate
  ) SELECT SRC.HeldDatabase,
           SRC.HeldTableSchema,
           SRC.HeldTableName,
           SRC.HeldView,
           SRC.HeldCount,
           SRC.EarliestHeldDate,
           SRC.LatestHeldDate,
           0,
           @MonitoringTime
      FROM #Failure SRC
      LEFT JOIN [Monitoring].[Held] TRG
        ON SRC.HeldDatabase = TRG.HeldDatabase
       AND SRC.HeldTableSchema = TRG.HeldTableSchema
       AND SRC.HeldTableName = TRG.HeldTableName
       AND @MonitoringTime BETWEEN TRG.[InsertDate] AND DATEADD(MINUTE, @TimeWindow, TRG.[InsertDate])
     WHERE TRG.HeldDatabase IS NULL;
  SET @RecCountFail = @@ROWCOUNT;
  ------------------------
  -- BUILD NOTIFICATIONS
  ------------------------
  IF @RecCountFail > 0
  BEGIN;
    DECLARE @AlertID INT;
    SET @AlertMessageHeader = N'(' + @MessageTime + N') CPT BI-RETENTION ' + @RunEnvironment + N' Held - ('
                              + CAST(@RecCountFail AS VARCHAR(5)) + N') long-Held entries detected!'
  ---------------
  -- EMAIL
  ---------------
    IF @SendType = 'EMail' BEGIN;
      SET @AlertQuery= '
      SELECT [HeldDatabase],
             [HeldTableSchema],
             [HeldTableName],
             [HeldView],
             [HeldCount],
             CONVERT(VARCHAR(30), [EarliestHeldDate], 121) AS [EarliestHeldDate],
             CONVERT(VARCHAR(30), [LatestHeldDate], 121) AS [LatestHeldDate],
             CONVERT(VARCHAR(30), [InsertDate], 121) AS [InsertDate]
      FROM [Monitoring].[Held]
      WHERE [AlertID] = 0';
      SET @AlertBodyOrder = ' ORDER BY HeldDatabase ASC, HeldTableSchema ASC, HeldTableName ASC';
	  
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
      UPDATE [Monitoring].[Held] WITH (ROWLOCK, READPAST)
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
GO
CREATE PROCEDURE [Monitoring].[Process_Held] AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-04-08
  -- Description: Monitor Held
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
  DECLARE @ProcessName VARCHAR(150) = 'Monitoring|Held',
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
  -- PROCESS
  -------------------------------------------------------------------------------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Monitoring].[StagingHeld] @ProcessID = @ProcessID,
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