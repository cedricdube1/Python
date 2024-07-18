/************************************************************************
* Script     : 99.1.ToolBox - CodeHouse - Setup - Tag.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Tag --
DECLARE @Tag VARCHAR(50),
        @Description VARCHAR(150);

SET @Tag = 'Schema'; SET @Description = 'Placeholder for Schema value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ExtractSchema'; SET @Description = 'Placeholder for Extract Schema value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'HeldSchema'; SET @Description = 'Placeholder for Held Schema value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'Stream'; SET @Description = 'Placeholder for Stream value. e.g. Adjustment';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'HubStream'; SET @Description = 'Placeholder for HubStream value. e.g. Player as the hub for PlayerBalance';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'StreamVariant'; SET @Description = 'Placeholder for StreamVariant value. e.g. SURGE_MIT';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'Layer'; SET @Description = 'Placeholder for Layer value. e.g. Source';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'Database'; SET @Description = 'Placeholder for Database value. e.g. dbSurge';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'FileGroup'; SET @Description = 'Placeholder for FileGroup value. e.g. FG_DATA_01';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'Authorization'; SET @Description = 'Placeholder for Authorization value. e.g. AUTHORIZATION [dbo]';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ProcessNamePart'; SET @Description = 'Placeholder for component of ProcessName that is not the Stream value. e.g. Adjustment|ProcessNamePart';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'ProcessNamePrefix'; SET @Description = 'Placeholder for prefix component of ProcessName that is not the Stream value. e.g. ProcessNamePrefix|ProcessNamePart';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'JobProcessName'; SET @Description = 'Placeholder for full ProcessName e.g. Adjustment|Pala_US_NJ';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'PartitionNamePart'; SET @Description = 'Placeholder for component of PartitionScheme/Function that is not the Scheme/Function or Stream value. e.g. PartScheme_{PartitionNamePart}_{Stream}_Date';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'PartitionFunctionDataType'; SET @Description = 'Placeholder for component of PartitionFunction that indicates the datatype e.g. DATETIME2';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'PartitionFunctionLowerPartition'; SET @Description = 'Placeholder for component of PartitionFunction that indicates the lowest value of partitioning e.g. ''1900-01-01 00:00:00''';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'PartitionFunctionInitialisedPartition'; SET @Description = 'Placeholder for component of PartitionFunction that indicates the initialised value of partitioning e.g. ''2020-12-15 00:00:00''';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'TableObject'; SET @Description = 'Placeholder for table object e.g. Table Name/Indexed View Name.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'TableObjectType'; SET @Description = 'Placeholder for table object type e.g. Table/View.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'StageTableNamepart'; SET @Description = 'Placeholder for part of staging table name e.g. #Stage_{StageTableNamePart}.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ExtractTableNamepart'; SET @Description = 'Placeholder for part of extract table name e.g. #Extract_{StageTableNamePart}.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ProcedureNamePart'; SET @Description = 'Placeholder for part of stored procedure name e.g. RaiseEvent_{ProcedureNamePart}.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ExtractDatabase'; SET @Description = 'Placeholder for Extract Database value. e.g. dbSurge';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ExtractTableName'; SET @Description = 'Placeholder for extract table name e.g. {Schema}.{ExtractTableName}.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'CodeObjectName'; SET @Description = 'Placeholder for code object name e.g. Deployment_Pala_Source_Landing.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'ProviderCallerName'; SET @Description = 'Placeholder for Provider callername e.g. ''Surge''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'ProviderExternalSystemID'; SET @Description = 'Placeholder for Provider external system id e.g. ''Default''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'MasterProviderExternalSystemID'; SET @Description = 'Placeholder for Master Provider external system id e.g. ''Default''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'CountryCode'; SET @Description = 'Placeholder for Country Code e.g. ''US''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'StateCode'; SET @Description = 'Placeholder for Country Code e.g. ''NJ''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'WaitTime'; SET @Description = 'Placeholder for wait time for jobs e.g. ''00:30:00''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'JobProcedure'; SET @Description = 'Placeholder for procedure for jobs e.g. ''Process_Adjustment''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'JobNameClass'; SET @Description = 'Placeholder for name class for jobs e.g. ''Process''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
SET @Tag = 'JobCategoryClass'; SET @Description = 'Placeholder for category class for jobs e.g. ''Process''.';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'SourceSystemID'; SET @Description = 'Placeholder for SourceSystemID value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'DeploymentSet'; SET @Description = 'Placeholder for DeploymentSet value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'DeploymentGroup'; SET @Description = 'Placeholder for DeploymentGroup value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'Deployment'; SET @Description = 'Placeholder for Deployment code value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'CDOTrackedColumn'; SET @Description = 'Placeholder for TrackedColumn value for CDO processing';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'JobCategory'; SET @Description = 'Placeholder for SQL Server Agent job category value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;

SET @Tag = 'JobOwner'; SET @Description = 'Placeholder for SQL Server Agent job owner value';
EXEC [CodeHouse].[SetTag] @Tag = @Tag, @Description = @Description;
-- CHECK --
SELECT * FROM [CodeHouse].[Tag];
GO
/* End of File ********************************************************************************************************************/