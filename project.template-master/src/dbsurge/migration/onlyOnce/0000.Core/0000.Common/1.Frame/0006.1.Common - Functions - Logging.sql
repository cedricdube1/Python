/***********************************************************************************************************************************
* Script      : 6.Common - Functions - Logging.sql                                                                                *
* Created By  : Cedric Dube                                                                                                        *
* Created On  : 2020-10-02                                                                                                           *
* Execute On  : As required.                                                                                  *
* Execute As  : N/A                                                                                                                  *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                  *
* Steps       :  1. Logging                                                                                                           *
***********************************************************************************************************************************/
USE [dbSurge]
GO

GO
CREATE FUNCTION [Logging].[GetProcessLogStatus] (
  @ProcessLogID BIGINT
) RETURNS TINYINT
BEGIN;
  DECLARE @StatusCode TINYINT;
  SELECT @StatusCode = StatusCode
   FROM [Logging].[Process] WITH (NOLOCK)
  WHERE [ProcessLogID] = @ProcessLogID;
  -- Default / Return --
  RETURN @StatusCode;
END;
GO

GO
CREATE FUNCTION [Logging].[GetLastCompletedProcessLog] (
  @ProcessID SMALLINT
) RETURNS BIGINT
BEGIN;
  DECLARE @ProcessLogID BIGINT;
  SELECT @ProcessLogID = MAX(ProcessLogID)
   FROM [Logging].[Process] WITH (NOLOCK)
  WHERE [ProcessID] = @ProcessID
    AND [StatusCode] = 1;
  -- Default / Return --
  RETURN @ProcessLogID;
END;
GO

GO
CREATE FUNCTION [Logging].[GetProcessTaskLogStatus] (
  @ProcessTaskLogID BIGINT
) RETURNS TINYINT
BEGIN;
  DECLARE @StatusCode TINYINT;
  SELECT @StatusCode = StatusCode
   FROM [Logging].[ProcessTask] WITH (NOLOCK)
  WHERE [ProcessTaskLogID] = @ProcessTaskLogID;
  -- Default / Return --
  RETURN @StatusCode;
END;
GO


GO
CREATE FUNCTION [Logging].[GetProcessLogCreatedMonth] (
  @ProcessLogID BIGINT
) RETURNS INTEGER
BEGIN;
  DECLARE @ProcessLogCreatedMonth INT;
  SELECT @ProcessLogCreatedMonth = [ProcessLogCreatedMonth]
   FROM [Logging].[Process] WITH (NOLOCK)
  WHERE [ProcessLogID] = @ProcessLogID;
  -- Default / Return --
  RETURN @ProcessLogCreatedMonth;
END;
GO

GO
CREATE FUNCTION [Logging].[GetLogArchivePartition]()
  RETURNS INTEGER
BEGIN;
  DECLARE @ArchivePartition INT;
  DECLARE @NowTime DATETIME2 = SYSUTCDATETIME();
  DECLARE @MonthPartitions TABLE (MonthInt INT, PartitionNumber INT);
  DECLARE @ExcludedMonths TABLE (MonthInt INT);
  -- All Partitions --
  INSERT INTO @MonthPartitions (MonthInt)
   VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12);
  UPDATE @MonthPartitions SET PartitionNumber = $PARTITION.PartFunc_MonthNumber(MonthInt);  
  -- Exclude this month and last month --
  INSERT INTO @ExcludedMonths (MonthInt)
   VALUES (DATEPART(MONTH, DATEADD(MONTH, -1, @NowTime))),
          (DATEPART(MONTH, @NowTime));
  -- Get the earliest partition number (partitions to the left, so furthest month) prior to excluded periods --
  SET @ArchivePartition = (SELECT PartitionNumber FROM @MonthPartitions MP WHERE MonthInt = (SELECT MIN(MonthInt) FROM @MonthPartitions WHERE MonthInt < (SELECT MIN(MonthInt) FROM @ExcludedMonths)));
  -- Default / Return --
  RETURN @ArchivePartition;
END;
GO


/* End of File ********************************************************************************************************************/