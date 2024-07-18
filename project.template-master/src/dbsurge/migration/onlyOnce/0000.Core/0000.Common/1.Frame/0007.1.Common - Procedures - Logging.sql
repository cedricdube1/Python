/***********************************************************************************************************************************
* Script      : 7.Common - Procedures - Logging.sql                                                                               *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Logging                                                                                                           *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- LogStart --
GO
CREATE PROCEDURE [Logging].[LogJobStart] (
  @JobID SMALLINT = NULL,
  @JobName VARCHAR(150) = NULL,
  @ReuseOpenLog BIT = 1,
  @JobLogID BIGINT = NULL OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  DECLARE @Output TABLE (JobLogID BIGINT);
  IF @JobID IS NULL
    SET @JobID = [Config].[GetJobIDByName] (@JobName);
  -- Not found --
  IF (@JobID = -1 OR @JobID IS NULL) BEGIN
    SET @JobLogID = -1;
    RETURN;
  END;
  IF @ReuseOpenLog = 1 BEGIN;
    -- EXISTING LOG IS OPEN --
    SELECT TOP 1 @JobLogID = JobLogID
      FROM [Logging].[Job] WITH (NOLOCK)
     WHERE JobID = @JobID
       AND StatusCode = 0;
    IF @JobLogID IS NOT NULL BEGIN;
      INSERT INTO @Output (JobLogID)
        VALUES (@JobLogID);
      -- Update the Log --
      UPDATE [Logging].[Job] WITH (ROWLOCK, READPAST)
         SET StartDateTime = @StartDateTime
       WHERE JobLogID = @JobLogID;
      GOTO ReturnOutput;
    END;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[Job] ([JobID], [StartDateTime])
  OUTPUT Inserted.JobLogID
    INTO @Output (JobLogID)
    VALUES( @JobID, @StartDateTime);
  -- Output Variables --
  ReturnOutput:
  SELECT @JobLogID = JobLogID
  FROM @Output;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogEnd --
GO
CREATE PROCEDURE [Logging].[LogJobEnd] (
  @JobID SMALLINT = NULL,
  @JobName VARCHAR(150) = NULL,
  @StatusCode TINYINT = 1
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @SystemEndTime DATETIME = SYSDATETIME(); -- intentionally uses system time
  IF @JobID IS NULL
    SET @JobID = [Config].[GetJobIDByName] (@JobName);
  UPDATE [Logging].[Job] WITH (ROWLOCK, READPAST)
     SET EndDateTime = SYSUTCDATETIME(),
         StatusCode = @StatusCode
   WHERE JobID = @JobID
     AND StatusCode = 0; -- Incomplete logs for job only  
  -- Handle Job Queue (Enqueue) --
  EXEC [DataFlow].[QueueJob] @JobID = @JobID, @Enqueue = 1, @StatusCode = @StatusCode, @JobReportTime = @SystemEndTime;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
-- LogStart --
GO
CREATE PROCEDURE [Logging].[LogProcessStart] (
  @ProcessID SMALLINT,
  @ReuseOpenLog BIT = 1,
  @IsEnabled BIT = 1,
  @SourceProcessLogID BIGINT = NULL,
  @ProcessLogID BIGINT OUTPUT,
  @ProcessLogCreatedMonth TINYINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  DECLARE @Output TABLE (ProcessLogID BIGINT, ProcessLogCreatedMonth TINYINT);
  -- IsEnabled = 0, Invalid ProcessID --
  IF @IsEnabled = 0 OR @ProcessID = -1 BEGIN
    SET @ProcessLogID = -1;
    RETURN;
  END;
  -- Not found --
  IF @ProcessID IS NULL BEGIN;
    RETURN;
  END;
  IF @ReuseOpenLog = 1 BEGIN;
    -- EXISTING LOG IS OPEN --
    SELECT TOP 1 @ProcessLogID = ProcessLogID, @ProcessLogCreatedMonth = ProcessLogCreatedMonth
      FROM [Logging].[Process] WITH (NOLOCK)
     WHERE ProcessID = @ProcessID
       AND StatusCode = 0;
    IF @ProcessLogID IS NOT NULL BEGIN;
      INSERT INTO @Output (ProcessLogID, ProcessLogCreatedMonth)
        VALUES (@ProcessLogID, @ProcessLogCreatedMonth);
      -- Update the Log --
      UPDATE [Logging].[Process] WITH (ROWLOCK, READPAST)
         SET StartDateTime = @StartDateTime
       WHERE ProcessLogID = @ProcessLogID
         AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth;
      GOTO ReturnOutput;
    END;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[Process] ([SourceProcessLogID], [ProcessID], [StartDateTime])
  OUTPUT Inserted.ProcessLogID, Inserted.ProcessLogCreatedMonth
    INTO @Output (ProcessLogID, ProcessLogCreatedMonth)
    VALUES(@SourceProcessLogID, @ProcessID, @StartDateTime);
  -- Output Variables --
  ReturnOutput:
  SELECT @ProcessLogID = ProcessLogID,
         @ProcessLogCreatedMonth = ProcessLogCreatedMonth
  FROM @Output;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogEnd --
GO
CREATE PROCEDURE [Logging].[LogProcessEnd] (
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @SourceProcessLogID BIGINT = NULL,
  @StatusCode TINYINT = 1
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  UPDATE [Logging].[Process] WITH (ROWLOCK, READPAST)
     SET EndDateTime = SYSUTCDATETIME(),
         SourceProcessLogID = @SourceProcessLogID,
         StatusCode = @StatusCode
   WHERE ProcessLogID = @ProcessLogID
     AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth;  
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogStart --
GO
CREATE PROCEDURE [Logging].[LogProcessTaskStart] (
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @ProcessTaskID INT,
  @IsEnabled BIT = 1,
  @ProcessTaskLogID BIGINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  -- IsEnabled = 0, Invalid ProcessTaskID --
  IF @IsEnabled = 0 OR @ProcessTaskID = -1 BEGIN
    SET @ProcessTaskLogID = -1;
    RETURN;
  END;
  -- Not found --
  IF @ProcessTaskID IS NULL BEGIN;
    RETURN;
  END;
  -- EXISTING LOG IS OPEN --
  SELECT TOP 1 @ProcessTaskLogID = ProcessTaskLogID
    FROM [Logging].[ProcessTask] WITH (NOLOCK)
   WHERE ProcessTaskID = @ProcessTaskID
     AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth
     AND StatusCode = 0;
  IF @ProcessTaskLogID IS NOT NULL BEGIN;
    -- Update the Log --
    UPDATE [Logging].[ProcessTask] WITH (ROWLOCK, READPAST)
       SET StartDateTime = @StartDateTime
     WHERE ProcessTaskLogID = @ProcessTaskID;
    RETURN;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[ProcessTask] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [StartDateTime])
    VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @StartDateTime);
  SET @ProcessTaskLogID = @@IDENTITY;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogEnd --
GO
CREATE PROCEDURE [Logging].[LogProcessTaskEnd] (
  @ProcessTaskLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @StatusCode TINYINT = 1
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  UPDATE [Logging].[ProcessTask] WITH (ROWLOCK, READPAST)
     SET EndDateTime = SYSUTCDATETIME(),
         StatusCode = @StatusCode
   WHERE ProcessTaskLogID = @ProcessTaskLogID
     AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth;  
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogBulkExtractByIDStart --
GO
CREATE PROCEDURE [Logging].[LogBulkExtractByIDStart] (
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @ProcessTaskID INT,
  @ProcessTaskLogID BIGINT,
  @TaskExtractSourceID INT,
  @MinSourceTableID BIGINT,
  @MaxSourceTableID BIGINT,
  @BulkExtractLogID BIGINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  -- PROC. VARS --
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  -- EXISTING LOG IS OPEN --
  SELECT TOP 1 @BulkExtractLogID = BulkExtractByIDLogID
    FROM [Logging].[BulkExtractByID] WITH (NOLOCK)
   WHERE ProcessTaskID = @ProcessTaskID
     AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth
     AND TaskExtractSourceID = @TaskExtractSourceID
     AND StatusCode = 0;
  IF @BulkExtractLogID IS NOT NULL BEGIN;
    -- Update the Log --
    UPDATE [Logging].[BulkExtractByID] WITH (ROWLOCK, READPAST)
       SET StartDateTime = @StartDateTime
     WHERE BulkExtractByIDLogID = @BulkExtractLogID;
    RETURN;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[BulkExtractByID] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [TaskExtractSourceID], [MinSourceTableID], [MaxSourceTableID], [StartDateTime])
    VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @TaskExtractSourceID, @MinSourceTableID, @MaxSourceTableID, @StartDateTime);
  SET @BulkExtractLogID = @@IDENTITY;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Logging].[LogBulkExtractByDateStart] (
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @ProcessTaskID INT,
  @ProcessTaskLogID BIGINT,
  @TaskExtractSourceID INT,
  @MinSourceDateTime DATETIME2,
  @MaxSourceDateTime DATETIME2,
  @BulkExtractLogID BIGINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  -- PROC. VARS --
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  -- EXISTING LOG IS OPEN --
  SELECT TOP 1 @BulkExtractLogID = BulkExtractByDateLogID
    FROM [Logging].[BulkExtractByDate] WITH (NOLOCK)
   WHERE ProcessTaskID = @ProcessTaskID
     AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth
     AND TaskExtractSourceID = @TaskExtractSourceID
     AND StatusCode = 0;
  IF @BulkExtractLogID IS NOT NULL BEGIN;
    -- Update the Log --
    UPDATE [Logging].[BulkExtractByDate] WITH (ROWLOCK, READPAST)
       SET StartDateTime = @StartDateTime
     WHERE BulkExtractByDateLogID = @BulkExtractLogID;
    RETURN;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[BulkExtractByDate] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [TaskExtractSourceID], [MinSourceDateTime], [MaxSourceDateTime], [StartDateTime])
    VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @TaskExtractSourceID, @MinSourceDateTime, @MaxSourceDateTime, @StartDateTime);
  SET @BulkExtractLogID = @@IDENTITY;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogBulkExtractEnd --
GO
CREATE PROCEDURE [Logging].[LogBulkExtractEnd] (
  @BulkExtractLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @BulkExtractLogType VARCHAR(4) = 'ID',
  @StatusCode TINYINT = 1
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  IF @BulkExtractLogType = 'ID' BEGIN;
    UPDATE [Logging].[BulkExtractByID] WITH (ROWLOCK, READPAST)
       SET EndDateTime = SYSUTCDATETIME(),
           StatusCode = @StatusCode
     WHERE BulkExtractByIDLogID = @BulkExtractLogID
       AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth; 
  END;
  IF @BulkExtractLogType = 'DATE' BEGIN;
    UPDATE [Logging].[BulkExtractByDate] WITH (ROWLOCK, READPAST)
       SET EndDateTime = SYSUTCDATETIME(),
           StatusCode = @StatusCode
     WHERE BulkExtractByDateLogID = @BulkExtractLogID
       AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth; 
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogCDOExtractStart --
GO
CREATE PROCEDURE [Logging].[LogCDOExtractByIDStart] (
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @ProcessTaskID INT,
  @ProcessTaskLogID BIGINT,
  @TaskExtractSourceID INT,
  @InitialID BIGINT = NULL,
  @BeginID BIGINT OUTPUT,
  @EndID BIGINT OUTPUT,
  @CDOExtractLogID BIGINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  -- PROC. VARS. --
  DECLARE @DBName NVARCHAR(128),
          @ExtractObject NVARCHAR(128),
          @ExtractObject_Column_SourceTableID NVARCHAR(128),
          @PrevMaxID BIGINT,
          @CMD NVARCHAR(2000);
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  DECLARE @Output TABLE (CDOExtractLogID BIGINT, MinSourceID BIGINT, MaxSourceID BIGINT);
  -- GET Extract Database --
  SELECT @DBName = ExtractDatabase,
         @ExtractObject = ExtractObject,
           @ExtractObject_Column_SourceTableID = TrackedColumn
    FROM [Config].[ProcessTaskExtractSource] TES WITH (NOLOCK)
   INNER JOIN [Config].[ExtractSource] ES WITH (NOLOCK)
      ON TES.ExtractSourceID = ES.ExtractSourceID
   WHERE TES.[ProcessTaskID] = @ProcessTaskID;
  -- EXISTING LOG IS OPEN --
  INSERT INTO @Output
    SELECT CDOExtractByIDLogID, MinSourceTableID, MaxSourceTableID
      FROM [Logging].[CDOExtractByID] WITH (NOLOCK)
     WHERE ProcessTaskID = @ProcessTaskID
       AND TaskExtractSourceID = @TaskExtractSourceID
       AND StatusCode = 0;
  IF EXISTS (SELECT 1 FROM @Output) BEGIN;
    -- Update the Log --
    UPDATE [Logging].[CDOExtractByID] WITH (ROWLOCK, READPAST)
       SET StartDateTime = @StartDateTime
     WHERE CDOExtractByIDLogID = (SELECT TOP 1 CDOExtractLogID FROM @Output);
    GOTO ReturnOutput;
  END;
  -- Get Previous Max VALUES from last extract --
  SELECT @PrevMaxID =  MAX(MaxSourceTableID)
    FROM [Logging].[CDOExtractByID] WITH (NOLOCK)
   WHERE ProcessTaskID = @ProcessTaskID
     AND TaskExtractSourceID = @TaskExtractSourceID
     AND (StatusCode = 1 OR StatusCode = 3);

  -- Only ID relevant. Lookup via ID, record only ID --
  -- Get MinID if no Log --
  IF @PrevMaxID IS NULL BEGIN;
    SET @CMD = N'SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
                   SELECT @Begin_ID = MIN(' + @ExtractObject_Column_SourceTableID + ') FROM '+@DBName+'.'+ @ExtractObject + '; 
                 SET TRANSACTION ISOLATION LEVEL READ COMMITTED;';
    EXEC SP_ExecuteSQL @CMD, N'@Begin_ID BIGINT OUTPUT', @BeginID OUTPUT;
  END;
  IF @BeginID IS NULL SET @BeginID = @PrevMaxID;
  -- Get MaxTime --
  SET @CMD = N'SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
                 SELECT @End_ID = MAX('+@ExtractObject_Column_SourceTableID+') FROM '+@DBName+'.'+ @ExtractObject + '; 
               SET TRANSACTION ISOLATION LEVEL READ COMMITTED; ';
  EXEC SP_ExecuteSQL @CMD, N'@End_ID BIGINT OUTPUT', @EndID OUTPUT;
  -- There must be an End ID. If there is none, Start and End ID will end up the same. --
  SET @EndID = CASE WHEN @EndID IS NULL AND @BeginID IS NULL AND @PrevMaxID IS NULL THEN 0
                    WHEN @EndID IS NULL AND @BeginID IS NULL AND @PrevMaxID IS NOT NULL THEN @PrevMaxID
                    WHEN @EndID IS NULL AND @BeginID IS NOT NULL AND @PrevMaxID IS NULL THEN @BeginID
                    ELSE @EndID
                  END;
  IF (@PrevMaxID > @EndID) OR (@BeginID IS NULL) SET @BeginID = @EndID;
  -- INITIAL RANGE HAS BEEN PROVIDED --
  IF @InitialID IS NOT NULL
    SET @BeginID = @InitialID;
  -- BEGIN AND END ARE THE SAME, NO CHANGE --
  IF @BeginID = @EndID BEGIN;
    SET @CDOExtractLogID = -1;
    GOTO ReturnOutput;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[CDOExtractByID] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [TaskExtractSourceID], [MinSourceTableID], [MaxSourceTableID], [StartDateTime])
    OUTPUT Inserted.CDOExtractByIDLogID, Inserted.MinSourceTableID, Inserted.MaxSourceTableID INTO @Output
  VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @TaskExtractSourceID, @BeginID, @EndID, @StartDateTime);  
  -- Output Variables --
  ReturnOutput:
  SELECT @CDOExtractLogID = CDOExtractLogID,
         @BeginID = MinSourceID,
         @EndID = MaxSourceID
  FROM @Output;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Logging].[LogCDOExtractByDateStart] (
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @ProcessTaskID INT,
  @ProcessTaskLogID BIGINT,
  @TaskExtractSourceID INT,
  @InitialDateTime DATETIME2 = NULL,
  @BeginDateTime DATETIME2 OUTPUT,
  @EndDateTime DATETIME2 OUTPUT,
  @CDOExtractLogID BIGINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  -- PROC. VARS. --
  DECLARE @DBName NVARCHAR(128),
          @ExtractObject NVARCHAR(128),
          @ExtractObject_Column_DateTime  NVARCHAR(128),
          @PrevMaxTime DATETIME2,
          @CMD NVARCHAR(2000);
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  DECLARE @Output TABLE (CDOExtractLogID BIGINT, MinSourceDateTime DATETIME2, MaxSourceDateTime DATETIME2);
  -- GET Extract Database --
  SELECT @DBName = ExtractDatabase,
         @ExtractObject = ExtractObject,
           @ExtractObject_Column_DateTime = TrackedColumn
    FROM [Config].[ProcessTaskExtractSource] TES WITH (NOLOCK)
   INNER JOIN [Config].[ExtractSource] ES WITH (NOLOCK)
      ON TES.ExtractSourceID = ES.ExtractSourceID
   WHERE TES.[ProcessTaskID] = @ProcessTaskID;
  -- EXISTING LOG IS OPEN --
  INSERT INTO @Output
    SELECT CDOExtractByDateLogID, MinSourceDateTime, MaxSourceDateTime
      FROM [Logging].[CDOExtractByDate] WITH (NOLOCK)
     WHERE ProcessTaskID = @ProcessTaskID
       AND TaskExtractSourceID = @TaskExtractSourceID
       AND StatusCode = 0;
  IF EXISTS (SELECT 1 FROM @Output) BEGIN;
    -- Update the Log --
    UPDATE [Logging].[CDOExtractByDate] WITH (ROWLOCK, READPAST)
       SET StartDateTime = @StartDateTime
     WHERE CDOExtractByDateLogID = (SELECT TOP 1 CDOExtractLogID FROM @Output);
    GOTO ReturnOutput;
  END;
  -- Get Previous Max VALUESfrom last extract --
  SELECT @PrevMaxTime = MAX(MaxSourceDateTime)
    FROM [Logging].[CDOExtractByDate] WITH (NOLOCK)
   WHERE ProcessTaskID = @ProcessTaskID
     AND TaskExtractSourceID = @TaskExtractSourceID
     AND (StatusCode = 1 OR StatusCode = 3);
  
  -- Only Date column relevant. Lookup via Date, record only date  --
  -- Get MinTime if no Log --
  IF @PrevMaxTime IS NULL BEGIN; 
    SET @CMD = N'SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
                   SELECT @Begin_Time = MIN(' + @ExtractObject_Column_DateTime + ') FROM '+@DBName+'.'+ @ExtractObject + '; 
                 SET TRANSACTION ISOLATION LEVEL READ COMMITTED;';
    EXEC SP_ExecuteSQL @CMD, N'@Begin_Time DATETIME2 OUTPUT', @BeginDateTime OUTPUT;
  END;
  IF @BeginDateTime IS NULL SET @BeginDateTime = @PrevMaxTime;
  -- Get MaxTime --
  SET @CMD = N'SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
                 SELECT @End_Time = MAX('+@ExtractObject_Column_DateTime+') FROM '+@DBName+'.'+ @ExtractObject + '; 
               SET TRANSACTION ISOLATION LEVEL READ COMMITTED; ';
  EXEC SP_ExecuteSQL @CMD, N'@End_Time DATETIME2 OUTPUT', @EndDateTime OUTPUT;
  -- There must be an End Time. If there is none, Start and End time will end up the same. --
  SET @EndDateTime = CASE WHEN @EndDateTime IS NULL AND @BeginDateTime IS NULL AND @PrevMaxTime IS NULL THEN '1753-01-01'
                          WHEN @EndDateTime IS NULL AND @BeginDateTime IS NULL AND @PrevMaxTime IS NOT NULL THEN @PrevMaxTime
                          WHEN @EndDateTime IS NULL AND @BeginDateTime IS NOT NULL AND @PrevMaxTime IS NULL THEN @BeginDateTime
                          ELSE @EndDateTime
                  END;
  IF (@PrevMaxTime > @EndDateTime) OR (@BeginDateTime IS NULL) SET @BeginDateTime = @EndDateTime;
  -- INITIAL RANGE HAS BEEN PROVIDED --
  IF @InitialDateTime IS NOT NULL
    SET @BeginDateTime = @InitialDateTime;
  -- BEGIN AND END ARE THE SAME, NO CHANGE --
  IF @BeginDateTime = @EndDateTime BEGIN;
    SET @CDOExtractLogID = -1;
    GOTO ReturnOutput;
  END;
  -- CREATE NEW OPEN LOG --
  INSERT INTO [Logging].[CDOExtractByDate] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [TaskExtractSourceID], [MinSourceDateTime], [MaxSourceDateTime], [StartDateTime])
    OUTPUT Inserted.CDOExtractByDateLogID, Inserted.MinSourceDateTime, Inserted.MaxSourceDateTime INTO @Output
  VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @TaskExtractSourceID, @BeginDateTime, @EndDateTime, @StartDateTime);  
  -- Output Variables --
  ReturnOutput:
  SELECT @CDOExtractLogID = CDOExtractLogID,
         @BeginDateTime = MinSourceDateTime,
         @EndDateTime = MaxSourceDateTime
  FROM @Output;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogCDOExtractEnd --
GO
CREATE PROCEDURE [Logging].[LogCDOExtractEnd] (
  @CDOExtractLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @CDOExtractLogType VARCHAR(4) = 'ID',
  @StatusCode TINYINT = 1
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  IF @CDOExtractLogType = 'ID' BEGIN;
    UPDATE [Logging].[CDOExtractByID] WITH (ROWLOCK, READPAST)
       SET EndDateTime = SYSUTCDATETIME(),
           StatusCode = @StatusCode
     WHERE CDOExtractByIDLogID = @CDOExtractLogID
       AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth; 
  END;
  IF @CDOExtractLogType = 'DATE' BEGIN;
    UPDATE [Logging].[CDOExtractByDate] WITH (ROWLOCK, READPAST)
       SET EndDateTime = SYSUTCDATETIME(),
           StatusCode = @StatusCode
     WHERE CDOExtractByDateLogID = @CDOExtractLogID
       AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth; 
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO


-- LogExtractEnd --
GO
CREATE PROCEDURE [Logging].[LogExtractEnd] (
  @ExtractLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @ExtractType CHAR(3),
  @ExtractLogType VARCHAR(4) = 'ID',
  @StatusCode TINYINT = 1
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  IF @ExtractLogID = -1 RETURN; -- Nothing to do.
  IF @ExtractType = 'CDO'
    EXEC [Logging].[LogCDOExtractEnd] @CDOExtractLogID = @ExtractLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @CDOExtractLogType = @ExtractLogType, @StatusCode = @StatusCode;
  IF @ExtractType = 'BUL'
    EXEC [Logging].[LogBulkExtractEnd] @BulkExtractLogID = @ExtractLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @BulkExtractLogType = @ExtractLogType, @StatusCode = @StatusCode;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

-- LogProcessTaskCapture --
GO
CREATE PROCEDURE [Logging].[LogProcessTaskCapture] (
   @ProcessLogID BIGINT,
   @ProcessLogCreatedMonth TINYINT,
   @ProcessTaskID INT,
   @ProcessTaskLogID BIGINT,
   @TargetObject NVARCHAR(128),
   @RaiseCount INT = NULL,
   @MergeCount INT = NULL,
   @InsertCount INT = NULL,
   @UpdateCount INT = NULL,
   @DeleteCount INT = NULL
) AS
  SET NOCOUNT ON;
BEGIN
BEGIN TRY;
  -- PROC. VARS --
  SET @RaiseCount = ISNULL(@RaiseCount, 0);
  SET @MergeCount = ISNULL(@MergeCount, 0);
  SET @InsertCount = ISNULL(@InsertCount, 0);
  SET @UpdateCount = ISNULL(@UpdateCount, 0);
  SET @DeleteCount = ISNULL(@DeleteCount, 0);
  -- ONLY RECORD NON-ZERO CAPTURE
  IF @RaiseCount = 0 AND @MergeCount = 0 AND @InsertCount = 0 AND @UpdateCount = 0 AND @DeleteCount = 0
    RETURN;
  DECLARE @TargetObjectType VARCHAR(10) = CASE WHEN LEFT(@TargetObject, 1) = '#' THEN 'TEMP'
                                               WHEN LEFT(@TargetObject, 1) = '@' THEN 'PAYLOAD'
                                               ELSE 'SCHEMA' END;
  INSERT INTO [Logging].[ProcessTaskCapture] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [TargetObject], [TargetObjectType], [RaiseCount], [MergeCount], [InsertCount], [UpdateCount], [DeleteCount])
    VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @TargetObject, @TargetObjectType, @RaiseCount, @MergeCount, @InsertCount, @UpdateCount, @DeleteCount);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END
GO

-- LogProcessTaskInfo --
GO
CREATE PROCEDURE [Logging].[LogProcessTaskInfo] (
   @ProcessLogID BIGINT,
   @ProcessLogCreatedMonth TINYINT,
   @ProcessTaskID INT,
   @ProcessTaskLogID BIGINT,
   @InfoMessage NVARCHAR(1000),
   @Ordinal INT = NULL
) AS
  SET NOCOUNT ON;
BEGIN
BEGIN TRY;
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  -- PROC. VARS --
  IF @InfoMessage IS NULL
    RETURN;
  SET @Ordinal = ISNULL(@Ordinal, 0);
  INSERT INTO [Logging].[ProcessTaskInfo] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [InfoMessage], [Ordinal], [StartDateTime], [EndDateTime])
    VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @InfoMessage, @Ordinal, @StartDateTime, @StartDateTime);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END
GO

-- LogProcessTaskInfoStart --
GO
CREATE PROCEDURE [Logging].[LogProcessTaskInfoStart] (
   @ProcessLogID BIGINT,
   @ProcessLogCreatedMonth TINYINT,
   @ProcessTaskID INT,
   @ProcessTaskLogID BIGINT,
   @InfoMessage NVARCHAR(1000),
   @Ordinal INT = NULL,
   @ProcessTaskInfoLogID BIGINT OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN
BEGIN TRY;
  DECLARE @StartDateTime DATETIME2 = SYSUTCDATETIME();
  -- PROC. VARS --
  IF @InfoMessage IS NULL
    RETURN;
  SET @Ordinal = ISNULL(@Ordinal, 0);
  INSERT INTO [Logging].[ProcessTaskInfo] ([ProcessLogID], [ProcessLogCreatedMonth], [ProcessTaskID], [ProcessTaskLogID], [InfoMessage], [Ordinal], [StartDateTime])
    VALUES(@ProcessLogID, @ProcessLogCreatedMonth, @ProcessTaskID, @ProcessTaskLogID, @InfoMessage, @Ordinal, @StartDateTime);
  -- Output Variables --
   SELECT @ProcessTaskInfoLogID = @@IDENTITY; 
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END
GO

-- LogProcessTaskInfoEnd --
GO
CREATE PROCEDURE [Logging].[LogProcessTaskInfoEnd] (
  @ProcessTaskInfoLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT
) AS
  SET NOCOUNT ON;
BEGIN
BEGIN TRY;
  IF @ProcessTaskInfoLogID IS NOT NULL
  UPDATE [Logging].[ProcessTaskInfo] WITH (ROWLOCK, READPAST)
     SET EndDateTime = SYSUTCDATETIME()
   WHERE ProcessTaskInfoLogID = @ProcessTaskInfoLogID
     AND ProcessLogCreatedMonth = @ProcessLogCreatedMonth;  
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END
GO

-- LogError --
GO
-- This does not include a Try/Catch block by design. --
CREATE PROCEDURE [Logging].[LogError] (
  @ProcessID SMALLINT = NULL,
  @TaskID SMALLINT = NULL,
  @ProcessLogID BIGINT = NULL,
  @ProcessTaskLogID BIGINT = NULL,
  @ErrorNumber INT = NULL,
  @ErrorProcedure NVARCHAR(128) = NULL,
  @ErrorLine INT = NULL,
  @ErrorMessage NVARCHAR(4000) = NULL,
  @ConversationHandle UNIQUEIDENTIFIER = NULL,
  @ConversationID UNIQUEIDENTIFIER = NULL,
  @ErrorPayloadXML XML = NULL,
  @ErrorPayloadJSON NVARCHAR(MAX) = NULL
) AS
  SET NOCOUNT ON;
BEGIN;
  -- PROC. VARS --
  DECLARE @ErrorLogID BIGINT;
  SET @ProcessLogID = ISNULL(@ProcessLogID, -1);
  SET @ProcessTaskLogID = ISNULL(@ProcessTaskLogID, -1);
  SET @ProcessID = ISNULL(@ProcessID, -1);
  SET @TaskID = ISNULL(@TaskID, -1);
  -- Error --
  INSERT INTO [Logging].[Error] ([ProcessID], [TaskID], [ProcessLogID], [ProcessTaskLogID], [ErrorNumber], [ErrorProcedure], [ErrorLine], [ErrorMessage])
    VALUES(@ProcessID, @TaskID, @ProcessLogID, @ProcessTaskLogID, @ErrorNumber, @ErrorProcedure, @ErrorLine, @ErrorMessage);
  SET @ErrorLogID = @@IDENTITY;
  -- Error Payload - XML
  IF @ErrorPayloadXML IS NOT NULL BEGIN;
    INSERT INTO [Logging].[ErrorPayloadXML] ([ErrorLogID], [ConversationHandle], [ConversationID], [ErrorPayload])
      VALUES(@ErrorLogID, @ConversationHandle, @ConversationID, @ErrorPayloadXML);   
  END;
  -- Error Payload - JSON
  IF @ErrorPayloadJSON IS NOT NULL BEGIN;
    INSERT INTO [Logging].[ErrorPayloadJSON] ([ErrorLogID], [ConversationHandle], [ConversationID], [ErrorPayload])
      VALUES(@ErrorLogID, @ConversationHandle, @ConversationID, @ErrorPayloadJSON);   
  END;
END;
GO
/* End of File ********************************************************************************************************************/