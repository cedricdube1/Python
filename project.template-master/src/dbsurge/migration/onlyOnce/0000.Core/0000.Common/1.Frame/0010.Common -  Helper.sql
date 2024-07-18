/***********************************************************************************************************************************
* Script      : 10.Common - Helper.sql                                                                                             *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-20                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO
CREATE FUNCTION [Helper].[CreateHTMLTable_FromXMLRAW](
  @XMLRaw XML
) RETURNS NVARCHAR(MAX)
AS
BEGIN
  RETURN
  (
      SELECT N'<table border="1">' +
      CONVERT(NVARCHAR(MAX),@XMLRaw.query('let $first:=/row[1]
                  return 
                  <tr> 
                  {
                  for $th in $first/*
                  return <td>{local-name($th)}</td>
                  }
                  </tr>')) +
      CONVERT(NVARCHAR(MAX),@XMLRaw.query('for $tr in /row
                   return 
                   <tr>
                   {
                   for $td in $tr/*
                   return <td>{string($td)}</td>
                   }
                   </tr>')) + N'/table>'
  );
END
GO
--EXEC [Helper].[TableStorage] @SchemaName = 'dbo', @TableName = 'DimPlayer';
GO
CREATE PROCEDURE [Helper].[TableStorage] (
  @SchemaName NVARCHAR (128) = NULL,
  @TableName NVARCHAR(128) = NULL,
  @TableNamePattern NVARCHAR(128) = NULL,
  @TableNamePatternPosition CHAR(1) = 'A', --L = Left, R = Right, A = Anywhere
  @IncludeEmptyTables BIT = 0
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY;
  SELECT DB_NAME() AS DatabaseName, SchemaName, TableName, PartitionNumber, [FileGroup], Display_RowCount, Display_Used_MB, Display_Unused_MB, Display_Total_MB, [RowCount], Used_MB, Unused_MB, Total_MB 
    FROM (SELECT S.Name AS SchemaName,
                 T.Name AS TableName,
                 P.partition_number AS PartitionNumber,
                 FG.name AS [FileGroup],
                 FORMAT(P.rows,'N0') AS Display_RowCount,
                 FORMAT(CAST(ROUND((SUM(SAU.used_pages) / 128.00), 2) AS NUMERIC(36, 2)),'N2') AS Display_Used_MB,
                 FORMAT(CAST(ROUND((SUM(SAU.total_pages) - SUM(SAU.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)),'N2') AS Display_Unused_MB,
                 FORMAT(CAST(ROUND((SUM(SAU.total_pages) / 128.00), 2) AS NUMERIC(36, 2)),'N2') AS Display_Total_MB,
                 P.rows AS [RowCount],
                 CAST(ROUND((SUM(SAU.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB,
                 CAST(ROUND((SUM(SAU.total_pages) - SUM(SAU.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB,
                 CAST(ROUND((SUM(SAU.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB
            FROM sys.tables T
           INNER JOIN sys.schemas S
              ON T.schema_id = S.schema_id
           INNER JOIN sys.indexes I
              ON T.OBJECT_ID = I.object_id
             AND I.is_primary_key = 1
           INNER JOIN sys.partitions P
              ON I.object_id = P.OBJECT_ID AND I.index_id = P.index_id
           INNER JOIN sys.allocation_units SAU
              ON P.partition_id = SAU.container_id
            LEFT OUTER JOIN sys.partition_schemes PS 
              ON I.data_space_id = PS.data_space_id
            LEFT OUTER JOIN sys.destination_data_spaces DDS 
              ON PS.data_space_id = DDS.partition_scheme_id 
             AND P.partition_number = DDS.destination_id
           INNER JOIN sys.filegroups FG 
             ON COALESCE(DDS.data_space_id, I.data_space_id) = FG.data_space_id
           WHERE ((T.name = @TableName AND S.name = @SchemaName) OR (S.name = @SchemaName AND @Tablename IS NULL) OR (@SchemaName IS NULL AND @TableName IS NULL))
		     AND (   (@TableNamePatternPosition = 'A' AND T.name LIKE '%' + @TableNamePattern + '%' ) 
			      OR (@TableNamePatternPosition = 'R' AND T.name LIKE '%' + @TableNamePattern) 
				  OR (@TableNamePatternPosition = 'L' AND T.name LIKE @TableNamePattern + '%') 
				  OR @TableNamePattern IS NULL)
           GROUP BY T.Name, S.Name, P.Rows, P.partition_number, FG.name) QRY
     WHERE ([RowCount] <> 0 OR @IncludeEmptyTables =1 )
     ORDER BY SchemaName ASC, TableName ASC, PartitionNumber ASC;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
GO
--EXEC [Helper].[IndexScript_ColumnStore] @SchemaName = 'dbo', @TableName = 'DimPlayer';
GO
CREATE PROCEDURE [Helper].[IndexScript_ColumnStore] (
  @SchemaName NVARCHAR (128) = NULL,
  @TableName NVARCHAR(128) = NULL
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY;
  SELECT DISTINCT '[' + sc.name + '].[' + t.NAME + ']' AS TableName,
                  'DROP INDEX IF EXISTS [' + i.NAME + '] ON [' + sc.name + '].[' + t.NAME + '];' AS DropScript,
                  'CREATE ' + CASE WHEN i.type = 5 THEN 'CLUSTERED' ELSE 'NONCLUSTERED' END + ' COLUMNSTORE INDEX [' + i.NAME + '] ON [' + sc.name + '].[' + t.NAME + '] (' + IndexColumns.IndexColumnList + ') WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);' AS CreationScript
    FROM sys.tables AS t
   INNER JOIN sys.schemas AS sc 
     ON t.schema_id=sc.schema_id
   INNER JOIN sys.indexes AS i
     ON t.object_id = i.object_id
   INNER JOIN ( SELECT C.object_id, icc.index_id,
                         (
                            STUFF((
                                  SELECT ',' + sc.NAME
                                  FROM sys.columns sc
                                  INNER JOIN sys.index_columns AS ic
                                   ON sc.object_id = ic.object_id
								  AND sc.column_id = ic.column_id
	                              AND ic.is_included_column = 1
                                  WHERE sc.object_id = C.object_id
								  AND ic.index_id = icc.index_id
                                  FOR XML PATH(''),
                                     TYPE
                                  ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
                            ) AS IndexColumnList
                   FROM sys.columns AS C
                  INNER JOIN sys.index_columns AS icc
                   ON C.object_id = icc.object_id
                  AND C.column_id = icc.column_id
                  AND icc.is_included_column = 1
                  GROUP BY C.object_id, icc.index_id
     ) AS IndexColumns
     ON IndexColumns.object_id = i.object_id AND IndexColumns.index_id = i.index_id
  WHERE i.type IN (5,6)
    AND ((t.name = @TableName AND sc.name = @SchemaName) OR (sc.name = @SchemaName AND @Tablename IS NULL) OR (@SchemaName IS NULL AND @TableName IS NULL))
  ORDER BY '[' + sc.name + '].[' + t.NAME + ']';

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
--EXEC [Helper].[IndexScript_RowStore] @SchemaName = 'Pala_US_NJ', @TableName = 'ApplicationSession_Held';
GO
CREATE PROCEDURE [Helper].[IndexScript_RowStore] (
  @SchemaName NVARCHAR (128) = NULL,
  @TableName NVARCHAR(128) = NULL
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  /*****************************************************************************
  MIT License, http://www.opensource.org/licenses/mit-license.php
  Contact: help@sqlworkbooks.com
  Copyright (c) 2018 SQL Workbooks LLC
  Permission is hereby granted, free of charge, to any person 
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without 
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom 
  the Software is furnished to do so, subject to the following 
  conditions:
  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
  OTHER DEALINGS IN THE SOFTWARE.
  *****************************************************************************/
