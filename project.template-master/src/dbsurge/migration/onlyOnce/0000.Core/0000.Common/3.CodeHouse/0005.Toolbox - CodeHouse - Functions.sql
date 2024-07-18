/************************************************************************
* Script     : 3.ToolBox - CodeHouse - Functions.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE OR ALTER FUNCTION [CodeHouse].[GetCodeObjectComponentList] (
  @InputCodeObject NVARCHAR(MAX)
) RETURNS @ComponentList TABLE (
   [Component] NVARCHAR(128) NOT NULL
  )
WITH SCHEMABINDING
AS   
BEGIN;
  DECLARE @Component NVARCHAR(128);
  WHILE (CHARINDEX('{<', @InputCodeObject) > 0) BEGIN;
    SET @Component = NULL;
    SET @Component = SUBSTRING(@InputCodeObject, CHARINDEX('{<', @InputCodeObject) + 2, CHARINDEX('>}', @InputCodeObject)-2 - CHARINDEX('{<', @InputCodeObject));
    INSERT INTO @ComponentList ([Component]) VALUES (@Component);
    SET @InputCodeObject = REPLACE(@InputCodeObject, '{<' + @Component + '>}', '');
  END;
  RETURN;
END;
GO
GO
CREATE OR ALTER FUNCTION [CodeHouse].[GetCodeObjectTagList] (
  @InputCodeObject NVARCHAR(MAX)
) RETURNS @TagList TABLE (
   [Tag] VARCHAR(50) NOT NULL
  )
WITH SCHEMABINDING
AS   
BEGIN;
  DECLARE @Tag VARCHAR(128);
  WHILE (CHARINDEX('{', @InputCodeObject) > 0) BEGIN;
    SET @Tag = NULL;
    SET @Tag = SUBSTRING(@InputCodeObject, CHARINDEX('{', @InputCodeObject), CHARINDEX('}', @InputCodeObject) - CHARINDEX('{', @InputCodeObject)+1);
    IF (LEFT(@Tag,2) <> '{<')
      INSERT INTO @TagList (Tag) VALUES (LEFT(@Tag,50));
    SET @InputCodeObject = REPLACE(@InputCodeObject, @Tag, '');
  END;
  RETURN;
END;
GO
GO
CREATE OR ALTER FUNCTION [CodeHouse].[GetComponentCodeObject] (
  @Layer VARCHAR(50),
  @Stream VARCHAR(50),
  @StreamVariant VARCHAR(50),
  @CodeObject NVARCHAR(MAX)
) RETURNS @Component TABLE (
   [CodeObjectID] INT NOT NULL
  )
--WITH SCHEMABINDING
AS   
BEGIN;
  INSERT INTO @Component(
   [CodeObjectID]
  ) SELECT ComponentCodeObjectID FROM (
              SELECT COALESCE(A.[CodeObjectID], B.[CodeObjectID], C.[CodeObjectID], D.[CodeObjectID], E.[CodeObjectID], F.[CodeObjectID], G.[CodeObjectID]) AS ComponentCodeObjectID
                FROM [CodeHouse].[GetCodeObjectComponentList] (@CodeObject) T
               -- ALL MATCH --
             LEFT JOIN [CodeHouse].[vCodeObject] A
                ON A.[Layer] = @Layer
               AND A.[Stream] = @Stream
               AND A.[StreamVariant] = @StreamVariant
               AND A.[CodeObjectName] = T.[Component]
               -- LAYER and STREAM MATCH, VARIANT can be any --
             LEFT JOIN [CodeHouse].[vCodeObject] B
                ON B.[Layer] = @Layer
               AND B.[Stream] = @Stream
               AND B.[StreamVariant] = 'Any' 
               AND B.[CodeObjectName] = T.[Component]
               -- LAYER and VARIANT MATCH, STREAM can be any --
             LEFT JOIN [CodeHouse].[vCodeObject] C
                ON C.[Layer] = @Layer
               AND C.[Stream] = 'Any'
               AND C.[StreamVariant] = @StreamVariant
               AND C.[CodeObjectName] = T.[Component]
               -- STREAM and VARIANT MATCH, LAYER can be any --
             LEFT JOIN [CodeHouse].[vCodeObject] D
                ON D.[Layer] = 'Any'
               AND D.[Stream] = @Stream
               AND D.[StreamVariant] = @StreamVariant
               AND D.[CodeObjectName] = T.[Component]
               -- LAYER MATCH, STREAM and VARIANT can be any --
             LEFT JOIN [CodeHouse].[vCodeObject] E
                ON E.[Layer] = @Layer
               AND E.[Stream] = 'Any'
               AND E.[StreamVariant] = 'Any' 
               AND E.[CodeObjectName] = T.[Component]
               -- STREAM MATCH, LAYER and VARIANT can be any --
             LEFT JOIN [CodeHouse].[vCodeObject] F
                ON F.[Layer] = 'Any'
               AND F.[Stream] = @Stream
               AND F.[StreamVariant] = 'Any' 
               AND F.[CodeObjectName] = T.[Component]
               -- NO MATCH, LAYER and STREAM and VARIANT can be any --
             LEFT JOIN [CodeHouse].[vCodeObject] G
                ON G.[Layer] = 'Any'
               AND G.[Stream] = 'Any'
               AND G.[StreamVariant] = 'Any' 
               AND G.[CodeObjectName] = T.[Component]) QRY WHERE ComponentCodeObjectID IS NOT NULL;
  RETURN;
END;
GO
/* End of File ********************************************************************************************************************/