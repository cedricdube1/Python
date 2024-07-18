/***********************************************************************************************************************************
* Script      : 7.Common - Procedures - Maintenance.sql                                                                            *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Append partitions                                                                                              *
*             :  2. Merge partitions                                                                                               *
*             :  3. Switch partitions                                                                                              *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- Partition Procedures --
GO
CREATE PROCEDURE [Maintenance].[AppendPartitions_Date] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxDate DATE,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition DATE = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[AppendPartitions_Date]
  -- Author:      Cedric Dube
  -- Create date: 2020-10-02
  -- Description: Append empty partitions from the latest date partition up to the @NewMaxDate
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMaxDate DATE;
  DECLARE @NextDate DATE;
  SELECT @CurrentMaxDate = ISNULL(CAST(MAX(value) AS DATE), SYSUTCDATETIME())
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentHighestPartition = @CurrentMaxDate;
  IF @CheckLatestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW DATE IS LATER THAN CURRENT MAX DATE --
  IF @CurrentMaxDate >= @NewMaxDate BEGIN;
    RETURN;
  END;
  -- ITERATE AND ADD PER DATE UNTIL @NewMaxDate --
  SET @Command = N'
    WHILE(@CurrentMaxDate < @NewMaxDate) BEGIN;
     SELECT @NextDate = DATEADD(DAY, 1, @CurrentMaxDate);
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() SPLIT RANGE(@NextDate);   
     -- ITERATE --
     SELECT @CurrentMaxDate = CAST(MAX(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;
    END;';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMaxDate DATE, @NewMaxDate DATE, @NextDate DATE, @PartitionFunction NVARCHAR(128)',
                     @CurrentMaxDate = @CurrentMaxDate,
                     @NewMaxDate = @NewMaxDate,
                     @NextDate = @NextDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO

GO
CREATE PROCEDURE [Maintenance].[AppendPartitions_Month] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxDate DATE,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition DATE = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[AppendPartitions_Month]
  -- Author:      Cedric Dube
  -- Create date: 2020-10-02
  -- Description: Append empty partitions from the latest month partition up to the @NewMaxDate
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMaxDate DATE;
  DECLARE @NextDate DATE;
  SELECT @CurrentMaxDate = ISNULL(CAST(MAX(value) AS DATE), SYSUTCDATETIME())
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentHighestPartition = @CurrentMaxDate;
  IF @CheckLatestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW DATE IS LATER THAN CURRENT MAX DATE --
  IF @CurrentMaxDate >= @NewMaxDate BEGIN;
    RETURN;
  END;
  -- GET FIRST OF THE MONTH FOR NEXT PARTITION --
  SET @NewMaxDate = DATEADD(mm, DATEDIFF(mm, 0, @NewMaxDate), 0);
  -- ITERATE AND ADD PER DATE UNTIL @NewMaxDate --
  SET @Command = N'
    WHILE(@CurrentMaxDate < @NewMaxDate) BEGIN;
     SELECT @NextDate = DATEADD(MONTH, 1, @CurrentMaxDate);
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() SPLIT RANGE(@NextDate);   
     -- ITERATE --
     SELECT @CurrentMaxDate = CAST(MAX(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;
    END;';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMaxDate DATE, @NewMaxDate DATE, @NextDate DATE, @PartitionFunction NVARCHAR(128)',
                     @CurrentMaxDate = @CurrentMaxDate,
                     @NewMaxDate = @NewMaxDate,
                     @NextDate = @NextDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO

GO
CREATE PROCEDURE [Maintenance].[AppendPartitions_Year] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxDate DATE,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition DATE = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[AppendPartitions_Year]
  -- Author:      Cedric Dube
  -- Create date: 2020-10-02
  -- Description: Append empty partitions from the latest year partition up to the @NewMaxDate
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMaxDate DATE;
  DECLARE @NextDate DATE;
  SELECT @CurrentMaxDate = ISNULL(CAST(MAX(value) AS DATE), SYSUTCDATETIME())
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentHighestPartition = @CurrentMaxDate;
  IF @CheckLatestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW DATE IS LATER THAN CURRENT MAX DATE --
  IF @CurrentMaxDate >= @NewMaxDate BEGIN;
    RETURN;
  END;
  -- GET FIRST OF THE YEAR FOR NEXT PARTITION --  
  SET @NewMaxDate = DATEADD(yy, DATEDIFF(yy, 0, @NewMaxDate), 0);
  -- ITERATE AND ADD PER DATE UNTIL @NewMaxDate --
  SET @Command = N'
    WHILE(@CurrentMaxDate < @NewMaxDate) BEGIN;
     SELECT @NextDate = DATEADD(YEAR, 1, @CurrentMaxDate);
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() SPLIT RANGE(@NextDate);   
     -- ITERATE --
     SELECT @CurrentMaxDate = CAST(MAX(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;
    END;';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMaxDate DATE, @NewMaxDate DATE, @NextDate DATE, @PartitionFunction NVARCHAR(128)',
                     @CurrentMaxDate = @CurrentMaxDate,
                     @NewMaxDate = @NewMaxDate,
                     @NextDate = @NextDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO
GO
CREATE PROCEDURE [Maintenance].[AppendPartitions_SourceSystem] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxSourceSystem INT,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition INT = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[AppendPartitions_SourceSystem]
  -- Author:      Cedric Dube
  -- Create date: 2020-10-02
  -- Description: Append empty partitions from the latest SourceSystemID partition up to the @NewMaxSourceSystem
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMaxSourceSystem INT;
  DECLARE @NextSourceSystem INT;
  SELECT @CurrentMaxSourceSystem = ISNULL(CAST(MAX(value) AS INT), 0)
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentHighestPartition = @CurrentMaxSourceSystem;
  IF @CheckLatestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW SOURCESYSTEM IS LATER THAN CURRENT MAX SOURCESYSTEM --
  IF @CurrentMaxSourceSystem >= @NewMaxSourceSystem BEGIN;
    RETURN;
  END;
  -- GET FIRST OF THE YEAR FOR NEXT PARTITION --  
  SET @NewMaxSourceSystem = @NewMaxSourceSystem + 1;
  -- ITERATE AND ADD PER SOURCESYSTEM UNTIL @NewMaxSourceSystem --
  SET @Command = N'
     SELECT @NextSourceSystem = @CurrentMaxSourceSystem + 1;
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() SPLIT RANGE(@NextSourceSystem);   
     -- ITERATE --
     SELECT @CurrentMaxSourceSystem = CAST(MAX(value) AS INT)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMaxSourceSystem INT, @NewMaxSourceSystem INT, @NextSourceSystem INT, @PartitionFunction NVARCHAR(128)',
                     @CurrentMaxSourceSystem = @CurrentMaxSourceSystem,
                     @NewMaxSourceSystem = @NewMaxSourceSystem,
                     @NextSourceSystem = @NextSourceSystem,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxSourceSystem;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO

-- Partition Procedures --
GO
CREATE PROCEDURE [Maintenance].[MergePartitions_Date] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @MergeRangeDate DATE,
  @CheckEarliestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentLowestPartition DATE = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[MergePartitions_Date]
  -- Author:      Cedric Dube
  -- Create date: 2021-01-28
  -- Description: Merge partitions for the range provided
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMinDate DATE;
  SELECT @CurrentMinDate = ISNULL(CAST(MIN(value) AS DATE), SYSUTCDATETIME())
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentLowestPartition = @CurrentMinDate;
  IF @CheckEarliestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW DATE IS NOT EARLIER THAN CURRENT MIN DATE --
  IF @CurrentMinDate > @MergeRangeDate BEGIN;
    RETURN;
  END;
  -- ITERATE AND ADD PER DATE UNTIL @MergeRangeDate --
  SET @Command = N'
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() MERGE RANGE(@MergeRangeDate);   
     -- ITERATE --
     SELECT @CurrentMinDate = CAST(MIN(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMinDate DATE, @MergeRangeDate DATE, @PartitionFunction NVARCHAR(128)',
                     @CurrentMinDate = @CurrentMinDate,
                     @MergeRangeDate = @MergeRangeDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentLowestPartition = @CurrentMinDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO

GO
CREATE PROCEDURE [Maintenance].[MergePartitions_Month] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @MergeRangeDate DATE,
  @CheckEarliestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentLowestPartition DATE = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[MergePartitions_Month]
  -- Author:      Cedric Dube
  -- Create date: 2021-01-28
  -- Description: Merge partitions for the range provided
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMinDate DATE;
  SELECT @CurrentMinDate = ISNULL(CAST(MIN(value) AS DATE), SYSUTCDATETIME())
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentLowestPartition = @CurrentMinDate;
  IF @CheckEarliestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW DATE IS NOT EARLIER THAN CURRENT MIN DATE --
  IF @CurrentMinDate > @MergeRangeDate BEGIN;
    RETURN;
  END;
  -- GET FIRST OF THE MONTH FOR NEXT PARTITION --
  SET @MergeRangeDate = DATEADD(mm, DATEDIFF(mm, 0, @MergeRangeDate), 0);
  -- ITERATE AND ADD PER DATE UNTIL @MergeRangeDate --
  SET @Command = N'
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() MERGE RANGE(@MergeRangeDate);   
     -- ITERATE --
     SELECT @CurrentMinDate = CAST(MIN(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMinDate DATE, @MergeRangeDate DATE, @PartitionFunction NVARCHAR(128)',
                     @CurrentMinDate = @CurrentMinDate,
                     @MergeRangeDate = @MergeRangeDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentLowestPartition = @CurrentMinDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO

GO
CREATE PROCEDURE [Maintenance].[MergePartitions_Year] (  
  @PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @MergeRangeDate DATE,
  @CheckEarliestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentLowestPartition DATE = NULL OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[MergePartitions_Year]
  -- Author:      Cedric Dube
  -- Create date: 2021-01-28
  -- Description: Merge partitions for the range provided
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- PARTITION VARS. --
  DECLARE @CurrentMinDate DATE;
  SELECT @CurrentMinDate = ISNULL(CAST(MIN(value) AS DATE), SYSUTCDATETIME())
    FROM sys.partition_functions F WITH (NOLOCK)
    LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = @PartitionFunction;
  -- JUST CHECKING, RETURN --
  SET @CurrentLowestPartition = @CurrentMinDate;
  IF @CheckEarliestPartitionOnly = 1 BEGIN;
   RETURN;
  END;
  -- ENSURE THE NEW DATE IS NOT EARLIER THAN CURRENT MIN DATE --
  IF @CurrentMinDate > @MergeRangeDate BEGIN;
    RETURN;
  END;
  -- GET FIRST OF THE YEAR FOR NEXT PARTITION --  
  SET @MergeRangeDate = DATEADD(yy, DATEDIFF(yy, 0, @MergeRangeDate), 0);
  -- ITERATE AND ADD PER DATE UNTIL @MergeRangeDate --
  SET @Command = N'
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION SCHEME ' + @PartitionScheme + ' NEXT USED [' + @NextUsedFileGroup + '];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER PARTITION FUNCTION ' + @PartitionFunction + '() MERGE RANGE(@MergeRangeDate);   
     -- ITERATE --
     SELECT @CurrentMinDate = CAST(MIN(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@CurrentMinDate DATE, @MergeRangeDate DATE, @PartitionFunction NVARCHAR(128)',
                     @CurrentMinDate = @CurrentMinDate,
                     @MergeRangeDate = @MergeRangeDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentLowestPartition = @CurrentMinDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO
GO
CREATE PROCEDURE [Maintenance].[SwitchPartition] (  
  @SourceSchemaName NVARCHAR(128),
  @SourceTableName NVARCHAR(128),
  @TargetSchemaName NVARCHAR(128),
  @TargetTableName NVARCHAR(128),
  @TargetPartitionFunction NVARCHAR(128),
  @PartitionColumn NVARCHAR(128),
  @SourcePartitionNumber INT,
  @TargetPartitionNumber INT,
  @TruncateTarget BIT = 0,
  @LockTimeoutValue INT = 30000,
  @ResultCode TINYINT = 2 OUTPUT, -- 1: Success; 2: Fail
  @ResultDescriptor VARCHAR(1000) = 'Unknown result' OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[SwitchPartition]
  -- Author:      Cedric Dube
  -- Create date: 2021-01-28
  -- Description: Swith partition from @SourceTableName to @TargetTableName
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
  SET @SourceSchemaName = REPLACE(REPLACE(@SourceSchemaName,'[',''),']','');
  SET @SourceTableName = REPLACE(REPLACE(@SourceTableName,'[',''),']','');
  SET @TargetSchemaName = REPLACE(REPLACE(@TargetSchemaName,'[',''),']','');
  SET @TargetTableName = REPLACE(REPLACE(@TargetTableName,'[',''),']','');
  -- Check Source Object --
  IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SourceSchemaName AND TABLE_NAME = @SourceTableName)) BEGIN;
    SET @ResultCode = 2;
    SET @ResultDescriptor = 'Source Object: ' + '[' + @SourceSchemaName + '].[' + @SourceTableName + ']' + ' does not exist. Terminating';
    RETURN
  END;
  -- Check Target Function --
  IF NOT EXISTS (SELECT 1 FROM SYS.Partition_Functions WHERE [Name] = @TargetPartitionFunction) BEGIN;
    SET @ResultCode = 2;
    SET @ResultDescriptor = 'Partition Function: ' + @TargetPartitionFunction + ' does not exist. Terminating';
    RETURN
  END;
  -- Check Target Object --
  IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @TargetSchemaName AND TABLE_NAME = @TargetTableName)) BEGIN;
    SET @ResultCode = 2;
    SET @ResultDescriptor = 'Target Object: ' + '[' + @TargetSchemaName + '].[' + @TargetTableName + ']' + ' does not exist. Terminating';
    RETURN
  END;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000) = N'';
  IF @TruncateTarget = 1 BEGIN;
    SET @Command = @Command + N'
     -- TRUNCATE --
     TRUNCATE TABLE [' + @TargetSchemaName + '].[' + @TargetTableName + '] WITH (PARTITIONS ('+ CAST(@TargetPartitionNumber AS VARCHAR) +'));
  ';
  END;
  SET @Command = @Command + N'
     -- CHECK FOR DATA --
     IF EXISTS (SELECT TOP 1 1 FROM [' + @TargetSchemaName + '].[' + @TargetTableName + '] WHERE $PARTITION.' + @TargetPartitionFunction +'(' + @PartitionColumn + ') = '+ CAST(@TargetPartitionNumber AS VARCHAR) + ') BEGIN;
       SET @ResultCode = 2;
       SET @ResultDescriptor = ''Target Object: [' + @TargetSchemaName + '].[' + @TargetTableName + ']' + ' contains data and cannot be a SWITCH target. Terminating'';
       RETURN;
     END;
     -- SWITCH --
	 SET LOCK_TIMEOUT ' + CAST(@LockTimeoutValue AS VARCHAR) + ';
     ALTER TABLE [' + @SourceSchemaName + '].[' + @SourceTableName + '] SWITCH 
       PARTITION ' + CAST(@SourcePartitionNumber AS VARCHAR) + ' TO [' + @TargetSchemaName + '].[' + @TargetTableName + '] PARTITION ' + CAST(@TargetPartitionNumber AS VARCHAR) + ';
     SET @ResultCode = 1;
     SET @ResultDescriptor = ''Successfully switched: Source Object: ' + '[' + @SourceSchemaName + '].[' + @SourceTableName + ']' + ', Partition:' + CAST(@SourcePartitionNumber AS VARCHAR) + ' to Target Object: ' + '[' + @TargetSchemaName + '].[' + @TargetTableName + ']' + ', Partition:' + CAST(@TargetPartitionNumber AS VARCHAR) + '''';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@ResultCode TINYINT OUTPUT,
                                 @ResultDescriptor VARCHAR(1000) OUTPUT',
					 @ResultCode = @ResultCode OUTPUT,
					 @ResultDescriptor = @ResultDescriptor OUTPUT;

END TRY
BEGIN CATCH
  SET @ResultCode = 2;
  SET @ResultDescriptor = ERROR_MESSAGE();
  THROW;
END CATCH
END;
GO
GO
CREATE PROCEDURE [Maintenance].[GetPartitionNumberFromDATE] (
  @PartitionFunction NVARCHAR(128),
  @Date DATE,
  @PartitionNumber INT OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[GetPartitionNumberFromDate]
  -- Author:      Cedric Dube
  -- Create date: 2021-01-28
  -- Description: Determine partition number from input date
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
  IF NOT EXISTS (SELECT 1 FROM SYS.Partition_Functions WHERE [Name] = @PartitionFunction)
    RETURN;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- COLLECT PARTITION NUMBER --
  SET @Command = N'SET @PartitionNumber = $PARTITION.' + @PartitionFunction + '(' + '''' + CONVERT(VARCHAR, @Date, 121) + '''' + ');';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@PartitionNumber INT OUTPUT',
                     @PartitionNumber = @PartitionNumber OUTPUT;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO
GO
CREATE PROCEDURE [Maintenance].[GetPartitionNumberFromINT] (
  @PartitionFunction NVARCHAR(128),
  @INT INT,
  @PartitionNumber INT OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Name:        [Maintenance].[GetPartitionNumberFromDate]
  -- Author:      Cedric Dube
  -- Create date: 2021-01-28
  -- Description: Determine partition number from input INT
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN;
BEGIN TRY;
  IF NOT EXISTS (SELECT 1 FROM SYS.Partition_Functions WHERE [Name] = @PartitionFunction)
    RETURN;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- COLLECT PARTITION NUMBER --
  SET @Command = N'SET @PartitionNumber = $PARTITION.' + @PartitionFunction + '(' + CAST(@INT AS VARCHAR) + ');';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N'@PartitionNumber INT OUTPUT',
                     @PartitionNumber = @PartitionNumber OUTPUT;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO
/* End of File ********************************************************************************************************************/