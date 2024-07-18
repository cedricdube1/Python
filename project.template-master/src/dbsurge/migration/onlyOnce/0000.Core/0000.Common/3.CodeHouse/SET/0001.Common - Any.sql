/************************************************************************
* Script     : 1.Common - Any.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps      : 1 > Schema
*            : 2 > AppendPartition_Date
*            : 5 > Calling Scripts
*            :   5.1 > GetDeployment_Schema
*            :   5.2 > GetDeployment_Maintain_PartitionByDate
*            : 6 > Setup_LoopJob
*            : 7 > Maintenance
*            :   7.1  > AppendPartitions_Date
*            :   7.2  > AppendPartitions_Month
*            :   7.3  > AppendPartitions_Year
*            :   7.4  > AppendPartitions_SourceSystem
*            :   7.5  > MergePartitions_Date
*            :   7.6  > MergePartitions_Month
*            :   7.7  > MergePartitions_Year
*            :   7.8  > SwitchPartition
*            :   7.9  > GetPartitionNumberFromDATE
*            :   7.10 > GetPartitionNumberFromINT
*            :   7.11 > Process_Partitions_Date_{ProcedureNamePart}
*            :   7.12 > Setup_Maintain_PartitionByDate
************************************************************************/
USE [dbSurge]
GO

-------------------------------------
-- Schema
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = '{Schema}',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Schema',
		@CodeType VARCHAR(50) = 'Security',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Security Schema.';

SET @CodeObject = 
'CREATE SCHEMA [{Schema}]
  AUTHORIZATION [{Authorization}];';

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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- AppendPartition_Date
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'AppendPartition_Date',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Script',
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
'Append Date partition.';

SET @CodeObject = 
'EXEC [{Schema}].[{JobProcedure}];';

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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- Calls
-------------------------------------
------------------
-- GetDeployment_Schema
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'GetDeployment_Schema',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Call',
		@CodeType VARCHAR(50) = 'Security',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Generic call to GetDeployment which will generate deployment scripts.';

SET @CodeObject = 
'BEGIN TRY;
  -- Validate tags --
  DECLARE @StreamTag VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = ''{Stream}'');
  IF @StreamTag IS NULL
    THROW 50000, ''{Stream} Tag and Value must be provided. Terminating Procedure.'', 1;
  DECLARE @StreamVariantTag VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = ''{StreamVariant}'');
  IF @StreamVariantTag IS NULL
    THROW 50000, ''{StreamVariant} Tag and Value must be provided. Terminating Procedure.'', 1;

  -- Check for Existence --
  IF @DeploymentSet IS NOT NULL BEGIN;
    EXEC [CodeHouse].[GenerateDeployment_Output] @DeploymentSet = @DeploymentSet,
                                                 @ReturnDropScript = @ReturnDropScript,
                                                 @ReturnObjectScript = @ReturnObjectScript,
                                                 @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript;
  END; ELSE BEGIN;
    -- List of CodeObjects --
    DECLARE @GenerateList [CodeHouse].[GenerateCodeObjectList];
    INSERT INTO @GenerateList (
      [Ordinal],
      [Stream],
      [StreamVariant],
      [ObjectType],
      [CodeType],
      [CodeObjectName],
	  [ObjectLayer]
     ) VALUES (1, ''Any'', ''Any'', ''Schema'', ''Security'', ''{Schema}'', ''Any'');
    
    -- Components to use --
    DECLARE @ReplacementComponents [CodeHouse].[ReplacementComponent];
    -- Create/output deployment --
    EXEC [CodeHouse].[GenerateDeployment] @DeploymentName = @DeploymentName,
                                          @DeploymentNotes = @DeploymentNotes,
                                          @DeploymentSet = @DeploymentSet OUTPUT,
                                          @Layer = @Layer,
                                          @ReturnDropScript = @ReturnDropScript,
                                          @ReturnObjectScript = @ReturnObjectScript,
                                          @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript,
                                          @GenerateList = @GenerateList,
                                          @ReplacementTags = @ReplacementTags,
                                          @ReplacementComponents = @ReplacementComponents;
  END;
