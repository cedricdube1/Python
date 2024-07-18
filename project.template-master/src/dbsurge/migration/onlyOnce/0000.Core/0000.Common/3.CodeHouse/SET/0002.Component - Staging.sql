/************************************************************************
* Script     : 2.Component - Staging.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
**********************************************************************
* Steps      : 1 > ProcessStatement_Catch
*            : 2 > TaskStatement_Catch
*            : 3 > ExtractTaskStatement_Catch
*            : 4 > ExtractTaskStatement_CDOByIDSetup
*            : 5 > TaskStatement_DetermineProcessTask
*            : 6 > ExtractTaskStatement_DetermineExtractTask
*            : 7 > ExtractTaskStatement_CollectChangeRows
*            : 8 > ExtractTaskStatement_CollectHeldRows
*            : 9 > ExtractTaskStatement_CollectNone
*            :10 > TaskStatement_Finalize
*            :11 > ExtractTaskStatement
*            :11 > ExtractTaskStatement_WithoutHeld
*            :12 > StageTaskStatement_Setup
*            :13 > StageTaskStatement_CollectNone
*            :14 > StageTaskStatement_IterationsHeader
*            :15 > StageTaskStatement_IterationsFooter
*            :16 > StageTaskStatement_RemoveStageDuplicates
*            :17 > StageTaskStatement_Header
*            :18 > StageTaskStatement_Footer
*            :19 > RaiseEventTaskStatement_Setup
*            :20 > RaiseEventTaskStatement_CollectNone
*            :21 > RaiseEventTaskStatement_IterationsHeader
*            :22 > RaiseEventTaskStatement_IterationsFooter
*            :23 > RaiseEventTaskStatement_Header
*            :24 > RaiseEventTaskStatement_Footer
*            :25 > LoadTaskStatement_Setup
*            :26 > LoadTaskStatement_CollectNone
*            :27 > LoadTaskStatement_IterationsHeader
*            :28 > LoadTaskStatement_IterationsFooter
*            :29 > LoadTaskStatement_Header
*            :30 > LoadTaskStatement_Footer
*            :31 > ProcessStatement_ExtractDelta
*            :32 > ProcessStatement_CallExtract
*            :33 > ProcessStatement_CallStage
*            :34 > ProcessStatement_CallRaiseEvent
*            :35 > ProcessStatement_CallLoad
*            :36 > ProcessStatement_Header
*            :37 > ProcessStatement_Finalize
*            :38 > ProcessStatement_Footer
*            :39 > LoadTaskStatement_InsertReference_HubPlayer
*            :40 > LoadTaskStatement_InsertReference_Player
*            :41 > StageTaskStatement_Footer_TournamentPlayer
*            :42 > StageTaskStatement_RemoveStageDuplicates_TournamentPlayer
*            :43 > StageTaskStatement_UpdateIsCurrentFlag_TournamentPlayer

************************************************************************/
USE [dbSurge]
GO
-------------------------------------
-- ProcessStatement_Catch
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_Catch',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CATCH block for Source Process.';

SET @CodeObject = 
'  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  -- CREATE ERROR LOG ENTRIES
  DECLARE @ErrorNumber INTEGER = ERROR_NUMBER(),
          @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
          @ErrorLine INTEGER = ERROR_LINE(),
          @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
  ------------------------
  -- COMPLETE LOG -- ERROR
  ------------------------
  -- EXTRACT - FOR RANGE REPLAY --
  IF @ExtractLogID IS NOT NULL
    EXEC [Logging].[LogExtractEnd] @ExtractLogID = @ExtractLogID,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                   @ExtractType = @ExtractType,
                                   @ExtractLogType = @ExtractLogType,
                                   @StatusCode = 2;
  -- PROCESS --
  EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @StatusCode = 2;
  -- LOG ERROR --
  EXEC [Logging].[LogError] @ProcessID = @ProcessID,
                            @TaskID = @TaskID,
                            @ProcessLogID = @ProcessLogID,
                            @ProcessTaskLogID = @ProcessTaskLogID, 
                            @ErrorNumber = @ErrorNumber,
                            @ErrorProcedure = @ErrorProcedure,
                            @ErrorLine= @ErrorLine,
                            @ErrorMessage = @ErrorMessage;
  THROW;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

-------------------------------------
-- TaskStatement_Catch
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'TaskStatement_Catch',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CATCH block for Source Process Task.';

SET @CodeObject = 
'  /*
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
  THROW; ';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

-------------------------------------
-- ExtractTaskStatement_Catch
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_Catch',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CATCH block for Source Process Task that handles Extract.';

SET @CodeObject = 
'  /*
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
  EXEC [Logging].[LogExtractEnd] @ExtractLogID = @ExtractLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @ExtractType = @ExtractType,
                                 @ExtractLogType = @ExtractLogType,
                                 @StatusCode = 2;
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 2;
  THROW; ';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

-------------------------------------
-- ExtractTaskStatement_CDOByIDSetup
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_CDOByIDSetup',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for setting up a procedure for Source CDO Extract by ID.';

SET @CodeObject = 
'  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------    
  DECLARE @Taskname NVARCHAR(128) = ''Extract'';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''InfoDisabled'') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''CaptureDisabled'') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
  DECLARE @RaiseCount INT = 0,
          @MergeCount INT = 0,
          @InsertCount INT = 0,
          @UpdateCount INT = 0,
          @DeleteCount INT = 0,
          @TargetObject NVARCHAR(128);
  DECLARE @SourceInsertCount INT = 0,
          @HeldInsertCount INT = 0,
          @BeginID BIGINT,
          @EndID BIGINT;
  SET @ExtractLogType = ''ID'';
  SET @ChangeDetected = 0;
  DECLARE @TaskExtractSourceID INT,
          @TrackedColumn NVARCHAR(128) = ''{CDOTrackedColumn}'';
  DECLARE @CE_ExtractType CHAR(3) = ''CDO'',
          @BE_ExtractType CHAR(3) = ''BUL'',
          @ExtractObject NVARCHAR(128) = ''{ExtractSchema}.{ExtractTableName}'';
  SET @ExtractType = @CE_ExtractType;
  DECLARE @IgnoreHeldEntries BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Held](@ProcessTaskID, ''Ignore'') AS BIT);';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- TaskStatement_DetermineProcessTask
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'TaskStatement_DetermineProcessTask',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for determining the process task for Source Process Task.';

