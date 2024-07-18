/***********************************************************************************************************************************
* Script      : 7.Common - Procedures - DataFlow.sql                                                                               *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-02-26                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. DataFlow                                                                                                       *
***********************************************************************************************************************************/
USE [dbSurge]
GO

--EXEC [DataFlow].[QueueJob] @JobID = @JobID, @StatusCode = @StatusCode; @JobReportTime = @SystemEndTime;
GO
CREATE PROCEDURE [DataFlow].[QueueJob] (
  @JobID SMALLINT,
  @Enqueue BIT,
  @StatusCode TINYINT = NULL,
  @JobReportTime DATETIME = NULL,
  @EarliestNextExecution DATETIME = NULL
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  -- Remove existing entry --
  IF @Enqueue = 0 BEGIN;
    DELETE FROM [Config].[JobQueue] WITH (ROWLOCK)
      WHERE JobID = @JobID;
    RETURN;
  END;
  -- Add new entry --
  IF @Enqueue = 1 BEGIN;
    SET @EarliestNextExecution = CASE WHEN @EarliestNextExecution IS NULL 
                                      THEN (SELECT EarliestNextExecution FROM [Config].[GetEarliestNextExecution_JobLoop] (@JobID, @JobReportTime))
                                 ELSE @EarliestNextExecution END;
    IF @EarliestNextExecution IS NULL -- No job details found, Exit.
      RETURN;
    IF @StatusCode <> 1-- Job was not successful, Exit without enqueue.
      RETURN;
    -- Enqueue --
	IF NOT EXISTS (SELECT 1 FROM [Config].[JobQueue] WHERE JobID = @JobID) BEGIN;
      INSERT INTO [Config].[JobQueue] (
        JobID,
        EarliestNextExecution
      ) VALUES(@JobID, @EarliestNextExecution);
    END; ELSE BEGIN;
	  UPDATE [Config].[JobQueue] WITH (ROWLOCK, READPAST)
	    SET EarliestNextExecution = @EarliestNextExecution
      WHERE JobID = @JobID;
	END;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [DataFlow].[QueueJobList] (
  @JobQueueList DataFlow.JobQueueList READONLY
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  -- Remove existing entry --
  DELETE FROM [Config].[JobQueue] WITH (ROWLOCK)
   WHERE JobID IN ( SELECT JobID FROM @JobQueueList);

  -- Insert new entry --
  INSERT INTO [Config].[JobQueue] (
    JobID,
    EarliestNextExecution
  ) SELECT JobID,
           EarliestNextExecution
	FROM @JobQueueList WHERE Enqueue = 1;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [DataFlow].[JobController] (
  @ControllerProcessID INT,
  @ReturnCode INT = NULL OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  DECLARE @Iteration SMALLINT = ISNULL(TRY_CAST([Config].[GetVariable_Process](@ControllerProcessID, 'JobControllerIteration') AS SMALLINT), 10);
  DECLARE @ActiveJobLimit SMALLINT = ISNULL(TRY_CAST([Config].[GetVariable_Process](@ControllerProcessID, 'JobControllerActiveJobLimit') AS SMALLINT), 150);
  DECLARE @ExecutionStyle VARCHAR(30) = ISNULL(TRY_CAST([Config].[GetVariable_Process](@ControllerProcessID, 'JobControllerExecutionStyle') AS VARCHAR(30)), 'Limit');
  DECLARE @CurrentTime DATETIME = SYSDATETIME();
  DECLARE @JobID SMALLINT,
          @JobName VARCHAR(150),
          @JobStatus VARCHAR(9);
  DECLARE @Counter SMALLINT = 0;

  -- Keep adding jobs until max running jobs reached --
  IF @ExecutionStyle = 'Limit' BEGIN;
    SELECT @Counter = COUNT(1) FROM (
    SELECT SJ.[Name] AS JobName, 
           [JobStatus] = ISNULL(CASE WHEN [SJA].[Start_Execution_Date] IS NOT NULL AND [SJA].[Stop_Execution_Date] IS NULL THEN 'Running'
                            ELSE 'Idle' END, 'Unknown')
    FROM [MSDB].[DBO].[SysJobs] [SJ] WITH (NOLOCK)
    INNER JOIN [MSDB].[DBO].[SysJobActivity] [SJA] WITH (NOLOCK)
      ON  [SJ].[Job_Id] = [SJA].[Job_Id]) QRY WHERE @JobStatus = 'Running';

    WHILE @Counter < @ActiveJobLimit BEGIN;
      SET @JobID = NULL;
  	  SET @JobName = NULL;
  	  SET @JobStatus = NULL;
      -- Get first job that is executable --
      SET @JobID = (SELECT TOP (1) JobID 
  	                FROM [Config].[JobQueue] WITH (NOLOCK) 
  	               WHERE [EarliestNextExecution] <= @CurrentTime ORDER BY [EarliestNextExecution] ASC, [JobID] ASC);
      IF @JobID IS NULL
        RETURN;
      SET @JobName = (SELECT TOP (1) JobName FROM [Config].[Job] WITH (NOLOCK) WHERE JobID = @JobID);
      IF @JobName IS NULL
        RETURN;
      SET @JobStatus = (SELECT JobStatus FROM [Monitoring].[GetCurrentJobState] (@JobName));
      IF @JobStatus <> 'Running' OR @JobStatus IS NULL
        EXEC @ReturnCode = MSDB.dbo.sp_start_job @JobName;
      IF @ReturnCode = 0 BEGIN;
        -- Handle Job Queue (Dequeue)--
        EXEC [DataFlow].[QueueJob] @JobID = @JobID, @Enqueue = 0;
      END;
      SET @Counter = @Counter + 1;
    END;
  END;

  -- keep adding jobs until defined number have been started --
  IF @ExecutionStyle = 'Iterate' BEGIN;
    WHILE @Counter < @Iteration BEGIN;
      SET @JobID = NULL;
  	  SET @JobName = NULL;
  	  SET @JobStatus = NULL;
      -- Get first job that is executable --
      SET @JobID = (SELECT TOP (1) JobID 
  	                FROM [Config].[JobQueue] WITH (NOLOCK) 
  	               WHERE [EarliestNextExecution] <= @CurrentTime ORDER BY [EarliestNextExecution] ASC, [JobID] ASC);
      IF @JobID IS NULL
        RETURN;
      SET @JobName = (SELECT TOP (1) JobName FROM [Config].[Job] WITH (NOLOCK) WHERE JobID = @JobID);
      IF @JobName IS NULL
        RETURN;
      SET @JobStatus = (SELECT JobStatus FROM [Monitoring].[GetCurrentJobState] (@JobName));
      IF @JobStatus <> 'Running' OR @JobStatus IS NULL
        EXEC @ReturnCode = MSDB.dbo.sp_start_job @JobName;
      IF @ReturnCode = 0 BEGIN;
        -- Handle Job Queue (Dequeue)--
        EXEC [DataFlow].[QueueJob] @JobID = @JobID, @Enqueue = 0;
      END;
      SET @Counter = @Counter + 1;
    END;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO


/* End of File ********************************************************************************************************************/