END TRY
BEGIN CATCH
  THROW
END CATCH;';

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
------------------
-- GetDeployment_Maintain_PartitionByDate
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'GetDeployment_Maintain_PartitionByDate',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Call',
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
'Generic call to GetDeployment which will generate deployment scripts.';

SET @CodeObject = 
'BEGIN TRY;
  -- Validate tags --
  DECLARE @StreamTag VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = ''{Stream}'');
  IF @StreamTag IS NULL
    THROW 50000, ''{Stream} Tag and Value must be provided. Terminating Procedure.'', 1;
  DECLARE @StreamVariantTag VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = ''{StreamVariant}'');
  IF @StreamVariantTag IS NULL
    THROW 50000, ''{StreamVariant} Tag and Value must be provided. Terminating Procedure.'', 1;

  -- Check for Existence --
  IF @DeploymentSet IS NOT NULL BEGIN;
    EXEC [CodeHouse].[GenerateDeployment_Output] @DeploymentSet = @DeploymentSet,
                                                 @ReturnDropScript = @ReturnDropScript,
                                                 @ReturnObjectScript = @ReturnObjectScript,
                                                 @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript;
  END; ELSE BEGIN;
    -- List of CodeObjects --
    DECLARE @GenerateList [CodeHouse].[GenerateCodeObjectList];
    INSERT INTO @GenerateList (
      [Ordinal],
      [Stream],
      [StreamVariant],
      [ObjectType],
      [CodeType],
      [CodeObjectName],
	  [ObjectLayer]
     ) VALUES (1, ''Any'', ''Any'', ''Procedure'', ''Process'', ''Process_Partitions_Date_{ProcedureNamePart}'', ''Any''),
              (2, ''Any'', ''Any'', ''Script'',    ''Process'', ''Setup_Maintain_PartitionByDate'', ''Any''),
              (3, ''Any'', ''Any'', ''Script'',    ''Job'', ''Setup_LoopJob'', ''Any''),
              (4, ''Any'', ''Any'', ''Script'',    ''Process'', ''AppendPartition_Date'', ''Any'');
    
    -- Components to use --
    DECLARE @ReplacementComponents [CodeHouse].[ReplacementComponent];
    -- Create/output deployment --
    EXEC [CodeHouse].[GenerateDeployment] @DeploymentName = @DeploymentName,
                                          @DeploymentNotes = @DeploymentNotes,
                                          @DeploymentSet = @DeploymentSet OUTPUT,
                                          @Layer = @Layer,
                                          @ReturnDropScript = @ReturnDropScript,
                                          @ReturnObjectScript = @ReturnObjectScript,
                                          @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript,
                                          @GenerateList = @GenerateList,
                                          @ReplacementTags = @ReplacementTags,
                                          @ReplacementComponents = @ReplacementComponents;
  END;
END TRY
BEGIN CATCH
  THROW
END CATCH;';

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
-- SETUP
-------------------------------------
------------------
-- Setup_LoopJob
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'Setup_LoopJob',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Script',
		@CodeType VARCHAR(50) = 'Job',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Script to populate Job config and generate job deployment.';

SET @CodeObject = 
'DECLARE @ProcessName VARCHAR(150) = ''{ProcessNamePrefix}|{ProcessNamePart}'';
DECLARE @ProcessID INT = [Config].[GetProcessIDByName] (@ProcessName);
IF (@ProcessID IS NULL OR @ProcessID = -1)
  THROW 50000, ''No ProcessID Located for Job Process. Terminating setup.'', 1;