BEGIN
BEGIN TRY;

  SELECT 
      DB_NAME() AS database_name,
      sc.name + N'.' + t.name AS table_name,
      (SELECT MAX(user_reads) 
          FROM (VALUES (last_user_seek), (last_user_scan), (last_user_lookup)) AS value(user_reads)) AS last_user_read,
      last_user_update,
      CASE si.index_id WHEN 0 THEN N'/* No create statement (Heap) */'
      ELSE 
          CASE is_primary_key WHEN 1 THEN
              N'ALTER TABLE ' + QUOTENAME(sc.name) + N'.' + QUOTENAME(t.name) + N' ADD CONSTRAINT ' + QUOTENAME(si.name) + N' PRIMARY KEY ' +
                  CASE WHEN si.index_id > 1 THEN N'NON' ELSE N'' END + N'CLUSTERED '
              ELSE N'CREATE ' + 
                  CASE WHEN si.is_unique = 1 then N'UNIQUE ' ELSE N'' END +
                  CASE WHEN si.index_id > 1 THEN N'NON' ELSE N'' END + N'CLUSTERED ' +
                  N'INDEX ' + QUOTENAME(si.name) + N' ON ' + QUOTENAME(sc.name) + N'.' + QUOTENAME(t.name) + N' '
          END +
          /* key def */ N'(' + key_definition + N')' +
          /* includes */ CASE WHEN include_definition IS NOT NULL THEN 
              N' INCLUDE (' + include_definition + N')'
              ELSE N''
          END +
          /* filters */ CASE WHEN filter_definition IS NOT NULL THEN 
              N' WHERE ' + filter_definition ELSE N''
          END +
          /* with clause - compression goes here */
          CASE WHEN row_compression_partition_list IS NOT NULL OR page_compression_partition_list IS NOT NULL 
              THEN N' WITH (' +
                  CASE WHEN row_compression_partition_list IS NOT NULL THEN
                      N'DATA_COMPRESSION = ROW ' + CASE WHEN psc.name IS NULL THEN N'' ELSE + N' ON PARTITIONS (' + row_compression_partition_list + N')' END
                  ELSE N'' END +
                  CASE WHEN row_compression_partition_list IS NOT NULL AND page_compression_partition_list IS NOT NULL THEN N', ' ELSE N'' END +
                  CASE WHEN page_compression_partition_list IS NOT NULL THEN
                      N'DATA_COMPRESSION = PAGE ' + CASE WHEN psc.name IS NULL THEN N'' ELSE + N' ON PARTITIONS (' + page_compression_partition_list + N')' END
                  ELSE N'' END
              + N')'
              ELSE N''
          END +
          /* ON where? filegroup? partition scheme? */
          ' ON ' + CASE WHEN psc.name is null 
              THEN ISNULL(QUOTENAME(fg.name),N'')
              ELSE psc.name + N' (' + partitioning_column.column_name + N')' 
              END
          + N';'
      END AS index_create_statement,
      si.index_id,
      si.name AS index_name,
      partition_sums.reserved_in_row_GB,
      partition_sums.reserved_LOB_GB,
      partition_sums.row_count,
      stat.user_seeks,
      stat.user_scans,
      stat.user_lookups,
      user_updates AS queries_that_modified,
      partition_sums.partition_count,
      si.allow_page_locks,
      si.allow_row_locks,
      si.is_hypothetical,
      si.has_filter,
      si.fill_factor,
      si.is_unique,
      ISNULL(pf.name, '/* Not partitioned */') AS partition_function,
      ISNULL(psc.name, fg.name) AS partition_scheme_or_filegroup,
      t.create_date AS table_created_date,
      t.modify_date AS table_modify_date
  FROM sys.indexes AS si
  JOIN sys.tables AS t ON si.object_id=t.object_id
  JOIN sys.schemas AS sc ON t.schema_id=sc.schema_id
  LEFT JOIN sys.dm_db_index_usage_stats AS stat ON 
      stat.database_id = DB_ID() 
      and si.object_id=stat.object_id 
      and si.index_id=stat.index_id
  LEFT JOIN sys.partition_schemes AS psc ON si.data_space_id=psc.data_space_id
  LEFT JOIN sys.partition_functions AS pf ON psc.function_id=pf.function_id
  LEFT JOIN sys.filegroups AS fg ON si.data_space_id=fg.data_space_id
  /* Key list */ OUTER APPLY ( SELECT STUFF (
      (SELECT N', ' + QUOTENAME(c.name) +
          CASE ic.is_descending_key WHEN 1 then N' DESC' ELSE N'' END
      FROM sys.index_columns AS ic 
      JOIN sys.columns AS c ON 
          ic.column_id=c.column_id  
          and ic.object_id=c.object_id
      WHERE ic.object_id = si.object_id
          and ic.index_id=si.index_id
          and ic.key_ordinal > 0
      ORDER BY ic.key_ordinal FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,2,'')) AS keys ( key_definition )
  /* Partitioning Ordinal */ OUTER APPLY (
      SELECT MAX(QUOTENAME(c.name)) AS column_name
      FROM sys.index_columns AS ic 
      JOIN sys.columns AS c ON 
          ic.column_id=c.column_id  
          and ic.object_id=c.object_id
      WHERE ic.object_id = si.object_id
          and ic.index_id=si.index_id
          and ic.partition_ordinal = 1) AS partitioning_column
  /* Include list */ OUTER APPLY ( SELECT STUFF (
      (SELECT N', ' + QUOTENAME(c.name)
      FROM sys.index_columns AS ic 
      JOIN sys.columns AS c ON 
          ic.column_id=c.column_id  
          and ic.object_id=c.object_id
      WHERE ic.object_id = si.object_id
          and ic.index_id=si.index_id
          and ic.is_included_column = 1
      ORDER BY c.name FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,2,'')) AS includes ( include_definition )
  /* Partitions */ OUTER APPLY ( 
      SELECT 
          COUNT(*) AS partition_count,
          CAST(SUM(ps.in_row_reserved_page_count)*8./1024./1024. AS NUMERIC(32,1)) AS reserved_in_row_GB,
          CAST(SUM(ps.lob_reserved_page_count)*8./1024./1024. AS NUMERIC(32,1)) AS reserved_LOB_GB,
          SUM(ps.row_count) AS row_count
      FROM sys.partitions AS p
      JOIN sys.dm_db_partition_stats AS ps ON
          p.partition_id=ps.partition_id
      WHERE p.object_id = si.object_id
          and p.index_id=si.index_id
      ) AS partition_sums
  /* row compression list by partition */ OUTER APPLY ( SELECT STUFF (
      (SELECT N', ' + CAST(p.partition_number AS VARCHAR(32))
      FROM sys.partitions AS p
      WHERE p.object_id = si.object_id
          and p.index_id=si.index_id
          and p.data_compression = 1
      ORDER BY p.partition_number FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,2,'')) AS row_compression_clause ( row_compression_partition_list )
  /* data compression list by partition */ OUTER APPLY ( SELECT STUFF (
      (SELECT N', ' + CAST(p.partition_number AS VARCHAR(32))
      FROM sys.partitions AS p
      WHERE p.object_id = si.object_id
          and p.index_id=si.index_id
          and p.data_compression = 2
      ORDER BY p.partition_number FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,2,'')) AS page_compression_clause ( page_compression_partition_list )
  WHERE 
      si.type IN (0,1,2) /* heap, clustered, nonclustered */
   AND ((t.name = @TableName AND sc.name = @SchemaName) OR (sc.name = @SchemaName AND @Tablename IS NULL) OR (@SchemaName IS NULL AND @TableName IS NULL))
  ORDER BY table_name, si.index_id
      OPTION (RECOMPILE);
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Helper].[ViewSchemaBinding_Remove] (
  @ViewName NVARCHAR(255)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-03-16
  -- Description: Remove WITH SCHEMABINDING clause from view
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @PositionShemaBinding INT;
  DECLARE @Command NVARCHAR(MAX);

  SELECT @Command = OBJECT_DEFINITION(OBJECT_ID(@ViewName));
  SET @PositionShemaBinding = CHARINDEX('WITH SCHEMABINDING', @Command);

  IF NOT @PositionShemaBinding = 0 BEGIN;
    SET @Command = 'ALTER VIEW ' + @ViewName + ' ' + RIGHT(@Command, LEN(@Command) - (@PositionShemaBinding + LEN('WITH SCHEMABINDING')));
    EXECUTE sp_executesql @Command;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Helper].[ViewSchemaBinding_Add] (
  @ViewName NVARCHAR(255)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-03-16
  -- Description: Add WITH SCHEMABINDING clause to view
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @PositionShemaBinding INT;
  DECLARE @Command NVARCHAR(MAX);
  DECLARE @ObjectName VARCHAR(255);

  SELECT  @Command = OBJECT_DEFINITION(OBJECT_ID(@ViewName)),
          @ObjectName = OBJECT_NAME(OBJECT_ID(@ViewName));
  SET @PositionShemaBinding = PATINDEX('%WITH SCHEMABINDING%', @Command);

  IF @PositionShemaBinding = 0 BEGIN;
    SET @Command = REPLACE(@Command, 'CREATE VIEW', 'ALTER VIEW');

    IF NOT CHARINDEX('[' + @ObjectName + ']', @Command) = 0 BEGIN;
      SET @ObjectName = '[' + @ObjectName + ']'
    END;

    SET @Command = STUFF(@Command, CHARINDEX(@ObjectName, @Command), LEN(@ObjectName), @ObjectName + CHAR(13) + CHAR(10) + '  ' + 'WITH SCHEMABINDING ');
    EXECUTE sp_executesql @Command;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Helper].[FunctionSchemaBinding_Comment] (
  @FunctionName NVARCHAR(255)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-03-16
  -- Description: Remove WITH SCHEMABINDING clause from Function
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @PositionShemaBinding INT;
  DECLARE @Command NVARCHAR(MAX);

  SELECT @Command = OBJECT_DEFINITION(OBJECT_ID(@FunctionName));
  SET @PositionShemaBinding = CHARINDEX('WITH SCHEMABINDING', @Command);

  IF NOT @PositionShemaBinding = 0 BEGIN;
    SET @Command = REPLACE(REPLACE(REPLACE(@Command,'WITH SCHEMABINDING','--WITH SCHEMABINDING'), 'CREATE   FUNCTION', 'ALTER FUNCTION'), 'CREATE FUNCTION','ALTER FUNCTION');
    EXECUTE sp_executesql @Command;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Helper].[FunctionSchemaBinding_UnComment] (
  @FunctionName NVARCHAR(255)
)
AS
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-03-16
  -- Description: Add WITH SCHEMABINDING clause to Function
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @PositionShemaBinding INT;
  DECLARE @Command NVARCHAR(MAX);
  DECLARE @ObjectName VARCHAR(255);

  SELECT  @Command = OBJECT_DEFINITION(OBJECT_ID(@FunctionName)),
          @ObjectName = OBJECT_NAME(OBJECT_ID(@FunctionName));

    SET @Command = REPLACE(REPLACE(REPLACE(@Command,'--WITH SCHEMABINDING','WITH SCHEMABINDING'), 'CREATE   FUNCTION', 'ALTER FUNCTION'), 'CREATE FUNCTION','ALTER FUNCTION');
    EXECUTE sp_executesql @Command;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Helper].[ObjectSchemaSummary] (
  @SchemaName NVARCHAR(128) = NULL,
  @ObjectName NVARCHAR(128) = NULL
)
AS   
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ObjectSchemaSummary]
  -- Author: Cedric Dube
  -- Create date: 2020-11-02
  -- Description: Collect summary on Object, Columns, Defaults and Indexes
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
;WITH CTE AS (
 SELECT S.[Name] AS SchemaName,
        O.[Name] AS ObjectName,
		I.[type_desc] AS IndexType,
		I.[Name] AS IndexName,
		I.[Is_Unique] AS Is_Index_Unique,
		I.[Is_Primary_Key] AS Is_Index_Primary_Key,
		I.[Fill_Factor] AS IndexFillFactor,
        C.[Name] AS ColumnName,
		C.[Column_ID],
        ROW_NUMBER() OVER(PARTITION BY S.[Name], O.[Name] ORDER BY C.[Column_ID]) AS ColumnOrdinal,
        UPPER(TT.[Name]) AS DataType,
        CASE WHEN TT.[Name] IN ('VARCHAR','CHAR', 'BINARY', 'VARBINARY') THEN UPPER(TT.[Name]) +'(' + CAST(C.[Max_Length] AS VARCHAR) + ')'
             WHEN TT.[Name] IN ('NVARCHAR','NCHAR') THEN UPPER(TT.[Name]) +'(' + CAST(C.[Max_Length]/2 AS VARCHAR) + ')'
             WHEN TT.[Name] IN ('DECIMAL', 'NUMERIC') THEN UPPER(TT.[Name]) +'(' + CAST(C.[Precision] AS VARCHAR) + ',' + CAST(C.[Scale] AS VARCHAR) + ')'
			 WHEN TT.[Name] IN ('DATETIME2') THEN UPPER(TT.[Name]) +'(' + CAST(C.[Scale] AS VARCHAR) + ')'
      	   ELSE UPPER(TT.[Name]) END +
		CASE WHEN C.[Is_Nullable] = 1 THEN ' NULL' ELSE ' NOT NULL' END AS ColumnDefinition,
        C.[Is_Nullable],
		C.[Is_Computed],
        C.[Is_Identity],
        C.[Max_Length],
        C.[Precision],
        C.[Scale],
		SC.[Text] AS ColumnDefault
   FROM [Sys].[Objects] O WITH (NOLOCK)
  INNER JOIN [Sys].[Schemas] S WITH (NOLOCK)
     ON O.[Schema_ID] = S.[Schema_ID]
  INNER JOIN [Sys].[Columns] C WITH (NOLOCK)
     ON O.[object_id] = C.[object_id]
  INNER JOIN [Sys].[Types] TT WITH (NOLOCK)
     ON C.[user_type_id] = TT.[user_type_id]
   LEFT JOIN [Sys].[SysComments] SC 
     ON C.[Default_Object_ID] = SC.[ID]
   LEFT JOIN [Sys].[Index_Columns] IC WITH (NOLOCK)
     ON C.[object_id] = IC.[object_id]
    AND C.[Column_ID] = IC.[Column_Id]
   LEFT JOIN [Sys].[Indexes] I WITH (NOLOCK)
     ON IC.[object_id] = I.[object_id]
    AND IC.[Index_ID] = I.[Index_ID]
  WHERE (S.[Name] = @SchemaName OR @SchemaName IS NULL)
    AND (O.[Name] = @ObjectName OR @ObjectName IS NULL)
	AND S.[Name] <> 'SYS' -- EXCLUDE SYS SCHEMA
) SELECT * FROM CTE ORDER BY SchemaName ASC, ObjectName ASC, ColumnOrdinal ASC;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Helper].[GetTablesWithColumn] (
  @ColumnName NVARCHAR(128)
)
AS   
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2020-11-02
  -- Description: Collect list of tables wih the columnname provided
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
 SELECT S.[Name] AS SchemaName,
        T.[Name] AS TableName
   FROM [Sys].[Tables] T WITH (NOLOCK)
  INNER JOIN [Sys].[Schemas] S WITH (NOLOCK)
     ON T.[Schema_ID] = S.[Schema_ID]
  INNER JOIN [Sys].[Columns] C WITH (NOLOCK)
     ON T.[object_id] = C.[object_id]
  WHERE C.[Name] = @ColumnName;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Helper].[HashCreationGuide] (
  @SchemaName NVARCHAR(128) = NULL,
  @ObjectName NVARCHAR(128) = NULL
)
AS   
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Name: [Helper].[ObjectSchemaSummary]
  -- Author: Cedric Dube
  -- Create date: 2020-11-02
  -- Description: Collect summary on Object, Columns, Defaults and Indexes
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;

  IF OBJECT_ID('TempDB..#ObjDet') IS NOT NULL 
    DROP TABLE #ObjDet;
  CREATE TABLE #ObjDet (
    [SchemaName] NVARCHAR(128) NOT NULL,
	[ObjectName] NVARCHAR(128) NOT NULL,
	[IndexType] VARCHAR(30) NULL,
	[IndexName] NVARCHAR(128) NULL,
	[Is_Index_Unique] BIT NULL,
	[Is_Index_Primary_Key] BIT NULL,
	[IndexFillFactor] INT NULL,
	[ColumnName] NVARCHAR(128) NOT NULL,
	[Column_ID] INT NOT NULL,
	[ColumnOrdinal] INT NOT NULL,
	[DataType] NVARCHAR(128) NOT NULL,
	[ColumnDefinition] NVARCHAR(500) NOT NULL,
	[Is_Nullable] BIT NOT NULL,
	[Is_Computed] BIT NOT NULL,
	[Is_Identity] BIT NOT NULL,
	[Max_Length] INT NOT NULL,
	[Precision] INT NOT NULL,
	[Scale] INT NOT NULL,
	[ColumnDefault] VARCHAR(MAX)
  );
  INSERT INTO #ObjDet
    EXEC [Helper].[ObjectSchemaSummary] @SchemaName = @SchemaName, @ObjectName = @ObjectName;

