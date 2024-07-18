/************************************************************************
* Script     : 99.1.ToolBox - CodeHouse - Setup - StreamVariant.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- StreamVariant --
DECLARE @StreamVariant VARCHAR(50);

SET @StreamVariant = 'Any';
EXEC [CodeHouse].[SetStreamVariant] @StreamVariant = @StreamVariant;

SET @StreamVariant = 'Surge';
EXEC [CodeHouse].[SetStreamVariant] @StreamVariant = @StreamVariant;


-- CHECK --
SELECT * FROM [CodeHouse].[StreamVariant];
GO
/* End of File ********************************************************************************************************************/