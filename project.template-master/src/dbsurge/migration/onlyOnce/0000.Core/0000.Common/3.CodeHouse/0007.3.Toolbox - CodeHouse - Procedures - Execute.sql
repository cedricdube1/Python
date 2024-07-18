/************************************************************************
* Script     : 7.3.ToolBox - CodeHouse - Procedures - Execute.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
--------------------------------------------- COURTESY OF https://www.red-gate.com/simple-talk/sql/t-sql-programming/consuming-json-strings-in-sql-server/

USE [dbSurge]
GO

GO
CREATE OR ALTER FUNCTION [CodeHouse].[parseJSON](
  @JSON NVARCHAR(MAX)
)
/**
Summary: >
  The code for the JSON Parser/Shredder will run in SQL Server 2005, 
  and even in SQL Server 2000 (with some modifications required).
 
  First the function replaces all strings with tokens of the form @Stringxx,
  where xx is the foreign key of the table variable where the strings are held.
  This takes them, and their potentially difficult embedded brackets, out of 
  the way. Names are  always strings in JSON as well as  string values.
 
  Then, the routine iteratively finds the next structure that has no structure 
  Contained within it, (and is, by definition the leaf structure), and parses it,
  replacing it with an object token of the form ‘@Objectxxx‘, or ‘@arrayxxx‘, 
  where xxx is the object id assigned to it. The values, or name/value pairs 
  are retrieved from the string table and stored in the hierarchy table. G
  radually, the JSON document is eaten until there is just a single root
  object left.
Author: PhilFactor
Date: 01/07/2010
Version: 
  Number: 4.6.2
  Date: 01/07/2019
  Why: case-insensitive version
Example: >
  Select * from parseJSON('{    "Person": 
      {
       "firstName": "John",
       "lastName": "Smith",
       "age": 25,
       "Address": 
           {
          "streetAddress":"21 2nd Street",
          "city":"New York",
          "state":"NY",
          "postalCode":"10021"
           },
       "PhoneNumbers": 
           {
           "home":"212 555-1234",
          "fax":"646 555-4567"
           }
        }
     }
  ')
Returns: >
  nothing
**/
	RETURNS @hierarchy TABLE
	  (
	   Element_ID INT IDENTITY(1, 1) NOT NULL, /* internal surrogate primary key gives the order of parsing and the list order */
	   SequenceNo [int] NULL, /* the place in the sequence for the element */
	   Parent_ID INT null, /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
	   Object_ID INT null, /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
	   Name NVARCHAR(MAX) NULL, /* the Name of the object */
	   StringValue NVARCHAR(MAX) NOT NULL,/*the string representation of the value of the element. */
	   ValueType VARCHAR(10) NOT null /* the declared type of the value represented as a string in StringValue*/
	  )
	  /*
 
	   */
	AS
	BEGIN
	  DECLARE
	    @FirstObject INT, --the index of the first open bracket found in the JSON string
	    @OpenDelimiter INT,--the index of the next open bracket found in the JSON string
	    @NextOpenDelimiter INT,--the index of subsequent open bracket found in the JSON string
	    @NextCloseDelimiter INT,--the index of subsequent close bracket found in the JSON string
	    @Type NVARCHAR(10),--whether it denotes an object or an array
	    @NextCloseDelimiterChar CHAR(1),--either a '}' or a ']'
	    @Contents NVARCHAR(MAX), --the unparsed contents of the bracketed expression
	    @Start INT, --index of the start of the token that you are parsing
	    @end INT,--index of the end of the token that you are parsing
	    @param INT,--the parameter at the end of the next Object/Array token
	    @EndOfName INT,--the index of the start of the parameter at end of Object/Array token
	    @token NVARCHAR(MAX),--either a string or object
	    @value NVARCHAR(MAX), -- the value as a string
	    @SequenceNo int, -- the sequence number within a list
	    @Name NVARCHAR(MAX), --the Name as a string
	    @Parent_ID INT,--the next parent ID to allocate
	    @lenJSON INT,--the current length of the JSON String
	    @characters NCHAR(36),--used to convert hex to decimal
	    @result BIGINT,--the value of the hex symbol being parsed
	    @index SMALLINT,--used for parsing the hex value
	    @Escape INT --the index of the next escape character
	    
	  DECLARE @Strings TABLE /* in this temporary table we keep all strings, even the Names of the elements, since they are 'escaped' in a different way, and may contain, unescaped, brackets denoting objects or lists. These are replaced in the JSON string by tokens representing the string */
	    (
	     String_ID INT IDENTITY(1, 1),
	     StringValue NVARCHAR(MAX)
	    )
	  SELECT--initialise the characters to convert hex to ascii
	    @characters='0123456789abcdefghijklmnopqrstuvwxyz',
	    @SequenceNo=0, --set the sequence no. to something sensible.
	  /* firstly we process all strings. This is done because [{} and ] aren't escaped in strings, which complicates an iterative parse. */
	    @Parent_ID=0;
	  WHILE 1=1 --forever until there is nothing more to do
	    BEGIN
	      SELECT
	        @start=PATINDEX('%[^a-zA-Z]["]%', @json collate SQL_Latin1_General_CP850_Bin);--next delimited string
	      IF @start=0 BREAK --no more so drop through the WHILE loop
	      IF SUBSTRING(@json, @start+1, 1)='"' 
	        BEGIN --Delimited Name
	          SET @start=@Start+1;
	          SET @end=PATINDEX('%[^\]["]%', RIGHT(@json, LEN(@json+'|')-@start) collate SQL_Latin1_General_CP850_Bin);
	        END
	      IF @end=0 --either the end or no end delimiter to last string
	        BEGIN-- check if ending with a double slash...
             SET @end=PATINDEX('%[\][\]["]%', RIGHT(@json, LEN(@json+'|')-@start) collate SQL_Latin1_General_CP850_Bin);
 		     IF @end=0 --we really have reached the end 
				BEGIN
				BREAK --assume all tokens found
				END
			END 
	      SELECT @token=SUBSTRING(@json, @start+1, @end-1)
	      --now put in the escaped control characters
	      SELECT @token=REPLACE(@token, FromString, ToString)
	      FROM
	        (SELECT           '\b', CHAR(08)
	         UNION ALL SELECT '\f', CHAR(12)
	         UNION ALL SELECT '\n', CHAR(10)
	         UNION ALL SELECT '\r', CHAR(13)
	         UNION ALL SELECT '\t', CHAR(09)
			 UNION ALL SELECT '\"', '"'
	         UNION ALL SELECT '\/', '/'
	         UNION ALL SELECT '~', '\'
	        ) substitutions(FromString, ToString)
		SELECT @token=Replace(@token, '\\', '\')
	      SELECT @result=0, @escape=1
	  --Begin to take out any hex escape codes
	      WHILE @escape>0
	        BEGIN
	          SELECT @index=0,
	          --find the next hex escape sequence
	          @escape=PATINDEX('%\x[0-9a-f][0-9a-f][0-9a-f][0-9a-f]%', @token collate SQL_Latin1_General_CP850_Bin)
	          IF @escape>0 --if there is one
	            BEGIN
	              WHILE @index<4 --there are always four digits to a \x sequence   
	                BEGIN
	                  SELECT --determine its value
	                    @result=@result+POWER(16, @index)
	                    *(CHARINDEX(SUBSTRING(@token, @escape+2+3-@index, 1),
	                                @characters)-1), @index=@index+1 ;
	         
	                END
	                -- and replace the hex sequence by its unicode value
	              SELECT @token=STUFF(@token, @escape, 6, NCHAR(@result))
	            END
	        END
	      --now store the string away 
	      INSERT INTO @Strings (StringValue) SELECT @token
	      -- and replace the string with a token
	      SELECT @JSON=STUFF(@json, @start, @end+1,
	                    '@string'+CONVERT(NCHAR(5), @@identity))
	    END
	  -- all strings are now removed. Now we find the first leaf.  
	  WHILE 1=1  --forever until there is nothing more to do
	  BEGIN
	 
	  SELECT @Parent_ID=@Parent_ID+1
	  --find the first object or list by looking for the open bracket
	  SELECT @FirstObject=PATINDEX('%[{[[]%', @json collate SQL_Latin1_General_CP850_Bin)--object or array
	  IF @FirstObject = 0 BREAK
	  IF (SUBSTRING(@json, @FirstObject, 1)='{') 
	    SELECT @NextCloseDelimiterChar='}', @type='object'
	  ELSE 
	    SELECT @NextCloseDelimiterChar=']', @type='array'
	  SELECT @OpenDelimiter=@firstObject
	  WHILE 1=1 --find the innermost object or list...
	    BEGIN
	      SELECT
	        @lenJSON=LEN(@JSON+'|')-1
	  --find the matching close-delimiter proceeding after the open-delimiter
	      SELECT
	        @NextCloseDelimiter=CHARINDEX(@NextCloseDelimiterChar, @json,
	                                      @OpenDelimiter+1)
	  --is there an intervening open-delimiter of either type
	      SELECT @NextOpenDelimiter=PATINDEX('%[{[[]%',
	             RIGHT(@json, @lenJSON-@OpenDelimiter)collate SQL_Latin1_General_CP850_Bin)--object
	      IF @NextOpenDelimiter=0 
	        BREAK
	      SELECT @NextOpenDelimiter=@NextOpenDelimiter+@OpenDelimiter
	      IF @NextCloseDelimiter<@NextOpenDelimiter 
	        BREAK
	      IF SUBSTRING(@json, @NextOpenDelimiter, 1)='{' 
	        SELECT @NextCloseDelimiterChar='}', @type='object'
	      ELSE 
	        SELECT @NextCloseDelimiterChar=']', @type='array'
	      SELECT @OpenDelimiter=@NextOpenDelimiter
	    END
	  ---and parse out the list or Name/value pairs
	  SELECT
	    @contents=SUBSTRING(@json, @OpenDelimiter+1,
	                        @NextCloseDelimiter-@OpenDelimiter-1)
	  SELECT
	    @JSON=STUFF(@json, @OpenDelimiter,
	                @NextCloseDelimiter-@OpenDelimiter+1,
	                '@'+@type+CONVERT(NCHAR(5), @Parent_ID))
	  WHILE (PATINDEX('%[A-Za-z0-9@+.e]%', @contents collate SQL_Latin1_General_CP850_Bin))<>0 
	    BEGIN
	      IF @Type='object' --it will be a 0-n list containing a string followed by a string, number,boolean, or null
	        BEGIN
	          SELECT
	            @SequenceNo=0,@end=CHARINDEX(':', ' '+@contents)--if there is anything, it will be a string-based Name.
	          SELECT  @start=PATINDEX('%[^A-Za-z@][@]%', ' '+@contents collate SQL_Latin1_General_CP850_Bin)--AAAAAAAA
              SELECT @token=RTrim(Substring(' '+@contents, @start+1, @End-@Start-1)),
	            @endofName=PATINDEX('%[0-9]%', @token collate SQL_Latin1_General_CP850_Bin),
	            @param=RIGHT(@token, LEN(@token)-@endofName+1)
	          SELECT
	            @token=LEFT(@token, @endofName-1),
	            @Contents=RIGHT(' '+@contents, LEN(' '+@contents+'|')-@end-1)
	          SELECT  @Name=StringValue FROM @strings
	            WHERE string_id=@param --fetch the Name
	        END
	      ELSE 
	        SELECT @Name=null,@SequenceNo=@SequenceNo+1 
	      SELECT
	        @end=CHARINDEX(',', @contents)-- a string-token, object-token, list-token, number,boolean, or null
                IF @end=0
	        --HR Engineering notation bugfix start
	          IF ISNUMERIC(@contents) = 1
		    SELECT @end = LEN(@contents) + 1
	          Else
	        --HR Engineering notation bugfix end 
		  SELECT  @end=PATINDEX('%[A-Za-z0-9@+.e][^A-Za-z0-9@+.e]%', @contents+' ' collate SQL_Latin1_General_CP850_Bin) + 1
	       SELECT
	        @start=PATINDEX('%[^A-Za-z0-9@+.e][A-Za-z0-9@+.e]%', ' '+@contents collate SQL_Latin1_General_CP850_Bin)
	      --select @start,@end, LEN(@contents+'|'), @contents  
	      SELECT
	        @Value=RTRIM(SUBSTRING(@contents, @start, @End-@Start)),
	        @Contents=RIGHT(@contents+' ', LEN(@contents+'|')-@end)
	      IF SUBSTRING(@value, 1, 7)='@object' 
	        INSERT INTO @hierarchy
	          (Name, SequenceNo, Parent_ID, StringValue, Object_ID, ValueType)
	          SELECT @Name, @SequenceNo, @Parent_ID, SUBSTRING(@value, 8, 5),
	            SUBSTRING(@value, 8, 5), 'object' 
	      ELSE 
	        IF SUBSTRING(@value, 1, 6)='@array' 
	          INSERT INTO @hierarchy
	            (Name, SequenceNo, Parent_ID, StringValue, Object_ID, ValueType)
	            SELECT @Name, @SequenceNo, @Parent_ID, SUBSTRING(@value, 7, 5),
	              SUBSTRING(@value, 7, 5), 'array' 
	        ELSE 
	          IF SUBSTRING(@value, 1, 7)='@string' 
	            INSERT INTO @hierarchy
	              (Name, SequenceNo, Parent_ID, StringValue, ValueType)
	              SELECT @Name, @SequenceNo, @Parent_ID, StringValue, 'string'
	              FROM @strings
	              WHERE string_id=SUBSTRING(@value, 8, 5)
	          ELSE 
	            IF @value IN ('true', 'false') 
	              INSERT INTO @hierarchy
	                (Name, SequenceNo, Parent_ID, StringValue, ValueType)
	                SELECT @Name, @SequenceNo, @Parent_ID, @value, 'boolean'
	            ELSE
	              IF @value='null' 
	                INSERT INTO @hierarchy
	                  (Name, SequenceNo, Parent_ID, StringValue, ValueType)
	                  SELECT @Name, @SequenceNo, @Parent_ID, @value, 'null'
	              ELSE
	                IF PATINDEX('%[^0-9]%', @value collate SQL_Latin1_General_CP850_Bin)>0 
	                  INSERT INTO @hierarchy
	                    (Name, SequenceNo, Parent_ID, StringValue, ValueType)
	                    SELECT @Name, @SequenceNo, @Parent_ID, @value, 'real'
	                ELSE
	                  INSERT INTO @hierarchy
	                    (Name, SequenceNo, Parent_ID, StringValue, ValueType)
	                    SELECT @Name, @SequenceNo, @Parent_ID, @value, 'int'
	      if @Contents=' ' Select @SequenceNo=0
	    END
	  END
	INSERT INTO @hierarchy (Name, SequenceNo, Parent_ID, StringValue, Object_ID, ValueType)
	  SELECT '-',1, NULL, '', @Parent_ID-1, @type
	--
	   RETURN
	END
GO
GO
CREATE TYPE [CodeHouse].[Hierarchy] AS TABLE
(
   element_id INT NOT NULL, /* internal surrogate primary key gives the order of parsing and the list order */
   sequenceNo [int] NULL, /* the place in the sequence for the element */
   parent_ID INT,/* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
   [Object_ID] INT,/* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
   NAME NVARCHAR(MAX),/* the name of the object, null if it hasn't got one */
   StringValue NVARCHAR(MAX) NOT NULL,/*the string representation of the value of the element. */
   ValueType VARCHAR(10) NOT null /* the declared type of the value represented as a string in StringValue*/
    PRIMARY KEY (element_id)
);
GO
CREATE OR ALTER FUNCTION [CodeHouse].[JSONEscaped] (
 @Unescaped NVARCHAR(MAX) --a string with maybe characters that will break json
 )
 /* this is a simple utility function that takes a SQL String with all its clobber and outputs it as a sting with all the JSON escape sequences in it.*/
RETURNS NVARCHAR(MAX)
AS
BEGIN
  SELECT @Unescaped = REPLACE(@Unescaped, FROMString, TOString)
  FROM (SELECT '' AS FromString, '\' AS ToString 
        UNION ALL SELECT '"', '"' 
        UNION ALL SELECT '/', '/'
        UNION ALL SELECT CHAR(08),'b'
        UNION ALL SELECT CHAR(12),'f'
        UNION ALL SELECT CHAR(10),'n'
        UNION ALL SELECT CHAR(13),'r'
        UNION ALL SELECT CHAR(09),'t'
 ) substitutions
RETURN @Unescaped
END
GO
CREATE OR ALTER FUNCTION [CodeHouse].[ToJSON]
	(
	      @Hierarchy [CodeHouse].[Hierarchy] READONLY
	)
	 
	/*
	the function that takes a Hierarchy table and converts it to a JSON string
	 
	Author: Phil Factor
	Revision: 1.5
	date: 1 May 2014
	why: Added a fix to add a name for a list.
	example:
	 
	Declare @XMLSample XML
	Select @XMLSample='
	  <glossary><title>example glossary</title>
	  <GlossDiv><title>S</title>
	   <GlossList>
	    <GlossEntry id="SGML"" SortAs="SGML">
	     <GlossTerm>Standard Generalized Markup Language</GlossTerm>
	     <Acronym>SGML</Acronym>
	     <Abbrev>ISO 8879:1986</Abbrev>
	     <GlossDef>
	      <para>A meta-markup language, used to create markup languages such as DocBook.</para>
	      <GlossSeeAlso OtherTerm="GML" />
	      <GlossSeeAlso OtherTerm="XML" />
	     </GlossDef>
	     <GlossSee OtherTerm="markup" />
	    </GlossEntry>
	   </GlossList>
	  </GlossDiv>
	 </glossary>'
	 
	DECLARE @MyHierarchy Hierarchy -- to pass the hierarchy table around
	insert into @MyHierarchy select * from dbo.ParseXML(@XMLSample)
	SELECT dbo.ToJSON(@MyHierarchy)
	 
	       */
	RETURNS NVARCHAR(MAX)--JSON documents are always unicode.
	AS
	BEGIN
	  DECLARE
	    @JSON NVARCHAR(MAX),
	    @NewJSON NVARCHAR(MAX),
	    @Where INT,
	    @ANumber INT,
	    @notNumber INT,
	    @indent INT,
	    @ii int,
	    @CrLf CHAR(2)--just a simple utility to save typing!
	      
	  --firstly get the root token into place 
	  SELECT @CrLf=CHAR(13)+CHAR(10),--just CHAR(10) in UNIX
	         @JSON = CASE ValueType WHEN 'array' THEN 
	         +COALESCE('{'+@CrLf+'  "'+NAME+'" : ','')+'[' 
	         ELSE '{' END
	            +@CrLf
	            + case when ValueType='array' and NAME is not null then '  ' else '' end
	            + '@Object'+CONVERT(VARCHAR(5),OBJECT_ID)
	            +@CrLf+CASE ValueType WHEN 'array' THEN
	            case when NAME is null then ']' else '  ]'+@CrLf+'}'+@CrLf end
	                ELSE '}' END
	  FROM @Hierarchy 
	    WHERE parent_id IS NULL AND valueType IN ('object','document','array') --get the root element
	/* now we simply iterat from the root token growing each branch and leaf in each iteration. This won't be enormously quick, but it is simple to do. All values, or name/value pairs withing a structure can be created in one SQL Statement*/
	  Select @ii=1000
	  WHILE @ii>0
	    begin
	    SELECT @where= PATINDEX('%[^[a-zA-Z0-9]@Object%',@json)--find NEXT token
	    if @where=0 BREAK
	    /* this is slightly painful. we get the indent of the object we've found by looking backwards up the string */ 
	    SET @indent=CHARINDEX(char(10)+char(13),Reverse(LEFT(@json,@where))+char(10)+char(13))-1
	    SET @NotNumber= PATINDEX('%[^0-9]%', RIGHT(@json,LEN(@JSON+'|')-@Where-8)+' ')--find NEXT token
	    SET @NewJSON=NULL --this contains the structure in its JSON form
	    SELECT  
	        @NewJSON=COALESCE(@NewJSON+','+@CrLf+SPACE(@indent),'')
	        +case when parent.ValueType='array' then '' else COALESCE('"'+TheRow.NAME+'" : ','') end
	        +CASE TheRow.valuetype
	        WHEN 'array' THEN '  ['+@CrLf+SPACE(@indent+2)
	           +'@Object'+CONVERT(VARCHAR(5),TheRow.[OBJECT_ID])+@CrLf+SPACE(@indent+2)+']' 
	        WHEN 'object' then '  {'+@CrLf+SPACE(@indent+2)
	           +'@Object'+CONVERT(VARCHAR(5),TheRow.[OBJECT_ID])+@CrLf+SPACE(@indent+2)+'}'
	        WHEN 'string' THEN '"'+[CodeHouse].[JSONEscaped](TheRow.StringValue)+'"'
	        ELSE TheRow.StringValue
	       END 
	     FROM @Hierarchy TheRow 
	     inner join @hierarchy Parent
	     on parent.element_ID=TheRow.parent_ID
	      WHERE TheRow.parent_id= SUBSTRING(@JSON,@where+8, @Notnumber-1)
	     /* basically, we just lookup the structure based on the ID that is appended to the @Object token. Simple eh? */
	    --now we replace the token with the structure, maybe with more tokens in it.
	    Select @JSON=STUFF (@JSON, @where+1, 8+@NotNumber-1, @NewJSON),@ii=@ii-1
	    end
	  return @JSON
	end;
GO
--------------------------------------------- END https://www.red-gate.com/simple-talk/sql/t-sql-programming/consuming-json-strings-in-sql-server/
GO
CREATE OR ALTER PROCEDURE [CodeHouse].[ExecuteCall_Deployment] (
  @DeploymentName NVARCHAR(128),
  @DeploymentNotes NVARCHAR(MAX),
  @Layer VARCHAR(50),
  @Stream VARCHAR(50),
  @StreamVariant VARCHAR(50),
  @CodeObjectName VARCHAR(50),
  @DeploymentSet UNIQUEIDENTIFIER = NULL OUTPUT,
  @ReturnDropScript BIT = 1,
  @ReturnObjectScript BIT = 1,
  @ReturnExtendedPropertiesScript BIT = 0,
  @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,
  @OnlyObjectTypes [CodeHouse].[ObjectType] READONLY
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Execute Call object type for Deployment
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10);
  DECLARE @GoStatement NVARCHAR(10) = CONCAT(N'GO', @CRLF);
  DECLARE @CodeObjectInput NVARCHAR(MAX),
          @CodeObject NVARCHAR(MAX);
  DECLARE @CMD NVARCHAR(MAX);
  IF @Layer IS NULL
    THROW 50000, 'Layer must be provided. Terminating Procedure.', 1;  
  DECLARE @DatabaseName NVARCHAR(MAX) = (SELECT [DatabaseName] FROM [CodeHouse].[Layer] WHERE [Layer] = @Layer);
  IF @DatabaseName IS NULL
    THROW 50000, 'Layer supplied cannot be located in CodeHouse.Layer. Terminating Procedure.', 1;
  IF @Stream IS NULL
    THROW 50000, '{Stream} Tag and Value must be provided. Terminating Procedure.', 1;
  IF @StreamVariant IS NULL
    THROW 50000, '{StreamVariant} Tag and Value must be provided. Terminating Procedure.', 1;
  IF @CodeObjectName IS NULL
    THROW 50000, '{CodeObjectName} Tag and Value must be provided. Terminating Procedure.', 1;
  DECLARE @UseComponent NVARCHAR(140) = CONCAT('USE ','[', @DatabaseName, ']', @CRLF, @GoStatement);
  SET @CodeObjectInput = (SELECT [CodeObject] FROM [CodeHouse].[vCodeObject] WHERE [Layer] = @Layer AND [Stream] = @Stream AND [StreamVariant] = @StreamVariant AND [CodeObjectName] = @CodeObjectName);
  -- Execute --
  SET @CodeObject = @CodeObjectInput;
  SET @CMD = CONCAT(@Codeobject, @CRLF);
  EXEC SP_ExecuteSQL @CMD, N'@DeploymentName NVARCHAR(128), @DeploymentNotes NVARCHAR(MAX), @Layer VARCHAR(50), @DeploymentSet UNIQUEIDENTIFIER = NULL OUTPUT, @ReturnDropScript BIT = 1, @ReturnObjectScript BIT = 1, @ReturnExtendedPropertiesScript BIT = 0, @ReplacementTags [CodeHouse].[ReplacementTag] READONLY,   @OnlyObjectTypes [CodeHouse].[ObjectType] READONLY',
                     @DeploymentName = @DeploymentName,
                     @DeploymentNotes = @DeploymentNotes,
                     @Layer = @Layer,
                     @DeploymentSet = @DeploymentSet OUTPUT,
                     @ReturnDropScript  = @ReturnDropScript,
                     @ReturnObjectScript  = @ReturnObjectScript,
                     @ReturnExtendedPropertiesScript  = @ReturnExtendedPropertiesScript,
                     @ReplacementTags = @ReplacementTags,
                     @OnlyObjectTypes = @OnlyObjectTypes;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

GO
CREATE OR ALTER PROCEDURE [CodeHouse].[ExecuteCall_DeploymentGroup] (
  @DeploymentName NVARCHAR(128),
  @DeploymentNotes NVARCHAR(MAX) = NULL,
  @DeployExist BIT = 1,
  @ReturnDropScript BIT = 1,
  @ReturnObjectScript BIT = 1,
  @ReturnExtendedPropertiesScript BIT = 0,
  @OnlyLayer VARCHAR(50) = NULL,
  @OnlyStream VARCHAR(50) = NULL,
  @OnlyDeploymentGroupID INT = NULL,
  @OnlyObjectTypes [CodeHouse].[ObjectType] READONLY
)
AS
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  SET XACT_ABORT ON;
  -------------------------------------------------------------------------------------------------
  -- Author: Cedric Dube
  -- Create date: 2021-08-05
  -- Description: Execute calls stored for a Deployment Group.
  -- Version: 1.0
  -------------------------------------------------------------------------------------------------
BEGIN
BEGIN TRY;
  -- VALIDATE --
  IF (@DeploymentName IS NULL OR LTRIM(TRIM(@DeploymentName)) = '')
    THROW 50000, 'DeploymentName must be provided. Terminating Procedure.', 1;
  IF (@DeploymentNotes IS NULL OR LTRIM(TRIM(@DeploymentNotes)) = '') AND @DeployExist = 0
    THROW 50000, 'DeploymentNotes must be provided when not deploying existing. Terminating Procedure.', 1; 
  -- INITIALIZE --
  DECLARE @ReplacementTags [CodeHouse].[ReplacementTag];
  DECLARE @DeploymentGroupID INT,
          @DeploymentSet UNIQUEIDENTIFIER,
          @DeploymentOrdinal SMALLINT,
          @ObjectLayer VARCHAR(50),
          @ObjectStream VARCHAR(50),
          @ObjectStreamVariant VARCHAR(50),
          @CodeObjectName NVARCHAR(128),
          @Layer VARCHAR(50),
          @Stream VARCHAR(50);
  DROP TABLE IF EXISTS #DeploymentGroup;
  CREATE TABLE #DeploymentGroup (
    [DeploymentGroupID] INT NOT NULL,
    [Ordinal] SMALLINT NOT NULL,
    [DeploymentGroupName] NVARCHAR(128) NOT NULL,
    -- If using existing deployment --
    [DeploymentSet] UNIQUEIDENTIFIER NULL,
    -- Object --
    [DeploymentScriptObject] NVARCHAR(128) NOT NULL,
    [DeploymentScriptLayer] VARCHAR(50) NOT NULL,
    [DeploymentScriptStream] VARCHAR(50) NOT NULL,
    [DeploymentScriptStreamVariant] VARCHAR(50) NOT NULL,
    -- Stream --
    [Layer] VARCHAR(50) NOT NULL,
    [Stream] VARCHAR(50) NOT NULL,
    [StreamVariant] VARCHAR(50) NOT NULL,
    -- Tags --
    [ReplacementTags] NVARCHAR(MAX) NULL
  );
  -- COLLECT DEPLOYMENTS IN GROUP --
  INSERT INTO #DeploymentGroup(
    [DeploymentGroupID],
    [Ordinal],
    [DeploymentGroupName],
    [DeploymentSet],
    [DeploymentScriptObject],
    [DeploymentScriptLayer],
    [DeploymentScriptStream],
    [DeploymentScriptStreamVariant],
    [Layer],
    [Stream],
    [StreamVariant],
    [ReplacementTags] 
  ) SELECT [DeploymentGroupID],
           [Ordinal],
           [DeploymentGroupName],
           [DeploymentSet],
           [DeploymentScriptObject],
           [DeploymentScriptLayer],
           [DeploymentScriptStream],
           [DeploymentScriptStreamVariant],
           [Layer],
           [Stream],
           [StreamVariant],
           [ReplacementTags] 
      FROM [CodeHouse].[vDeploymentGroup] 
     WHERE [DeploymentGroupName] = @DeploymentName
       AND ([Layer] = @OnlyLayer OR @OnlyLayer IS NULL)
       AND ([Stream] = @OnlyStream OR @OnlyStream IS NULL)
       AND ([DeploymentGroupID] = @OnlyDeploymentGroupID OR @OnlyDeploymentGroupID IS NULL);
  -- ITERATE --
  WHILE EXISTS (SELECT 1 FROM #DeploymentGroup) BEGIN;
    DELETE FROM @ReplacementTags;
    SELECT @DeploymentOrdinal = MIN(Ordinal) FROM #DeploymentGroup;
    -- IF ONLY DROPS, REVERSE ORDINAL --
    IF (@ReturnDropScript = 1 AND @ReturnObjectScript = 0 AND @ReturnExtendedPropertiesScript = 0)
      SELECT @DeploymentOrdinal = MAX(Ordinal) FROM #DeploymentGroup;
    SELECT @DeploymentGroupID = [DeploymentGroupID],
           @DeploymentSet = CASE WHEN @DeployExist = 0 THEN NULL ELSE [DeploymentSet] END,
           @ObjectLayer = [DeploymentScriptLayer],
           @ObjectStream = [DeploymentScriptStream],
           @ObjectStreamVariant = [DeploymentScriptStreamVariant],
           @CodeObjectName = [DeploymentScriptObject],
           @Layer = [Layer],
           @Stream = [Stream]
      FROM #DeploymentGroup WHERE [Ordinal] = @DeploymentOrdinal;
    -- REPLACEMENT TAGS INPUT --
    --INSERT INTO @ReplacementTags ([Tag], [Value])
    --  SELECT [Tag],[Value] 
    --    FROM #DeploymentGroup PDG
    --  CROSS APPLY OPENJSON(ReplacementTags) WITH (
    --    [ReplacementTags] NVARCHAR(MAX) AS JSON
    --  ) Tags
    --  CROSS APPLY OPENJSON([Tags].[ReplacementTags]) WITH (
    --    [Tag] VARCHAR(50)  '$.Tag',
    --    [Value] NVARCHAR(MAX)  '$.Value'
    --  ) TagValues
    --   WHERE PDG.[Ordinal] = @DeploymentOrdinal;
    -- REPLACEMENT TAGS INPUT --
    INSERT INTO @ReplacementTags ([Tag], [Value])
      SELECT TAGS.[StringValue] AS [Tag], VALS.[StringValue] AS [Value]
        FROM #DeploymentGroup PDG
       CROSS APPLY (SELECT [Parent_ID], [StringValue] FROM [CodeHouse].[ParseJSON] (PDG.ReplacementTags) WHERE [Name] = 'Tag') TAGS
       CROSS APPLY (SELECT [Parent_ID], [StringValue] FROM [CodeHouse].[ParseJSON] (PDG.ReplacementTags) WHERE [Name] = 'Value' AND [Parent_ID] = TAGS.[Parent_ID]) VALS
       WHERE PDG.[Ordinal] = @DeploymentOrdinal;
    -- STANDARD TAGS --
    INSERT INTO @ReplacementTags ([Tag], [Value])
      SELECT '{Layer}', [Layer] FROM  #DeploymentGroup WHERE [Ordinal] = @DeploymentOrdinal AND NOT EXISTS (SELECT 1 FROM @ReplacementTags WHERE [Tag] = '{Layer}') UNION
      SELECT '{Stream}', [Stream] FROM  #DeploymentGroup WHERE [Ordinal] = @DeploymentOrdinal AND NOT EXISTS (SELECT 1 FROM @ReplacementTags WHERE [Tag] = '{Stream}')  UNION
      SELECT '{StreamVariant}', [StreamVariant] FROM  #DeploymentGroup WHERE [Ordinal] = @DeploymentOrdinal AND NOT EXISTS (SELECT 1 FROM @ReplacementTags WHERE [Tag] = '{StreamVariant}');
    -- CALL DEPLOYMENTS --
    EXEC [CodeHouse].[ExecuteCall_Deployment] @DeploymentName = @DeploymentName,
                                              @DeploymentNotes = @DeploymentNotes,
                                              @DeploymentSet = @DeploymentSet OUTPUT,
                                              @Layer = @ObjectLayer,
                                              @Stream = @ObjectStream,
                                              @StreamVariant = @ObjectStreamVariant, 
                                              @CodeObjectName = @CodeObjectName, 
                                              @ReturnDropScript = @ReturnDropScript,
                                              @ReturnObjectScript = @ReturnObjectScript,
                                              @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript,
                                              @ReplacementTags = @ReplacementTags,
                                              @OnlyObjectTypes = @OnlyObjectTypes;
    -- UPDATE GROUP --
    UPDATE [CodeHouse].[DeploymentGroup] SET [DeploymentSet] = @DeploymentSet WHERE [DeploymentGroupID] = @DeploymentGroupID AND ([DeploymentSet] IS NULL OR [DeploymentSet] <> @DeploymentSet);
    DELETE FROM #DeploymentGroup WHERE [Ordinal] = @DeploymentOrdinal;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO

/* End of File ********************************************************************************************************************/