DECLARE @ProcessJobSchema NVARCHAR(128) = N''{Schema}'';
DECLARE @ProcessJobProcedure NVARCHAR(128) = N''{JobProcedure}'';
DECLARE @JobNameClass VARCHAR(30) = ''{JobNameClass}'';
DECLARE @JobCategoryClass VARCHAR(30) = ''{JobCategoryClass}'';
DECLARE @JobOwnerOverride NVARCHAR(128) = ''{JobOwner}'';
DECLARE @JobCategoryOverride NVARCHAR(128) = ''{JobCategory}'';
DECLARE @IsLoopJob BIT = 1;
DECLARE @IsControllerJob BIT = 0;
DECLARE @EnableJobLog BIT = 1;
DECLARE @WaitTime VARCHAR(9) = ''{WaitTime}'';
DECLARE @CheckServiceBroker BIT = 0;
DECLARE @DeleteExisting BIT = 0;

DECLARE @Environment CHAR(3) = CASE WHEN @@SERVERNAME IN (''CPTDEVDB02'',''CPTDEVDB10'') THEN ''DEV''
                                         WHEN @@SERVERNAME IN (''ANALYSIS01'',''CPTAOLSTN10'',''CPTAODB10A'',''CPTAODB10B'') THEN ''PRD''
                                    ELSE ''DEV'' END;