SET @CodeObject = 
'  EXEC [Logging].[LogProcessTaskStart] @IsEnabled = @IsProcessTaskEnabled, @ProcessLogID = @ProcessLogID,
                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                       @ProcessTaskID = @ProcessTaskID,
                                       @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;
  
  SET @InfoMessage = ''Task for '' + @Taskname + '' started.'';
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
    SET @InfoMessage = ''Task for '' + @Taskname + '' is DISABLED in Config.Task. Exiting.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ExtractTaskStatement_DetermineExtractTask
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_DetermineExtractTask',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for determining the extract task for Source Process Extract.';

SET @CodeObject = 
'  SET @StepID = @StepID +1;
  -- BULK EXTRACT --
  IF @pBE_MinID IS NOT NULL AND @pBE_MaxID IS NOT NULL BEGIN;
    SET @ExtractType = @BE_ExtractType;
    SET @BeginID = @pBE_MinID;
    SET @EndID = @pBE_MaxID;
  END;
  SET @TaskExtractSourceID = [Config].[GetProcessTaskExtractSourceID](@ProcessTaskID, @ExtractType, @ExtractObject, @TrackedColumn);
  -------------------------------
  -- LOG EXTRACT START
  -------------------------------
  -- BULK Extract (ID Range) --
  IF @ExtractType = @BE_ExtractType BEGIN;
    EXEC [Logging].[LogBulkExtractByIDStart] @ProcessLogID = @ProcessLogID,
                                             @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                             @ProcessTaskID = @ProcessTaskID,
                                             @ProcessTaskLogID = @ProcessTaskLogID,
                                             @TaskExtractSourceID = @TaskExtractSourceID,
                                             @MinSourceTableID = @BeginID,
                                             @MaxSourceTableID = @EndID,
                                             @BulkExtractLogID = @ExtractLogID OUTPUT;
    IF @ExtractLogID IS NULL BEGIN;
      SET @InfoMessage = ''No BulkExtractLogID was returned from [Logging].[LogBulkExtractByIDStart]. Procedure '' + @ProcedureName + '' terminated.'';
      THROW 50000, @InfoMessage, 0;
    END;
  END; ELSE BEGIN;
  -- CHANGE Extract (CDO) --
    EXEC [Logging].[LogCDOExtractByIDStart] @ProcessLogID = @ProcessLogID,
                                            @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                            @ProcessTaskID = @ProcessTaskID,
                                            @ProcessTaskLogID = @ProcessTaskLogID,
                                            @TaskExtractSourceID = @TaskExtractSourceID,
                                            @InitialID = @pCE_MinID,
                                            @BeginID = @BeginID OUTPUT,
                                            @EndID = @EndID OUTPUT,
                                            @CDOExtractLogID = @ExtractLogID OUTPUT;
    IF @ExtractLogID IS NULL BEGIN;
      SET @InfoMessage = ''No CDOCaptureLogID was returned from [Logging].[LogCDOExtractByIDStart]. Procedure '' + @ProcedureName + '' terminated.'';
      THROW 50000, @InfoMessage, 0;
    END;
    -- Range hasn''t changed at source, no work to do
    IF @ExtractLogID = -1 BEGIN;
      -- Info Log Start --
      SET @StepID = @StepID +1;
      SET @InfoMessage = ''No new data detected at Source. Exiting.'';
      IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                      @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                      @ProcessTaskID = @ProcessTaskID,
                                                                      @ProcessTaskLogID = @ProcessTaskLogID,
                                                                      @InfoMessage = @InfoMessage,
                                                                      @Ordinal = @StepID;
      GOTO Finalize;
    END;
  END;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ExtractTaskStatement_CollectChangeRows
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_CollectChangeRows',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for collecting change rows for Source Process Extract.';

SET @CodeObject = 
'  -------------------------------
  -- GET CHANGE ROWS
  -------------------------------
  -- Info Log Start --
  SET @StepID = @StepID +1;
  SET @InfoMessage = ''Collect change rows'';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                       @ProcessTaskID = @ProcessTaskID,
                                                                       @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                       @InfoMessage = @InfoMessage,
                                                                       @Ordinal = @StepID,
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
  SET @SourceInsertCount = 0;
  SET @TargetObject = ''#ExtractDelta_{StreamVariant}_{Stream}'';
  -- Bulk Extract (Inclusive of start of range, Exclusive of end of range) --
  IF @ExtractType = @BE_ExtractType BEGIN;
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    INSERT INTO #ExtractDelta_{StreamVariant}_{Stream} ([PayloadID])
      SELECT {CDOTrackedColumn}
          FROM [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}]
         WHERE [{CDOTrackedColumn}] >= @BeginID 
           AND [{CDOTrackedColumn}] < @EndID;
         SET @SourceInsertCount = @@ROWCOUNT;
     SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  END; ELSE BEGIN;
  -- Change Extract (Inclusive of start of range, Inclusive of end of range to ensure last arriving row is not excluded) --
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    INSERT INTO #ExtractDelta_{StreamVariant}_{Stream} ([PayloadID])
      SELECT {CDOTrackedColumn}
          FROM [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}]
         WHERE [{CDOTrackedColumn}] >= @BeginID
           AND [{CDOTrackedColumn}] <= @EndID;
         SET @SourceInsertCount = @@ROWCOUNT;
     SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  END;
  -- Capture Counts
  IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                        @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                        @ProcessTaskID = @ProcessTaskID,
                                                                        @ProcessTaskLogID = @ProcessTaskLogID,
                                                                        @TargetObject = @TargetObject,
                                                                        @InsertCount = @SourceInsertCount;

  -- Info Log End --
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ExtractTaskStatement_CollectHeldRows
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_CollectHeldRows',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for collecting held rows for Source Process Extract.';