SELECT SchemaName, 
       ObjectName, 
       ColumnName,
       [Column_ID] AS ColumnOrdinal,
	   AttributeName1 + AttributeName2 AS AttributeVariableDeclaration,
       FirstCondition + SecondCondition + ThirdCondition + FourthCondition + FifthCondition AS AttributeHashDefaultDefinition,
	   FirstAlternateCondition + SecondAlternateCondition + ThirdAlternateCondition + FourthAlternateCondition + FifthAlternateCondition AS Alternate_AttributeHashDefaultDefinition,
	   HashSalt
  FROM (
  SELECT DISTINCT 
                  SchemaName, 
                  ObjectName, 
                  ColumnName,
                  [Column_ID],
				  '@' + ColumnName + ' ' AS AttributeName1,
                  CASE WHEN DataType IN ('VARCHAR','CHAR', 'BINARY', 'VARBINARY') THEN UPPER(DataType) +'(' + CAST([Max_Length] AS VARCHAR) + ')'
                       WHEN DataType IN ('NVARCHAR','NCHAR') THEN UPPER(DataType) +'(' + CAST([Max_Length]/2 AS VARCHAR) + ')'
                       WHEN DataType IN ('DECIMAL', 'NUMERIC') THEN UPPER(DataType) +'(' + CAST([Precision] AS VARCHAR) + ',' + CAST([Scale] AS VARCHAR) + ')'
          			   WHEN DataType IN ('DATETIME2') THEN UPPER(DataType) +'(' + CAST([Scale] AS VARCHAR) + ')'
                	   ELSE UPPER(DataType) END AS AttributeName2,
                  '''' + '-' + '''' AS HashSalt,
				  CASE WHEN DataType NOT IN ('VARCHAR', 'NVARCHAR', 'CHAR', 'DATETIME',  'DATETIME2' ) THEN 'TRY_CAST(' 
				       WHEN DataType IN ('DATETIME', 'DATETIME2' ) THEN 'TRY_CONVERT(VARCHAR,' 
                       ELSE '' END AS FirstCondition,
				  CASE WHEN Is_Nullable = 1 THEN 'ISNULL(' ELSE '' END AS SecondCondition,
				  '@' + ColumnName AS ThirdCondition,
				  CASE WHEN Is_Nullable = 1 AND DataType IN ('VARCHAR', 'NVARCHAR', 'CHAR') AND Max_Length >= LEN('Unknown') THEN ', ' + '''' + 'Unknown' + '''' + ')'
				       WHEN Is_Nullable = 1 AND DataType IN ('VARCHAR', 'NVARCHAR', 'CHAR') AND Max_Length <LEN('Unknown') AND Max_Length >= LEN('UNK') THEN ', ' + '''' + 'UNK' + '''' + ')'
					   WHEN Is_Nullable = 1 AND DataType IN ('VARCHAR', 'NVARCHAR', 'CHAR') AND Max_Length <LEN('UNK') AND Max_Length >= LEN('U') THEN ', ' + '''' + 'U' + '''' + ')'
					   WHEN Is_Nullable = 1 AND DataType IN ('DATETIME', 'DATETIME2' ) THEN ', ' + '''' + '1900-01-01' + '''' + ')'
                       WHEN Is_Nullable = 1 AND DataType IN ('DECIMAL', 'NUMERIC', 'FLOAT', 'TINYINT' , 'BIT') THEN ', 0)'
					   WHEN Is_Nullable = 1 AND DataType IN ('INT', 'BIGINT', 'SMALLINT' ) THEN ', -1)'
					   ELSE '' END AS FourthCondition,
				  CASE WHEN DataType NOT IN ('VARCHAR', 'NVARCHAR', 'CHAR', 'DATETIME',  'DATETIME2' ) THEN ' AS VARCHAR)'
                       WHEN DataType IN ('DATETIME', 'DATETIME2' ) THEN ', 121)' 
                       ELSE '' END AS FifthCondition,
				  CASE WHEN DataType NOT IN ('VARCHAR', 'NVARCHAR', 'CHAR', 'DATETIME',  'DATETIME2' ) THEN 'TRY_CAST(' 
				       WHEN DataType IN ('DATETIME', 'DATETIME2' ) THEN 'TRY_CONVERT(VARCHAR,' 
                       ELSE '' END AS FirstAlternateCondition,
				  CASE WHEN Is_Nullable = 1 THEN 'ISNULL(' ELSE '' END AS SecondAlternateCondition,
				  '@' + ColumnName AS ThirdAlternateCondition,
				  CASE WHEN Is_Nullable = 1 AND DataType IN ('VARCHAR', 'NVARCHAR', 'CHAR') AND Max_Length >= LEN('Unknown') THEN ', ' + '''' + '' + '''' + ')'
				       WHEN Is_Nullable = 1 AND DataType IN ('VARCHAR', 'NVARCHAR', 'CHAR') AND Max_Length <LEN('Unknown') AND Max_Length >= LEN('UNK') THEN ', ' + '''' + '' + '''' + ')'
					   WHEN Is_Nullable = 1 AND DataType IN ('VARCHAR', 'NVARCHAR', 'CHAR') AND Max_Length <LEN('UNK') AND Max_Length >= LEN('U') THEN ', ' + '''' + '' + '''' + ')'
					   WHEN Is_Nullable = 1 AND DataType IN ('DATETIME', 'DATETIME2' ) THEN ', ' + '''' + '' + '''' + ')'
                       WHEN Is_Nullable = 1 AND DataType IN ('DECIMAL', 'NUMERIC', 'FLOAT', 'TINYINT' , 'BIT') THEN ', ' + '''' + '' + '''' + ')'
					   WHEN Is_Nullable = 1 AND DataType IN ('INT', 'BIGINT', 'SMALLINT' ) THEN ', ' + '''' + '' + '''' + ')'
					   ELSE '' END AS FourthAlternateCondition,
				  CASE WHEN DataType NOT IN ('VARCHAR', 'NVARCHAR', 'CHAR', 'DATETIME',  'DATETIME2' ) THEN ' AS VARCHAR)'
                       WHEN DataType IN ('DATETIME', 'DATETIME2' ) THEN ', 121)' 
                       ELSE '' END AS FifthAlternateCondition
     FROM #ObjDet )QRY
     ORDER BY SchemaName ASC, ObjectName ASC, ColumnName ASC;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO	 


