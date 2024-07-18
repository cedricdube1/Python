/************************************************************************
* Script     : 2.Common - Staging.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
**********************************************************************
* Steps      : 1 > Partitions
*            :   1.1 > PartFunc_{PartitionNamePart}_{Stream}_Date
*            :   1.2 > PartScheme_{PartitionNamePart}_{Stream}_Date
*            : 2 > Tables
*		     :   2.2 > {Stream}_Held
*                2.3 > v{Stream}_HeldSummary
*            : 3 > Procedures
*                2.1 > Extract_{Stream}
************************************************************************/
USE [dbSurge]
GO

-------------------------------------
-- Partitions
-------------------------------------
------------------
-- PartFunc_{PartitionNamePart}_{Stream}_Date
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'PartFunc_{PartitionNamePart}_{Stream}_Date',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'PartitionFunction',
		@CodeType VARCHAR(50) = 'Landing',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Structure for date partitioning. Standardised across all inbound topics.';

SET @CodeObject = 
'CREATE PARTITION FUNCTION [PartFunc_{PartitionNamePart}_{Stream}_Date] ({PartitionFunctionDataType})
  AS RANGE RIGHT FOR VALUES (
    ''{PartitionFunctionLowerPartition}'', 
	''{PartitionFunctionInitialisedPartition}'' --initialised date
  );';

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
-- PartScheme_{PartitionNamePart}_{Stream}_Date
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'PartScheme_{PartitionNamePart}_{Stream}_Date',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'PartitionScheme',
		@CodeType VARCHAR(50) = 'Landing',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;
SET @CodeObjectRemark = 
'Structure for date partitioning. Standardised across all inbound topics.';

SET @CodeObject = 
'CREATE PARTITION SCHEME [PartScheme_{PartitionNamePart}_{Stream}_Date]
  AS PARTITION [PartFunc_{PartitionNamePart}_{Stream}_Date]
  ALL TO ([{FileGroup}]);';

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
-- Tables
-------------------------------------
------------------
-- {Stream}_Held
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = '{Stream}_Held',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Table',
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
'Structure for retaining inbound held entries. Standardised across all process streams.';

SET @CodeObject = 
'CREATE TABLE [{HeldSchema}].[{Stream}_Held] (
  [EventUTCDateTimeStamp] [DATETIME2] NOT NULL,
  [PayloadID]             [BIGINT]    NOT NULL,
  [SourceSystemID]        [INT]       NOT NULL,
  [OriginSystemID]        [INT]       NOT NULL,
  CONSTRAINT [PK_{Stream}_Held]
    PRIMARY KEY CLUSTERED  ([PayloadID] ASC, [SourceSystemID] ASC, [OriginSystemID] ASC)
      WITH (FILLFACTOR = 100),
  [Processed]             [BIT]       NOT NULL
  CONSTRAINT [DF_{Stream}_Held_Processed]
    DEFAULT (0),
  [HeldProcessTaskLogID]  [BIGINT]    NOT NULL,
  [InsertedDate]          [DATETIME2] NOT NULL
  CONSTRAINT [DF_{Stream}_Held_InsertedDate]
    DEFAULT (SYSUTCDATETIME()),
  [ProcessedTaskLogID]    [BIGINT]        NULL,
  [ProcessedDate]         [DATETIME2]     NULL
) ON [{FileGroup}];
GO
-- Index(es) --
CREATE NONCLUSTERED INDEX [NIDX_Processed]
  ON [{HeldSchema}].[{Stream}_Held] ([Processed] ASC, [SourceSystemID] ASC, [OriginSystemID] ASC)
    INCLUDE ([InsertedDate]);';

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
-- v{Stream}_HeldSummary
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'v{Stream}_HeldSummary',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'View',
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
'View for summary data related to held entries. Standardised across all process streams.';

SET @CodeObject = 
'CREATE VIEW [{HeldSchema}].[v{Stream}_HeldSummary]                
  WITH SCHEMABINDING
AS
 SELECT [Processed]
       ,[SourceSystemID]
       ,[OriginSystemID]
       ,[HeldCount]
       ,[EarliestHeldDate]
       ,DATEDIFF(MINUTE, QRY.[EarliestHeldDate], SYSUTCDATETIME()) AS DurationHeldMinute
       ,(RIGHT(''00'' + CONVERT(VARCHAR,(DATEDIFF(SECOND, QRY.[EarliestHeldDate], SYSUTCDATETIME()) / (60*60))),2)
                 + '':'' +
                 RIGHT(''00'' + CONVERT(VARCHAR,((DATEDIFF(SECOND, QRY.[EarliestHeldDate], SYSUTCDATETIME()) % (60*60)) / (60))),2)
                 + '':'' +
                 RIGHT(''00'' + CONVERT(VARCHAR,((DATEDIFF(SECOND, QRY.[EarliestHeldDate], SYSUTCDATETIME()) % (60*60)%(60)))),2)
                 + ''.'' +
                 RIGHT(''00'' + CONVERT(VARCHAR,((DATEDIFF(SECOND, QRY.[EarliestHeldDate], SYSUTCDATETIME()) % (60*60)%(60)))),3)
         ) AS [DurationHeld]
   FROM ( SELECT [Processed]
                ,[SourceSystemID]
                ,[OriginSystemID]
                ,COUNT(1) AS HeldCount
                ,MIN([InsertedDate]) AS EarliestHeldDate
   FROM [{Schema}].[{Stream}_Held] 
  GROUP BY [Processed], [SourceSystemID], [OriginSystemID] ) QRY;';

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
-- Extract_{Stream}
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Extract_{Stream}',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
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
'Extract stream using CDO from Source.';

SET @CodeObjectHeader = 
'@ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @pCE_MinID BIGINT = NULL,
  @pBE_MinID BIGINT = NULL,
  @pBE_MaxID BIGINT = NULL,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT,
  @ExtractLogID BIGINT OUTPUT,
  @ExtractType CHAR(3) OUTPUT,
  @ExtractLogType VARCHAR(4) OUTPUT,
  @ChangeDetected BIT OUTPUT';

SET @CodeObjectExecutionOptions =
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'{<ExtractTaskStatement>}';
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