SET @CodeObject = 
'  -------------------------------
  -- GET HELD ROWS
  -------------------------------
  IF @IgnoreHeldEntries = 0 BEGIN;
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Collect Held rows'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    SET @HeldInsertCount = 0;
    SET @TargetObject = ''#ExtractDelta_{StreamVariant}_{Stream}'';
    INSERT INTO #ExtractDelta_{StreamVariant}_{Stream} ([PayloadID])
      SELECT [PayloadID]
      FROM [{HeldSchema}].[{Stream}_Held] HK WITH (NOLOCK)
     WHERE [Processed] = 0
       AND SourceSystemID = @SourceSystemID
       AND OriginSystemID = @OriginSystemID
       AND NOT EXISTS (SELECT TOP 1 1 FROM #ExtractDelta_{StreamVariant}_{Stream} WHERE [PayloadID] = HK.[PayloadID]);
    SET @HeldInsertCount = @@ROWCOUNT;
    -- Capture Counts
    IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                          @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                          @ProcessTaskID = @ProcessTaskID,
                                                                          @ProcessTaskLogID = @ProcessTaskLogID,
                                                                          @TargetObject = @TargetObject,
                                                                          @InsertCount = @HeldInsertCount;
    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
  END;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ExtractTaskStatement_CollectNone
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_CollectNone',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for exiting when no rows collected for Source Process Extract.';

SET @CodeObject = 
'  -- No changes detected -- Close logs and exit --
  IF @SourceInsertCount + @HeldInsertCount = 0 BEGIN;
     -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''No Data Collected. Exiting.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  SET @ChangeDetected = 1;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- TaskStatement_Finalize
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'TaskStatement_Finalize',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for finalizing task for Source Process.';

SET @CodeObject = 
'  Finalize:
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Info --
  SET @StepID = @StepID +1;
  SET @InfoMessage = ''Task for '' + @Taskname + '' Completed.'';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;
  -- Task --
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 1;
';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ExtractTaskStatement
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for creating Extract task for Source Process.';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  {<ExtractTaskStatement_CDOByIDSetup>}
  -------------------------------
  -- SOURCE SYSTEM
  -------------------------------
  DECLARE @SourceSystemID INT = [Lookup].[GetMasterSourceSystemID](''{StreamVariant}'',''{CountryCode}'',''{StateCode}'',''{MasterProviderExternalSystemID}''),
          @OriginSystemID INT = [Lookup].[GetSourceSystemID](''{StreamVariant}'',''{CountryCode}'',''{StateCode}'',''{ProviderExternalSystemID}'');
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  {<TaskStatement_DetermineProcessTask>}
  -------------------------------
  -- DETERMINE EXTRACT TASK
  -------------------------------
  {<ExtractTaskStatement_DetermineExtractTask>}
  -------------------------------------------------------------------------------------------------
  -- COLLECT CHANGES
  ------------------------------------------------------------------------------------------------- 
  {<ExtractTaskStatement_CollectChangeRows>}        
  {<ExtractTaskStatement_CollectHeldRows>}
  {<ExtractTaskStatement_CollectNone>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<TaskStatement_Finalize>}
END TRY
BEGIN CATCH
{<ExtractTaskStatement_Catch>}
END CATCH;
END;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ExtractTaskStatement_WithoutHeld
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ExtractTaskStatement_WithoutHeld',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for creating Extract task for Source Process where Held mechanics are not included.';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  {<ExtractTaskStatement_CDOByIDSetup>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  {<TaskStatement_DetermineProcessTask>}
  -------------------------------
  -- DETERMINE EXTRACT TASK
  -------------------------------
  {<ExtractTaskStatement_DetermineExtractTask>}
  -------------------------------------------------------------------------------------------------
  -- COLLECT CHANGES
  ------------------------------------------------------------------------------------------------- 
  {<ExtractTaskStatement_CollectChangeRows>}        
  {<ExtractTaskStatement_CollectNone>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<TaskStatement_Finalize>}
END TRY
BEGIN CATCH
{<ExtractTaskStatement_Catch>}
END CATCH;
END;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_Setup
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_Setup',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for Stage task setup for Source Process.';

SET @CodeObject = 
'  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------    
  DECLARE @Taskname NVARCHAR(128) = ''StageData'';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''InfoDisabled'') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''CaptureDisabled'') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
  DECLARE @RaiseCount INT = 0,
          @MergeCount INT = 0,
          @InsertCount INT = 0,
          @UpdateCount INT = 0,
          @DeleteCount INT = 0,
          @TargetObject NVARCHAR(128);
  DECLARE @ProcessBatchCount INT,
          @ProcessBatchBeginID BIGINT,
          @ProcessBatchEndID BIGINT,
          @ProcessSourceCount INT = 0;
  DECLARE @DefaultHubID BINARY(32) = 0x0000000000000000000000000000000000000000000000000000000000000000;
  -- APP. LOCKING --
  DECLARE @AppLockRetry INT,
          @AppLockTimeout INT,
          @AppLockResult INT,
          @AppLockAttempts INT;
  SET @ChangeDetected = 0;
  DECLARE @ProcessBatchSize INT = TRY_CAST([Config].[GetVariable_ProcessTask_Stage](@ProcessTaskID, ''BatchSize'') AS INT);
  DECLARE @HeldEntriesDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Held](@ProcessTaskID, ''Disabled'') AS BIT);
  -------------------------------
  -- SOURCE SYSTEM
  -------------------------------
  DECLARE @SourceSystemID INT = [Lookup].[GetMasterSourceSystemID](''{StreamVariant}'',''{CountryCode}'',''{StateCode}'',''{MasterProviderExternalSystemID}''),
          @OriginSystemID INT = [Lookup].[GetSourceSystemID](''{StreamVariant}'',''{CountryCode}'',''{StateCode}'',''{ProviderExternalSystemID}'');';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

-------------------------------------
-- StageTaskStatement_UpdateHeld
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_UpdateHeld',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for Stage task setup for Source Process.';