GO
CREATE FUNCTION [Helper].[Conversion_BigIntToDateTime2](
  @Ticks BIGINT,
  @Basis VARCHAR(5) = 'SQL'
) RETURNS DATETIME2(7)
 -- REFERENCE: https://www.neowin.net/forum/topic/1296568-t-sql-converting-between-datetime27-time7-and-bigint-in-sql-20122014/
  WITH SCHEMABINDING
AS
BEGIN
  DECLARE @Precision BINARY(1) = 7;
  DECLARE @ReturnDateTime DATETIME2(7);
  IF @Basis = 'SQL' BEGIN;
    -- Base date of 1900-01-01 --
    DECLARE @dtTime BIGINT = @ticks % 864000000000;
    DECLARE @dtDays BIGINT = (@ticks - @dtTime) / 864000000000;
    -- CONVERSIONS
    DECLARE @dtTimeBytes BINARY(5) = CAST(REVERSE(CONVERT(BINARY(5), @dtTime)) AS BINARY(5));
    DECLARE @dtDaysBytes BINARY(3) = CAST(REVERSE(CONVERT(BINARY(3), @dtDays)) AS BINARY(3));
    SET @ReturnDateTime = CAST(CAST(@Precision + @dtTimeBytes + @dtDaysBytes AS BINARY(9)) AS DATETIME2(7));
  END;
  IF @Basis = 'UNIX' BEGIN;
    -- Base date of 1970-01-01
    DECLARE @dtAddSeconds DATETIME2(7) = DATEADD(SECOND, @Ticks / 1000, CAST('1970-01-01' AS DATETIME2(7)));
    SET @ReturnDateTime =  DATEADD(NANOSECOND, @Ticks * 1000000 % 1000000000, @dtAddSeconds);
  END;
  -- RETURN --
  RETURN @ReturnDateTime;
