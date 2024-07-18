CREATE SCHEMA [tSQLt_Helper] AUTHORIZATION [dbo];
GO

-- [tSQLt_Helper].[SystemVersioning_Remove] 'Lookup','MatchEntity'
GO

CREATE PROCEDURE [tSQLt_Helper].[SystemVersioning_Remove] (
  @Schema NVARCHAR (128), @Table NVARCHAR (128)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  BEGIN;
    BEGIN TRY;
      DECLARE @CMD NVARCHAR (MAX);
      DECLARE @FullName SYSNAME;
      SET @Schema = QUOTENAME( REPLACE( REPLACE( @Schema, '[', '' ), ']', '' ));
      SET @Table = QUOTENAME( REPLACE( REPLACE( @Table, '[', '' ), ']', '' ));
      SET @FullName = CONCAT( @Schema, '.', @Table );
      IF OBJECT_ID( @FullName, N'U' ) IS NULL
        THROW 50000, 'Table does not exist.', 1;
      -- SYSTEM VERSIONING OFF --
      SET @CMD = CONCAT( N'ALTER TABLE ', @FullName, ' SET ( SYSTEM_VERSIONING = OFF );' );
      EXEC [sp_ExecuteSQL] @CMD;
      -- PERIOD SYSTEM_TIME --
      SET @CMD = CONCAT( N'ALTER TABLE ', @FullName, '  DROP PERIOD FOR SYSTEM_TIME;' );
      EXEC [sp_ExecuteSQL] @CMD;
    END TRY
    BEGIN CATCH
      THROW;
    END CATCH;
  END;
GO

-- [tSQLt_Helper].[SystemVersioning_Add] 'Lookup','MatchEntity', 'SystemFromDate', 'SystemToDate', 'Lookup', 'MatchEntity_History';
GO

CREATE PROCEDURE [tSQLt_Helper].[SystemVersioning_Add] (
  @Schema         NVARCHAR (128)
 ,@Table          NVARCHAR (128)
 ,@FromDateColumn NVARCHAR (28)
 ,@ToDateColumn   NVARCHAR (28)
 ,@HistorySchema  NVARCHAR (128)
 ,@HistoryTable   NVARCHAR (128)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  BEGIN;
    BEGIN TRY;
      DECLARE @CMD NVARCHAR (MAX);
      DECLARE @FullName SYSNAME;
      DECLARE @HistoryFullName SYSNAME;
      SET @Schema = QUOTENAME( REPLACE( REPLACE( @Schema, '[', '' ), ']', '' ));
      SET @Table = QUOTENAME( REPLACE( REPLACE( @Table, '[', '' ), ']', '' ));
      SET @FullName = CONCAT( @Schema, '.', @Table );
      SET @FromDateColumn = QUOTENAME( REPLACE( REPLACE( @FromDateColumn, '[', '' ), ']', '' ));
      SET @ToDateColumn = QUOTENAME( REPLACE( REPLACE( @ToDateColumn, '[', '' ), ']', '' ));
      SET @HistorySchema = QUOTENAME( REPLACE( REPLACE( @HistorySchema, '[', '' ), ']', '' ));
      SET @HistoryTable = QUOTENAME( REPLACE( REPLACE( @HistoryTable, '[', '' ), ']', '' ));
      SET @HistoryFullName = CONCAT( @HistorySchema, '.', @HistoryTable );
      IF OBJECT_ID( @FullName, N'U' ) IS NULL
        THROW 50000, 'Table does not exist.', 1;
      -- PERIOD SYSTEM_TIME --
      SET @CMD = CONCAT( N'ALTER TABLE ', @FullName, ' ADD PERIOD FOR SYSTEM_TIME (', @FromDateColumn, ',', @ToDateColumn, ');' );
      BEGIN TRY
        EXEC [sp_ExecuteSQL] @CMD;
      END TRY
      BEGIN CATCH
        GOTO Versioning;
      END CATCH;
      -- SYSTEM VERSIONING ON --
      Versioning:
      SET @CMD = CONCAT( N'ALTER TABLE ', @FullName, '  SET ( SYSTEM_VERSIONING = ON (HISTORY_TABLE = ', @HistoryFullName, '));' );
      EXEC [sp_ExecuteSQL] @CMD;
    END TRY
    BEGIN CATCH
      THROW;
    END CATCH;
  END;
GO

GO

CREATE PROCEDURE [tSQLt_Helper].[SchemaBinding_Comment] (
  @Schema NVARCHAR (128), @Name NVARCHAR (255)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  BEGIN
    BEGIN TRY;
      DECLARE @PositionSchemaBinding INT;
      DECLARE @Command NVARCHAR (MAX);
      DECLARE @FullName SYSNAME;
      DECLARE @Seek NVARCHAR (150) = N'WITH SCHEMABINDING';
      DECLARE @Replacement NVARCHAR (150) = CONCAT( N'--WITH SCHEMABINDING ', CHAR( 13 ), CHAR( 10 ));
      SET @Schema = QUOTENAME( REPLACE( REPLACE( @Schema, '[', '' ), ']', '' ));
      SET @Name = QUOTENAME( REPLACE( REPLACE( @Name, '[', '' ), ']', '' ));
      SET @FullName = CONCAT( @Schema, '.', @Name );

      SELECT @Command = OBJECT_DEFINITION( OBJECT_ID( @FullName ));
      SET @PositionSchemaBinding = CHARINDEX( 'WITH SCHEMABINDING', @Command );

      IF NOT @PositionSchemaBinding = 0
        BEGIN;
          SET @Command = REPLACE( REPLACE( REPLACE( @Command, @Seek, @Replacement ), 'CREATE VIEW', 'ALTER VIEW' ), 'CREATE FUNCTION', 'ALTER FUNCTION' );
          EXECUTE [sp_executesql] @Command;
        END;
    END TRY
    BEGIN CATCH
      THROW;
    END CATCH;
  END;
GO

GO

CREATE PROCEDURE [tSQLt_Helper].[SchemaBinding_UnComment] (
  @Schema NVARCHAR (128), @Name NVARCHAR (255)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  BEGIN
    BEGIN TRY;
      DECLARE @Command NVARCHAR (MAX);
      DECLARE @FullName SYSNAME;
      SET @Schema = QUOTENAME( REPLACE( REPLACE( @Schema, '[', '' ), ']', '' ));
      SET @Name = QUOTENAME( REPLACE( REPLACE( @Name, '[', '' ), ']', '' ));
      SET @FullName = CONCAT( @Schema, '.', @Name );
      DECLARE @Replacement NVARCHAR (150) = N'WITH SCHEMABINDING';
      DECLARE @Seek NVARCHAR (150) = CONCAT( N'--WITH SCHEMABINDING ', CHAR( 13 ), CHAR( 10 ));
      SELECT @Command = OBJECT_DEFINITION( OBJECT_ID( @FullName ));

      SET @Command = REPLACE( REPLACE( REPLACE( @Command, @Seek, @Replacement ), 'CREATE VIEW', 'ALTER VIEW' ), 'CREATE FUNCTION', 'ALTER FUNCTION' );
      EXECUTE [sp_executesql] @Command;
    END TRY
    BEGIN CATCH
      THROW;
    END CATCH;
  END;
GO