SET @CodeObject = 
'  -------------------------------
  -- UPDATE HELD ROWS
  -------------------------------
  IF @HeldEntriesDisabled = 0 BEGIN;
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Update Held entries.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID,
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID,
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @TargetObject = ''{HeldSchema}.{Stream}_Held'';

    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      -- Update Processed Held --
      UPDATE HK
        SET  Processed = 1,
             ProcessedDate = @NowTime,
             ProcessedTaskLogID = @ProcessTaskLogID
        FROM #Stage_{StreamVariant}_{Stream} HT
       INNER JOIN [{HeldSchema}].[{Stream}_Held] HK
          ON HT.SourcePayloadID = HK.PayloadID
         AND HT.SourceSystemID = HK.SourceSystemID
         AND HT.OriginSystemID = HK.OriginSystemID
       WHERE HK.Processed = 0; -- In #HoldingTable, so has passed Held conditions
       SET @UpdateCount = @@ROWCOUNT;
	  
      -- Insert Held --
      INSERT INTO [{HeldSchema}].[{Stream}_Held] (
        PayloadID,
        SourceSystemID,
        OriginSystemID,
        HeldProcessTaskLogID
      ) SELECT DISTINCT CT.PayloadID,
                        @SourceSystemID,
                        @OriginSystemID,
                        @ProcessTaskLogID
          FROM #ExtractDelta_{StreamVariant}_{Stream} CT-- In Batch and view but...
          LEFT JOIN #Stage_{StreamVariant}_{Stream} HT
            ON CT.PayloadID = HT.SourcePayloadID
          LEFT JOIN [{HeldSchema}].[{Stream}_Held] HK
            ON CT.PayloadID = HK.PayloadID
           AND HK.SourceSystemID = @SourceSystemID
           AND HK.OriginSystemID = @OriginSystemID
         WHERE HT.SourcePayloadID IS NULL -- ...Not in #HoldingTable AND ...
           AND HK.PayloadID IS NULL; -- ...Not in Held table
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                            @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                            @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID,
                                                                            @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount,
                                                                            @UpdateCount = @UpdateCount;
	  
      -- Info Log End --
      IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    COMMIT;
  END;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

-------------------------------------
-- StageTaskStatement_CollectNone
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_CollectNone',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for exiting when no rows collected for Source Process Stage.';

SET @CodeObject = 
'  SET @ProcessSourceCount = (SELECT COUNT(1) FROM #ExtractDelta_{StreamVariant}_{Stream});
  IF @ProcessSourceCount = 0 BEGIN;
    -- Info Log Start --
    SET @InfoMessage = ''No delta keys for staging. Exiting.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  SET @ChangeDetected = 1;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_IterationsHeader
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_IterationsHeader',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for determining and beginning batch iterations for Source Process Stage.';

SET @CodeObject = 
'  -------------------------------
  -- DETERMINE ITERATIONS
  -------------------------------  
  SET @ProcessBatchCount = @ProcessSourceCount / @ProcessBatchSize;
  IF @ProcessBatchCount <= 0 SET @ProcessBatchCount = 1;
  -- If there is only a single full batch but there are some remainders, increase batch count by 1 --
  IF @ProcessSourceCount > (@ProcessBatchSize * @ProcessBatchCount)
    SET @ProcessBatchCount = @ProcessBatchCount +1;
  -- Info Log Start --
  IF @InfoLoggingDisabled = 0 BEGIN;
    SET @InfoMessage = ''Process in MAX Batch Size: '' + CAST(@ProcessBatchSize AS VARCHAR) + '' for total number of batches: '' + CAST(@ProcessBatchCount AS VARCHAR);
    SET @InfoMessage = ''Collect change rows'';                                                                                                                           
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
  END;
  -- Info Log End --
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
  -------------------------------
  -- ITERATE PER BATCH SIZE
  -------------------------------
  -- COLLECT ITERATION BATCH --
  SET @ProcessBatchBeginID = 1;
  -- FOR PARTITION ELIMINATION --
  DECLARE @MaxDeltaID BIGINT,
          @MinDeltaID BIGINT;
  SELECT @MaxDeltaID = MAX([PayloadID]), @MinDeltaID = MIN([PayloadID]) FROM #ExtractDelta_{StreamVariant}_{Stream};

  
  WHILE @ProcessBatchCount > 0 BEGIN; --BEGIN PROCESS ITERATION
    SET @ProcessBatchCount = @ProcessBatchCount - 1;
    SET @ProcessBatchEndID = @ProcessBatchBeginID + @ProcessBatchSize;
    -- Info Log Start --
    SET @InfoMessage = ''Processing batch from Source Keys. Start of range: '' + CAST(@ProcessBatchBeginID AS VARCHAR) + ''. End of range: '' + CAST(@ProcessBatchEndID AS VARCHAR);
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_IterationsFooter
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_IterationsFooter',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for iteration and ending batch iterations for Source Process Stage.';

SET @CodeObject = 
'    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
    -- Info Log Start --
    SET @InfoMessage = ''Process in Batch Size: '' + CAST(@ProcessBatchSize AS VARCHAR) + ''. Batches Remaining: '' + CAST(@ProcessBatchCount AS VARCHAR);
    IF @ProcessBatchCount = 0
      SET @InfoMessage = ''Process in Batch Size: '' + CAST(@ProcessBatchSize AS VARCHAR) + ''. Batches Completed'';
      IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                      @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                      @ProcessTaskID = @ProcessTaskID,
                                                                      @ProcessTaskLogID = @ProcessTaskLogID,
                                                                      @InfoMessage = @InfoMessage,
                                                                      @Ordinal = @StepID;
    -- Start Range
    SET @ProcessBatchBeginID = @ProcessBatchBeginID + @ProcessBatchSize;
  END; -- END PROCESS ITERATION';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_RemoveStageDuplicates
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_RemoveStageDuplicates',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for handling removal of stage duplicates in Source Process for Stage Procedures.';

