/************************************************************************
* Script     : 7.2.ToolBox - CodeHouse - Procedures - Get.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/

---COURTESY OF:  https://www.richardswinbank.net/tsql/print_big

USE [dbSurge]
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_OutputPrint] (
  @CodeObject NVARCHAR(MAX)
)
AS
BEGIN;
BEGIN TRY;
  DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @MaxLen INT = 4000;
   
  DECLARE @LastLineSep INT;
  DECLARE @Len INT;
  DECLARE @Offset INT = 1;
   
  WHILE @Offset < LEN(@CodeObject)
  BEGIN;   
    SET @LastLineSep = CHARINDEX(REVERSE(@CRLF), REVERSE(SUBSTRING(@CodeObject, @Offset, @MaxLen + LEN(@CRLF))));
    SET @Len = @MaxLen - CASE @LastLineSep WHEN 0 THEN 0 ELSE @LastLineSep - 1 END;
    PRINT SUBSTRING(@CodeObject, @Offset, @Len);
    SET @Offset += CASE @LastLineSep WHEN 0 THEN 0 ELSE LEN(@CRLF) END + @Len;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Output] (
  @CodeObject NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles output from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
    EXEC [CodeHouse].[GenerateCodeObject_OutputPrint] @CodeObject = @CodeObject;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_FileObject] (
  @DatabaseName NVARCHAR(128),
  @SchemaName NVARCHAR(128),
  @CodeObjectName NVARCHAR(128)
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles file object comments from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @FileObject NVARCHAR(MAX);

  SET @FileObject = CONCAT(@CRLF, N'-------------------------------------------------------------', @CRLF);
  IF @SchemaName IS NOT NULL BEGIN;
    SET @FileObject = CONCAT(@FileObject, N'-- [', @DatabaseName, N'].[', @SchemaName, N'].[', @CodeObjectName, N']', N' --', @CRLF);
  END; ELSE BEGIN;
    SET @FileObject = CONCAT(@FileObject, N'-- [', @DatabaseName, N'].[', @CodeObjectName, N']', N' --', @CRLF);
  END;
  SET @FileObject = CONCAT(@FileObject, N'-------------------------------------------------------------', @CRLF, @GoStatement);

  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @FileObject;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DirectExecuteHeader]
  @MessagePrefix NVARCHAR(50),
  @DatabaseName NVARCHAR(128),
  @SchemaName NVARCHAR(128),
  @CodeObjectName NVARCHAR(128)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles direct execute object header statement from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @DirectExecuteHeader NVARCHAR(MAX);
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);

  -- File Statement --
  EXEC [CodeHouse].[GenerateCodeObject_FileObject] @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @CodeObjectName = @CodeObjectName;
  -- Deployment Print --
  IF @SchemaName IS NOT NULL BEGIN;
    SET @DirectExecuteHeader = CONCAT('PRINT N''', @MessagePrefix, N'[', @DatabaseName, N'].[', @SchemaName, N'].[', @CodeObjectName, N']', ''';', @CRLF, @GoStatement);
  END; ELSE BEGIN;
    SET @DirectExecuteHeader = CONCAT('PRINT N''', @MessagePrefix, N'[', @DatabaseName, N'].[', @CodeObjectName, N']', ''';', @CRLF, @GoStatement);
  END;
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @DirectExecuteHeader;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DirectExecuteFooter] (
  @DeploymentID INT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles direct execute footer statement for objects from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @DirectExecuteFooter NVARCHAR(MAX);
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @ToolboxDB NVARCHAR(128) = (SELECT TOP (1) [DatabaseName] FROM [CodeHouse].[Layer] WHERE [Layer] = 'Toolbox');

  SET @DirectExecuteFooter = CONCAT(N'DECLARE @Error INT = @@ERROR', @CRLF, 'IF @ERROR <> 0 BEGIN;', @CRLF);
  SET @DirectExecuteFooter = CONCAT(@DirectExecuteFooter, N'  INSERT INTO [', @ToolboxDB, '].[CodeHouse].[DeploymentError] ([DeploymentID], [ErrorMessage]) VALUES(', @DeploymentID, ', @Error', ');', @CRLF);
  SET @DirectExecuteFooter = CONCAT(@DirectExecuteFooter,  '  PRINT ''**** !! The execution FAILED !!''', @CRLF);
  SET @DirectExecuteFooter = CONCAT(@DirectExecuteFooter, N'END; ELSE BEGIN;', @CRLF);
  SET @DirectExecuteFooter = CONCAT(@DirectExecuteFooter,  '  PRINT ''**** The execution succeeded.''', @CRLF);
  SET @DirectExecuteFooter = CONCAT(@DirectExecuteFooter, N'END;', @CRLF, @GoStatement);

  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @DirectExecuteFooter;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_FileSection] (
  @SectionName NVARCHAR(100)
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles file section comments from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @FileSection NVARCHAR(MAX);

  SET @FileSection = CONCAT(@CRLF, N'/*********************************************************************************', @CRLF);
  SET @FileSection = CONCAT(@FileSection,N'-- ',@SectionName, @CRLF);
  SET @FileSection = CONCAT(@FileSection, N'********************************************************************************/', @CRLF);

  SET @FileSection = CONCAT(@FileSection, N'PRINT ''-----------------------------------------------------------------------'';', @CRLF);
  SET @FileSection = CONCAT(@FileSection, N'PRINT ''----  ',@SectionName, ''';', @CRLF);
  SET @FileSection = CONCAT(@FileSection, N'PRINT ''-----------------------------------------------------------------------'';', @CRLF);
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @FileSection;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_FileFooter] 
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles file footer comments from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @FileFooter NVARCHAR(MAX);

  SET @FileFooter = CONCAT(N'/**End Of File*******************************************************************************************/', @CRLF);

  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @FileFooter;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO


GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_FileHeader] (
  @DeploymentName NVARCHAR(128),
  @DeploymentNotes NVARCHAR(MAX),
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObjectNames [CodeHouse].[CodeObjectFullName] READONLY,
  @Drops BIT,
  @Objects BIT,
  @ExtendedProperties BIT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles file header comments from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @FileHeader NVARCHAR(MAX);
  DECLARE @PrintFileHeader NVARCHAR(MAX);

  DECLARE @ObjectsAffectedCount SMALLINT;
  DECLARE @ObjectsList  [CodeHouse].[CodeObjectFullName];
  DECLARE @Ordinal SMALLINT;
  DECLARE @DatabaseName NVARCHAR(128);
  DECLARE @SchemaName NVARCHAR(128);
  DECLARE @CodeObjectName NVARCHAR(128);
  INSERT INTO @ObjectsList(DatabaseName, SchemaName, CodeObjectName) SELECT DatabaseName, SchemaName, CodeObjectname FROM @CodeObjectNames ORDER BY Ordinal ASC;
  DECLARE @Databases AS TABLE ( DatabaseName NVARCHAR(128) NOT NULL);
  INSERT INTO @Databases SELECT DISTINCT DatabaseName FROM @ObjectsList ORDER BY DatabaseName ASC;

  SET @FileHeader = CONCAT(N'/*********************************************************************************************************', @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'* Script       : Generated Deployment Set : ', @DeploymentSet, @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'* Deployment   : ', @DeploymentName, @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'* Generated By : ', SYSTEM_USER, @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'* Generated On : ', CAST(GETDATE() AS DATE), @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'* Execution    : Entire script will execute within a single Transaction. Failure will result in Rollback. Check for Errors.' , @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'* Steps        : 1 > Drop Statements      : ', CASE WHEN @Drops = 1 THEN 'YES' ELSE 'NO' END, @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'*              : 2 > Create Statements    : ', CASE WHEN @Objects = 1 THEN 'YES' ELSE 'NO' END, @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'*              : 3 > Extended Properties  : ', CASE WHEN @ExtendedProperties = 1 THEN 'YES ' ELSE 'NO' END, @CRLF);
  WHILE EXISTS (SELECT 1 FROM @ObjectsList) BEGIN;
    SELECT TOP (1) @Databasename = DatabaseName FROM @Databases ORDER BY DatabaseName ASC;
    SET @FileHeader = CONCAT(@FileHeader, N'* Database     : [', @DatabaseName, N']',@CRLF);
    SELECT @ObjectsAffectedCount = COUNT(1) FROM @ObjectsList WHERE DatabaseName = @DatabaseName;
    SET @FileHeader = CONCAT(@FileHeader, N'* Objects      : ( ', @ObjectsAffectedCount, ' ) affected.', @CRLF);
    WHILE EXISTS (SELECT 1 FROM @ObjectsList) BEGIN;
      SELECT @Ordinal = MIN(Ordinal) FROM @ObjectsList;
      SELECT @DatabaseName = CONCAT(N'[', DatabaseName, N']'),
             @SchemaName = CONCAT(N'.[', SchemaName, N']'),
             @CodeObjectName = CONCAT(N'.[', CodeObjectName, N']')
        FROM @ObjectsList WHERE Ordinal = @Ordinal;
      IF @SchemaName IS NOT NULL BEGIN;
        SET @FileHeader = CONCAT(@FileHeader, N'*              : ', @DatabaseName, @SchemaName, @CodeObjectName,@CRLF);
      END; ELSE BEGIN;
        SET @FileHeader = CONCAT(@FileHeader, N'*              : ', @DatabaseName, @CodeObjectName,@CRLF);
      END;
      DELETE FROM @ObjectsList WHERE Ordinal = @Ordinal;
    END;
    DELETE FROM @Databases WHERE Databasename = @Databasename;
  END;

  SET @FileHeader = CONCAT(@FileHeader, N'*********************************************************************************************************/', @CRLF);
  SET @PrintFileHeader = CONCAT(N'PRINT ''', @FileHeader, ''';', @CRLF);

  SET @FileHeader = CONCAT(@FileHeader, N'/*----------------------------------------- NOTES -------------------------------------------------------', @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, @DeploymentNotes, @CRLF);
  SET @FileHeader = CONCAT(@FileHeader, N'-------------------------------------------------------------------------------------------------------*/', @CRLF);
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @FileHeader;
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @PrintFileHeader;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DeploymentHeader] 
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles deployment header statement from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @DeploymentHeader NVARCHAR(MAX);
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);

  SET @DeploymentHeader = CONCAT(N'SET NUMERIC_ROUNDABORT OFF;', @CRLF, @GoStatement);
  SET @DeploymentHeader = CONCAT(@DeploymentHeader, N'SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON;', @CRLF, @GoStatement);
  SET @DeploymentHeader = CONCAT(@DeploymentHeader, N'SET XACT_ABORT ON; SET NOCOUNT ON;', @CRLF, @GoStatement);
  SET @DeploymentHeader = CONCAT(@DeploymentHeader, N'SET TRANSACTION ISOLATION LEVEL Serializable;', @CRLF, @GoStatement);
  SET @DeploymentHeader = CONCAT(@DeploymentHeader, N'BEGIN TRANSACTION;', @CRLF, @GoStatement);
  SET @DeploymentHeader = CONCAT(@DeploymentHeader, N'IF @@ERROR <> 0 SET NOEXEC ON;', @CRLF, @GoStatement);

  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @DeploymentHeader;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DeploymentObjectHeader]
  @MessagePrefix NVARCHAR(50),
  @DatabaseName NVARCHAR(128),
  @SchemaName NVARCHAR(128),
  @CodeObjectName NVARCHAR(128)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles deployment object header statement from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @DeploymentObjectHeader NVARCHAR(MAX);
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);

  -- File Statement --
  EXEC [CodeHouse].[GenerateCodeObject_FileObject] @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @CodeObjectName = @CodeObjectName;
  -- Deployment Print --
  IF @SchemaName IS NOT NULL BEGIN;
    SET @DeploymentObjectHeader = CONCAT('PRINT N''', @MessagePrefix, N'[', @DatabaseName, N'].[', @SchemaName, N'].[', @CodeObjectName, N']', ''';', @CRLF, @GoStatement);
  END; ELSE BEGIN;
    SET @DeploymentObjectHeader = CONCAT('PRINT N''', @MessagePrefix, N'[', @DatabaseName, N'].[', @CodeObjectName, N']', ''';', @CRLF, @GoStatement);
  END;
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @DeploymentObjectHeader;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DeploymentObjectFooter] (
  @DeploymentID INT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles deployment footer statement for objects from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @DeploymentObjectFooter NVARCHAR(MAX);
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @ToolboxDB NVARCHAR(128) = (SELECT TOP (1) [DatabaseName] FROM [CodeHouse].[Layer] WHERE [Layer] = 'Toolbox');

  SET @DeploymentObjectFooter = CONCAT(N'DECLARE @Error INT = @@ERROR', @CRLF, 'IF @ERROR <> 0 BEGIN;', @CRLF);
  SET @DeploymentObjectFooter = CONCAT(@DeploymentObjectFooter, N'  IF OBJECT_ID(''[', @ToolboxDB, '].[CodeHouse].[DeploymentError]'') IS NOT NULL', @CRLF);
  SET @DeploymentObjectFooter = CONCAT(@DeploymentObjectFooter, N'    INSERT INTO [', @ToolboxDB, '].[CodeHouse].[DeploymentError] ([DeploymentID], [ErrorMessage]) VALUES(', @DeploymentID, ', @Error', ');', @CRLF);
  SET @DeploymentObjectFooter = CONCAT(@DeploymentObjectFooter, N'  SET NOEXEC ON;', @CRLF, 'END;', @CRLF, @GoStatement);

  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @DeploymentObjectFooter;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DeploymentFooter] (
  @DeploymentSet UNIQUEIDENTIFIER
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles deployment footer statement from generation
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @DeploymentFooter NVARCHAR(MAX);
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @ToolboxDB NVARCHAR(128) = (SELECT TOP (1) [DatabaseName] FROM [CodeHouse].[Layer] WHERE [Layer] = 'Toolbox');

  SET @DeploymentFooter = CONCAT(N'COMMIT TRANSACTION;', @CRLF, @GoStatement);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'IF @@ERROR <> 0 SET NOEXEC ON;', @CRLF, @GoStatement);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'DECLARE @Success AS BIT;', @CRLF, 'SET @Success = 1;', @CRLF, 'SET NOEXEC OFF;', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'IF (@Success = 1) BEGIN;', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter,  '  PRINT ''**********************************************************************************************************''', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter,  '  PRINT ''The database update succeeded.''', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter,  '  PRINT ''**********************************************************************************************************''', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'  IF OBJECT_ID(''[', @ToolboxDB,'].[CodeHouse].[Deployment]'') IS NOT NULL', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'    UPDATE [', @ToolboxDB, '].[CodeHouse].[Deployment] SET [DeploymentStatus] = ''S'' WHERE [DeploymentSet] = ''', @DeploymentSet, ''';', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'END; ELSE BEGIN;', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter,  '  PRINT ''**********************************************************************************************************''', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter,  '  PRINT ''The database update failed and was rolled back.''', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter,  '  PRINT ''**********************************************************************************************************''', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'  IF OBJECT_ID(''[', @ToolboxDB, '].[CodeHouse].[Deployment]'') IS NOT NULL', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'    UPDATE [',@ToolboxDB, '].[CodeHouse].[Deployment] SET [DeploymentStatus] = ''F'' WHERE [DeploymentSet] = ''', @DeploymentSet,''';', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'END;', @CRLF, @GoStatement);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'  IF OBJECT_ID(''[', @ToolboxDB, '].[CodeHouse].[Deployment]'') IS NOT NULL', @CRLF);
  SET @DeploymentFooter = CONCAT(@DeploymentFooter, N'    SELECT * FROM [',@ToolboxDB, '].[CodeHouse].[vDeploymentDocument] WHERE [DeploymentSet] = ''', @DeploymentSet,''' ORDER BY [Layer] ASC, [StreamVariant] ASC, [Stream] ASC;', @CRLF, @GoStatement);
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @DeploymentFooter;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO


GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DropComponent] (
  @ObjectType VARCHAR(50),
  @SchemaName NVARCHAR(128) = NULL,
  @TableObject NVARCHAR(128) = NULL,
  @CodeObjectName NVARCHAR(128),
  @DropComponent NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles drop statements
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  -- Script --
  IF (@ObjectType = 'Script') BEGIN;
    SET @DropComponent = @DropComponent; -- Scripts must handle their own work
  END;
  -- Schema --
  IF (@ObjectType = 'Schema') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE [SCHEMA_NAME] = ''', @CodeObjectName,''')',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP SCHEMA [',@CodeObjectName, N'];');
  END;
  -- PartitionFunction --
  IF (@ObjectType = 'PartitionFunction') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.partition_functions WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP PARTITION FUNCTION [',@CodeObjectName, N'];');
  END;
  -- PartitionScheme --
  IF (@ObjectType = 'PartitionScheme') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.partition_schemes WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP PARTITION SCHEME [',@CodeObjectName, N'];');
  END;
  -- Table --
  IF (@ObjectType = 'Table') BEGIN;
    SET @DropComponent = CONCAT(N'DROP TABLE IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''',@SchemaName, ''' AND TABLE_NAME = ''', @CodeObjectName, ''')', @CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP TABLE [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  IF (@ObjectType = 'TemporalTable') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''',@SchemaName, ''' AND TABLE_NAME = ''', @CodeObjectName, ''')', @CRLF);
    SET @DropComponent = CONCAT(@DropComponent, '  ALTER TABLE [',@SchemaName, N'].[',@CodeObjectName,N'] SET ( SYSTEM_VERSIONING = OFF);', @CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'DROP TABLE IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
  END;
  -- Index --
  IF (@ObjectType = 'Index') BEGIN;
    SET @DropComponent = CONCAT(N'DROP INDEX IF EXISTS [',@CodeObjectName,N'] ON [',@SchemaName, N'].[',@TableObject,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.indexes WHERE [Name] = ''',@CodeObjectName, ''' AND Object_ID = OBJECT_ID(''', @SchemaName, '.', @TableObject, '''))', @CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP TABLE [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  -- TableType --
  IF (@ObjectType = 'TableType') BEGIN;
   SET @DropComponent = CONCAT(N'DROP TYPE IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.types WHERE [Name] = ''',@CodeObjectName, ''' AND Schema_ID = SCHEMA_ID(''', @SchemaName, '''))', @CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP TYPE [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  -- DataType --
  IF (@ObjectType = 'DataType') BEGIN;
   SET @DropComponent = CONCAT(N'DROP TYPE IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.types WHERE [Name] = ''',@CodeObjectName, ''' AND Schema_ID = SCHEMA_ID(''', @SchemaName, '''))', @CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP TYPE [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  -- View --
  IF (@ObjectType = 'View') BEGIN;
    SET @DropComponent = CONCAT(N'DROP VIEW IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = ''',@SchemaName, ''' AND TABLE_NAME = ''', @CodeObjectName, ''')', @CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP VIEW [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  -- Function --
  IF (@ObjectType = 'Function') BEGIN;
    SET @DropComponent = CONCAT(N'DROP FUNCTION IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE Specific_Schema = ''', @SchemaName, ''' AND specific_name = ''', @CodeObjectName, ''' AND Routine_Type = ''FUNCTION'')',@CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP FUNCTION [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  -- Procedure --
  IF (@ObjectType = 'Procedure') BEGIN;
    SET @DropComponent = CONCAT(N'DROP PROCEDURE IF EXISTS [',@SchemaName, N'].[',@CodeObjectName,N'];');
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE Specific_Schema = ''', @SchemaName, ''' AND specific_name = ''', @CodeObjectName, ''' AND Routine_Type = ''PROCEDURE'')',@CRLF);
      SET @DropComponent = CONCAT(@DropComponent, N'  DROP PROCEDURE [',@SchemaName, N'].[',@CodeObjectName,N'];');
    END;
  END;
  -- SBContract --
  IF (@ObjectType = 'SBContract') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.service_contracts WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP CONTRACT [',@CodeObjectName, N'];');
  END;
  -- SBMessageType --
  IF (@ObjectType = 'SBMessageType') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.service_message_types WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP MESSAGE TYPE [',@CodeObjectName, N'];');
  END;
  -- SBQueue --
  IF (@ObjectType = 'SBQueue') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.service_queues WHERE [Name] = ''', @CodeObjectName,'''AND SCHEMA_ID(''', @SchemaName, ''') = schema_id)',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP QUEUE [',@SchemaName, N'].[',@CodeObjectName,N'];');
  END;
  -- SBService --
  IF (@ObjectType = 'SBService') BEGIN;
    SET @DropComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.services WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
    SET @DropComponent = CONCAT(@DropComponent, N'  DROP SERVICE [',@CodeObjectName, N'];');
  END;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_ExistsComponent] (
  @ObjectType VARCHAR(50),
  @SchemaName NVARCHAR(128) = NULL,
  @TableObject NVARCHAR(128) = NULL,
  @CodeObjectName NVARCHAR(128),
  @ExistsComponent NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Handles exists statements
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  -- Script --
  IF (@ObjectType = 'Script') BEGIN;
    SET @ExistsComponent = @ExistsComponent; -- Scripts must handle their own work
  END;
  -- Schema --
  IF (@ObjectType = 'Schema') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE [SCHEMA_NAME] = ''', @CodeObjectName,''')',@CRLF);
  END;
  -- PartitionFunction --
  IF (@ObjectType = 'PartitionFunction') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM sys.partition_functions WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
  END;
  -- PartitionScheme --
  IF (@ObjectType = 'PartitionScheme') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
  END;
  -- Table --
  IF (@ObjectType = 'Table') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''',@SchemaName, ''' AND TABLE_NAME = ''', @CodeObjectName, ''')', @CRLF);
  END;
  IF (@ObjectType = 'TemporalTable') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''',@SchemaName, ''' AND TABLE_NAME = ''', @CodeObjectName, ''')', @CRLF);
  END;
  -- Index --
  IF (@ObjectType = 'Index') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF INDEXPROPERTY(OBJECT_ID(''', @SchemaName, '.', @TableObject, '''),''', @CodeObjectName, ''', ''IndexID'') IS NULL', @CRLF);
  END;
  -- TableType --
  IF (@ObjectType = 'TableType') BEGIN;
   SET @ExistsComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.types WHERE [Name] = ''', @CodeObjectName, ''' AND is_table_Type = 1 AND SCHEMA_ID(''', @SchemaName, ''' = schema_id', @CRLF);
  END;
  -- DataType --
  IF (@ObjectType = 'DataType') BEGIN;
   SET @ExistsComponent = CONCAT(N'IF EXISTS (SELECT * FROM sys.types WHERE [Name] = ''', @CodeObjectName, ''' AND is_table_Type = 0 AND SCHEMA_ID(''', @SchemaName, ''' = schema_id', @CRLF);
  END;
  -- View --
  IF (@ObjectType = 'View') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = ''',@SchemaName, ''' AND TABLE_NAME = ''', @CodeObjectName, ''')', @CRLF);
  END;
  -- Function --
  IF (@ObjectType = 'Function') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE Specific_Schema = ''', @SchemaName, ''' AND specific_name = ''', @CodeObjectName, ''' AND Routine_Type = ''FUNCTION'')',@CRLF);
  END;
  -- Procedure --
  IF (@ObjectType = 'Procedure') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE Specific_Schema = ''', @SchemaName, ''' AND specific_name = ''', @CodeObjectName, ''' AND Routine_Type = ''PROCEDURE'')',@CRLF);
  END;
  -- SBContract --
  IF (@ObjectType = 'SBContract') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM sys.service_contracts WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
  END;
  -- SBMessageType --
  IF (@ObjectType = 'SBMessageType') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM sys.service_message_types WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
  END;
  -- SBQueue --
  IF (@ObjectType = 'SBQueue') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM sys.service_queues WHERE [Name] = ''', @CodeObjectName,''' AND SCHEMA_ID(''', @SchemaName, ''' = schema_id)',@CRLF);
  END;
  -- SBService --
  IF (@ObjectType = 'SBService') BEGIN;
    SET @ExistsComponent = CONCAT(N'IF NOT EXISTS (SELECT * FROM sys.services WHERE [Name] = ''', @CodeObjectName,''')',@CRLF);
  END;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_ReplaceTags] (
  @CodeObjectIDInput INT,
  @CodeObjectInput NVARCHAR(MAX),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @CodeObject NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Replace vars in code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @Tag VARCHAR(50),
          @Value NVARCHAR(MAX),
          @Tags [CodeHouse].[ReplacementTag];
  DECLARE @CodeObjectOutput NVARCHAR(MAX) = @CodeObjectInput;

  INSERT INTO @Tags SELECT * FROM @ReplacementTags;
  WHILE EXISTS (SELECT 1 FROM @Tags) BEGIN;
    SET @Tag = (SELECT TOP (1) [Tag] FROM @Tags);
    SET @Value = (SELECT [Value] FROM @Tags WHERE [Tag] = @Tag);
    SET @CodeObjectOutput = REPLACE(@CodeObjectOutput, @Tag, @Value);
    DELETE @Tags WHERE [Tag] = @Tag;
  END;
  SET @CodeObject = @CodeObjectOutput;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_ReplaceComponents] (
  @CodeObjectIDInput INT,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObjectInput NVARCHAR(MAX),
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @CodeObject NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Replace vars in code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @Components AS TABLE (
    [Ordinal] INT IDENTITY(1,1) NOT NULL,
    [CodeObjectID] INT NOT NULL,
    [Layer] VARCHAR(50) NOT NULL,
    [Stream] VARCHAR(50) NOT NULL,
    [StreamVariant] VARCHAR(50) NOT NULL,
    [CodeObjectName] NVARCHAR(128) NOT NULL,
    [CodeObject] NVARCHAR(MAX) NOT NULL
  );
  DECLARE @Component NVARCHAR(128),
          @CodeObjectID INT,
          @CodeObjectName NVARCHAR(128),
          @ComponentCodeObject NVARCHAR(MAX);

  DECLARE @CodeObjectOutput NVARCHAR(MAX) = @CodeObjectInput;

  INSERT INTO @Components ([CodeObjectID], [Layer], [Stream], [StreamVariant], [CodeObjectName], [CodeObject])
    SELECT [CO].[CodeObjectID], [CO].[Layer], [CO].[Stream], [CO].[StreamVariant], [CO].[CodeObjectName], [CO].[CodeObject]
      FROM @ReplacementComponents [COM] INNER JOIN [CodeHouse].[vCodeObject] [CO]
        ON [COM].[Layer] = [CO].[Layer]
       AND [COM].[Stream] = [CO].[Stream]
       AND [COM].[StreamVariant] = [CO].[StreamVariant]
       AND [COM].[CodeObjectName] = [CO].[CodeObjectName];
  -- IF COMPONENTS WERE NOT EXPLICITLY DEFINED IN CALL --
  IF NOT EXISTS (SELECT 1 FROM @Components) BEGIN;
    INSERT INTO @Components ([CodeObjectID], [Layer], [Stream], [StreamVariant], [CodeObjectName], [CodeObject])
      SELECT [COM].[Component_CodeObjectID], [COM].[Component_Layer], [COM].[Component_Stream], [COM].[Component_StreamVariant], [COM].[Component_CodeObjectName], [CO].[CodeObject]
        FROM [CodeHouse].[vCodeObjectComponent] [COM] INNER JOIN [CodeHouse].[CodeObject] [CO] ON [COM].[Component_CodeObjectID] = [CO].[CodeObjectID] WHERE [COM].[CodeObjectID] = @CodeObjectIDInput;
  END;
  WHILE EXISTS (SELECT 1 FROM @Components) BEGIN;
    -- Components can contain components --
    INSERT INTO @Components ([CodeObjectID], [Layer], [Stream], [StreamVariant], [CodeObjectName], [CodeObject])
      SELECT [COM].[Component_CodeObjectID], [COM].[Component_Layer], [COM].[Component_Stream], [COM].[Component_StreamVariant], [COM].[Component_CodeObjectName], [CO].[CodeObject]
        FROM @Components [C] INNER JOIN [CodeHouse].[vCodeObjectComponent] [COM] ON [C].[CodeObjectID] = [COM].[CodeobjectID] INNER JOIN [CodeHouse].[CodeObject] [CO] ON [COM].[Component_CodeObjectID] = [CO].[CodeObjectID]
       WHERE NOT EXISTS (SELECT 1 FROM @Components WHERE [CodeObjectID] = [COM].[Component_CodeObjectID]);
    SELECT TOP(1)  @CodeObjectID = [CodeObjectID],
                   @Component = CONCAT(N'{<', [CodeObjectName], N'>}'),
                   @ComponentCodeObject = [CodeObject]
            FROM @Components ORDER BY [Ordinal] ASC;
    IF CHARINDEX(@Component, @CodeObjectOutput) > 0 BEGIN;     
      SET @CodeObjectOutput = REPLACE(@CodeObjectOutput, @Component, @ComponentCodeObject);
    END;
	INSERT INTO ##CodeHouse_Deployment_Components (CodeObjectID) VALUES (@CodeObjectID);
    DELETE @Components WHERE [CodeObjectID] = @CodeObjectID;
  END;
  SET @CodeObject = @CodeObjectOutput;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0] (
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name NVARCHAR(128),
  @Author NVARCHAR(128),
  @Version DECIMAL(9,1),
  @Date DATE,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObjectRemark NVARCHAR(2000),
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Replace vars in code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @AddExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Add] ';
  DECLARE @UpdateExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Update] ';
  DECLARE @SetExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Set] ';
  -- Author
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Author'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Author, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Date
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Date'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Date, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Version
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Version'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Version, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- DeploySet
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''DeploySet'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @DeploymentSet, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Remark
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Remark'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @CodeObjectRemark, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''';', @CRLF);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1] (
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name NVARCHAR(128),
  @Level1_Type VARCHAR(128),
  @Level1_Name NVARCHAR(128),
  @Author NVARCHAR(128),
  @Version DECIMAL(9,1),
  @Date DATE,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObjectRemark NVARCHAR(2000),
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Replace vars in code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @AddExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Add] ';
  DECLARE @UpdateExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Update] ';
  DECLARE @SetExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Set] ';
  -- Author
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Author'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Author, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Date
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Date'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Date, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Version
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Version'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Version, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- DeploySet
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''DeploySet'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @DeploymentSet, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Remark
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Remark'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @CodeObjectRemark, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''';', @CRLF);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level2] (
  @Level0_Type VARCHAR(128) = 'SCHEMA',
  @Level0_Name NVARCHAR(128),
  @Level1_Type VARCHAR(128),
  @Level1_Name NVARCHAR(128),
  @Level2_Type VARCHAR(128),
  @Level2_Name NVARCHAR(128),
  @Author NVARCHAR(128),
  @Version DECIMAL(9,1),
  @Date DATE,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObjectRemark NVARCHAR(2000),
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Replace vars in code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @AddExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Add] ';
  DECLARE @UpdateExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Update] ';
  DECLARE @SetExtendedProperty NVARCHAR(150) = 'EXEC [Helper].[ExtendedProperty_Set] ';
  -- Author
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Author'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Author, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Type = ''', @Level2_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Name = ''', @Level2_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Date
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Date'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Date, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Type = ''', @Level2_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Name = ''', @Level2_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Version
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Version'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @Version, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Type = ''', @Level2_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Name = ''', @Level2_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- DeploySet
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''DeploySet'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @DeploymentSet, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Type = ''', @Level2_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Name = ''', @Level2_Name, ''';', @CRLF);
  --SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @GoStatement);
  -- Remark
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @SetExtendedProperty, '@PropertyName = ''Remark'',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @PropertyValue = ''', @CodeObjectRemark, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Type = ''', @Level0_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level0_Name = ''', @Level0_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Type = ''', @Level1_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level1_Name = ''', @Level1_Name, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Type = ''', @Level2_Type, ''',', @CRLF);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, N'                                     @Level2_Name = ''', @Level2_Name, ''';', @CRLF);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Script] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Nothing else to to. Scripts handle themselves --

  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Schema] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  IF NOT EXISTS (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}')
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  DECLARE @Authorization NVARCHAR(128) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Authorization}');
  IF @Authorization IS NULL
    THROW 50000, '{Authorization} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = NULL,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;

  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = NULL,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;

  -- Extended Properties --
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0]  @Level0_Type = @ObjectType,
                                                                   @Level0_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_PartitionFunction] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = NULL,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = NULL,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'PartitionFunction' SET @ObjectType = 'Partition Function';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0]  @Level0_Type = @ObjectType,
                                                                   @Level0_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_PartitionScheme] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = NULL,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = NULL,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'PartitionScheme' SET @ObjectType = 'Partition Scheme';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0]  @Level0_Type = @ObjectType,
                                                                   @Level0_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_TableType] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'TableType' SET @ObjectType = 'Type';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_DataType] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'DataType' SET @ObjectType = 'Type';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Table] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_TemporalTable] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'TemporalTable' SET @ObjectType = 'Table';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Index] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  DECLARE @TableObject NVARCHAR(128) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{TableObject}');
  IF @TableObject IS NULL
    THROW 50000, '{TableObject} Tag and Value must be provided. Terminating Procedure.', 1;
  DECLARE @TableObjectType VARCHAR(10) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{TableObjectType}');
  IF @TableObject IS NULL
    THROW 50000, '{TableObjectType} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = @TableObject,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = @TableObject,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level2]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @TableObjectType,
                                                                   @Level1_Name = @TableObject,
                                                                   @Level2_Type = @ObjectType,
                                                                   @Level2_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_View] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Function] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Generate CREATE --
  SET @CreateComponent = CONCAT(N'CREATE OR ALTER FUNCTION [',@SchemaName, N'].[',@UsedCodeObjectName,N']');
  IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014
     SET @CreateComponent = REPLACE(@CreateComponent,'OR ALTER ','');
  IF @CodeObjectHeader IS NOT NULL BEGIN;
    SET @CreateComponent = CONCAT(@CreateComponent, N' (', @CRLF, N'  ', @CodeObjectHeader, @CRLF, N')');
  END; ELSE BEGIN;
    SET @CreateComponent = CONCAT(@CreateComponent, N' ()', @CRLF);
  END;
  -- CREATE, COMMENT, EXECUTION OPTIONS --
  SET @CreateComponent = CONCAT(@CreateComponent, @CommentComponent, N' ', @CodeObjectExecutionOptions);
  SET @CreateComponent = CONCAT(@CreateComponent, @CRLF, N' AS', @CRLF);
  -- Generate COMMENT --
  SET @CommentComponent = CONCAT(N'  /*-------------------------------------------------------------------------------------------------', @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    Author     : ', @Author, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    Date       : ', @Date, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    Version    : ', @Version, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    DeploySet  : ', @DeploymentSet, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'  -------------------------------------------------------------------------------------------------*/', @CRLF);

  -- CREATE, COMMENT, EXECUTION OPTIONS --
  SET @CreateComponent = CONCAT(@CreateComponent, @CommentComponent, @CRLF);
  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_Procedure] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Generate CREATE --
  SET @CreateComponent = CONCAT(N'CREATE OR ALTER PROCEDURE [',@SchemaName, N'].[',@UsedCodeObjectName,N']');
  IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014
     SET @CreateComponent = REPLACE(@CreateComponent,'OR ALTER ','');
  IF @CodeObjectHeader IS NOT NULL BEGIN;
    SET @CreateComponent = CONCAT(@CreateComponent, N' (', @CRLF, N'  ', @CodeObjectHeader, @CRLF, N')', N' AS', @CRLF);
  END; ELSE BEGIN;
      SET @CreateComponent = CONCAT(@CreateComponent, N' AS', @CRLF);
  END;

  -- Generate COMMENT --
  SET @CommentComponent = CONCAT(N'  /*-------------------------------------------------------------------------------------------------', @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    Author     : ', @Author, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    Date       : ', @Date, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    Version    : ', @Version, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'    DeploySet  : ', @DeploymentSet, @CRLF);
  SET @CommentComponent = CONCAT(@CommentComponent, N'  -------------------------------------------------------------------------------------------------*/', @CRLF);

  -- CREATE, COMMENT, EXECUTION OPTIONS --
  SET @CreateComponent = CONCAT(@CreateComponent, @CommentComponent, N'  ', @CodeObjectExecutionOptions, @CRLF);

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_SBContract] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = NULL,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = NULL,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'SBContract' SET @ObjectType = 'Contract';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0]  @Level0_Type = @ObjectType,
                                                                   @Level0_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_SBMessageType] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = NULL,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = NULL,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'SBMessageType' SET @ObjectType = 'Message Type';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0]  @Level0_Type = @ObjectType,
                                                                   @Level0_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_SBQueue] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  SET @SchemaName = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Schema}');
  IF @SchemaName IS NULL
    THROW 50000, '{Schema} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = @SchemaName,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = @SchemaName,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'SBQueue' SET @ObjectType = 'Queue';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1]  @Level0_Type = 'Schema',
                                                                   @Level0_Name = @SchemaName,
                                                                   @Level1_Type = @ObjectType,
                                                                   @Level1_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject_SBService] (
  @CodeObjectID INT,
  @ObjectType VARCHAR(50),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) OUTPUT,
  @SchemaName NVARCHAR(128)  = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectID
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeObjectID ''', @CodeObjectID, ''' with ObjectType ''', @ObjectType, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  IF (NOT EXISTS ( SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType))
    THROW 50000, @NoFindMsg, 1;
  -- Vars. --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10),
          -- Collected from CodeObject --
          @CodeObjectInput NVARCHAR(MAX),
          @CodeObjectHeader NVARCHAR(2000),
          @CodeObjectRemark NVARCHAR(2000),
          @CodeObjectExecutionOptions NVARCHAR(1000),
          @CodeObjectName NVARCHAR(128),
          @Author NVARCHAR(128),
          @Version DECIMAL(9,1),
          @Date DATE,
          -- Generated in Proc --
          @ExistsComponent NVARCHAR(4000),
          @CreateComponent NVARCHAR(4000),
          @CommentComponent NVARCHAR(4000);
  SELECT @CodeObjectInput = [CodeObject],
         @CodeObjectHeader = [CodeObjectHeader],
         @CodeObjectRemark = [CodeObjectRemark],
         @CodeObjectExecutionOptions = [CodeObjectExecutionOptions],
         @CodeObjectName = [CodeObjectName],
         @Author = [Author],
         @Version = [CodeVersion],
         @Date = [SystemFromDate]
    FROM [CodeHouse].[vCodeObject]
   WHERE [CodeObjectID] = @CodeObjectID AND [ObjectType] = @ObjectType;

  -- Replace Components --
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceComponents] @CodeObjectIDInput = @CodeObjectID, @DeploymentSet = @DeploymentSet, @CodeObjectInput = @CodeObjectInput, @ReplacementComponents = @ReplacementComponents, @CodeObject = @CodeObjectInput OUTPUT;
  -- Replace Tags --
  -- Name
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectName, @ReplacementTags = @ReplacementTags, @CodeObject = @UsedCodeObjectName OUTPUT;
  -- Code
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectInput, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObject OUTPUT;
  -- CodeHeader
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectHeader, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectHeader OUTPUT;
  -- CodeRemark
  EXEC [CodeHouse].[GenerateCodeObject_ReplaceTags] @CodeObjectIDInput = @CodeObjectID, @CodeObjectInput = @CodeObjectRemark, @ReplacementTags = @ReplacementTags, @CodeObject = @CodeObjectRemark OUTPUT;

  -- Exists --
  EXEC [CodeHouse].[GenerateCodeObject_ExistsComponent]  @ObjectType = @ObjectType,
                                                         @SchemaName = NULL,
                                                         @TableObject = NULL,
                                                         @CodeObjectName = @UsedCodeObjectName,
                                                         @ExistsComponent = @ExistsComponent OUTPUT;
  -- Generate DROP --
  EXEC [CodeHouse].[GenerateCodeObject_DropComponent]  @ObjectType = @ObjectType,
                                                       @SchemaName = NULL,
                                                       @TableObject = NULL,
                                                       @CodeObjectName = @UsedCodeObjectName,
                                                       @DropComponent = @DropComponent OUTPUT;
  -- Extended Properties --
  IF @ObjectType = 'SBService' SET @ObjectType = 'Service';
  EXEC [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0]  @Level0_Type = @ObjectType,
                                                                   @Level0_Name = @UsedCodeObjectName,
                                                                   @Author = @Author,
                                                                   @Version = @Version,
                                                                   @Date = @Date,
                                                                   @DeploymentSet = @DeploymentSet,
                                                                   @CodeObjectRemark = @CodeObjectRemark,
                                                                   @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT;
  -- OUTPUT --
  SET @CodeObject = CONCAT(@CreateComponent, @CodeObject);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateCodeObject] (
  @Layer VARCHAR(50),
  @ObjectLayer VARCHAR(50) = NULL,
  @Stream VARCHAR(50),
  @StreamVariant VARCHAR(50),
  @CodeObjectName NVARCHAR(128),
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER,
  @LayerID SMALLINT = NULL OUTPUT,
  @StreamID SMALLINT = NULL OUTPUT,
  @StreamVariantID SMALLINT = NULL OUTPUT,
  @ObjectTypeID SMALLINT = NULL OUTPUT,
  @CodeTypeID SMALLINT = NULL OUTPUT,
  @CodeObjectID INT = NULL OUTPUT,
  @CodeVersion DECIMAL(9,1) = NULL OUTPUT,
  @CodeObject NVARCHAR(MAX) OUTPUT,
  @DropComponent NVARCHAR(MAX) = NULL OUTPUT,
  @ExtendedPropertiesComponent NVARCHAR(MAX) = NULL OUTPUT,
  @SchemaName NVARCHAR(128) = NULL OUTPUT,
  @UsedCodeObjectName NVARCHAR(128) = NULL OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObject
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  -- Working Vars. --
  DECLARE @CodeObjectOutput NVARCHAR(MAX);
  DECLARE @CodeObjectInput NVARCHAR(MAX);
  DECLARE @ObjectType VARCHAR(50),
          @CodeType VARCHAR(50);
  -- Formatters --
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  -- Messages --
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' was not found on table CodeHouse.CodeObject. Procedure Terminated.');
  DECLARE @NoFindTagMsg NVARCHAR(2048) = 'One or more ReplacementTags provided were not found on table CodeHouse.Tag. Procedure Terminated.';
  DECLARE @NoFindComponentMsg NVARCHAR(2048) = 'One or more Components provided were not found on table CodeHouse.CodeObject. Procedure Terminated.';
  -- Existence --
  -- Tags --
  IF EXISTS (SELECT [Tag] FROM @ReplacementTags RT WHERE NOT EXISTS(SELECT [Tag] FROM [CodeHouse].[Tag] T WHERE T.[Tag] = RT.[Tag]))
    THROW 50000, @NoFindTagMsg, 1;
  -- Components --
  IF EXISTS (SELECT [CodeObjectName] FROM @ReplacementComponents RC WHERE NOT EXISTS(SELECT 1 FROM [CodeHouse].[vCodeObject] CO WHERE CO.[Layer] = RC.[Layer] AND CO.[Stream] = RC.[Stream] AND CO.[StreamVariant] = RC.[StreamVariant] AND CO.[CodeObjectName] = RC.[CodeObjectName]))
    THROW 50000, @NoFindComponentMsg, 1;
  -- Object --
  SELECT @LayerID = [LayerID],
         @StreamID = [StreamID],
         @StreamVariantID = [StreamVariantID],
         @ObjectTypeID = [ObjectTypeID],
         @CodeTypeID = [CodeTypeID],
         @CodeVersion = [CodeVersion],
         @CodeObjectID = [CodeObjectID],
         @ObjectType = [ObjectType],
         @CodeType = [CodeType],
         @CodeObjectInput = [CodeObject]
    FROM [CodeHouse].[vCodeObject]
   WHERE [Layer] = @Layer AND [Stream] = @Stream AND [StreamVariant] = @StreamVariant AND [CodeObjectName] = @CodeObjectName;
  IF @LayerID IS NULL BEGIN;
    SELECT @StreamID = [StreamID],
           @StreamVariantID = [StreamVariantID],
           @ObjectTypeID = [ObjectTypeID],
           @CodeTypeID = [CodeTypeID],
           @CodeVersion = [CodeVersion],
           @CodeObjectID = [CodeObjectID],
           @ObjectType = [ObjectType],
           @CodeType = [CodeType],
           @CodeObjectInput = [CodeObject]
      FROM [CodeHouse].[vCodeObject]
     WHERE [Layer] = @ObjectLayer AND [Stream] = @Stream AND [StreamVariant] = @StreamVariant AND [CodeObjectName] = @CodeObjectName;
  END;
  IF (@CodeObjectID IS NULL)
    THROW 50000, @NoFindMsg, 1;
  -- Deployment --
  SET @DeploymentSet = ISNULL(@DeploymentSet, NEWID());
  -- Script --
  IF (@ObjectType = 'Script')
    EXEC [CodeHouse].[GenerateCodeObject_Script] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- Schema --
  IF (@ObjectType = 'Schema')
    EXEC [CodeHouse].[GenerateCodeObject_Schema] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- PartitionFunction --
  IF (@ObjectType = 'PartitionFunction')
    EXEC [CodeHouse].[GenerateCodeObject_PartitionFunction] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- PartitionScheme --
  IF (@ObjectType = 'PartitionScheme')
    EXEC [CodeHouse].[GenerateCodeObject_PartitionScheme] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- Table --
  IF (@ObjectType = 'Table')
    EXEC [CodeHouse].[GenerateCodeObject_Table] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  IF (@ObjectType = 'TemporalTable') BEGIN;
    IF TRY_CAST(RIGHT(LEFT(@@VERSION, 25), 4) AS INT) <= 2014 BEGIN;
      THROW 50000, 'TemporalTable (System versioning) is not supported in MSSQL <=2014. Terminating Procedure.', 1;
    END; ELSE BEGIN;
      EXEC [CodeHouse].[GenerateCodeObject_TemporalTable] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
    END;
  END;
  -- Index --
  IF (@ObjectType = 'Index')
    EXEC [CodeHouse].[GenerateCodeObject_Index] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- TableType --
  IF (@ObjectType = 'TableType')
    EXEC [CodeHouse].[GenerateCodeObject_TableType] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- DataType --
  IF (@ObjectType = 'DataType')
    EXEC [CodeHouse].[GenerateCodeObject_DataType] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- View --
  IF (@ObjectType = 'View')
    EXEC [CodeHouse].[GenerateCodeObject_View] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- Function --
  IF (@ObjectType = 'Function')
    EXEC [CodeHouse].[GenerateCodeObject_Function] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- Procedure --
  IF (@ObjectType = 'Procedure')
    EXEC [CodeHouse].[GenerateCodeObject_Procedure] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- SBContract --
  IF (@ObjectType = 'SBContract')
    EXEC [CodeHouse].[GenerateCodeObject_SBContract] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- SBMessageType --
  IF (@ObjectType = 'SBMessageType')
    EXEC [CodeHouse].[GenerateCodeObject_SBMessageType] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- SBQueue --
  IF (@ObjectType = 'SBQueue')
    EXEC [CodeHouse].[GenerateCodeObject_SBQueue] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
  -- SBService --
  IF (@ObjectType = 'SBService')
    EXEC [CodeHouse].[GenerateCodeObject_SBService] @CodeObjectID = @CodeObjectID, @ObjectType = @ObjectType, @ReplacementTags = @ReplacementTags, @ReplacementComponents = @ReplacementComponents, @DeploymentSet = @DeploymentSet, @CodeObject = @CodeObject OUTPUT, @DropComponent = @DropComponent OUTPUT, @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT, @SchemaName = @SchemaName OUTPUT, @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;

  SET @CodeObject = CONCAT(@CodeObject, @CRLF, @GoStatement);
  SET @DropComponent = CONCAT(@DropComponent, @CRLF, @GoStatement);
  SET @ExtendedPropertiesComponent = CONCAT(@ExtendedPropertiesComponent, @CRLF, @GoStatement);

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateDeployment_Output] (
  @DeploymentSet UNIQUEIDENTIFIER,
  @ReturnDropScript BIT = 1,
  @ReturnObjectScript BIT = 1,
  @ReturnExtendedPropertiesScript BIT = 1,
  @OnlyObjectTypes [CodeHouse].[ObjectType] READONLY
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Output Deployment
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @FileHeader NVARCHAR(MAX);
  DECLARE @FileSection NVARCHAR(MAX);
  DECLARE @FileObject NVARCHAR(MAX);
  DECLARE @FileFooter NVARCHAR(MAX);   
  DECLARE @CodeObjectFullNames [CodeHouse].[CodeObjectFullName];
  DECLARE @DeploymentName NVARCHAR(128),
          @DeploymentNotes NVARCHAR(MAX);
  SELECT @DeploymentName = [DeploymentName],
         @DeploymentNotes = [Notes]
    FROM [CodeHouse].[vDeploymentDocument] WHERE [DeploymentSet] = @DeploymentSet;
  DECLARE @DatabaseName NVARCHAR(128) = (SELECT TOP (1) [DatabaseName] FROM [CodeHouse].[vDeployment] WHERE [DeploymentSet] = @DeploymentSet),
          @SchemaName NVARCHAR(128);
  DECLARE @CodeObjectName NVARCHAR(128);
  DECLARE @UsedCodeObjectName NVARCHAR(128);
  DECLARE @UseComponent NVARCHAR(140) = CONCAT('USE ','[', @DatabaseName, ']', @CRLF, @GoStatement);
  DECLARE @MessagePrefix NVARCHAR(50);

  DROP TABLE IF EXISTS #DropComponents;
  CREATE TABLE #DropComponents (
    [ID] SMALLINT IDENTITY(1,1) NOT NULL,
    [DeploymentID] INT NOT NULL,
    [DatabaseName] NVARCHAR(128) NOT NULL,
    [SchemaName] NVARCHAR(128) NULL,
    [UsedCodeObjectName] NVARCHAR(128) NOT NULL,
    [DropComponent] NVARCHAR(MAX) NOT NULL,
    [ObjectType] VARCHAR(50) NOT NULL
  );
  DROP TABLE IF EXISTS #CodeObjects;
  CREATE TABLE #CodeObjects (
    [ID] SMALLINT IDENTITY(1,1) NOT NULL,
    [DeploymentID] INT NOT NULL,
    [DatabaseName] NVARCHAR(128) NOT NULL,
    [SchemaName] NVARCHAR(128) NULL,
    [UsedCodeObjectName] NVARCHAR(128) NOT NULL,
    [CodeObject] NVARCHAR(MAX) NOT NULL,
    [ObjectType] VARCHAR(50) NOT NULL
  );
  DROP TABLE IF EXISTS #ExtendedProperties;
  CREATE TABLE #ExtendedProperties (
    [ID] SMALLINT IDENTITY(1,1) NOT NULL,
    [DeploymentID] INT NOT NULL,
    [DatabaseName] NVARCHAR(128) NOT NULL,
    [SchemaName] NVARCHAR(128) NULL,
    [UsedCodeObjectName] NVARCHAR(128) NOT NULL,
    [ExtendedPropertiesComponent] NVARCHAR(MAX) NOT NULL,
    [ObjectType] VARCHAR(50) NOT NULL
  );
  DROP TABLE IF EXISTS #DirectExecutes;
  CREATE TABLE #DirectExecutes (
    [ID] SMALLINT IDENTITY(1,1) NOT NULL,
    [DeploymentID] INT NOT NULL,
    [DatabaseName] NVARCHAR(128) NOT NULL,
    [SchemaName] NVARCHAR(128) NULL,
    [UsedCodeObjectName] NVARCHAR(128) NOT NULL,
    [DirectExecuteComponent] NVARCHAR(MAX) NOT NULL,
    [ObjectType] VARCHAR(50) NOT NULL
  );
  -- File Header --
  IF EXISTS (SELECT 1 FROM @OnlyObjectTypes) BEGIN;
    INSERT INTO @CodeObjectFullNames (DatabaseName, SchemaName, CodeObjectName) 
      SELECT [DatabaseName],CASE WHEN [ObjectType] = 'Script' THEN 'Scripting' ELSE [SchemaName] END,[ObjectName] FROM [CodeHouse].[vDeployment] 
	  WHERE [DeploymentSet] = @DeploymentSet AND  [ObjectType] IN (SELECT [ObjectType] FROM @OnlyObjectTypes) ORDER BY [DeploymentOrdinal] ASC;
  END; ELSE BEGIN;
    INSERT INTO @CodeObjectFullNames (DatabaseName, SchemaName, CodeObjectName) 
      SELECT [DatabaseName],CASE WHEN [ObjectType] = 'Script' THEN 'Scripting' ELSE [SchemaName] END,[ObjectName] FROM [CodeHouse].[vDeployment] 
	  WHERE [DeploymentSet] = @DeploymentSet ORDER BY [DeploymentOrdinal] ASC;
  END;

  EXEC [CodeHouse].[GenerateCodeObject_FileHeader]  @DeploymentName = @DeploymentName,
                                                    @DeploymentNotes = @DeploymentNotes,
                                                    @DeploymentSet = @DeploymentSet,
                                                    @CodeObjectNames = @CodeObjectFullNames,
                                                    @Drops = @ReturnDropScript,
                                                    @Objects = @ReturnObjectScript,
                                                    @ExtendedProperties  = @ReturnExtendedPropertiesScript;
  -- Deployment Header --
  EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @UseComponent;
  EXEC [CodeHouse].[GenerateCodeObject_DeploymentHeader];
  DECLARE @CodeObjectOutput NVARCHAR(MAX),
          @DeploymentID INT,
          @DeploymentOrdinal SMALLINT;
  -- DROPS -- IN REVERSE ORDER FROM CREATION
  -- File Section --
  IF @ReturnDropScript = 1 BEGIN;
    EXEC [CodeHouse].[GenerateCodeObject_FileSection]  @SectionName = 'DROPS';
    INSERT INTO #DropComponents (DeploymentID, DatabaseName, SchemaName, UsedCodeObjectName, DropComponent, ObjectType)
      SELECT [DeploymentID], [DatabaseName],CASE WHEN [ObjectType] = 'Script' THEN 'Scripting' ELSE [SchemaName] END,[ObjectName],[DropScript],[ObjectType]
	    FROM [CodeHouse].[vDeployment] WHERE [DeploymentSet] = @DeploymentSet AND [CodeType] <> 'DirectExecute' ORDER BY [DeploymentOrdinal] ASC;
    -- REMOVE ANYTHING THAT'S NOT PART OF THE ONLY OBJECTS LIST --
    IF EXISTS (SELECT 1 FROM @OnlyObjectTypes) BEGIN;
      DELETE #DropComponents WHERE [ObjectType] NOT IN (SELECT [ObjectType] FROM @OnlyObjectTypes);
    END;
    -- Objects --
    WHILE EXISTS (SELECT 1 FROM #DropComponents) BEGIN;
      SET @CodeObjectOutput = NULL;
      SET @DeploymentOrdinal = NULL;
      SET @DeploymentID = NULL;
      SET @DatabaseName = NULL;
      SET @SchemaName = NULL;
      SET @UsedCodeObjectName = NULL;
      SELECT @DeploymentOrdinal = MAX(ID) FROM #DropComponents;
      SELECT @DeploymentID = DeploymentID,
             @DatabaseName = DatabaseName,
             @SchemaName = SchemaName,
             @UsedCodeObjectName = UsedCodeObjectName,
             @CodeObjectOutput = DropComponent
        FROM #DropComponents WHERE ID = @DeploymentOrdinal;
      SET @MessagePrefix = CASE WHEN @SchemaName  ='Scripting' THEN 'No Drop execution for ' ELSE 'Dropping: ' END;
      EXEC [CodeHouse].[GenerateCodeObject_DeploymentObjectHeader] @MessagePrefix = @MessagePrefix, @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @CodeObjectName = @UsedCodeObjectName;
      EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @CodeObjectOutput;
      EXEC [CodeHouse].[GenerateCodeObject_DeploymentObjectFooter] @DeploymentID = @DeploymentID;
      DELETE #DropComponents WHERE ID = @DeploymentOrdinal;
    END;
  END;

  -- OBJECTS -- IN ORDER OF CREATION
  -- File Section --
  IF @ReturnObjectScript = 1 BEGIN;
    EXEC [CodeHouse].[GenerateCodeObject_FileSection]  @SectionName = 'CREATES / SCRIPT EXECUTIONS';
    INSERT INTO #CodeObjects (DeploymentID, DatabaseName, SchemaName, UsedCodeObjectName, CodeObject, ObjectType)
      SELECT [DeploymentID], [DatabaseName],CASE WHEN [ObjectType] = 'Script' THEN 'Scripting' ELSE [SchemaName] END,[ObjectName],[ObjectScript], [ObjectType]
	    FROM [CodeHouse].[vDeployment] WHERE [DeploymentSet] = @DeploymentSet AND [CodeType] <> 'DirectExecute' ORDER BY [DeploymentOrdinal] ASC;
    -- REMOVE ANYTHING THAT'S NOT PART OF THE ONLY OBJECTS LIST --
    IF EXISTS (SELECT 1 FROM @OnlyObjectTypes) BEGIN;
      DELETE #CodeObjects WHERE [ObjectType] NOT IN (SELECT [ObjectType] FROM @OnlyObjectTypes);
    END;
    -- Objects --
    WHILE EXISTS (SELECT 1 FROM #CodeObjects) BEGIN;
      SET @CodeObjectOutput = NULL;
      SET @DeploymentOrdinal = NULL;
      SET @DeploymentID = NULL;
      SET @DatabaseName = NULL;
      SET @SchemaName = NULL;
      SET @UsedCodeObjectName = NULL;
      SELECT @DeploymentOrdinal = MIN(ID) FROM #CodeObjects;
      SELECT @DeploymentID = DeploymentID,
             @DatabaseName = DatabaseName,
             @SchemaName = SchemaName,
             @UsedCodeObjectName = UsedCodeObjectName,
             @CodeObjectOutput = CodeObject
        FROM #CodeObjects WHERE ID = @DeploymentOrdinal;
      SET @MessagePrefix = CASE WHEN @SchemaName  ='Scripting' THEN 'Execution for: ' ELSE 'Creating/Executing: ' END;
      EXEC [CodeHouse].[GenerateCodeObject_DeploymentObjectHeader] @MessagePrefix = @MessagePrefix, @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @CodeObjectName = @UsedCodeObjectName;
      EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @CodeObjectOutput;
      EXEC [CodeHouse].[GenerateCodeObject_DeploymentObjectFooter] @DeploymentID = @DeploymentID;
      DELETE #CodeObjects WHERE ID = @DeploymentOrdinal;
    END;
  END;
  -- EXTENDED PROPERTIES -- IN ORDER OF CREATION
  -- File Section --
  IF @ReturnExtendedPropertiesScript = 1 BEGIN;
    EXEC [CodeHouse].[GenerateCodeObject_FileSection]  @SectionName = 'EXTENDED PROPERTIES';
    INSERT INTO #ExtendedProperties (DeploymentID, DatabaseName, SchemaName, UsedCodeObjectName, ExtendedPropertiesComponent, ObjectType)
      SELECT [DeploymentID], [DatabaseName],CASE WHEN [ObjectType] = 'Script' THEN 'Scripting' ELSE [SchemaName] END,[ObjectName],[ExtendedPropertiesScript],[ObjectType]
	    FROM [CodeHouse].[vDeployment] WHERE [DeploymentSet] = @DeploymentSet AND [CodeType] <> 'DirectExecute' ORDER BY [DeploymentOrdinal] ASC;
    -- REMOVE ANYTHING THAT'S NOT PART OF THE ONLY OBJECTS LIST --
    IF EXISTS (SELECT 1 FROM @OnlyObjectTypes) BEGIN;
      DELETE #ExtendedProperties WHERE [ObjectType] NOT IN (SELECT [ObjectType] FROM @OnlyObjectTypes);
    END;
    -- Objects --
    WHILE EXISTS (SELECT 1 FROM #ExtendedProperties) BEGIN;
      SET @CodeObjectOutput = NULL;
      SET @DeploymentOrdinal = NULL;
      SET @DeploymentID = NULL;
      SET @DatabaseName = NULL;
      SET @SchemaName = NULL;
      SET @UsedCodeObjectName = NULL;
      SELECT @DeploymentOrdinal = MIN(ID) FROM #ExtendedProperties;
      SELECT @DeploymentID = DeploymentID,
             @DatabaseName = DatabaseName,
             @SchemaName = SchemaName,
             @UsedCodeObjectName = UsedCodeObjectName,
             @CodeObjectOutput = ExtendedPropertiesComponent 
       FROM #ExtendedProperties WHERE ID = @DeploymentOrdinal;
      SET @MessagePrefix = CASE WHEN @SchemaName  ='Scripting' THEN 'No Extended Properties execution for: ' ELSE 'Adding/Updating Extended Properties for: ' END;
      EXEC [CodeHouse].[GenerateCodeObject_DeploymentObjectHeader] @MessagePrefix = @MessagePrefix, @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @CodeObjectName = @UsedCodeObjectName;
      EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @CodeObjectOutput;
      EXEC [CodeHouse].[GenerateCodeObject_DeploymentObjectFooter] @DeploymentID = @DeploymentID;
      DELETE #ExtendedProperties WHERE ID = @DeploymentOrdinal;
    END;
  END;
  -- Deployment Footer --
  EXEC [CodeHouse].[GenerateCodeObject_DeploymentFooter] @DeploymentSet = @DeploymentSet;
  -- Direct Execute --
  IF @ReturnObjectScript = 1 BEGIN;  
    INSERT INTO #DirectExecutes (DeploymentID, DatabaseName, SchemaName, UsedCodeObjectName, DirectExecuteComponent, ObjectType)
      SELECT [DeploymentID], [DatabaseName],CASE WHEN [ObjectType] = 'Script' THEN 'Scripting' ELSE [SchemaName] END,[ObjectName],[ObjectScript],[ObjectType]
        FROM [CodeHouse].[vDeployment] WHERE [DeploymentSet] = @DeploymentSet AND [CodeType] = 'DirectExecute' ORDER BY [DeploymentOrdinal] ASC;
    -- REMOVE ANYTHING THAT'S NOT PART OF THE ONLY OBJECTS LIST --
    IF EXISTS (SELECT 1 FROM @OnlyObjectTypes) BEGIN;
      DELETE #DirectExecutes WHERE [ObjectType] NOT IN (SELECT [ObjectType] FROM @OnlyObjectTypes);
    END;
    IF EXISTS (SELECT 1 FROM #DirectExecutes)
      EXEC [CodeHouse].[GenerateCodeObject_FileSection]  @SectionName = 'DIRECT EXECUTION';
    WHILE EXISTS (SELECT 1 FROM #DirectExecutes) BEGIN;
      SET @CodeObjectOutput = NULL;
      SET @DeploymentOrdinal = NULL;
      SET @DeploymentID = NULL;
      SET @DatabaseName = NULL;
      SET @SchemaName = NULL;
      SET @UsedCodeObjectName = NULL;
      SELECT @DeploymentOrdinal = MIN(ID) FROM #DirectExecutes;
      SELECT @DeploymentID = DeploymentID,
             @DatabaseName = DatabaseName,
             @SchemaName = SchemaName,
             @UsedCodeObjectName = UsedCodeObjectName,
             @CodeObjectOutput = DirectExecuteComponent 
       FROM #DirectExecutes WHERE ID = @DeploymentOrdinal;
      SET @MessagePrefix = 'Direct Execution for: ';
      EXEC [CodeHouse].[GenerateCodeObject_DirectExecuteHeader] @MessagePrefix = @MessagePrefix, @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @CodeObjectName = @UsedCodeObjectName;
      EXEC [CodeHouse].[GenerateCodeObject_Output] @CodeObject = @CodeObjectOutput;
      EXEC [CodeHouse].[GenerateCodeObject_DirectExecuteFooter] @DeploymentID = @DeploymentID;
      DELETE #DirectExecutes WHERE ID = @DeploymentOrdinal;
    END;
  END;
  -- File Footer --
  EXEC [CodeHouse].[GenerateCodeObject_FileFooter];
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[GenerateDeployment] (
  @DeploymentName NVARCHAR(128) = NULL,
  @DeploymentNotes NVARCHAR(MAX) = NULL,
  @ReturnDropScript BIT = 1,
  @ReturnObjectScript BIT = 1,
  @ReturnExtendedPropertiesScript BIT = 1,
  @Layer VARCHAR(50),
  @GenerateList [CodeHouse].[GenerateCodeObjectList] READONLY,
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @ReplacementComponents [CodeHouse].[ReplacementComponent] READONLY,
  @DeploymentSet UNIQUEIDENTIFIER = NULL OUTPUT,
  @OnlyObjectTypes [CodeHouse].[ObjectType] READONLY
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Generate code from CodeObjectList
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @DeploymentStream VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{Stream}');
  -- Deployments record the Stream and Variant of the deployment --
  IF @DeploymentStream IS NULL
    THROW 50000, '{Stream} Tag and Value must be provided. Terminating Procedure.', 1;
  DECLARE @DeploymentStreamVariant VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = '{StreamVariant}');
  IF @DeploymentStreamVariant IS NULL
    THROW 50000, '{StreamVariant} Tag and Value must be provided. Terminating Procedure.', 1;
  -- Deployment ID
  DECLARE @ReDeployment BIT = 0; IF @DeploymentSet IS NOT NULL SET @ReDeployment = 1;
    SET @DeploymentSet = ISNULL(@DeploymentSet, NEWID());
  IF (@DeploymentName IS NULL OR TRIM(@DeploymentName) = '' AND @ReDeployment = 0)
    THROW 50000, 'DeploymentName must be supplied. Procedure terminated.', 1;
  IF (@DeploymentNotes IS NULL OR TRIM(@DeploymentNotes) = '' AND @ReDeployment = 0)
    THROW 50000, 'DeploymentNotes must be supplied. Procedure terminated.', 1;
  DECLARE @CodeObject NVARCHAR(MAX),
          @DropComponent NVARCHAR(MAX),
          @ExtendedPropertiesComponent NVARCHAR(MAX); 
  DECLARE @DatabaseName NVARCHAR(128),
          @SchemaName NVARCHAR(128),
          @Stream VARCHAR(50),
          @StreamVariant VARCHAR(50),
          @ObjectType VARCHAR(50),
          @CodeType VARCHAR(50),
          @Ordinal SMALLINT;
  DECLARE @LayerID SMALLINT = (SELECT [LayerID] FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer),
          @StreamID SMALLINT = (SELECT [StreamID] FROM [CodeHouse].[Stream] WHERE [Stream] = @DeploymentStream),
          @StreamVariantID SMALLINT = (SELECT [StreamVariantID] FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @DeploymentStreamVariant),
          @ObjectTypeID SMALLINT,
          @CodeTypeID SMALLINT,
          @CodeObjectID INT,
          @CodeVersion DECIMAL(9,1),
          @ObjectLayer VARCHAR(50);
  DECLARE @CodeObjectName NVARCHAR(128);
  DECLARE @UsedCodeObjectName NVARCHAR(128);
  SELECT TOP (1) @DatabaseName = [DatabaseName] FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer;
  IF @DatabaseName = '{Database}' BEGIN
    SET @Layer = (SELECT [Value] FROM @ReplacementTags WHERE [Tag] = '{Layer}');
    SELECT @LayerID = [LayerID], @DatabaseName = [DatabaseName] FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer;
  END;
  IF @LayerID IS NULL
    THROW 50000, 'LayerID could not be located on [CodeHouse].[Layer]. Terminating Procedure.', 1;
  IF @DatabaseName IS NULL
    THROW 50000, 'DatabaseName could not be located on [CodeHouse].[Layer]. Terminating Procedure.', 1;
  IF @StreamID IS NULL
    THROW 50000, 'StreamID could not be located on [CodeHouse].[Stream]. Terminating Procedure.', 1;
  IF @StreamVariantID IS NULL
    THROW 50000, 'StreamVariantID could not be located on [CodeHouse].[StreamVariant]. Terminating Procedure.', 1;

  DROP TABLE IF EXISTS ##CodeHouse_Deployment_Components;
  CREATE TABLE ##CodeHouse_Deployment_Components (
    [CodeObjectID] INT NOT NULL
  );

  DECLARE @CodeObjectlist [CodeHouse].[GenerateCodeObjectList];
  INSERT INTO @CodeObjectlist
    SELECT * FROM @GenerateList;
  DECLARE @CodeObjectFullNames [CodeHouse].[CodeObjectFullName];

  DECLARE @CodeObjectNames TABLE (
    [CodeObjectName] NVARCHAR(128) NOT NULL
  );

  IF EXISTS (SELECT 1 FROM @OnlyObjectTypes) BEGIN;
    DELETE @CodeObjectlist WHERE [ObjectType] NOT IN (SELECT [ObjectType] FROM @OnlyObjectTypes);
  END;

  WHILE EXISTS (SELECT 1 FROM @CodeObjectlist) BEGIN; -- Ordinals
    SET @CodeObjectName = NULL;
    SELECT TOP (1) @Stream = [Stream],
                   @StreamVariant = [StreamVariant],
                   @CodeObjectName = [CodeObjectName],
                   @ObjectType = [ObjectType],
                   @CodeType = [CodeType],
                   @Ordinal = [Ordinal],
                   @ObjectLayer = [ObjectLayer]
              FROM @CodeObjectlist
             ORDER BY [Ordinal] ASC;
    IF NOT EXISTS (
                     SELECT [CodeObjectName]
                       FROM [CodeHouse].[vCodeObject]
                      WHERE [Layer] = COALESCE(@ObjectLayer, @Layer)
                        AND [Stream] = @Stream
                        AND [StreamVariant] = @StreamVariant
                        AND ([CodeObjectName] = @CodeObjectName OR @CodeObjectName IS NULL)
                        AND ([ObjectType] = @ObjectType OR @ObjectType IS NULL)
                        AND ([CodeType] = @CodeType OR @CodeType IS NULL)
	) THROW 50000, 'One or more CodeObjects provided for generation does not exist. Terminating procedure.', 1;

    INSERT INTO @CodeObjectNames
    SELECT [CodeObjectName]
      FROM [CodeHouse].[vCodeObject]
     WHERE [Layer] = COALESCE(@ObjectLayer, @Layer)
       AND [Stream] = @Stream
       AND [StreamVariant] = @StreamVariant
       AND ([CodeObjectName] = @CodeObjectName OR @CodeObjectName IS NULL)
       AND ([ObjectType] = @ObjectType OR @ObjectType IS NULL)
       AND ([CodeType] = @CodeType OR @CodeType IS NULL);

    WHILE EXISTS (SELECT 1 FROM @CodeObjectNames) AND @ReDeployment = 0 BEGIN; -- Objects
      SET @CodeObject = NULL;
      SET @DropComponent = NULL;
      SET @ExtendedPropertiesComponent = NULL;
      SET @CodeObjectName = (SELECT TOP (1)[CodeObjectName] FROM @CodeObjectNames ORDER BY [CodeObjectName] ASC);
      -- Generate objects from templates --
      EXEC [CodeHouse].[GenerateCodeObject] @Layer = @Layer,
                                            @ObjectLayer = @ObjectLayer,
                                            @Stream = @Stream,
                                            @StreamVariant = @StreamVariant,
                                            @CodeObjectName = @CodeObjectName,
                                            @ReplacementTags = @ReplacementTags,
                                            @ReplacementComponents = @ReplacementComponents,
                                            @DeploymentSet = @DeploymentSet,
                                            @ObjectTypeID = @ObjectTypeID OUTPUT,
                                            @CodeTypeID = @CodeTypeID OUTPUT,
                                            @CodeObjectID = @CodeObjectID OUTPUT,
                                            @CodeVersion = @CodeVersion OUTPUT,
                                            @CodeObject = @CodeObject OUTPUT,
                                            @DropComponent = @DropComponent OUTPUT,
                                            @ExtendedPropertiesComponent = @ExtendedPropertiesComponent OUTPUT,
                                            @SchemaName = @SchemaName OUTPUT,
                                            @UsedCodeObjectName = @UsedCodeObjectName OUTPUT;
      -- Are there still tags/components in place? --
      IF CHARINDEX('{<',@CodeObject) > 0 BEGIN;
	    EXEC CodeHouse.GenerateCodeObject_Output @CodeObject;
        THROW 50000, 'There are Components e.g."{<component>}" which have not been replaced via @ReplaceComponents. Terminating program.', 1;
      END;
      IF CHARINDEX('{',@CodeObject) > 0 AND CHARINDEX('{<',@CodeObject) = 0 BEGIN;
	    EXEC CodeHouse.GenerateCodeObject_Output @CodeObject;
        THROW 50000, 'There are Tags e.g."{tag}" which have not been replaced via @ReplaceTags. Terminating program.', 1;
      END;
      -- Record actual objects in deployment --
      EXEC [CodeHouse].[SetDeployment] @DeploymentSet = @DeploymentSet,
                                       @DeploymentStatus = 'U',
                                       @LayerID = @LayerID,
                                       @StreamID = @StreamID,
                                       @StreamVariantID = @StreamVariantID,
                                       @CodeVersion = @CodeVersion,
                                       @ObjectTypeID = @ObjectTypeID,
                                       @CodeTypeID = @CodeTypeID,
                                       @CodeObjectID = @CodeObjectID,
                                       @DeploymentOrdinal = @Ordinal,
                                       @ObjectSchema = @SchemaName,
                                       @ObjectName = @UsedCodeObjectName,
                                       @DropScript = @DropComponent,
                                       @ObjectScript = @CodeObject,
                                       @ExtendedPropertiesScript = @ExtendedPropertiesComponent,
                                       @DeploymentServer = @@SERVERNAME;
      DELETE FROM @CodeObjectNames WHERE [CodeObjectName] = @CodeObjectName;
    END; -- Objects
    DELETE FROM @CodeObjectlist WHERE [Ordinal] = @Ordinal;
  END; -- Ordinals
  -- Deployment Tags --
  IF @ReDeployment = 0 EXEC [CodeHouse].[SetDeploymentTag] @DeploymentSet = @DeploymentSet, @DeploymentTags = @ReplacementTags;
  -- Deployment Components --
  SET @CodeObjectID = NULL;
  WHILE EXISTS (SELECT 1 FROM ##CodeHouse_Deployment_Components) AND @ReDeployment = 0 BEGIN;
    SET @CodeObjectID = (SELECT TOP (1) CodeObjectID FROM ##CodeHouse_Deployment_Components)
    EXEC [CodeHouse].[SetDeploymentComponent] @DeploymentSet = @DeploymentSet, @CodeObjectID = @CodeObjectID;
    DELETE FROM ##CodeHouse_Deployment_Components WHERE CodeObjectID = @CodeObjectID;
  END;
  -- Deployment Notes --
  IF @ReDeployment = 0 EXEC [CodeHouse].[SetDeploymentDocument] @DeploymentSet = @DeploymentSet, @DeploymentName = @DeploymentName, @DeploymentNotes = @DeploymentNotes;
  -- CLEANUP --
  DROP TABLE IF EXISTS ##CodeHouse_Deployment_Components;
  -- OUTPUT --
  EXEC [CodeHouse].[GenerateDeployment_Output] @DeploymentSet = @DeploymentSet,
                                               @ReturnDropScript = @ReturnDropScript,
                                               @ReturnObjectScript = @ReturnObjectScript,
                                               @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript,
                                               @OnlyObjectTypes = @OnlyObjectTypes;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

/* End of File ********************************************************************************************************************/