END;
GO
GO
CREATE FUNCTION [Helper].[Conversion_DateTime2ToBigInt](
  @DT DATETIME2(7),
  @Basis VARCHAR(5) = 'SQL'
)  RETURNS BIGINT
 -- REFERENCE: https://www.neowin.net/forum/topic/1296568-t-sql-converting-between-datetime27-time7-and-bigint-in-sql-20122014/
 WITH SCHEMABINDING
AS
BEGIN
  DECLARE @ReturnVal BIGINT;
  IF @Basis = 'SQL' BEGIN;
    DECLARE @dtBinary BINARY(9) = CAST(REVERSE(CONVERT(BINARY(9), @DT)) AS BINARY(9));
    DECLARE @dtDateBytes BINARY(3) = SUBSTRING(@dtBinary, 1, 3);
    DECLARE @dtTimeBytes BINARY(5) = SUBSTRING(@dtBinary, 4, 5);
    DECLARE @dtPrecisionByte BINARY(1) = SUBSTRING(@dtBinary, 9, 1);
    SET @ReturnVal = (CONVERT(BIGINT, @dtDateBytes) * 864000000000) + CONVERT(BIGINT, @dtTimeBytes);
  END;
  -- RETURN --
  RETURN @ReturnVal;
END;
GO

/* End of File ********************************************************************************************************************/