SET @CodeObject = 
'  -- Info Log Start --
  SET @StepID = @StepID +1;
  SET @InfoMessage = ''Remove duplicates in Staging Table.'';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                       @ProcessTaskID = @ProcessTaskID,
                                                                       @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                       @InfoMessage = @InfoMessage,
                                                                       @Ordinal = @StepID,
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
  SET @DeleteCount = 0;
  SET @TargetObject = ''#Stage_{StreamVariant}_{Stream}'';
  -- Update Holding Table --
  ;WITH CTE AS (
    SELECT STG.RowNo,
           STG.Hub{HubStream}ID,
           STG.SourceSystemID,
           ROW_NUMBER() OVER (PARTITION BY STG.Hub{HubStream}ID, STG.SourceSystemID ORDER BY STG.ModifiedDate DESC, STG.SourcePayloadID DESC) AS RowNumber
    FROM #Stage_{StreamVariant}_{Stream} STG
  ) UPDATE CTE
    SET RowNo = RowNumber;
  -- Remove duplicate records --
  DELETE FROM #Stage_{StreamVariant}_{Stream}
  WHERE RowNo <> 1; 
  SET @DeleteCount = @@ROWCOUNT;
  -- Capture Counts
  IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                        @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                        @ProcessTaskID = @ProcessTaskID,
                                                                        @ProcessTaskLogID = @ProcessTaskLogID,
                                                                        @TargetObject = @TargetObject,
                                                                        @DeleteCount = @DeleteCount;
   -- Info Log End --
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_RemoveStageDuplicates_TournamentPlayer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_RemoveStageDuplicates_TournamentPlayer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for handling removal of stage duplicates in Source Process for Stage Procedures.';

SET @CodeObject = 
'  -- Info Log Start --
  SET @StepID = @StepID +1;
  SET @InfoMessage = ''Remove duplicates in Staging Table.'';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                       @ProcessTaskID = @ProcessTaskID,
                                                                       @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                       @InfoMessage = @InfoMessage,
                                                                       @Ordinal = @StepID,
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
  SET @DeleteCount = 0;
  SET @TargetObject = ''#Stage_{StreamVariant}_{Stream}'';
  -- Update Holding Table --
  ;WITH CTE AS (
    SELECT STG.RowNo,
           STG.Hub{HubStream}ID,
           STG.SourceSystemID,
		   ROW_NUMBER() OVER (PARTITION BY STG.Hub{HubStream}ID, STG.SourceSystemID, STG.StatusName ORDER BY STG.ModifiedDate DESC, STG.SourcePayloadID DESC) AS RowNumber
    FROM #Stage_{StreamVariant}_{Stream} STG
  ) UPDATE CTE
    SET RowNo = RowNumber;
  -- Remove duplicate records --
  DELETE FROM #Stage_{StreamVariant}_{Stream}
  WHERE RowNo <> 1; 
  SET @DeleteCount = @@ROWCOUNT;
  -- Capture Counts
  IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                        @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                        @ProcessTaskID = @ProcessTaskID,
                                                                        @ProcessTaskLogID = @ProcessTaskLogID,
                                                                        @TargetObject = @TargetObject,
                                                                        @DeleteCount = @DeleteCount;
   -- Info Log End --
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_UpdateIsCurrentFlag_TournamentPlayer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_UpdateIsCurrentFlag_TournamentPlayer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for Updating the IsCurrentFlag of stage duplicates in Source Process for Stage Procedures.';

SET @CodeObject = 
'  -- Info Log Start --
  SET @StepID = @StepID +1;
  SET @InfoMessage = ''Updating IsCurrent Flag in Staging Table.'';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                       @ProcessTaskID = @ProcessTaskID,
                                                                       @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                       @InfoMessage = @InfoMessage,
                                                                       @Ordinal = @StepID,
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
  SET @UpdateCount = 0;
  SET @TargetObject = ''#Stage_{StreamVariant}_{Stream}'';
  -- Update Holding Table --
  ;WITH CTE AS (
    SELECT STG.RowNo,
           STG.Hub{HubStream}ID,
           STG.SourceSystemID,
           ROW_NUMBER() OVER (PARTITION BY STG.Hub{HubStream}ID, STG.SourceSystemID ORDER BY STG.ModifiedDate DESC, STG.SourcePayloadID DESC) AS RowNumber
    FROM #Stage_{StreamVariant}_{Stream} STG
  ) UPDATE CTE
    SET RowNo = RowNumber;
  -- Update non current records --
  UPDATE #Stage_{StreamVariant}_{Stream}
  SET IsCurrent = 0
  WHERE RowNo <> 1; 
  SET @UpdateCount = @@ROWCOUNT;
  -- Info Log End --
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_Header
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_Header',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for header for Source Process Stage Procedures.';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  {<StageTaskStatement_Setup>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  {<TaskStatement_DetermineProcessTask>}
  -------------------------------
  -- DELTAS TO PROCESS
  -------------------------------
  {<StageTaskStatement_CollectNone>}'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_Footer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_Footer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for footer for Source Process Stage Procedures.';

SET @CodeObject = 
'  -------------------------------
  --REMOVE STAGE DUPLICATES
  -------------------------------
  {<StageTaskStatement_RemoveStageDuplicates>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<TaskStatement_Finalize>}
END TRY
BEGIN CATCH
{<TaskStatement_Catch>}
END CATCH;
END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- StageTaskStatement_Footer_TournamentPlayer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'StageTaskStatement_Footer_TournamentPlayer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for footer for Source Process Stage Procedures.';

SET @CodeObject = 
'  -------------------------------
  --REMOVE STAGE DUPLICATES
  -------------------------------
  {<StageTaskStatement_RemoveStageDuplicates_TournamentPlayer>}
  -------------------------------
  --UPDATE IS CURRENT FLAG
  -------------------------------
  {<StageTaskStatement_UpdateIsCurrentFlag_TournamentPlayer>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<TaskStatement_Finalize>}
END TRY
BEGIN CATCH
{<TaskStatement_Catch>}
END CATCH;
END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- RaiseEventTaskStatement_Setup
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'RaiseEventTaskStatement_Setup',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for RaiseEvent task setup for Source Process.';

SET @CodeObject = 
'  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------    
  DECLARE @Taskname NVARCHAR(128) = ''RaiseServiceBrokerEvents'';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''InfoDisabled'') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''CaptureDisabled'') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
  DECLARE @RaiseCount INT = 0,
          @MergeCount INT = 0,
          @InsertCount INT = 0,
          @UpdateCount INT = 0,
          @DeleteCount INT = 0,
          @TargetObject NVARCHAR(128);
  DECLARE @ProcessBatchCount INT,
          @ProcessBatchBeginID BIGINT,
          @ProcessBatchEndID BIGINT,
          @ProcessSourceCount INT = 0;
  SET @ChangeDetected = 0;
  DECLARE @ProcessBatchSize INT = TRY_CAST([Config].[GetVariable_ProcessTask_RaiseEvent](@ProcessTaskID, ''BatchSize'') AS INT);';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- RaiseEventTaskStatement_CollectNone
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'RaiseEventTaskStatement_CollectNone',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for exiting when no rows collected for Source Process RaiseEvent.';

