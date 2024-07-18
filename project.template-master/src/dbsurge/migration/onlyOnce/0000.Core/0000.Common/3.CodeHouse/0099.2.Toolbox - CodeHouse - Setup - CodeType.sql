/************************************************************************
* Script     : 99.1.ToolBox - CodeHouse - Setup - CodeType.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- CodeType --
DECLARE @CodeType VARCHAR(50);

SET @CodeType = 'Any';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Component';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Framework';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Lookup';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Security';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Landing';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Process';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Task';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Job';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Config';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'Queue';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;

SET @CodeType = 'DirectExecute';
EXEC [CodeHouse].[SetCodeType] @CodeType = @CodeType;
-- CHECK --
SELECT * FROM [CodeHouse].[CodeType];
GO
/* End of File ********************************************************************************************************************/