/***********************************************************************************************************************************
* Script      : 9.Common - Extended Properties.sql                                                                                *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-20                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- Functions --
GO
CREATE FUNCTION [Helper].[ExtendedProperty_Check] (
  @PropertyName NVARCHAR(128),
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name NVARCHAR(128),
  @Level1_Type VARCHAR(128) = NULL,
  @Level1_Name NVARCHAR(128) = NULL,
  @Level2_Type VARCHAR(128) = NULL,
  @Level2_Name NVARCHAR(128) = NULL
) RETURNS BIT
BEGIN;
  DECLARE @Exists BIT = 0;
  IF EXISTS (SELECT 1 FROM fn_listextendedproperty(@PropertyName, @Level0_Type, @Level0_Name, @Level1_Type, @Level1_Name, @Level2_Type, @Level2_Name))
    SET @Exists = 1;
  -- Default / Return --
  RETURN @Exists;
END;
GO
GO
CREATE FUNCTION [Helper].[ExtendedProperty_Validate_Level0_Type] (
  @Type VARCHAR(128)
) RETURNS BIT
AS   
BEGIN
  DECLARE @IsValid BIT = 1;
  IF @Type NOT IN (
   'ASSEMBLY',
   'CONTRACT',
   'EVENT NOTIFICATION',
   'FILEGROUP',
   'MESSAGE TYPE',
   'PARTITION FUNCTION',
   'PARTITION SCHEME',
   'REMOTE SERVICE BINDING',
   'ROUTE',
   'SCHEMA',
   'SERVICE',
   'TRIGGER'
  ) AND @Type IS NOT NULL
    SET @IsValid = 0;

  RETURN @IsValid;
END;
GO

GO
CREATE FUNCTION [Helper].[ExtendedProperty_Validate_Level1_Type] (
  @Type VARCHAR(128)
) RETURNS BIT
AS   
BEGIN
  DECLARE @IsValid BIT = 1;
  IF @Type NOT IN (
   'AGGREGATE',
   'DEFAULT',
   'FUNCTION',
   'LOGICAL FILE NAME',
   'PROCEDURE',
   'QUEUE',
   'RULE',
   'SYNONYM',
   'TABLE',
   'TABLE_TYPE',
   'TYPE',
   'VIEW',
   'XML SCHEMA COLLECTION'
  ) AND @Type IS NOT NULL
    SET @IsValid = 0;

  RETURN @IsValid;
END;
GO

GO
CREATE FUNCTION [Helper].[ExtendedProperty_Validate_Level2_Type] (
  @Type VARCHAR(128)
) RETURNS BIT
AS   
BEGIN
  DECLARE @IsValid BIT = 1;
  IF @Type NOT IN (
   'COLUMN', 
   'CONSTRAINT', 
   'EVENT NOTIFICATION',
   'INDEX',
   'PARAMETER',
   'TRIGGER'
  ) AND @Type IS NOT NULL
    SET @IsValid = 0;

  RETURN @IsValid;
END;
GO

GO
CREATE PROCEDURE [Helper].[ExtendedProperty_Add] (
  @PropertyName NVARCHAR(128),
  @PropertyValue VARCHAR(2000),
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name SYSNAME = NULL,
  @Level1_Type VARCHAR(128) = NULL,
  @Level1_Name SYSNAME = NULL,
  @Level2_Type VARCHAR(128) = NULL,
  @Level2_Name SYSNAME = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ExtendedProperty_Add]
  -- Author: Cedric Dube
  -- Create date: 2020-10-20
  -- Description: Add extended property
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  -- Validate Types --
  IF [Helper].[ExtendedProperty_Validate_Level0_Type](@Level0_Type) = 0
    THROW 50000, 'Level 0 Type provided is invalid.', 1;
  IF [Helper].[ExtendedProperty_Validate_Level1_Type](@Level1_Type) = 0
    THROW 50000, 'Level 1 Type provided is invalid.', 1;
  IF [Helper].[ExtendedProperty_Validate_Level2_Type](@Level2_Type) = 0
    THROW 50000, 'Level 2 Type provided is invalid.', 1;
  -- Get System User and Date --
  DECLARE @SystemUser NVARCHAR(128) = SYSTEM_USER;
  DECLARE @SetDate DATETIME = SYSUTCDATETIME();
  SET @PropertyValue = '<' + @PropertyValue + '> ' + '{' + '"SYSTEM_USER": ' + @SystemUser + '}';
  -- Add property --
  EXEC sp_addextendedproperty @name = @PropertyName, @value = @PropertyValue,  
                              @level0type = @Level0_Type, @level0name = @Level0_Name,  
                              @level1type = @Level1_Type, @level1name = @Level1_Name,   
                              @level2type = @Level2_Type,@level2name = @Level2_Name; 
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Helper].[ExtendedProperty_Update] (
  @PropertyName NVARCHAR(128),
  @PropertyValue VARCHAR(2000),
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name SYSNAME = NULL,
  @Level1_Type VARCHAR(128) = NULL,
  @Level1_Name SYSNAME = NULL,
  @Level2_Type VARCHAR(128) = NULL,
  @Level2_Name SYSNAME = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ExtendedProperty_Update]
  -- Author: Cedric Dube
  -- Create date: 2020-10-20
  -- Description: Update extended property
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  -- Validate Types --
  IF [Helper].[ExtendedProperty_Validate_Level0_Type](@Level0_Type) = 0
    THROW 50000, 'Level 0 Type provided is invalid.', 1;
  IF [Helper].[ExtendedProperty_Validate_Level1_Type](@Level1_Type) = 0
    THROW 50000, 'Level 1 Type provided is invalid.', 1;
  IF [Helper].[ExtendedProperty_Validate_Level2_Type](@Level2_Type) = 0
    THROW 50000, 'Level 2 Type provided is invalid.', 1;
  -- Get System User and Date --
  DECLARE @SystemUser NVARCHAR(128) = SYSTEM_USER;
  DECLARE @SetDate DATETIME = SYSUTCDATETIME();
  SET @PropertyValue = '<' + @PropertyValue + '> ' + '{' + '"SYSTEM_USER": ' + @SystemUser + '}';
  -- Update property --
  EXEC sp_updateextendedproperty @name = @PropertyName, @value = @PropertyValue,  
                              @level0type = @Level0_Type, @level0name = @Level0_Name,  
                              @level1type = @Level1_Type, @level1name = @Level1_Name,   
                              @level2type = @Level2_Type,@level2name = @Level2_Name; 
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Helper].[ExtendedProperty_Remove] (
  @PropertyName NVARCHAR(128),
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name SYSNAME = NULL,
  @Level1_Type VARCHAR(128) = NULL,
  @Level1_Name SYSNAME = NULL,
  @Level2_Type VARCHAR(128) = NULL,
  @Level2_Name SYSNAME = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ExtendedProperty_Remove]
  -- Author: Cedric Dube
  -- Create date: 2020-10-20
  -- Description: Remove extended property
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  -- Validate Types --
  IF [Helper].[ExtendedProperty_Validate_Level0_Type](@Level0_Type) = 0
    THROW 50000, 'Level 0 Type provided is invalid.', 1;
  IF [Helper].[ExtendedProperty_Validate_Level1_Type](@Level1_Type) = 0
    THROW 50000, 'Level 1 Type provided is invalid.', 1;
  IF [Helper].[ExtendedProperty_Validate_Level2_Type](@Level2_Type) = 0
    THROW 50000, 'Level 2 Type provided is invalid.', 1;
  -- Remove property --
  EXEC sp_dropextendedproperty @name = @PropertyName,  
                              @level0type = @Level0_Type, @level0name = @Level0_Name,  
                              @level1type = @Level1_Type, @level1name = @Level1_Name,   
                              @level2type = @Level2_Type,@level2name = @Level2_Name; 
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Helper].[ExtendedProperty_ListAll] AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ExtendedProperty_ListAll]
  -- Author: Cedric Dube
  -- Create date: 2020-10-20
  -- Description: List all extended property
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  SELECT S.[Name] AS [Schema Name],
         O.[Type_Desc] AS [Object Type Description],
         O.[Name] AS [Object Name],
         C.[Name] AS [Column Name],
         EP.[Name] AS [Property Name], 
         EP.[Value] AS [Property Value]
    FROM sys.extended_properties EP
    LEFT JOIN sys.all_objects O 
      ON EP.major_id = O.object_id 
    LEFT JOIN sys.schemas S 
      ON O.schema_id = S.schema_id
    LEFT JOIN sys.columns AS C 
      ON EP.major_id = C.object_id AND EP.minor_id = C.column_id;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Helper].[ExtendedProperty_Add_Classification_PII] (
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name SYSNAME = NULL,
  @Level1_Type VARCHAR(128) = NULL,
  @Level1_Name SYSNAME = NULL,
  @Level2_Type VARCHAR(128) = NULL,
  @Level2_Name SYSNAME = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ExtendedProperty_Add]
  -- Author: Cedric Dube
  -- Create date: 2020-10-20_PII
  -- Description: Add extended property to classify object as PII
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  -- Default Val --
  DECLARE @PropertyName NVARCHAR(128) = 'PII';
  DECLARE @PropertyValue VARCHAR(2000) = 'Classification';
  -- Add property --
  EXEC [Helper].[ExtendedProperty_Add] @PropertyName = @PropertyName,
                                        @PropertyValue = @PropertyValue,
                                        @Level0_Type = @Level0_Type,
                                        @Level0_Name = @Level0_Name,
                                        @Level1_Type = @Level1_Type,
                                        @Level1_Name = @Level1_Name,
                                        @Level2_Type = @Level2_Type,
                                        @Level2_Name = @Level2_Name;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO


GO
CREATE PROCEDURE [Helper].[ExtendedProperty_Set] (
  @PropertyName NVARCHAR(128),
  @PropertyValue VARCHAR(2000),
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name SYSNAME = NULL,
  @Level1_Type VARCHAR(128) = NULL,
  @Level1_Name SYSNAME = NULL,
  @Level2_Type VARCHAR(128) = NULL,
  @Level2_Name SYSNAME = NULL
)
AS   
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ExtendedProperty_Set]
  -- Author: Cedric Dube
  -- Create date: 2021-08-12
  -- Description: Add/Update extended property
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  IF ([Helper].[ExtendedProperty_Check] (@PropertyName,@Level0_Type, @Level0_Name, @Level1_Type, @Level1_Name, @Level2_Type, @Level2_Name) = 1)
    EXEC [Helper].[ExtendedProperty_Update] @PropertyName,@PropertyValue,@Level0_Type, @Level0_Name, @Level1_Type, @Level1_Name, @Level2_Type, @Level2_Name;
  ELSE
    EXEC [Helper].[ExtendedProperty_Add] @PropertyName,@PropertyValue,@Level0_Type, @Level0_Name, @Level1_Type, @Level1_Name, @Level2_Type, @Level2_Name;    
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
/* End of File ********************************************************************************************************************/