SET @CodeObject = 
'  SET @ProcessSourceCount = (SELECT ISNULL(MAX(StageID),0) FROM #Stage_{StreamVariant}_{Stream});
  IF @ProcessSourceCount = 0 BEGIN;
    -- Info Log Start --
    SET @InfoMessage = ''No loaded data for Raise Events. Exiting.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  SET @ChangeDetected = 1;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- RaiseEventTaskStatement_IterationsHeader
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'RaiseEventTaskStatement_IterationsHeader',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for determining and beginning batch iterations for Source Process RaiseEvent.';

SET @CodeObject = 
'  -- Info log step --
  SET @StepID = @StepID +1;
  SET @RaiseCount = 0;
  SET @TargetObject = ''@Payload'';
  SET @ProcessBatchCount = @ProcessSourceCount / @ProcessBatchSize;
  IF @ProcessBatchCount <=0 SET @ProcessBatchCount = 1;
  -- If there is only a single full batch but there are some remainders, increase batch count by 1 --
  IF @ProcessSourceCount > (@ProcessBatchSize * @ProcessBatchCount)
    SET @ProcessBatchCount = @ProcessBatchCount +1;
  -- Start Range --
  SET @ProcessBatchBeginID = 1;
  
  WHILE @ProcessBatchCount > 0 BEGIN; --BEGIN RAISE ITERATION
    SET @ProcessBatchCount = @ProcessBatchCount - 1;
    SET @ProcessBatchEndID = @ProcessBatchBeginID + @ProcessBatchSize;
    -- Info Log Start --
    SET @InfoMessage = ''Collect change rows to XML for Raise Service Broker Events for: {StreamVariant}.{Stream}; from ID(Inclusive): '' + CAST(@ProcessBatchBeginID AS VARCHAR) + ''; to ID(Exclusive): '' + CAST(@ProcessBatchEndID AS VARCHAR)
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- RaiseEventTaskStatement_IterationsFooter
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'RaiseEventTaskStatement_IterationsFooter',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for iteration and ending batch iterations for Source Process RaiseEvent.';

SET @CodeObject = 
'    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
  
    -- Info Log Start --
    SET @InfoMessage = ''Send change rows for Raise Service Broker Events for: {StreamVariant}.{Stream}'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    IF @Payload IS NOT NULL
    EXEC [DataFlow].[ServiceBroker_CreateMultiSendPayload_XML] @ProcessID = @ProcessID,
                                                               @ProcessLogID = @ProcessLogID,
                                                               @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                               @ProcessTaskID = @ProcessTaskID,
                                                               @ProcessTaskLogID = @ProcessTaskLogID,
                                                               @InfoLoggingDisabled = @InfoLoggingDisabled,
                                                               @Ordinal = @StepID,
                                                               @MessageBodyXML = @Payload;
    -- Capture Counts
    IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                          @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                          @ProcessTaskID = @ProcessTaskID,
                                                                          @ProcessTaskLogID = @ProcessTaskLogID,
                                                                          @TargetObject = @TargetObject,
                                                                          @RaiseCount = @RaiseCount;  
    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
    -- Start Range
    SET @ProcessBatchBeginID = @ProcessBatchBeginID + @ProcessBatchSize;
  END; -- END RAISE ITERATION';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- RaiseEventTaskStatement_Header
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'RaiseEventTaskStatement_Header',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for header for Source Process RaiseEvent Procedures.';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  {<RaiseEventTaskStatement_Setup>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  {<TaskStatement_DetermineProcessTask>}
  -------------------------------
  -- STAGE TO PROCESS
  -------------------------------
  {<RaiseEventTaskStatement_CollectNone>}
  -------------------------------
  -- RAISE EVENTS 
  -------------------------------'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- RaiseEventTaskStatement_Footer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'RaiseEventTaskStatement_Footer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for footer for Source Process RaiseEvent Procedures.';

SET @CodeObject = 
'  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<TaskStatement_Finalize>}
END TRY
BEGIN CATCH
{<TaskStatement_Catch>}
END CATCH;
END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_Setup
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_Setup',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for Load task setup for Source Process.';

SET @CodeObject = 
'  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------    
  DECLARE @Taskname NVARCHAR(128) = ''LoadData'';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''InfoDisabled'') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, ''CaptureDisabled'') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
  DECLARE @RaiseCount INT = 0,
          @MergeCount INT = 0,
          @InsertCount INT = 0,
          @UpdateCount INT = 0,
          @DeleteCount INT = 0,
          @TargetObject NVARCHAR(128);
  DECLARE @ProcessBatchCount INT,
          @ProcessBatchBeginID BIGINT,
          @ProcessBatchEndID BIGINT,
          @ProcessSourceCount INT = 0;
  DECLARE @DefaultHubID BINARY(32) = 0x0000000000000000000000000000000000000000000000000000000000000000;
  -- APP. LOCKING --
  DECLARE @AppLockRetry INT,
          @AppLockTimeout INT,
          @AppLockResult INT,
          @AppLockAttempts INT;
  SET @ChangeDetected = 0;
  DECLARE @ProcessBatchSize INT = TRY_CAST([Config].[GetVariable_ProcessTask_Load](@ProcessTaskID, ''BatchSize'') AS INT);
  DECLARE @HeldEntriesDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Held](@ProcessTaskID, ''Disabled'') AS BIT);';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_CollectNone
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_CollectNone',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for exiting when no rows collected for Source Process Load.';

SET @CodeObject = 
'  SET @ProcessSourceCount = (SELECT ISNULL(MAX(StageID),0) FROM #Stage_{StreamVariant}_{Stream});
  IF @ProcessSourceCount = 0 BEGIN;
    -- Info Log Start --
    SET @InfoMessage = ''No staged data for Load Events. Exiting.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  SET @ChangeDetected = 1;';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_IterationsHeader
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_IterationsHeader',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for determining and beginning batch iterations for Source Process Load.';

