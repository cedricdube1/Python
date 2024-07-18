/************************************************************************
* Script     : 7.1.ToolBox - CodeHouse - Procedures - Set.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO


CREATE OR ALTER PROCEDURE [CodeHouse].[SetCodeObject_Linter] (
  @CodeObjectInput NVARCHAR(MAX),
  @CodeObject NVARCHAR(MAX) OUTPUT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Linter for code object
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* RTrim */
  SET @CodeObjectInput = LTRIM(RTRIM(@CodeObjectInput));
  /* Tab */
  DECLARE @Tab CHAR(1) = CHAR(9),
          @TabReplace CHAR(4) ='    ';
  IF CHARINDEX(@Tab, @CodeObjectInput) > 0 BEGIN;
    SET @CodeObjectInput = REPLACE(@CodeObjectInput, @Tab, @TabReplace);
  END;

  /* Finalized */
  SET @CodeObject = @CodeObjectinput;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetObjectType] (
  @ObjectType VARCHAR(50),
  @NewObjectType VARCHAR(50) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @ObjectTypeID SMALLINT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete ObjectType generic lookup set
  -- Version: 1.0
  -- Usage: @ObjectType {required}: I/Insert {default}; U/Update; D/Delete
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@ObjectType IS NULL OR TRIM(@ObjectType) = '')
    THROW 50000, 'ObjectType must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Update') AND (@NewObjectType IS NULL OR TRIM(@NewObjectType) = ''))
    THROW 50000, 'NewObjectType must be supplied when Action is U/Update. Procedure terminated.', 1;
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('ObjectType value ''', @ObjectType, ''' already exists on table CodeHouse.ObjectType. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('ObjectType value ''', @ObjectType, ''' was not found on table CodeHouse.ObjectType. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('ObjectType value ''', @ObjectType, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');
  /* Inserts */
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[ObjectType] WHERE [ObjectType] = @ObjectType))
      THROW 50000, @ExistsMsg, 1;
    -- Insert ObjectType --
    INSERT INTO [CodeHouse].[ObjectType] ([ObjectType])
         VALUES (@ObjectType);
    SET @ObjectTypeID = @@IDENTITY;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.ObjectType with ObjectType ''', @ObjectType, '''.');
  END;
  /* Updates */
  IF (@Action = 'Update') BEGIN;
    SET @ExistsMsg = REPLACE(REPLACE(@ExistsMsg, @ObjectType, @NewObjectType),'ObjectType value','NewObjectType value');
    -- Update Exists --
    SELECT @ObjectTypeID = [ObjectTypeID]
      FROM [CodeHouse].[ObjectType] WHERE [ObjectType] = @NewObjectType;
    IF (@ObjectTypeID IS NOT NULL)
      THROW 50000, @ExistsMsg, 1;
    -- Update Not Exist --
    SELECT @ObjectTypeID = [ObjectTypeID]
      FROM [CodeHouse].[ObjectType] WHERE [ObjectType] = @ObjectType;
    IF (@ObjectTypeID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update ObjectType --
    UPDATE [CodeHouse].[ObjectType]
       SET [ObjectType] = @NewObjectType
     WHERE [ObjectTypeID] = @ObjectTypeID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.ObjectType from ObjectType ''', @ObjectType, ''' to ObjectType ''', @NewObjectType, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @ObjectTypeID = [ObjectTypeID]
      FROM [CodeHouse].[ObjectType] WHERE [ObjectType] = @ObjectType;
    -- Delete Not Exists --
    IF (@ObjectTypeID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vObjectTypeUsage] WHERE [ObjectTypeID] = @ObjectTypeID)
      THROW 50000, @DependMsg, 1;
    -- Delete ObjectType --
    DELETE [CodeHouse].[ObjectType]
     WHERE [ObjectTypeID] = @ObjectTypeID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.ObjectType with ObjectType ''', @ObjectType, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetCodeType] (
  @CodeType VARCHAR(50),
  @NewCodeType VARCHAR(50) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @CodeTypeID SMALLINT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete CodeType generic lookup set
  -- Version: 1.0
  -- Usage: @CodeType {required}: I/Insert {default}; U/Update; D/Delete
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@CodeType IS NULL OR TRIM(@CodeType) = '')
    THROW 50000, 'CodeType must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Update') AND (@NewCodeType IS NULL OR TRIM(@NewCodeType) = ''))
    THROW 50000, 'NewCodeType must be supplied when Action is U/Update. Procedure terminated.', 1;
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('CodeType value ''', @CodeType, ''' already exists on table CodeHouse.CodeType. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('CodeType value ''', @CodeType, ''' was not found on table CodeHouse.CodeType. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('CodeType value ''', @CodeType, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');
  /* Inserts */
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[CodeType] WHERE [CodeType] = @CodeType))
      THROW 50000, @ExistsMsg, 1;
    -- Insert CodeType --
    INSERT INTO [CodeHouse].[CodeType] ([CodeType])
         VALUES (@CodeType);
    SET @CodeTypeID = @@IDENTITY;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.CodeType with CodeType ''', @CodeType, '''.');
  END;
  /* Updates */
  IF (@Action = 'Update') BEGIN;
    SET @ExistsMsg = REPLACE(REPLACE(@ExistsMsg, @CodeType, @NewCodeType),'CodeType value','NewCodeType value');
    -- Update Exists --
    SELECT @CodeTypeID = [CodeTypeID]
      FROM [CodeHouse].[CodeType] WHERE [CodeType] = @NewCodeType;
    IF (@CodeTypeID IS NOT NULL)
      THROW 50000, @ExistsMsg, 1;
    -- Update Not Exist --
    SELECT @CodeTypeID = [CodeTypeID]
      FROM [CodeHouse].[CodeType] WHERE [CodeType] = @CodeType;
    IF (@CodeTypeID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update CodeType --
    UPDATE [CodeHouse].[CodeType]
       SET [CodeType] = @NewCodeType
     WHERE [CodeTypeID] = @CodeTypeID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.CodeType from CodeType ''', @CodeType, ''' to CodeType ''', @NewCodeType, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @CodeTypeID = [CodeTypeID]
      FROM [CodeHouse].[CodeType] WHERE [CodeType] = @CodeType;
    -- Delete Not Exists --
    IF (@CodeTypeID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vCodeTypeUsage] WHERE [CodeTypeID] = @CodeTypeID)
      THROW 50000, @DependMsg, 1;
    -- Delete CodeType --
    DELETE [CodeHouse].[CodeType]
     WHERE [CodeTypeID] = @CodeTypeID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.CodeType with CodeType ''', @CodeType, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetLayer] (
  @Layer VARCHAR(50),
  @DatabaseName NVARCHAR(128) = NULL,
  @NewLayer VARCHAR(50) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @LayerID SMALLINT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete Layer generic lookup set
  -- Version: 1.0
  -- Usage: @Layer {required}: I/Insert {default}; U/Update; D/Delete
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@Layer IS NULL OR TRIM(@Layer) = '')
    THROW 50000, 'Layer must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Update') AND (@NewLayer IS NULL OR TRIM(@NewLayer) = ''))
    THROW 50000, 'NewLayer must be supplied when Action is U/Update. Procedure terminated.', 1;
  IF (@Action IN ('Insert','Update') AND (@DatabaseName IS NULL OR TRIM(@DatabaseName) = ''))
    THROW 50000, 'DatabaseName must be supplied when Action is I/Insert or U/Update. Procedure terminated.', 1;
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('Layer value ''', @Layer, ''' already exists on table CodeHouse.Layer. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('Layer value ''', @Layer, ''' was not found on table CodeHouse.Layer. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('Layer value ''', @Layer, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');
  /* Inserts */
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer))
      THROW 50000, @ExistsMsg, 1;
    -- Insert Layer --
    INSERT INTO [CodeHouse].[Layer] ([Layer], [DatabaseName])
         VALUES (@Layer, @DatabaseName);
    SET @LayerID = @@IDENTITY;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.Layer with Layer ''', @Layer, ''' and DatabaseName ''', @DatabaseName, '''.');
  END;
  /* Updates */
  IF (@Action = 'Update') BEGIN;
    SET @ExistsMsg = REPLACE(REPLACE(@ExistsMsg, @Layer, @NewLayer),'Layer value','NewLayer value');
    -- Update Exists --
    SELECT @LayerID = [LayerID]
      FROM [CodeHouse].[Layer] WHERE [Layer] = @NewLayer;
    IF (@LayerID IS NOT NULL)
      THROW 50000, @ExistsMsg, 1;
    -- Update Not Exist --
    SELECT @LayerID = [LayerID]
      FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer;
    IF (@LayerID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update Layer --
    UPDATE [CodeHouse].[Layer]
       SET [Layer] = @NewLayer,
           [DatabaseName] = @DatabaseName
     WHERE [LayerID] = @LayerID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.Layer from Layer ''', @Layer, ''' to Layer ''', @NewLayer, ''' and DatabaseName ''', @DatabaseName, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @LayerID = [LayerID]
      FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer;
    -- Delete Not Exists --
    IF (@LayerID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vLayerUsage] WHERE [LayerID] = @LayerID)
      THROW 50000, @DependMsg, 1;
    -- Delete Layer --
    DELETE [CodeHouse].[Layer]
     WHERE [LayerID] = @LayerID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.Layer with Layer ''', @Layer, ''' and DatabaseName ''', @DatabaseName, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetStream] (
  @Stream VARCHAR(50),
  @NewStream VARCHAR(50) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @StreamID SMALLINT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete Stream generic lookup set
  -- Version: 1.0
  -- Usage: @Stream {required}: I/Insert {default}; U/Update; D/Delete
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@Stream IS NULL OR TRIM(@Stream) = '')
    THROW 50000, 'Stream must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Update') AND (@NewStream IS NULL OR TRIM(@NewStream) = ''))
    THROW 50000, 'NewStream must be supplied when Action is U/Update. Procedure terminated.', 1;
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('Stream value ''', @Stream, ''' already exists on table CodeHouse.Stream. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('Stream value ''', @Stream, ''' was not found on table CodeHouse.Stream. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('Stream value ''', @Stream, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');
  /* Inserts */
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[Stream] WHERE [Stream] = @Stream))
      THROW 50000, @ExistsMsg, 1;
    -- Insert Stream --
    INSERT INTO [CodeHouse].[Stream] ([Stream])
         VALUES (@Stream);
    SET @StreamID = @@IDENTITY;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.Stream with Stream ''', @Stream, '''.');
  END;
  /* Updates */
  IF (@Action = 'Update') BEGIN;
    SET @ExistsMsg = REPLACE(REPLACE(@ExistsMsg, @Stream, @NewStream),'Stream value','NewStream value');
    -- Update Exists --
    SELECT @StreamID = [StreamID]
      FROM [CodeHouse].[Stream] WHERE [Stream] = @NewStream;
    IF (@StreamID IS NOT NULL)
      THROW 50000, @ExistsMsg, 1;
    -- Update Not Exist --
    SELECT @StreamID = [StreamID]
      FROM [CodeHouse].[Stream] WHERE [Stream] = @Stream;
    IF (@StreamID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update Stream --
    UPDATE [CodeHouse].[Stream]
       SET [Stream] = @NewStream
     WHERE [StreamID] = @StreamID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.Stream from Stream ''', @Stream, ''' to Stream ''', @NewStream, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @StreamID = [StreamID]
      FROM [CodeHouse].[Stream] WHERE [Stream] = @Stream;
    -- Delete Not Exists --
    IF (@StreamID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vStreamUsage] WHERE [StreamID] = @StreamID)
      THROW 50000, @DependMsg, 1;
    -- Delete Stream --
    DELETE [CodeHouse].[Stream]
     WHERE [StreamID] = @StreamID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.Stream with Stream ''', @Stream, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetStreamVariant] (
  @StreamVariant VARCHAR(50),
  @NewStreamVariant VARCHAR(50) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @StreamVariantID SMALLINT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete StreamVariant generic lookup set
  -- Version: 1.0
  -- Usage: @StreamVariant {required}: I/Insert {default}; U/Update; D/Delete
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@StreamVariant IS NULL OR TRIM(@StreamVariant) = '')
    THROW 50000, 'StreamVariant must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Update') AND (@NewStreamVariant IS NULL OR TRIM(@NewStreamVariant) = ''))
    THROW 50000, 'NewStreamVariant must be supplied when Action is U/Update. Procedure terminated.', 1;
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('StreamVariant value ''', @StreamVariant, ''' already exists on table CodeHouse.StreamVariant. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('StreamVariant value ''', @StreamVariant, ''' was not found on table CodeHouse.StreamVariant. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('StreamVariant value ''', @StreamVariant, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');
  /* Inserts */
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @StreamVariant))
      THROW 50000, @ExistsMsg, 1;
    -- Insert StreamVariant --
    INSERT INTO [CodeHouse].[StreamVariant] ([StreamVariant])
         VALUES (@StreamVariant);
    SET @StreamVariantID = @@IDENTITY;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.StreamVariant with StreamVariant ''', @StreamVariant, '''.');
  END;
  /* Updates */
  IF (@Action = 'Update') BEGIN;
    SET @ExistsMsg = REPLACE(REPLACE(@ExistsMsg, @StreamVariant, @NewStreamVariant),'StreamVariant value','NewStreamVariant value');
    -- Update Exists --
    SELECT @StreamVariantID = [StreamVariantID]
      FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @NewStreamVariant;
    IF (@StreamVariantID IS NOT NULL)
      THROW 50000, @ExistsMsg, 1;
    -- Update Not Exist --
    SELECT @StreamVariantID = [StreamVariantID]
      FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @StreamVariant;
    IF (@StreamVariantID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update StreamVariant --
    UPDATE [CodeHouse].[StreamVariant]
       SET [StreamVariant] = @NewStreamVariant
     WHERE [StreamVariantID] = @StreamVariantID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.StreamVariant from StreamVariant ''', @StreamVariant, ''' to StreamVariant ''', @NewStreamVariant, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @StreamVariantID = [StreamVariantID]
      FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @StreamVariant;
    -- Delete Not Exists --
    IF (@StreamVariantID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vStreamVariantUsage] WHERE [StreamVariantID] = @StreamVariantID)
      THROW 50000, @DependMsg, 1;
    -- Delete StreamVariant --
    DELETE [CodeHouse].[StreamVariant]
     WHERE [StreamVariantID] = @StreamVariantID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.StreamVariant with StreamVariant ''', @StreamVariant, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetCodeObjectTag] (
  @CodeObjectID INT,
  @CodeObject NVARCHAR(MAX),
  @Action CHAR(1) = 'I'
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update CodeObject tags used
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@CodeObjectID IS NULL)
    THROW 50000, 'CodeObjectID must be supplied. Procedure terminated.', 1;
  IF (@CodeObject IS NULL OR LTRIM(RTRIM(@CodeObject)) = '')
    THROW 50000, 'CodeObject must be supplied. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[CodeObject] WHERE [CodeObjectID] = @CodeObjectID))
    THROW 50000, 'CodeObjectID was not found on table CodeHouse.CofdeObject. Procedure terminated.', 1;

  /* Deletes */
  IF @Action = 'D' BEGIN;
    DELETE [CodeHouse].[CodeObjectTag] WHERE [CodeObjectID] = @CodeObjectID;
  END;
  /* Inserts */
  IF @Action = 'I' BEGIN;
    INSERT INTO [CodeHouse].[CodeObjectTag] (
      [CodeObjectID],
      [TagID]  
    ) SELECT @CodeObjectID, TG.[TagID]
        FROM [CodeHouse].[GetCodeObjectTagList] (@CodeObject) T
     INNER JOIN [CodeHouse].[Tag] TG
        ON T.[Tag] = TG.[Tag]
     LEFT JOIN [CodeHouse].[CodeObjectTag] [DPT]
        ON TG.[TagID] = DPT.[TagID]
       AND DPT.[CodeObjectID] = @CodeObjectID
     WHERE DPT.[CodeObjectID] IS NULL;
  END;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetCodeObjectComponent] (
  @CodeObjectID INT,
  @CodeObject NVARCHAR(MAX),
  @Layer VARCHAR(50),
  @Stream VARCHAR(50),
  @StreamVariant VARCHAR(50),
  @Action CHAR(1) = 'I'
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update CodeObject Components used
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@CodeObjectID IS NULL)
    THROW 50000, 'CodeObjectID must be supplied. Procedure terminated.', 1;
  IF (@CodeObject IS NULL OR LTRIM(RTRIM(@CodeObject)) = '')
    THROW 50000, 'CodeObject must be supplied. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID))
    THROW 50000, 'CodeObjectID was not found on table CodeHouse.CofdeObject. Procedure terminated.', 1;
  IF (@Layer IS NULL OR TRIM(@Layer) = '')
    THROW 50000, 'Layer must be supplied. Procedure terminated.', 1;
  IF (@Stream IS NULL OR TRIM(@Stream) = '')
    THROW 50000, 'Stream must be supplied. Procedure terminated.', 1;
  IF (@StreamVariant IS NULL OR TRIM(@StreamVariant) = '')
    THROW 50000, 'StreamVariant must be supplied. Procedure terminated.', 1;

  /* Deletes */
  IF @Action = 'D' BEGIN;
    DELETE [CodeHouse].[CodeObjectComponent] WHERE [CodeObjectID] = @CodeObjectID;
  END;
  /* Inserts */
  IF @Action = 'I' BEGIN;
    INSERT INTO [CodeHouse].[CodeObjectComponent] (
      [CodeObjectID],
      [ComponentCodeObjectID]  
    ) SELECT DISTINCT @CodeObjectID, Component.CodeObjectID
	    FROM [CodeHouse].[GetComponentCodeObject] (@Layer, @Stream, @StreamVariant, @CodeObject) Component
     LEFT JOIN [CodeHouse].[CodeObjectComponent] CO
        ON CO.CodeObjectID = @CodeObjectID 
       AND Component.CodeObjectID = CO.ComponentCodeObjectID
     WHERE CO.[CodeObjectID] IS NULL;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetCodeObject] (
  @Layer VARCHAR(50),
  @Stream VARCHAR(50),
  @StreamVariant VARCHAR(50),
  @CodeObjectName NVARCHAR(128),
  @VersionType CHAR(5) = 'Major', -- Major|Minor|Exist
  @ObjectType VARCHAR(50) = NULL,
  @CodeType VARCHAR(50) = NULL,
  @Author NVARCHAR(128) = NULL,
  @Remark VARCHAR(1000),
  @CodeObjectRemark NVARCHAR(2000) = NULL,
  @CodeObjectHeader NVARCHAR(2000) = NULL,
  @CodeObjectExecutionOptions NVARCHAR(1000) = NULL,
  @CodeObject NVARCHAR(MAX) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @CodeObjectID INT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete CodeObject generic code set
  -- Version: 1.0
  -- Usage: @Layer {required}: I/Insert {default}; U/Update; D/Delete
  --        @Stream {required}: I/Insert {default}; U/Update; D/Delete
  --        @StreamVariant {required}: I/Insert {default}; U/Update; D/Delete
  --        @ObjectType {optional}: I/Insert {required}; U/Update {required}; D/Delete {ignored}
  --        @CodeObjectName {required}: I/Insert {default}; U/Update; D/Delete
  --        @Author {optional}: I/Insert {required}; U/Update {required}; D/Delete {ignored}
  --        @Remark {required}: I/Insert {required}; U/Update {required}; D/Delete {required}
  --        @CodeObjectHeader {optional}: I/Insert {required}; U/Update {required}; D/Delete {ignored}
  --        @CodeObject {optional}: I/Insert {required}; U/Update {required}; D/Delete {ignored}
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@Layer IS NULL OR TRIM(@Layer) = '')
    THROW 50000, 'Layer must be supplied. Procedure terminated.', 1;
  IF (@Stream IS NULL OR TRIM(@Stream) = '')
    THROW 50000, 'Stream must be supplied. Procedure terminated.', 1;
  IF (@StreamVariant IS NULL OR TRIM(@StreamVariant) = '')
    THROW 50000, 'StreamVariant must be supplied. Procedure terminated.', 1;
  IF (@CodeObjectName IS NULL OR TRIM(@CodeObjectName) = '')
    THROW 50000, 'CodeObjectName must be supplied. Procedure terminated.', 1;
  IF (@Remark IS NULL OR TRIM(@Remark) = '')
    THROW 50000, 'Remark must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Insert','Update') AND (@Author IS NULL OR TRIM(@Author) = ''))
    THROW 50000, 'Author must be supplied when Action is I/Insert or U/Update. Procedure terminated.', 1;
  IF (@Action IN ('Insert','Update') AND (@CodeObject IS NULL OR TRIM(@CodeObject) = ''))
    THROW 50000, 'CodeObject must be supplied when Action is I/Insert or U/Update. Procedure terminated.', 1;
  IF (@Action IN ('Insert','Update') AND (@VersionType NOT IN ('Major','Minor', 'Exist')))
    THROW 50000, 'VersionType must be one of Major, Minor, Exist when Action is I/Insert or U/Update. Procedure terminated.', 1;
  IF (@Action IN ('Insert','Update') AND (@ObjectType IS NULL OR TRIM(@ObjectType) = ''))
    THROW 50000, 'ObjectType must be supplied when Action is I/Insert or U/Update. Procedure terminated.', 1;
  IF (@Action IN ('Insert','Update') AND (@CodeType IS NULL OR TRIM(@CodeType) = ''))
    THROW 50000, 'CodeType must be supplied when Action is I/Insert or U/Update. Procedure terminated.', 1;
  -- Reference --
  DECLARE @ObjectTypeID SMALLINT = (SELECT [ObjectTypeID] FROM [CodeHouse].[ObjectType] WHERE [ObjectType] = @ObjectType);
  IF (@Action IN ('Insert','Update') AND (@ObjectTypeID IS NULL))
    THROW 50000, 'ObjectTypeID was not found on table CodeHouse.ObjectType. Procedure terminated.', 1;
  DECLARE @CodeTypeID SMALLINT = (SELECT [CodeTypeID] FROM [CodeHouse].[CodeType] WHERE [CodeType] = @CodeType);
  IF (@Action IN ('Insert','Update') AND (@CodeTypeID IS NULL))
    THROW 50000, 'CodeTypeID was not found on table CodeHouse.CodeType. Procedure terminated.', 1;
  DECLARE @LayerID SMALLINT = (SELECT [LayerID] FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer);
  IF (@Action IN ('Insert','Update') AND (@LayerID IS NULL))
    THROW 50000, 'LayerID was not found on table CodeHouse.Layer. Procedure terminated.', 1;
  DECLARE @StreamID SMALLINT = (SELECT [StreamID] FROM [CodeHouse].[Stream] WHERE [Stream] = @Stream);
  IF (@Action IN ('Insert','Update') AND (@StreamID IS NULL))
    THROW 50000, 'StreamID was not found on table CodeHouse.Stream. Procedure terminated.', 1;
  DECLARE @StreamVariantID SMALLINT = (SELECT [StreamVariantID] FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @StreamVariant);
  IF (@Action IN ('Insert','Update') AND (@StreamVariantID IS NULL))
    THROW 50000, 'StreamVariantID was not found on table CodeHouse.StreamVariant. Procedure terminated.', 1;
  IF (@Action IN ('Insert','Update') AND (@ObjectType IN ('Procedure','Function'))
             AND (
			           (CHARINDEX('CREATE PROCEDURE', @CodeObject) > 0)
			       OR  (CHARINDEX('CREATE FUNCTION', @CodeObject) > 0)
			       OR  (CHARINDEX('CREATE OR ALTER PROCEDURE', @CodeObject) > 0)
			       OR  (CHARINDEX('CREATE OR ALTER FUNCTION', @CodeObject) > 0)
                 )
      )
    THROW 50000, 'CREATE statement not allowed for Procedure/Function - these will be generated using ExecutionOptions and Header settings.Procedure terminated.', 1;
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' already exists on table CodeHouse.CodeObject. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' was not found on table CodeHouse.CodeObject. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');

  /* Linter */
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @CodeObjectName, @CodeObject = @CodeObjectName OUTPUT;
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @Author, @CodeObject = @Author OUTPUT;
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @Remark, @CodeObject = @Remark OUTPUT;
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @CodeObjectRemark, @CodeObject = @CodeObjectRemark OUTPUT;
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @CodeObjectHeader, @CodeObject = @CodeObjectHeader OUTPUT;
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @CodeObjectExecutionOptions, @CodeObject = @CodeObjectExecutionOptions OUTPUT;
  EXEC [CodeHouse].[SetCodeObject_Linter] @CodeObjectInput = @CodeObject, @CodeObject = @CodeObject OUTPUT;

  /* Tag Validation */
  IF EXISTS (SELECT [Tag] FROM [CodeHouse].[GetCodeObjectTagList] (@CodeObjectName) EXCEPT SELECT [Tag] FROM [CodeHouse].[Tag]) BEGIN;
    THROW 50000, 'CodeobjectName contains tags that were not found in CodeHouse.Tag. Procedure terminated.', 1;
  END;
  IF EXISTS (SELECT [Tag] FROM [CodeHouse].[GetCodeObjectTagList] (@CodeObject) EXCEPT SELECT [Tag] FROM [CodeHouse].[Tag]) BEGIN;
    THROW 50000, 'Codeobject contains tags that were not found in CodeHouse.Tag. Procedure terminated.', 1;
  END;

  /* Component Validation */
  IF EXISTS (SELECT [Component] FROM [CodeHouse].[GetCodeObjectComponentList] (@CodeObject) EXCEPT SELECT [CodeObjectName] FROM [CodeHouse].[vCodeObject] WHERE [ObjectType] = 'Component') BEGIN;
    THROW 50000, 'Codeobject contains components that were not found in CodeHouse.CodeObject. Procedure terminated.', 1;
  END;

  /* Inserts */
  DECLARE @InsertCodeVersion DECIMAL(9,1) = 1.0;
    SELECT @InsertCodeVersion = CASE WHEN @VersionType = 'Major' THEN FLOOR([CodeVersion] + 1) WHEN @VersionType = 'Exist' THEN [CodeVersion] ELSE [CodeVersion] + 0.1 END
      FROM [CodeHouse].[CodeObject] FOR SYSTEM_TIME ALL WHERE [LayerID] = @LayerID AND [StreamID] = @StreamID AND [StreamVariantID] = @StreamVariantID AND [CodeObjectName] = @CodeObjectName;
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[CodeObject] WHERE [LayerID] = @LayerID AND [StreamID] = @StreamID AND [StreamVariantID] = @StreamVariantID AND [CodeObjectName] = @CodeObjectName))
      THROW 50000, @ExistsMsg, 1;
    -- Insert CodeObject --
    INSERT INTO [CodeHouse].[CodeObject] ([LayerID], [StreamID], [StreamVariantID], [CodeVersion], [ObjectTypeID], [CodeTypeID], [CodeObjectName], [Author], [Remark], [CodeObjectRemark], [CodeObjectHeader], [CodeObjectExecutionOptions], [CodeObject])
         VALUES (@LayerID, @StreamID, @StreamVariantID, @InsertCodeVersion, @ObjectTypeID, @CodeTypeID, @CodeObjectName, @Author, @Remark, @CodeObjectRemark, @CodeObjectHeader, @CodeObjectExecutionOptions, @CodeObject);
    SET @CodeObjectID = @@IDENTITY;
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObject;
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObjectName;
    EXEC [CodeHouse].[SetCodeObjectComponent] @CodeObjectID, @CodeObject, @Layer, @Stream, @StreamVariant;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.CodeObject with Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' with Version ''', @InsertCodeVersion, '''.');
  END;
  /* Updates */
  DECLARE @UpdateCodeVersion DECIMAL(9,1) = 1.0;
  IF (@Action = 'Update') BEGIN;
    SELECT @CodeObjectID = [CodeObjectID],
           @UpdateCodeVersion = CASE WHEN @VersionType = 'Major' THEN FLOOR([CodeVersion] + 1) WHEN @VersionType = 'Exist' THEN [CodeVersion] ELSE [CodeVersion] + 0.1 END
      FROM [CodeHouse].[CodeObject] WHERE [LayerID] = @LayerID AND [StreamID] = @StreamID AND [StreamVariantID] = @StreamVariantID AND [CodeObjectName] = @CodeObjectName;
    -- New Exists --
    IF (@CodeObjectID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update CodeObject --
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObject, 'D';
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObjectName, 'D';
    EXEC [CodeHouse].[SetCodeObjectComponent] @CodeObjectID, @CodeObject, @Layer, @Stream, @StreamVariant, 'D';
    UPDATE [CodeHouse].[CodeObject]
       SET [CodeVersion] = @UpdateCodeVersion,
           [ObjectTypeID] = @ObjectTypeID,
           [CodeTypeID] = @CodeTypeID,
           [Author] = @Author,
           [Remark] = @Remark,
           [CodeObjectRemark] = @CodeObjectRemark,
           [CodeObjectHeader] = @CodeObjectHeader,
           [CodeObjectExecutionOptions] = @CodeObjectExecutionOptions,
           [CodeObject] = @CodeObject
     WHERE [CodeObjectID] = @CodeObjectID;
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObject;
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObjectName;
    EXEC [CodeHouse].[SetCodeObjectComponent] @CodeObjectID, @CodeObject, @Layer, @Stream, @StreamVariant;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.CodeObject with Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' with Version ''', @UpdateCodeVersion, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @CodeObjectID = [CodeObjectID],
           @UpdateCodeVersion = [CodeVersion]
      FROM [CodeHouse].[CodeObject] WHERE [LayerID] = @LayerID AND [StreamID] = @StreamID AND [StreamVariantID] = @StreamVariantID AND [CodeObjectName] = @CodeObjectName;
    -- Delete Not Exists --
    IF (@CodeObjectID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vCodeObjectUsage] WHERE [CodeObjectID] = @CodeObjectID)
      THROW 50000, @DependMsg, 1;
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObject, 'D';
    EXEC [CodeHouse].[SetCodeObjectTag] @CodeObjectID, @CodeObjectName, 'D';
    EXEC [CodeHouse].[SetCodeObjectComponent] @CodeObjectID, @CodeObject, @Layer, @Stream, @StreamVariant, 'D';
    -- Delete CodeObject --
    DELETE [CodeHouse].[CodeObject]
     WHERE [CodeObjectID] = @CodeObjectID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.CodeObject with Stream ''', @Stream, ''' for StreamVariant ''', @StreamVariant, ''' in Layer ''', @Layer, ''' with Name ''', @CodeObjectName, ''' with Version ''', @UpdateCodeVersion, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetTag] (
  @Tag VARCHAR(50),
  @Description VARCHAR(150),
  @NewTag VARCHAR(50) = NULL,
  @Action VARCHAR(6) = 'I', -- Insert|Update|Delete
  @TagID SMALLINT = NULL OUTPUT,
  @SelectResult BIT = 0
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update/Delete Tag generic lookup set
  -- Version: 1.0
  -- Usage: @Tag {required}: I/Insert {default}; U/Update; D/Delete
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@Tag IS NULL OR TRIM(@Tag) = '')
    THROW 50000, 'Tag must be supplied. Procedure terminated.', 1;
  IF (@Action NOT IN ('I', 'Insert', 'U', 'Update', 'D', 'Delete'))
    THROW 50000, 'Action must be one of I/Insert, U/Update or D/Delete. Procedure terminated.', 1;
  SET @Action = CASE @Action WHEN 'I' THEN 'Insert' WHEN 'U' THEN 'Update' WHEN 'D' THEN 'Delete' ELSE @Action END;
  IF (@Action IN ('Update') AND (@NewTag IS NULL OR TRIM(@NewTag) = ''))
    THROW 50000, 'NewTag must be supplied when Action is U/Update. Procedure terminated.', 1;
  -- Standardise Braces --
  IF (LEFT(@Tag,1) <> '{')
    SET @Tag = '{' + @Tag;
  IF (RIGHT(@Tag,1) <> '}')
    SET @Tag = @Tag + '}';
  IF (LEFT(@NewTag,1) <> '{')
    SET @NewTag = '{' + @NewTag;
  IF (RIGHT(@NewTag,1) <> '}')
    SET @NewTag = @NewTag + '}';
  -- Messages --
  DECLARE @ExistsMsg NVARCHAR(2048) = CONCAT('Tag value ''', @Tag, ''' already exists on table CodeHouse.Tag. Entry could not be inserted.');
  DECLARE @NoFindMsg NVARCHAR(2048) = CONCAT('Tag value ''', @Tag, ''' was not found on table CodeHouse.Tag. Entry could not be updated.');
  DECLARE @DependMsg NVARCHAR(2048) = CONCAT('Tag value ''', @Tag, ''' has dependents on table(s). These need to be resolved first. Entry could not be deleted.');
  /* Inserts */
  IF (@Action = 'Insert') BEGIN;
    -- New Exists --
    IF (EXISTS (SELECT 1 FROM [CodeHouse].[Tag] WHERE [Tag] = @Tag))
      THROW 50000, @ExistsMsg, 1;
    -- Insert Tag --
    INSERT INTO [CodeHouse].[Tag] ([Tag], [Description])
         VALUES (@Tag, @Description);
    SET @TagID = @@IDENTITY;
    IF (@SelectResult = 1) SELECT CONCAT('Entry inserted into CodeHouse.Tag with Tag ''', @Tag, '''.');
  END;
  /* Updates */
  IF (@Action = 'Update') BEGIN;
    SET @ExistsMsg = REPLACE(REPLACE(@ExistsMsg, @Tag, @NewTag),'Tag value','NewTag value');
    -- Update Exists --
    SELECT @TagID = [TagID]
      FROM [CodeHouse].[Tag] WHERE [Tag] = @NewTag;
    IF (@TagID IS NOT NULL)
      THROW 50000, @ExistsMsg, 1;
    -- Update Not Exist --
    SELECT @TagID = [TagID]
      FROM [CodeHouse].[Tag] WHERE [Tag] = @Tag;
    IF (@TagID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Update Tag --
    UPDATE [CodeHouse].[Tag]
       SET [Tag] = @NewTag,
           [Description] = @Description
     WHERE [TagID] = @TagID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry update in CodeHouse.Tag from Tag ''', @Tag, ''' to Tag ''', @NewTag, '''.');
  END;
  /* Deletes */
  IF (@Action = 'Delete') BEGIN;
    SELECT @TagID = [TagID]
      FROM [CodeHouse].[Tag] WHERE [Tag] = @Tag;
    -- Delete Not Exists --
    IF (@TagID IS NULL)
      THROW 50000, @NoFindMsg, 1;
    -- Delete Has Dependants
    IF EXISTS (SELECT 1 FROM [CodeHouse].[vTagUsage] WHERE [TagID] = @TagID)
      THROW 50000, @DependMsg, 1;
    -- Delete Tag --
    DELETE [CodeHouse].[Tag]
     WHERE [TagID] = @TagID;
    IF (@SelectResult = 1) SELECT CONCAT('Entry Deleted from CodeHouse.Tag with Tag ''', @Tag, '''.');
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetDeployment] (
  @DeploymentSet UNIQUEIDENTIFIER,
  @DeploymentStatus CHAR(1),
  @LayerID SMALLINT,
  @StreamID SMALLINT,
  @StreamVariantID SMALLINT,
  @CodeVersion DECIMAL(9,1),
  @ObjectTypeID SMALLINT,
  @CodeTypeID SMALLINT,
  @CodeObjectID INT,
  @DeploymentOrdinal SMALLINT,
  @ObjectSchema NVARCHAR(128) = NULL,
  @ObjectName NVARCHAR(128),
  @DropScript NVARCHAR(MAX),
  @ObjectScript NVARCHAR(MAX),
  @ExtendedPropertiesScript NVARCHAR(MAX),
  @DeploymentServer NVARCHAR(128) NULL
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update deployment generated code set
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @DeploymentID INT;
  IF (@DeploymentSet IS NULL)
    THROW 50000, 'DeploymentSet must be supplied. Procedure terminated.', 1;
  IF (@DeploymentStatus IS NULL OR TRIM(@DeploymentStatus) = '' OR @DeploymentStatus NOT IN ('U','F','S'))
    THROW 50000, 'DeploymentStatus must be supplied and must be one of U(Unactioned), F(Failed), S(Succeeded). Procedure terminated.', 1;
  IF (@CodeVersion IS NULL)
    THROW 50000, 'CodeVersion must be supplied. Procedure terminated.', 1;
  IF (@DeploymentOrdinal IS NULL)
    THROW 50000, 'DeploymentOrdinal must be supplied. Procedure terminated.', 1;
  IF (@ObjectName IS NULL OR TRIM(@ObjectName) = '')
    THROW 50000, 'ObjectName must be supplied. Procedure terminated.', 1;
  -- Reference --
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[Layer] WHERE [LayerID] = @LayerID))
    THROW 50000, 'LayerID was not found on table CodeHouse.Layer. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[Stream] WHERE [StreamID] = @StreamID))
    THROW 50000, 'StreamID was not found on table CodeHouse.Stream. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[StreamVariant] WHERE [StreamVariantID] = @StreamVariantID))
    THROW 50000, 'StreamVariantID was not found on table CodeHouse.StreamVariant. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[ObjectType] WHERE [ObjectTypeID] = @ObjectTypeID))
    THROW 50000, 'ObjectTypeID was not found on table CodeHouse.ObjectType. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[CodeType] WHERE [CodeTypeID] = @CodeTypeID))
    THROW 50000, 'CodeTypeID was not found on table CodeHouse.CodeType. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[CodeObject] WHERE [CodeObjectID] = @CodeObjectID))
    THROW 50000, 'CodeObjectID was not found on table CodeHouse.CodeObject. Procedure terminated.', 1;
  IF ((@DropScript IS NULL OR TRIM(@DropScript)='') AND (@ObjectScript IS NULL OR TRIM(@ObjectScript)='') AND (@ExtendedPropertiesScript IS NULL OR TRIM(@ExtendedPropertiesScript)=''))
    THROW 50000, 'DropScript or ObjectScript or ExtendedPropertiesScript must be provided. Procedure terminated.', 1;
  
  SET @DeploymentServer = ISNULL(@DeploymentServer,@@SERVERNAME);
  SELECT @DeploymentID = [DeploymentID]
    FROM [CodeHouse].[Deployment]
   WHERE [DeploymentSet] = @DeploymentSet AND
         [LayerID] = @LayerID AND
         [StreamID] = @StreamID AND
         [StreamVariantID] = @StreamVariantID AND
         [CodeVersion] = @CodeVersion AND
         [ObjectTypeID] = @ObjectTypeID AND
         [CodeTypeID] = @CodeTypeID AND
         [CodeObjectID] = @CodeObjectID; 
  /* Updates */
  IF (@DeploymentID IS NOT NULL) BEGIN;
    UPDATE [CodeHouse].[Deployment]
       SET [DeploymentOrdinal] = @DeploymentOrdinal,
           [ObjectSchema] = @ObjectSchema,
           [ObjectName] = @ObjectName,
	       [DropScript] = @DropScript,
           [ObjectScript] = @ObjectScript,
           [ExtendedPropertiesScript] = @ExtendedPropertiesScript,
           [DeploymentStatus] = @DeploymentStatus
     WHERE [DeploymentID] = @DeploymentID;
  END;

  /* Inserts */
  IF (@DeploymentID IS NULL) BEGIN;
    INSERT INTO [CodeHouse].[Deployment] (
      [DeploymentServer],
      [DeploymentSet],
      [DeploymentStatus],
      [LayerID],
      [StreamID],
      [StreamVariantID],
      [CodeVersion],
      [ObjectTypeID],
      [CodeTypeID],
      [CodeObjectID],
      [DeploymentOrdinal],
      [ObjectSchema],
      [ObjectName],
      [DropScript],
      [ObjectScript],
      [ExtendedPropertiesScript]    
    ) VALUES (  @DeploymentServer,
                @DeploymentSet,
                @DeploymentStatus,
                @LayerID,
                @StreamID,
                @StreamVariantID,
                @CodeVersion,
                @ObjectTypeID,
                @CodeTypeID,
                @CodeObjectID,
                @DeploymentOrdinal,
                @ObjectSchema,
                @ObjectName,
                @DropScript,
                @ObjectScript,
                @ExtendedPropertiesScript    
              );
  END;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetDeploymentTag] (
  @DeploymentSet UNIQUEIDENTIFIER,
  @DeploymentTags [CodeHouse].[ReplacementTag] READONLY
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Update deployment tags used
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@DeploymentSet IS NULL)
    THROW 50000, 'DeploymentSet must be supplied. Procedure terminated.', 1;
  -- Reference --
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[Deployment] WHERE [DeploymentSet] = @DeploymentSet))
    THROW 50000, 'DeploymentSet was not found on table CodeHouse.Deployment. Procedure terminated.', 1;
   
  /* Updates */
  UPDATE [DPT]
     SET [TagValue] = [Value]
    FROM @DeploymentTags T
   INNER JOIN [CodeHouse].[Tag] TG
      ON T.[Tag] = TG.[Tag]
   INNER JOIN [CodeHouse].[DeploymentTag] [DPT]
      ON TG.[TagID] = DPT.[TagID]
     AND DPT.[DeploymentSet] = @DeploymentSet;

  /* Inserts */
  INSERT INTO [CodeHouse].[DeploymentTag] (
    [DeploymentSet],
    [TagID],
    [TagValue]   
  ) SELECT @DeploymentSet, TG.[TagID], T.[Value]
    FROM @DeploymentTags T
   INNER JOIN [CodeHouse].[Tag] TG
      ON T.[Tag] = TG.[Tag]
   LEFT JOIN [CodeHouse].[DeploymentTag] [DPT]
      ON TG.[TagID] = DPT.[TagID]
     AND DPT.[DeploymentSet] = @DeploymentSet
   WHERE DPT.[DeploymentSet] IS NULL;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetDeploymentComponent] (
  @DeploymentSet UNIQUEIDENTIFIER,
  @CodeObjectID INT
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert deployment components used
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@DeploymentSet IS NULL)
    THROW 50000, 'DeploymentSet must be supplied. Procedure terminated.', 1;
  IF (@CodeObjectID IS NULL)
    THROW 50000, 'CodeObjectID must be supplied. Procedure terminated.', 1;
  -- Reference --
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[Deployment] WHERE [DeploymentSet] = @DeploymentSet))
    THROW 50000, 'DeploymentSet was not found on table CodeHouse.Deployment. Procedure terminated.', 1;
  IF (NOT EXISTS(SELECT 1 FROM [CodeHouse].[CodeObject] WHERE [CodeObjectID] = @CodeObjectID))
    THROW 50000, 'CodeObjectID was not found on table CodeHouse.CofdeObject. Procedure terminated.', 1;

  /* Inserts */
  IF NOT EXISTS (SELECT 1 FROM [CodeHouse].[DeploymentComponent] WHERE [DeploymentSet] = @DeploymentSet AND [CodeObjectID] = @CodeObjectID) BEGIN;
    INSERT INTO [CodeHouse].[DeploymentComponent] (
      [DeploymentSet],
      [CodeObjectID]
    ) VALUES( @DeploymentSet, @CodeObjectID);
  END;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetDeploymentDocument] (
  @DeploymentSet UNIQUEIDENTIFIER,
  @DeploymentName NVARCHAR(128),
  @DeploymentNotes NVARCHAR(MAX)
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Inserts deployment Document
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  IF (@DeploymentSet IS NULL)
    THROW 50000, 'DeploymentSet must be supplied. Procedure terminated.', 1;
  IF (@DeploymentName IS NULL OR TRIM(@DeploymentName) = '')
    THROW 50000, 'DeploymentName must be supplied. Procedure terminated.', 1;
  IF (@DeploymentNotes IS NULL OR TRIM(@DeploymentNotes) = '')
    THROW 50000, 'DeploymentNotes must be supplied. Procedure terminated.', 1;

  /* Inserts */
  IF NOT EXISTS (SELECT 1 FROM [CodeHouse].[DeploymentDocument] WHERE [DeploymentSet] = @DeploymentSet) BEGIN;
    INSERT INTO [CodeHouse].[DeploymentDocument] (
      [DeploymentSet],
      [DeploymentName],
      [Notes]   
    ) VALUES( @DeploymentSet, @DeploymentName, @DeploymentNotes);
  END;

END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[SetDeploymentGroup] (
  @Ordinal SMALLINT,
  @DeploymentGroupName NVARCHAR(128),
  @DeploymentSet UNIQUEIDENTIFIER,
  @DeploymentScriptObjectname NVARCHAR(128),
  @DeploymentScriptLayer VARCHAR(50),
  @DeploymentScriptStream VARCHAR(50),
  @DeploymentScriptStreamVariant VARCHAR(50),
  @Layer VARCHAR(50),
  @Stream VARCHAR(50),
  @StreamVariant VARCHAR(50),
  @ReplacementTags NVARCHAR(MAX),
  @Action CHAR(1) = 'I'
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Insert/Delete deployment groups
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  /* Initial */
  DECLARE @DeploymentGroupID INT;
  DECLARE @DeploymentScriptObjectID INT,
          @DeploymentScriptLayerID SMALLINT,
          @DeploymentScriptStreamID SMALLINT,
          @DeploymentScriptStreamVariantID SMALLINT,
          @LayerID SMALLINT,
          @StreamID SMALLINT,
          @StreamVariantID SMALLINT;
  IF (@Ordinal IS NULL)
    THROW 50000, 'Ordinal must be supplied. Procedure terminated.', 1;
  IF (@DeploymentGroupName IS NULL OR TRIM(@DeploymentGroupName) = '')
    THROW 50000, 'DeploymentGroupName must be supplied. Procedure terminated.', 1;
  IF (@DeploymentScriptObjectname IS NULL OR TRIM(@DeploymentScriptObjectname) = '')
    THROW 50000, 'DeploymentScriptObjectname must be supplied. Procedure terminated.', 1;
  IF (@DeploymentScriptLayer IS NULL OR TRIM(@DeploymentScriptLayer) = '')
    THROW 50000, 'DeploymentScriptLayer must be supplied. Procedure terminated.', 1;
  IF (@DeploymentScriptStream IS NULL OR TRIM(@DeploymentScriptStream) = '')
    THROW 50000, 'DeploymentScriptStream must be supplied. Procedure terminated.', 1;
  IF (@DeploymentScriptStreamVariant IS NULL OR TRIM(@DeploymentScriptStreamVariant) = '')
    THROW 50000, 'DeploymentScriptStreamVariant must be supplied. Procedure terminated.', 1;
  IF (@Layer IS NULL OR TRIM(@Layer) = '')
    THROW 50000, 'Layer must be supplied. Procedure terminated.', 1;
  IF (@Stream IS NULL OR TRIM(@Stream) = '')
    THROW 50000, 'Stream must be supplied. Procedure terminated.', 1;
  IF (@StreamVariant IS NULL OR TRIM(@StreamVariant) = '')
    THROW 50000, 'StreamVariant must be supplied. Procedure terminated.', 1;
  -- Reference --
  SET @DeploymentScriptLayerID = (SELECT [LayerID] FROM [CodeHouse].[Layer] WHERE [Layer] = @DeploymentScriptLayer);
  SET @DeploymentScriptStreamID = (SELECT [StreamID] FROM [CodeHouse].[Stream] WHERE [Stream] = @DeploymentScriptStream);
  SET @DeploymentScriptStreamVariantID = (SELECT [StreamVariantID] FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @DeploymentScriptStreamVariant);
  SET @DeploymentScriptObjectID = (SELECT [CodeObjectID] FROM [CodeHouse].[CodeObject] WHERE [LayerID] = @DeploymentScriptLayerID AND [StreamID] = @DeploymentScriptStreamID AND [StreamVariantID] = @DeploymentScriptStreamVariantID AND [CodeObjectname] = @DeploymentScriptObjectname);
  SET @LayerID = (SELECT [LayerID] FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer);
  SET @StreamID = (SELECT [StreamID] FROM [CodeHouse].[Stream] WHERE [Stream] = @Stream);
  SET @StreamVariantID = (SELECT [StreamVariantID] FROM [CodeHouse].[StreamVariant] WHERE [StreamVariant] = @StreamVariant);

  IF @DeploymentScriptLayerID IS NULL
    THROW 50000, 'DeploymentScriptLayerID was not found on table CodeHouse.Layer. Procedure terminated.', 1;
  IF @DeploymentScriptStreamID IS NULL
    THROW 50000, 'DeploymentScriptStreamID was not found on table CodeHouse.Stream. Procedure terminated.', 1;
  IF @DeploymentScriptStreamVariantID IS NULL
    THROW 50000, 'DeploymentScriptStreamVariantID was not found on table CodeHouse.StreamVariant. Procedure terminated.', 1;
  IF @LayerID IS NULL
    THROW 50000, 'LayerID was not found on table CodeHouse.Layer. Procedure terminated.', 1;
  IF @StreamID IS NULL
    THROW 50000, 'StreamID was not found on table CodeHouse.Stream. Procedure terminated.', 1;
  IF @StreamVariantID IS NULL
    THROW 50000, 'StreamVariantID was not found on table CodeHouse.StreamVariant. Procedure terminated.', 1;
  IF @DeploymentScriptObjectID IS NULL
    THROW 50000, 'DeploymentScriptObjectID was not found on table CodeHouse.CodeObject. Procedure terminated.', 1;

  SET @DeploymentGroupID = (SELECT [DeploymentGroupID] FROM [CodeHouse].[DeploymentGroup]
                             WHERE [DeploymentGroupName] = @DeploymentGroupName
							   AND [DeploymentScriptObjectID] = @DeploymentScriptObjectID
							   AND [DeploymentScriptLayerID] = @DeploymentScriptLayerID
							   AND [DeploymentScriptStreamID] = @DeploymentScriptStreamID
							   AND [DeploymentScriptStreamVariantID] = @DeploymentScriptStreamVariantID
                               AND [LayerID] = @LayerID
                               AND [StreamID] = @StreamID
                               AND [StreamVariantID] = @StreamVariantID
                               AND [Ordinal] = @Ordinal);
  /* Deletes */
  IF (@DeploymentGroupID IS NOT NULL AND @Action = 'D') BEGIN;
    DELETE FROM [CodeHouse].[DeploymentGroup] WHERE [DeploymentGroupID] = @DeploymentGroupID;
  END;
  /* Inserts */
  IF (@DeploymentGroupID IS NULL) BEGIN;
    INSERT INTO [CodeHouse].[DeploymentGroup] (
      [Ordinal],
      [DeploymentGroupName],
      [DeploymentSet],
      [DeploymentScriptObjectID],
      [DeploymentScriptLayerID],
      [DeploymentScriptStreamID],
      [DeploymentScriptStreamVariantID],
      [LayerID],
      [StreamID],
      [StreamVariantID],
      [ReplacementTags] 
    ) VALUES (@Ordinal,
              @DeploymentGroupName,
              @DeploymentSet,
              @DeploymentScriptObjectID,
              @DeploymentScriptLayerID,
              @DeploymentScriptStreamID,
              @DeploymentScriptStreamVariantID,
              @LayerID,
              @StreamID,
              @StreamVariantID,
              @ReplacementTags);
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

/* End of File ********************************************************************************************************************/