-- Add a Process job --
EXEC [Config].[SetJob_StandardProcess] @ProcessName = @ProcessName,
                                       @Environment = @Environment,
                                       @JobNameClass = @JobNameClass, 
                                       @JobCategoryClass = @JobCategoryClass,
                                       @JobCategoryOverride = @JobCategoryOverride,
                                       @JobOwnerOverride = @JobOwnerOverride,
                                       @ProcessJobSchema = @ProcessJobSchema,
                                       @ProcessJobProcedure = @ProcessJobProcedure,
                                       @IsLoopJob = @IsLoopJob,
                                       @EnableJobLog = @EnableJobLog,
                                       @CheckServiceBroker = @CheckServiceBroker,
                                       @DeleteExisting = @DeleteExisting,
                                       @WaitTime = @WaitTime;';

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
-- MAINTENANCE
-------------------------------------
------------------
-- AppendPartitions_Date
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'AppendPartitions_Date',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxDate DATE,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition DATE = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
    WHILE(@CurrentMaxDate < @NewMaxDate) BEGIN;
     SELECT @NextDate = DATEADD(DAY, 1, @CurrentMaxDate);
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() SPLIT RANGE(@NextDate);   
     -- ITERATE --
     SELECT @CurrentMaxDate = CAST(MAX(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;
    END;'';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMaxDate DATE, @NewMaxDate DATE, @NextDate DATE, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMaxDate = @CurrentMaxDate,
                     @NewMaxDate = @NewMaxDate,
                     @NextDate = @NextDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- AppendPartitions_Month
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'AppendPartitions_Month',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxDate DATE,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition DATE = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
    WHILE(@CurrentMaxDate < @NewMaxDate) BEGIN;
     SELECT @NextDate = DATEADD(MONTH, 1, @CurrentMaxDate);
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() SPLIT RANGE(@NextDate);   
     -- ITERATE --
     SELECT @CurrentMaxDate = CAST(MAX(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;
    END;'';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMaxDate DATE, @NewMaxDate DATE, @NextDate DATE, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMaxDate = @CurrentMaxDate,
                     @NewMaxDate = @NewMaxDate,
                     @NextDate = @NextDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- AppendPartitions_Year
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'AppendPartitions_Year',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxDate DATE,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition DATE = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
    WHILE(@CurrentMaxDate < @NewMaxDate) BEGIN;
     SELECT @NextDate = DATEADD(YEAR, 1, @CurrentMaxDate);
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() SPLIT RANGE(@NextDate);   
     -- ITERATE --
     SELECT @CurrentMaxDate = CAST(MAX(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;
    END;'';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMaxDate DATE, @NewMaxDate DATE, @NextDate DATE, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMaxDate = @CurrentMaxDate,
                     @NewMaxDate = @NewMaxDate,
                     @NextDate = @NextDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- AppendPartitions_SourceSystem
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'AppendPartitions_SourceSystem',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @NewMaxSourceSystem INT,
  @CheckLatestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentHighestPartition INT = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
     SELECT @NextSourceSystem = @CurrentMaxSourceSystem + 1;
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() SPLIT RANGE(@NextSourceSystem);   
     -- ITERATE --
     SELECT @CurrentMaxSourceSystem = CAST(MAX(value) AS INT)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;'';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMaxSourceSystem INT, @NewMaxSourceSystem INT, @NextSourceSystem INT, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMaxSourceSystem = @CurrentMaxSourceSystem,
                     @NewMaxSourceSystem = @NewMaxSourceSystem,
                     @NextSourceSystem = @NextSourceSystem,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentHighestPartition = @CurrentMaxSourceSystem;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- MergePartitions_Date
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'MergePartitions_Date',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @MergeRangeDate DATE,
  @CheckEarliestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentLowestPartition DATE = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() MERGE RANGE(@MergeRangeDate);   
     -- ITERATE --
     SELECT @CurrentMinDate = CAST(MIN(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;'';
  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMinDate DATE, @MergeRangeDate DATE, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMinDate = @CurrentMinDate,
                     @MergeRangeDate = @MergeRangeDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentLowestPartition = @CurrentMinDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- MergePartitions_Month
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'MergePartitions_Month',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @MergeRangeDate DATE,
  @CheckEarliestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentLowestPartition DATE = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() MERGE RANGE(@MergeRangeDate);   
     -- ITERATE --
     SELECT @CurrentMinDate = CAST(MIN(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;'';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMinDate DATE, @MergeRangeDate DATE, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMinDate = @CurrentMinDate,
                     @MergeRangeDate = @MergeRangeDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentLowestPartition = @CurrentMinDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- MergePartitions_Year
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'MergePartitions_Year',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @PartitionScheme NVARCHAR(128),
  @NextUsedFileGroup NVARCHAR(128),
  @MergeRangeDate DATE,
  @CheckEarliestPartitionOnly BIT = 0,
  @LockTimeoutValue INT = 30000,
  @CurrentLowestPartition DATE = NULL OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
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
  SET @Command = N''
     -- ALTER SCHEME FOR NEXT USED FILEGROUP --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION SCHEME '' + @PartitionScheme + '' NEXT USED ['' + @NextUsedFileGroup + ''];
     -- ALTER PARTITION FUNCTION - SPLIT LAST PARTITION TO NEXT --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER PARTITION FUNCTION '' + @PartitionFunction + ''() MERGE RANGE(@MergeRangeDate);   
     -- ITERATE --
     SELECT @CurrentMinDate = CAST(MIN(value) AS DATE)
      FROM sys.partition_functions F WITH (NOLOCK)
      LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
        ON R.function_id = F.function_id
     WHERE F.[Name] = @PartitionFunction;'';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@CurrentMinDate DATE, @MergeRangeDate DATE, @PartitionFunction NVARCHAR(128)'',
                     @CurrentMinDate = @CurrentMinDate,
                     @MergeRangeDate = @MergeRangeDate,
                     @PartitionFunction = @PartitionFunction;
  SET @CurrentLowestPartition = @CurrentMinDate;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- SwitchPartition
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'SwitchPartition',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@SourceSchemaName NVARCHAR(128),
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
  @ResultDescriptor VARCHAR(1000) = ''Unknown result'' OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  SET @SourceSchemaName = REPLACE(REPLACE(@SourceSchemaName,''['',''''),'']'','''');
  SET @SourceTableName = REPLACE(REPLACE(@SourceTableName,''['',''''),'']'','''');
  SET @TargetSchemaName = REPLACE(REPLACE(@TargetSchemaName,''['',''''),'']'','''');
  SET @TargetTableName = REPLACE(REPLACE(@TargetTableName,''['',''''),'']'','''');
  -- Check Source Object --
  IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SourceSchemaName AND TABLE_NAME = @SourceTableName)) BEGIN;
    SET @ResultCode = 2;
    SET @ResultDescriptor = ''Source Object: '' + ''['' + @SourceSchemaName + ''].['' + @SourceTableName + '']'' + '' does not exist. Terminating'';
    RETURN
  END;
  -- Check Target Function --
  IF NOT EXISTS (SELECT 1 FROM SYS.Partition_Functions WHERE [Name] = @TargetPartitionFunction) BEGIN;
    SET @ResultCode = 2;
    SET @ResultDescriptor = ''Partition Function: '' + @TargetPartitionFunction + '' does not exist. Terminating'';
    RETURN
  END;
  -- Check Target Object --
  IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @TargetSchemaName AND TABLE_NAME = @TargetTableName)) BEGIN;
    SET @ResultCode = 2;
    SET @ResultDescriptor = ''Target Object: '' + ''['' + @TargetSchemaName + ''].['' + @TargetTableName + '']'' + '' does not exist. Terminating'';
    RETURN
  END;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000) = N'''';
  IF @TruncateTarget = 1 BEGIN;
    SET @Command = @Command + N''
     -- TRUNCATE --
     TRUNCATE TABLE ['' + @TargetSchemaName + ''].['' + @TargetTableName + ''] WITH (PARTITIONS (''+ CAST(@TargetPartitionNumber AS VARCHAR) +''));
  '';
  END;
  SET @Command = @Command + N''
     -- CHECK FOR DATA --
     IF EXISTS (SELECT TOP 1 1 FROM ['' + @TargetSchemaName + ''].['' + @TargetTableName + ''] WHERE $PARTITION.'' + @TargetPartitionFunction +''('' + @PartitionColumn + '') = ''+ CAST(@TargetPartitionNumber AS VARCHAR) + '') BEGIN;
       SET @ResultCode = 2;
       SET @ResultDescriptor = ''''Target Object: ['' + @TargetSchemaName + ''].['' + @TargetTableName + '']'' + '' contains data and cannot be a SWITCH target. Terminating'''';
       RETURN;
     END;
     -- SWITCH --
	 SET LOCK_TIMEOUT '' + CAST(@LockTimeoutValue AS VARCHAR) + '';
     ALTER TABLE ['' + @SourceSchemaName + ''].['' + @SourceTableName + ''] SWITCH 
       PARTITION '' + CAST(@SourcePartitionNumber AS VARCHAR) + '' TO ['' + @TargetSchemaName + ''].['' + @TargetTableName + ''] PARTITION '' + CAST(@TargetPartitionNumber AS VARCHAR) + '';
     SET @ResultCode = 1;
     SET @ResultDescriptor = ''''Successfully switched: Source Object: '' + ''['' + @SourceSchemaName + ''].['' + @SourceTableName + '']'' + '', Partition:'' + CAST(@SourcePartitionNumber AS VARCHAR) + '' to Target Object: '' + ''['' + @TargetSchemaName + ''].['' + @TargetTableName + '']'' + '', Partition:'' + CAST(@TargetPartitionNumber AS VARCHAR) + '''''''';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@ResultCode TINYINT OUTPUT,
                                 @ResultDescriptor VARCHAR(1000) OUTPUT'',
					 @ResultCode = @ResultCode OUTPUT,
					 @ResultDescriptor = @ResultDescriptor OUTPUT;

END TRY
BEGIN CATCH
  SET @ResultCode = 2;
  SET @ResultDescriptor = ERROR_MESSAGE();
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- GetPartitionNumberFromDATE
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'GetPartitionNumberFromDATE',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @Date DATE,
  @PartitionNumber INT OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  IF NOT EXISTS (SELECT 1 FROM SYS.Partition_Functions WHERE [Name] = @PartitionFunction)
    RETURN;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- COLLECT PARTITION NUMBER --
  SET @Command = N''SET @PartitionNumber = $PARTITION.'' + @PartitionFunction + ''('' + '''''''' + CONVERT(VARCHAR, @Date, 121) + '''''''' + '');'';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@PartitionNumber INT OUTPUT'',
                     @PartitionNumber = @PartitionNumber OUTPUT;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- GetPartitionNumberFromINT
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'GetPartitionNumberFromINT',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Framework',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Maintain partitions.';

SET @CodeObjectHeader =
'@PartitionFunction NVARCHAR(128),
  @INT INT,
  @PartitionNumber INT OUTPUT';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'BEGIN;
BEGIN TRY;
  IF NOT EXISTS (SELECT 1 FROM SYS.Partition_Functions WHERE [Name] = @PartitionFunction)
    RETURN;
 -- WILL EXECUTE DYNAMICALLY --
  DECLARE @Command NVARCHAR(4000);
  -- COLLECT PARTITION NUMBER --
  SET @Command = N''SET @PartitionNumber = $PARTITION.'' + @PartitionFunction + ''('' + CAST(@INT AS VARCHAR) + '');'';

  EXEC sp_ExecuteSQL @Query = @Command,
                     @Params = N''@PartitionNumber INT OUTPUT'',
                     @PartitionNumber = @PartitionNumber OUTPUT;
END TRY
BEGIN CATCH
  THROW;
END CATCH
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- Process_Partitions_Date_{ProcedureNamePart}
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'Process_Partitions_Date_{ProcedureNamePart}',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
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
'Maintain partitions.';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;';

SET @CodeObject = 
'BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- CONFIG VARS.
  -------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @SchemaName NVARCHAR(128) = ''{ProcedureNamePart}'';
  DECLARE @TargetSchemaName NVARCHAR(128) = ''Archive'';
  DECLARE @PartitionFunctionGroup VARCHAR(30) = ''Date'';
  DECLARE @ProcessName VARCHAR(150) = ''Maintenance|PartitionByDate|'' + @SchemaName,
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
    SET @InfoMessage = ''No ProcessLogID was returned from [Logging].[LogProcessStart]. Procedure '' + @ProcedureName + '' terminated.'';
    THROW 50000, @InfoMessage, 0;
   END;
  -------------------------------------------------------------------------------------------------
  -- PROCESS
  -------------------------------------------------------------------------------------------------
  ------------------------
  -- TEMP. TABLES -- 
  ------------------------
  IF OBJECT_ID(''TempDB..#Partitions'') IS NOT NULL 
    DROP TABLE #Partitions;
  CREATE TABLE #Partitions(
    [PartitionID] INT IDENTITY(1,1) NOT NULL,
    INDEX [CIDX] CLUSTERED ([PartitionID] ASC) WITH (FILLFACTOR = 100),
    [SchemaName] NVARCHAR(128) NOT NULL,
    [TableName] NVARCHAR(128) NOT NULL,
    [PrimarykeyName] NVARCHAR(128) NOT NULL,
    [PartitionScheme] NVARCHAR(128) NOT NULL,
    INDEX [IDX1] NONCLUSTERED ([PartitionScheme] ASC) WITH (FILLFACTOR = 100),
    [PartitionFileGroup] NVARCHAR(128) NOT NULL,
    [PartitionFunctionGroup] VARCHAR(30) NOT NULL,
    [PartitionFunctionRangeDirection] VARCHAR(10) NOT NULL,
    [PartitionFunction] NVARCHAR(128) NOT NULL,
	[PartitionColumn] NVARCHAR(128) NOT NULL,
	[PartitionColumnDataType] NVARCHAR(128) NOT NULL,
    [LowestPartitionValue] DATE NOT NULL,
    [HighestPartitionValue] DATE NOT NULL,
    [LowestPartitionNumber] INT NOT NULL,
    [HighestPartitionNumber] INT NOT NULL
  );
  ------------------------
  -- SPLIT -- 
  ------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Maintenance].[Split_SchemaPartitions_Date] @ProcessID = @ProcessID,
                                                   @ProcessLogID = @ProcessLogID,
                                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                   @SchemaName = @SchemaName,
                                                   @TargetSchemaName = @TargetSchemaName,
                                                   @PartitionFunctionGroup = @PartitionFunctionGroup,
                                                   @TaskID = @TaskID OUTPUT,
                                                   @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;
  ------------------------
  -- SWITCH -- 
  ------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Maintenance].[Switch_SchemaPartitions_Date] @ProcessID = @ProcessID,
                                                    @ProcessLogID = @ProcessLogID,
                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                    @SchemaName = @SchemaName,
                                                    @TargetSchemaName = @TargetSchemaName,
                                                    @PartitionFunctionGroup = @PartitionFunctionGroup,
                                                    @TaskID = @TaskID OUTPUT,
                                                    @ProcessTaskLogID = @ProcessTaskLogID OUTPUT; 
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  Finalize:
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;      
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
                            @TaskID = @TaskID,
                            @ProcessLogID = @ProcessLogID,
                            @ProcessTaskLogID = @ProcessTaskLogID, 
                            @ErrorNumber = @ErrorNumber,
                            @ErrorProcedure = @ErrorProcedure,
                            @ErrorLine= @ErrorLine,
                            @ErrorMessage = @ErrorMessage;
  THROW;
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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- Setup_Maintain_PartitionByDate
------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'Setup_Maintain_PartitionByDate',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Script',
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
'Maintain partitions.';

SET @CodeObjectExecutionOptions = 
'SET NOCOUNT ON;';

SET @CodeObject = 
'DECLARE @ProcessID SMALLINT;
DECLARE @TaskID SMALLINT;
DECLARE @ProcessTaskID INT;
DECLARE @ExtractTypeID SMALLINT;
DECLARE @ExtractSourceID INT;
DECLARE @TopicName VARCHAR(50) = ''Maintenance'';
DECLARE @MaintenanceFunction VARCHAR(50) = ''PartitionByDate'';
DECLARE @Processname_Suffix VARCHAR(50) = ''{ProcessNamePart}'' -- Optional Suffix
DECLARE @ProcessName NVARCHAR(128) = @TopicName + ''|'' + @MaintenanceFunction + CASE WHEN @Processname_Suffix IS NOT NULL THEN ''|'' + @Processname_Suffix  ELSE '''' END;

/***********************************************************************************************************************************
-- Process --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = @ProcessName) BEGIN;
  INSERT INTO [Config].[Process] ([ProcessName], [ProcessDescription], [IsEnabled]) VALUES(@ProcessName, ''Maintain Date partitions for {ProcessNamePart} storage'', 1);
END;
  SET @ProcessID = [Config].[GetProcessIDByName](@ProcessName);

/***********************************************************************************************************************************
-- Process Task --
***********************************************************************************************************************************/
-- SELECT * FROM [Config].[Task];
SET @TaskID = [Config].[GetTaskIDByName] (''PartitionSplit'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
SET @TaskID = [Config].[GetTaskIDByName] (''PartitionMerge'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 0);
END;
SET @TaskID = [Config].[GetTaskIDByName] (''PartitionSwitch'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 0);
END;

/***********************************************************************************************************************************
-- Task Config --
***********************************************************************************************************************************/
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''PartitionSplit'');
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Maintenance'',
                                          @ConfigName = ''LockTimeout'',
                                          @ConfigValue = 30000,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Maintenance'',
                                          @ConfigName = ''PartitionIncreaseCount'',
                                          @ConfigValue = 3,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''InfoDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''CaptureDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''PartitionMerge'');
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Maintenance'',
                                          @ConfigName = ''LockTimeout'',
                                          @ConfigValue = 30000,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''InfoDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''CaptureDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''PartitionSwitch'');
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Maintenance'',
                                          @ConfigName = ''LockTimeout'',
                                          @ConfigValue = 30000,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Maintenance'',
                                          @ConfigName = ''PartitionRetainCount'',
                                          @ConfigValue = 7,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Maintenance'',
                                          @ConfigName = ''TruncateTarget'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''InfoDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''CaptureDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;';

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
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;

SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
/* End of File ********************************************************************************************************************/