SET @CodeObject = 
'  -------------------------------
  -- DETERMINE ITERATIONS
  -------------------------------
  SET @ProcessBatchCount = @ProcessSourceCount / @ProcessBatchSize;
  IF @ProcessBatchCount <=0 SET @ProcessBatchCount = 1;
  -- If there is only a single full batch but there are some remainders, increase batch count by 1 --
  IF @ProcessSourceCount > (@ProcessBatchSize * @ProcessBatchCount)
    SET @ProcessBatchCount = @ProcessBatchCount +1;
  -- Info Log Start --
  SET @InfoMessage = ''Process in MAX Batch Size: '' + CAST(@ProcessBatchSize AS VARCHAR) + '' for total number of batches: '' + CAST(@ProcessBatchCount AS VARCHAR);
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;
  -------------------------------
  -- ITERATE PER BATCH SIZE
  -------------------------------
  -- COLLECT ITERATION BATCH --
  SET @ProcessBatchBeginID = 1;
  
  WHILE @ProcessBatchCount > 0 BEGIN; --BEGIN PROCESS ITERATION
    SET @ProcessBatchCount = @ProcessBatchCount - 1;
    SET @ProcessBatchEndID = @ProcessBatchBeginID + @ProcessBatchSize';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_IterationsFooter
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_IterationsFooter',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for iteration and ending batch iterations for Source Process Load.';

SET @CodeObject = 
'    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; 
    -- Info Log Start --
    SET @InfoMessage = ''Process in Batch Size: '' + CAST(@ProcessBatchSize AS VARCHAR) + ''. Batches Remaining: '' + CAST(@ProcessBatchCount AS VARCHAR);
    IF @ProcessBatchCount = -1
      SET @InfoMessage = ''Process in Batch Size: '' + CAST(@ProcessBatchSize AS VARCHAR) + ''. Batches Completed'';
      IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                      @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                      @ProcessTaskID = @ProcessTaskID,
                                                                      @ProcessTaskLogID = @ProcessTaskLogID,
                                                                      @InfoMessage = @InfoMessage,
                                                                      @Ordinal = @StepID;
    -- Start Range
    SET @ProcessBatchBeginID = @ProcessBatchBeginID + @ProcessBatchSize;
  END; -- END PROCESS ITERATION';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- LoadTaskStatement_Header
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_Header',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for header for Source Process Load Procedures.';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  {<LoadTaskStatement_Setup>}
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  {<TaskStatement_DetermineProcessTask>}
  -------------------------------
  -- STAGE TO PROCESS
  -------------------------------
  {<LoadTaskStatement_CollectNone>}
'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_Footer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_Footer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for footer for Source Process Load Procedures.';

SET @CodeObject = 
'  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<TaskStatement_Finalize>}
END TRY
BEGIN CATCH
{<TaskStatement_Catch>}
END CATCH;
END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- ProcessStatement_ExtractDelta
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_ExtractDelta',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for creating extract delta for Source Process Procedures.';

SET @CodeObject = 
'  IF OBJECT_ID(''TempDB..#ExtractDelta_{StreamVariant}_{Stream}'') IS NOT NULL 
    DROP TABLE #ExtractDelta_{StreamVariant}_{Stream};
  CREATE TABLE #ExtractDelta_{StreamVariant}_{Stream}(
    [DeltaID] INT IDENTITY(1,1) NOT NULL,
    INDEX [IDX1_ExtractDelta_{StreamVariant}_{Stream}] NONCLUSTERED ([DeltaID] ASC) WITH (FILLFACTOR = 100),
    [PayloadID] BIGINT NOT NULL
    PRIMARY KEY CLUSTERED ([PayloadID] ASC) WITH (FILLFACTOR = 100)
  );'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- ProcessStatement_CallExtract
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_CallExtract',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for calling extract for Source Process Procedures.';

SET @CodeObject = 
'  ------------------------
  -- EXTRACT -- 
  ------------------------
  -- Manual Keys
  IF EXISTS(SELECT 1 FROM @ManualKeys) BEGIN;
    INSERT INTO #ExtractDelta_{StreamVariant}_{Stream} ([PayloadID])
      SELECT [PayloadID] FROM @ManualKeys;
  END ELSE BEGIN;
    -- Standard Extract --
    -- CLEAR PARAMS.
    SET @TaskID = NULL;
    SET @ProcessTaskLogID = NULL;
    SET @ChangeDetected = NULL;
    SET @ExtractLogID = NULL;
    SET @ExtractLogType = NULL;
    SET @ExtractType = NULL;
    -- RUN TASK
    EXEC [{Schema}].[Extract_{Stream}] @ProcessID = @ProcessID,
                                       @ProcessLogID = @ProcessLogID,
                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                       @pCE_MinID = @CE_MinID,
                                       @pBE_MinID = @BE_MinID,
                                       @pBE_MaxID = @BE_MaxID,
                                       @TaskID = @TaskID OUTPUT,
                                       @ProcessTaskLogID = @ProcessTaskLogID OUTPUT,
                                       @ExtractLogID = @ExtractLogID OUTPUT,
                                       @ExtractType = @ExtractType OUTPUT,
                                       @ExtractLogType = @ExtractLogType OUTPUT,
                                       @ChangeDetected = @ChangeDetected OUTPUT;
    -- NO CHANGE PROCESSED
    IF @ChangeDetected = 0
      GOTO Finalize;
  END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- ProcessStatement_CallStage
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_CallStage',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for calling stage for Source Process Procedures.';

SET @CodeObject = 
'  ------------------------
  -- STAGE -- 
  ------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  SET @ChangeDetected = NULL;
  -- RUN TASK
  EXEC [{Schema}].[Stage_{Stream}] @ProcessID = @ProcessID,
                                   @ProcessLogID = @ProcessLogID,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                   @TaskID = @TaskID OUTPUT,
                                   @ProcessTaskLogID = @ProcessTaskLogID OUTPUT,
                                   @ChangeDetected = @ChangeDetected OUTPUT;

  -- NO CHANGE PROCESSED
  IF @ChangeDetected = 0
    GOTO Finalize;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- ProcessStatement_CallRaiseEvent
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_CallRaiseEvent',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for calling raise event for Source Process Procedures.';

