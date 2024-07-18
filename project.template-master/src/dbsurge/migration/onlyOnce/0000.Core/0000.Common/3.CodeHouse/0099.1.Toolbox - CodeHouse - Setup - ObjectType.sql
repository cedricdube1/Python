/************************************************************************
* Script     : 99.1.ToolBox - CodeHouse - Setup - ObjectType.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- ObjectType --
DECLARE @ObjectType VARCHAR(50);

SET @ObjectType = 'Call';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Script';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Component';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Schema';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'PartitionFunction';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'PartitionScheme';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Table';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Index';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'TableType';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'DataType';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'View';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Function';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'Procedure';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'SBContract';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'SBMessageType';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'SBQueue';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

SET @ObjectType = 'SBService';
EXEC [CodeHouse].[SetObjectType] @ObjectType = @ObjectType;

GO
-- CHECK --
SELECT * FROM [CodeHouse].[ObjectType];
GO
/* End of File ********************************************************************************************************************/