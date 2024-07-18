/************************************************************************
* Script     : 99.1.ToolBox - CodeHouse - Setup - Layer.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Layer --
DECLARE @Layer VARCHAR(50), @DatabaseName NVARCHAR(128);

SET @Layer = 'Any'; SET @DatabaseName = '{Database}';
EXEC [CodeHouse].[SetLayer] @Layer = @Layer, @DatabaseName = @DatabaseName;

SET @Layer = 'Staging'; SET @DatabaseName = 'dbSurge';
EXEC [CodeHouse].[SetLayer] @Layer = @Layer, @DatabaseName = @DatabaseName;

SET @Layer = 'Business'; SET @DatabaseName = 'dbSurge';
EXEC [CodeHouse].[SetLayer] @Layer = @Layer, @DatabaseName = @DatabaseName;

SET @Layer = 'Toolbox'; SET @DatabaseName = 'dbSurge';
EXEC [CodeHouse].[SetLayer] @Layer = @Layer, @DatabaseName = @DatabaseName;

-- CHECK --
SELECT * FROM [CodeHouse].[Layer];
GO
/* End of File ********************************************************************************************************************/