SET @CodeObject = 
'  ------------------------
  -- RAISE EVENT -- 
  ------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  SET @ChangeDetected = NULL;
  -- RUN TASK
  EXEC [{Schema}].[RaiseEvent_{Stream}] @ProcessID = @ProcessID,
                                        @ProcessLogID = @ProcessLogID,
                                        @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                        @TaskID = @TaskID OUTPUT,
                                        @ProcessTaskLogID = @ProcessTaskLogID OUTPUT,
                                        @ChangeDetected = @ChangeDetected OUTPUT;
  -- NO CHANGE PROCESSED
  IF @ChangeDetected = 0
    GOTO Finalize;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- ProcessStatement_CallLoad
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_CallLoad',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for calling load for Source Process Procedures.';

SET @CodeObject = 
'  ------------------------
  -- LOAD -- 
  ------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  SET @ChangeDetected = NULL;
  -- RUN TASK
  EXEC [{Schema}].[Load_{Stream}] @ProcessID = @ProcessID,
                                        @ProcessLogID = @ProcessLogID,
                                        @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                        @TaskID = @TaskID OUTPUT,
                                        @ProcessTaskLogID = @ProcessTaskLogID OUTPUT,
                                        @ChangeDetected = @ChangeDetected OUTPUT;
  -- NO CHANGE PROCESSED
  IF @ChangeDetected = 0
    GOTO Finalize;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------------------------
-- ProcessStatement_Header
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_Header',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for header for Source Process Procedures.';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- CONFIG VARS.
  -------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @ProcessName VARCHAR(150) = ''{Stream}|{ProcessNamePart}'',
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
  -- EXTRACT --
  DECLARE @ExtractLogID BIGINT,
          @ExtractType CHAR(3),
          @ExtractLogType VARCHAR(4);
  -- PROCESS TASK --
  DECLARE @TaskID SMALLINT,
          @ProcessTaskLogID BIGINT,
          @ChangeDetected BIT;
  ------------------------
  -- CREATE LOG
  -- If Manual Keys are provided, ensure new log
  ------------------------
  IF EXISTS(SELECT 1 FROM @ManualKeys) BEGIN;
    EXEC [Logging].[LogProcessStart] @IsEnabled = @IsProcessEnabled, @ProcessID = @ProcessID,
                                     @ReuseOpenLog = 0,
                                     @ProcessLogID = @ProcessLogID OUTPUT,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth OUTPUT;
  END; ELSE BEGIN;
    EXEC [Logging].[LogProcessStart] @IsEnabled = @IsProcessEnabled, @ProcessID = @ProcessID,
                                     @ReuseOpenLog = 1,
                                     @ProcessLogID = @ProcessLogID OUTPUT,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth OUTPUT;
  END;
  -- No Log --
  IF @ProcessLogID IS NULL BEGIN;
    SET @ProcessLogID = -1;
    SET @InfoMessage = ''No ProcessLogID was returned from [Logging].[LogProcessStart]. Procedure '' + @ProcedureName + '' terminated.'';
    THROW 50000, @InfoMessage, 0;
   END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ProcessStatement_Finalize
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_Finalize',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for finalize of Source Process Procedures.';

SET @CodeObject = 
'  Finalize:
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;      
  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Extract -- Completion logged in Process to ensure that replay is available for range
  EXEC [Logging].[LogExtractEnd] @ExtractLogID = @ExtractLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @ExtractType = @ExtractType,
                                 @ExtractLogType = @ExtractLogType,
                                 @StatusCode = 1;
  -- Process
  EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @StatusCode = 1;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- ProcessStatement_Footer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'ProcessStatement_Footer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for components for footer for Source Process Procedures.';

SET @CodeObject = 
'  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  {<ProcessStatement_Finalize>}
END TRY
BEGIN CATCH
{<ProcessStatement_Catch>}
END CATCH;
END;'
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_InsertReference_HubPlayer
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_InsertReference_HubPlayer',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for inserting missing HubPlayer keys.';

SET @CodeObject = 
' ----------------------------------
    -- HUB PLAYER
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.HubPlayer'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO dbo.HubPlayer (
        HubPlayerID,
        SourceSystemID,
        CreatedDate,
        OriginSystemID,
        CaptureLogID,
        GamingSystemID,
        UserID
      ) SELECT PLD.HubPlayerID,
               PLD.SourceSystemID,
               MIN(PLD.ModifiedDate),
               PLD.OriginSystemID,
               PLD.CaptureLogID,
               PLD.GamingSystemID,
               PLD.UserID
        FROM #Stage_{StreamVariant}_{Stream} PLD
        LEFT JOIN dbo.HubPlayer Hub
          ON PLD.HubPlayerID = Hub.HubPlayerID
         AND PLD.SourceSystemID = Hub.SourceSystemID
        WHERE Hub.HubPlayerID IS NULL
         AND PLD.HubPlayerID <> @DefaultHubID -- Exclude default/unknown
		 AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
		GROUP BY PLD.HubPlayerID,
                 PLD.SourceSystemID,
                 PLD.OriginSystemID,
                 PLD.CaptureLogID,
                 PLD.GamingSystemID,
                 PLD.UserID;         
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; '
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- LoadTaskStatement_InsertReference_Player
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'LoadTaskStatement_InsertReference_Player',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Component',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for inserting missing Player reference data.';

SET @CodeObject = 
' ----------------------------------
    --PLAYER
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Player'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO dbo.Player (
        HubPlayerID,
        SourceSystemID,
        ModifiedDate,
        OriginSystemID,
        CaptureLogID,
        Operation
      ) SELECT DISTINCT PLD.HubPlayerID,
                        PLD.SourceSystemID,
                        TRY_CAST(''1900-01-01'' AS DATETIME2),
                        PLD.OriginSystemID,
                        PLD.CaptureLogID,
                        ''I''
        FROM #Stage_{StreamVariant}_{Stream} PLD
        LEFT JOIN dbo.Player P
          ON PLD.HubPlayerID = P.HubPlayerID
         AND PLD.SourceSystemID = P.SourceSystemID
        WHERE P.HubPlayerID IS NULL
         AND PLD.HubPlayerID <> @DefaultHubID -- Exclude default/unknown
         AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID;         
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID; '
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
/* End of File ********************************************************************************************************************/