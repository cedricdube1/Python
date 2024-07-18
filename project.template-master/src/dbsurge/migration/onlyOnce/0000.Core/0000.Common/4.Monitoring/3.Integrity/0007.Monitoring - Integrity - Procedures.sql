/***********************************************************************************************************************************
* Script      : 7.Integrity - Procedures.sql                                                                                       *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-04-15                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. [SetIntegrityObject]                                                                                           *
*             :  2. [SetIntegrityCompareObject]                                                                                    *
*             :  3. [IntegrityObjectCheck]                                                                                         *
*             :  4. [Process_Integrity]                                                                                            *
***********************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE PROCEDURE [Monitoring].[SetIntegrityObject] (
  @DatabaseName NVARCHAR(128),
  @SchemaName NVARCHAR(128),
  @ObjectName NVARCHAR(128),
  @IntegrityObjectColumnSet [Monitoring].[IntegrityObjectColumnSet] READONLY
) AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-04-15
  -- Description: Add Integrity Objects
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY
  -- Check --
  SET @DatabaseName = REPLACE(REPLACE(@DatabaseName,'[',''),']','');
  SET @SchemaName = REPLACE(REPLACE(@SchemaName,'[',''),']','');
  SET @ObjectName = REPLACE(REPLACE(@ObjectName,'[',''),']','');
  DECLARE @ObjectCheckName NVARCHAR(255) = @DatabaseName + '.' + @SchemaName + '.' + @ObjectName;
  DECLARE @IntegrityObjectID INT = (SELECT IntegrityObjectID FROM [Monitoring].[IntegrityObject] WHERE DatabaseName = @DatabaseName AND SchemaName = @SchemaName AND ObjectName = @ObjectName);

  -- Check top level --
  IF OBJECT_ID(@ObjectCheckName) IS NULL
    THROW 50000, 'Database Schema Object provided does not exist. Terminating.', 1;

  -- Check columns --
  IF EXISTS (SELECT * FROM ( SELECT COL_LENGTH(@ObjectCheckName,ColumnName) AS ColumnLength
                               FROM @IntegrityObjectColumnSet) QRY WHERE ColumnLength IS NULL)
  BEGIN;
    SELECT ColumnName, 0 AS [ExistsInDatabaseObject]
      FROM @IntegrityObjectColumnSet
    WHERE COL_LENGTH(@ObjectCheckName,ColumnName) IS NULL;
    THROW 50000, 'One or more Columns provided do not exist. Terminating.', 1;
  END;
  -- Object --
  -- Insert Only --
  IF @IntegrityObjectID IS NULL BEGIN;
   INSERT INTO [Monitoring].[IntegrityObject] (
     DatabaseName,
     SchemaName,
     ObjectName
   ) VALUES (@DatabaseName, @SchemaName, @ObjectName);
   SET @IntegrityObjectID = @@IDENTITY;
  END;

  -- Object Column --
  -- Update --
  UPDATE IOC
    SET IsParameter = IOS.IsParameter
   FROM [Monitoring].[IntegrityObjectColumn] IOC
  INNER JOIN @IntegrityObjectColumnSet IOS
     ON IOC.IntegrityObjectID = @IntegrityObjectID
    AND IOC.ColumnName = REPLACE(REPLACE(IOS.ColumnName,'[',''),']','');

  -- Insert --
  INSERT INTO [Monitoring].[IntegrityObjectColumn] (
    IntegrityObjectID,
    ColumnName,
    IsParameter
  ) SELECT @IntegrityObjectID,
           REPLACE(REPLACE(IOS.ColumnName,'[',''),']',''),
           IOS.IsParameter
      FROM @IntegrityObjectColumnSet IOS
    WHERE NOT EXISTS (SELECT *
                        FROM [Monitoring].[IntegrityObjectColumn]
                       WHERE IntegrityObjectID = @IntegrityObjectID
                         AND ColumnName = REPLACE(REPLACE(IOS.ColumnName,'[',''),']',''));
END TRY
BEGIN CATCH
  THROW
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Monitoring].[SetIntegrityCompareObject] (
  @DatabaseName_A NVARCHAR(128),
  @SchemaName_A NVARCHAR(128),
  @ObjectName_A NVARCHAR(128),
  @DatabaseName_B NVARCHAR(128),
  @SchemaName_B NVARCHAR(128),
  @ObjectName_B NVARCHAR(128),
  @IntegrityCompareObjectSet [Monitoring].[IntegrityCompareObjectSet] READONLY
) AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-04-15
  -- Description: Add Integrity Compare Objects map
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY
  -- Remove braces --
  SET @DatabaseName_A = REPLACE(REPLACE(@DatabaseName_A,'[',''),']','');
  SET @SchemaName_A = REPLACE(REPLACE(@SchemaName_A,'[',''),']','');
  SET @ObjectName_A = REPLACE(REPLACE(@ObjectName_A,'[',''),']','');
  DECLARE @ObjectCheckName NVARCHAR(255);
  DECLARE @IntegrityObjectID_A INT = (SELECT IntegrityObjectID FROM [Monitoring].[IntegrityObject] WHERE DatabaseName = @DatabaseName_A AND SchemaName = @SchemaName_A AND ObjectName = @ObjectName_A),
          @IntegrityObjectID_B INT = (SELECT IntegrityObjectID FROM [Monitoring].[IntegrityObject] WHERE DatabaseName = @DatabaseName_B AND SchemaName = @SchemaName_B AND ObjectName = @ObjectName_B);

  -- Do we have the object? --
  IF @IntegrityObjectID_A IS NULL
    THROW 50000, 'No IntegrityObjectID found for Database Schema Object for A. Terminating',1;
  IF @IntegrityObjectID_A IS NULL
    THROW 50000, 'No IntegrityObjectID found for Database Schema Object for B. Terminating',1;

  -- Check top level -- A --
  SET @ObjectCheckName  = @DatabaseName_A + '.' + @SchemaName_A + '.' + @ObjectName_A;
  IF OBJECT_ID(@ObjectCheckName) IS NULL
    THROW 50000, 'Database Schema Object for A provided does not exist. Terminating.', 1;
  -- Check columns -- A --
  IF EXISTS (SELECT * FROM ( SELECT COL_LENGTH(@ObjectCheckName,ColumnName_A) AS ColumnLength
                               FROM @IntegrityCompareObjectSet) QRY WHERE ColumnLength IS NULL)
  BEGIN;
    SELECT ColumnName_A, 0 AS [ExistsInDatabaseObject]
      FROM @IntegrityCompareObjectSet
    WHERE COL_LENGTH(@ObjectCheckName,ColumnName_A) IS NULL;
    THROW 50000, 'One or more Columns for A provided do not exist. Terminating.', 1;
  END;
  IF EXISTS (
    SELECT REPLACE(REPLACE(ColumnName_A,'[',''),']','') AS ColumnName FROM @IntegrityCompareObjectSet
    EXCEPT
    SELECT ColumnName FROM [Monitoring].[IntegrityObjectColumn] WHERE IntegrityObjectID = @IntegrityObjectID_A
  ) BEGIN;
        THROW 50000, 'One or more Columns for A provided does not exist in IntegrityObjectColumn. Terminating.', 1;
  END;

  -- Check top level -- B --
  SET @ObjectCheckName  = @DatabaseName_B + '.' + @SchemaName_B + '.' + @ObjectName_B;
  IF OBJECT_ID(@ObjectCheckName) IS NULL
    THROW 50000, 'Database Schema Object for B provided does not exist. Terminating.', 1;
  -- Check columns -- B --
  IF EXISTS (SELECT * FROM ( SELECT COL_LENGTH(@ObjectCheckName,ColumnName_B) AS ColumnLength
                               FROM @IntegrityCompareObjectSet) QRY WHERE ColumnLength IS NULL)
  BEGIN;
    SELECT ColumnName_B, 0 AS [ExistsInDatabaseObject]
      FROM @IntegrityCompareObjectSet
    WHERE COL_LENGTH(@ObjectCheckName,ColumnName_B) IS NULL;
    THROW 50000, 'One or more Columns for B provided do not exist. Terminating.', 1;
  END;
  IF EXISTS (
    SELECT REPLACE(REPLACE(ColumnName_B,'[',''),']','') AS ColumnName FROM @IntegrityCompareObjectSet
    EXCEPT
    SELECT ColumnName FROM [Monitoring].[IntegrityObjectColumn] WHERE IntegrityObjectID = @IntegrityObjectID_B
  ) BEGIN;
        THROW 50000, 'One or more Columns for B provided does not exist in IntegrityObjectColumn. Terminating.', 1;
  END;

  -- Compare Object --
  -- Update --
  UPDATE ICO
    SET IsEnabled = IOS.IsEnabled
   FROM [Monitoring].[IntegrityCompareObject] ICO
  INNER JOIN [Monitoring].[vIntegrityCompareObject] vICO
     ON ICO.[IntegrityCompareObjectID] = vICO.[IntegrityCompareObjectID]
  INNER JOIN @IntegrityCompareObjectSet IOS
     ON vICO.IntegrityObjectID_A = @IntegrityObjectID_A
    AND vICO.IntegrityObjectID_B = @IntegrityObjectID_B
    AND vICO.ColumnName_A = REPLACE(REPLACE(IOS.ColumnName_A,'[',''),']','')
    AND vICO.ColumnName_B = REPLACE(REPLACE(IOS.ColumnName_B,'[',''),']','');

  -- Insert --
  INSERT INTO [Monitoring].[IntegrityCompareObject] (
    IntegrityObjectID_A,
    IntegrityObjectID_B,
    IntegrityObjectColumnID_A,
    IntegrityObjectColumnID_B,
    IsEnabled
  ) SELECT @IntegrityObjectID_A,
           @IntegrityObjectID_B,
           IOC_A.IntegrityObjectColumnID,
           IOC_B.IntegrityObjectColumnID,
           IOS.IsEnabled
      FROM @IntegrityCompareObjectSet IOS
     INNER JOIN [Monitoring].[IntegrityObjectColumn] IOC_A
        ON IOC_A.IntegrityobjectID = @IntegrityObjectID_A
       AND IOC_A.ColumnName = REPLACE(REPLACE(IOS.ColumnName_A,'[',''),']','')
     INNER JOIN [Monitoring].[IntegrityObjectColumn] IOC_B
        ON IOC_B.IntegrityobjectID = @IntegrityObjectID_B
       AND IOC_B.ColumnName = REPLACE(REPLACE(IOS.ColumnName_B,'[',''),']','')
     WHERE NOT EXISTS (SELECT *
                         FROM [Monitoring].[vIntegrityCompareObject] vICO
                        WHERE vICO.IntegrityObjectID_A = @IntegrityObjectID_A
                          AND vICO.IntegrityObjectID_B = @IntegrityObjectID_B
                          AND vICO.IntegrityObjectColumnID_A = IOC_A.IntegrityObjectColumnID
                          AND vICO.IntegrityObjectColumnID_B = IOC_B.IntegrityObjectColumnID);
END TRY
BEGIN CATCH
  THROW
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Monitoring].[IntegrityObjectCheck] (
  @ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT
) AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-04-15
  -- Description: Check for Integrity Object variance
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @NowTime DATETIME2  = SYSUTCDATETIME();
  -------------------------------
  -- TASK VARS.
  -------------------------------
  DECLARE @Taskname NVARCHAR(128) = 'Integrity';
  SET @TaskID = [Config].[GetTaskIDByName](@Taskname);
  DECLARE @ProcessTaskID INT,
          @IsProcessTaskEnabled BIT;
  EXEC [Config].[GetProcessTaskStateByID] @ProcessID = @ProcessID, @TaskID = @TaskID,
                                          @ProcessTaskID = @ProcessTaskID OUTPUT, @IsEnabled = @IsProcessTaskEnabled OUTPUT;
  -------------------------------
  -- LOGGING VARS.
  -------------------------------
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @InfoLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, 'InfoDisabled') AS BIT);
  DECLARE @CaptureLoggingDisabled BIT = TRY_CAST([Config].[GetVariable_ProcessTask_Logging](@ProcessTaskID, 'CaptureDisabled') AS BIT);
  DECLARE @StepID INT = 0,
          @ProcessTaskInfoLogID BIGINT = 0;
  -------------------------------
  -- PROCESSING VARS.
  -------------------------------
  DECLARE @MonitoringTime DATETIME2 = SYSDATETIME();
  DECLARE @TimeWindow INT = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'TimeWindow') AS INT);
  DECLARE @DelayedTimeLimit INT = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'DelayedTimeLimit') AS INT);
  DECLARE @LowerDateBound DATE = ISNULL(TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'LowerDateBound') AS DATE), '1753-01-01');
  DECLARE @UpperDateBound DATE = ISNULL(TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'UpperDateBound') AS DATE), '9999-12-31');
  DECLARE @LowerDateBoundDecrement SMALLINT = ISNULL(TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'LowerDateBoundDecrement') AS SMALLINT), 1);
  DECLARE @UpperDateBoundDecrement SMALLINT = ISNULL(TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'UpperDateBoundDecrement') AS SMALLINT), 0);
  DECLARE @IntegrityParameters NVARCHAR(1000) = 'LowerDateBound: ' + CONVERT(VARCHAR, @LowerDateBound, 121) + '; UpperDateBound: ' + CONVERT(VARCHAR, @UpperDateBound, 121);
  DECLARE @RunEnvironment CHAR(3) = CASE WHEN @@SERVERNAME IN ('CPTDEVDB02','CPTDEVDB10') THEN 'DEV'
                                         WHEN @@SERVERNAME IN ('ANALYSIS01') THEN 'PRD'
                                    ELSE 'DEV' END;
  -------------------------------
  -- NOTIFICATION VARS.
  -------------------------------
  DECLARE @MessageTime CHAR(5) = CONVERT(VARCHAR(5), SYSDATETIME(), 108);
  DECLARE @SendType VARCHAR(10) = TRY_CAST([Config].[GetVariable_ProcessTask_Monitoring](@ProcessTaskID, 'SendType') AS VARCHAR(10));
  DECLARE @RecCountFail INT = 0;
  DECLARE @AlertType VARCHAR(10),
          @ProfileName NVARCHAR(128),
          @DefaultSubject NVARCHAR(128);
  DECLARE @AlertMessageHeader NVARCHAR(140),
          @AlertMessage NVARCHAR(MAX),
          @AlertQuery NVARCHAR(MAX),
          @AlertBodyOrder NVARCHAR(MAX);
  DECLARE @ToNumbers_Fail VARCHAR(8000) = [Notification].[GetRecipientList](@SendType);
  DECLARE @AlertFormat VARCHAR(20) = CASE WHEN @SendType = 'EMail' THEN 'HTML'
                                          WHEN @SendType = 'SMS' THEN 'TEXT'
                                     ELSE 'DEV' END;
  SELECT TOP (1) @AlertType = SendType,
                 @ProfileName = ProfileName,
                 @DefaultSubject = DefaultSubject
    FROM [Notification].[SendProfile] WITH (NOLOCK)
   WHERE ProfileType = 'DEFAULT' AND SendType = @SendType;
  -------------------------------
  -- UPDATED VARS.
  -------------------------------
  DECLARE @NewLowerBoundDate DATE = DATEADD(DAY, @LowerDateBoundDecrement * -1, SYSUTCDATETIME());
  DECLARE @NewUpperBoundDate DATE = DATEADD(DAY, @UpperDateBoundDecrement * -1, SYSUTCDATETIME());
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION PROCESS
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- DETERMINE PROCESS TASK
  -------------------------------
  EXEC [Logging].[LogProcessTaskStart] @IsEnabled = @IsProcessTaskEnabled, @ProcessLogID = @ProcessLogID,
                                       @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                       @ProcessTaskID = @ProcessTaskID,
                                       @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;

  SET @InfoMessage = 'Task for ' + @Taskname + ' started.';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;
  -- IsEnabled = 0 --
  IF @IsProcessTaskEnabled = 0 BEGIN;
      IF @ProcessTaskLogID IS NULL SET @ProcessTaskLogID = -1;
    -- Info Log Start --
    SET @InfoMessage = 'Task for ' + @Taskname + ' is DISABLED in Config.Task. Exiting.';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                    @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                    @ProcessTaskID = @ProcessTaskID,
                                                                    @ProcessTaskLogID = @ProcessTaskLogID,
                                                                    @InfoMessage = @InfoMessage,
                                                                    @Ordinal = @StepID;
    GOTO Finalize;
  END;
  ------------------------
  -- TEMP. TABLES --
  ------------------------
  IF OBJECT_ID('TempDB..#IntegrityCompareObject') IS NOT NULL 
    DROP TABLE #IntegrityCompareObject;
  CREATE TABLE #IntegrityCompareObject (
    IntegrityCompareObjectID INT NOT NULL,
    IntegrityObjectID_A INT NOT NULL,
    IntegrityObjectID_B INT NOT NULL,
    IntegrityObjectColumnID_A INT NOT NULL,
    IntegrityObjectColumnID_B INT NOT NULL,
    DatabaseName_A NVARCHAR(128) NOT NULL,
    DatabaseName_B NVARCHAR(128) NOT NULL,
    SchemaName_A NVARCHAR(128) NOT NULL,
    SchemaName_B NVARCHAR(128) NOT NULL,
    ObjectName_A NVARCHAR(128) NOT NULL,
    ObjectName_B NVARCHAR(128) NOT NULL,
    ColumnName_A NVARCHAR(128) NOT NULL,
    ColumnName_B NVARCHAR(128) NOT NULL,
    IsParameter_A BIT NOT NULL,
    IsParameter_B BIT NOT NULL
  );
  IF OBJECT_ID('TempDB..#Failure') IS NOT NULL 
    DROP TABLE #Failure;
  CREATE TABLE #Failure (
    IntegrityObjectID_A INT NOT NULL,
    IntegrityObjectID_B INT NOT NULL,
    IntegrityParameters NVARCHAR(1000) NULL,
    ValueA XML NULL,
    ValueB XML NULL,
    CheckQuery NVARCHAR(MAX) NULL
  );

  ------------------------
  -- COLLECT INTEGRITY OBJECT
  ------------------------
  INSERT INTO #IntegrityCompareObject (
    IntegrityCompareObjectID,
    IntegrityObjectID_A,
    IntegrityObjectID_B,
    IntegrityObjectColumnID_A,
    IntegrityObjectColumnID_B,
    DatabaseName_A,
    DatabaseName_B,
    SchemaName_A,
    SchemaName_B,
    ObjectName_A,
    ObjectName_B,
    ColumnName_A,
    ColumnName_B,
    IsParameter_A,
    IsParameter_B
  ) SELECT IntegrityCompareObjectID,
           IntegrityObjectID_A,
           IntegrityObjectID_B,
           IntegrityObjectColumnID_A,
           IntegrityObjectColumnID_B,
           DatabaseName_A,
           DatabaseName_B,
           SchemaName_A,
           SchemaName_B,
           ObjectName_A,
           ObjectName_B,
           ColumnName_A,
           ColumnName_B,
           IsParameter_A,
           IsParameter_B
     FROM [Monitoring].[vIntegrityCompareObject] WHERE [IsEnabled] = 1;
  ------------------------
  -- COLLECT DIFFERENCES
  ------------------------
  WHILE EXISTS (SELECT 1 FROM #IntegrityCompareObject) BEGIN;
    DECLARE @Command NVARCHAR(MAX);
	DECLARE @Command_A NVARCHAR(MAX);
	DECLARE @Command_B NVARCHAR(MAX);
	DECLARE @CheckQuery NVARCHAR(MAX);
    DECLARE @ValueA XML,
            @ValueB XML,
            @ObjectA NVARCHAR(255),
            @ObjectB NVARCHAR(255),
            @IntegrityObjectID_A INT,
            @IntegrityObjectID_B INT,
            @DatabaseName_A NVARCHAR(128),
            @DatabaseName_B NVARCHAR(128),
            @SchemaName_A NVARCHAR(128),
            @SchemaName_B NVARCHAR(128),
            @ObjectName_A NVARCHAR(128),
            @ObjectName_B NVARCHAR(128),
            @Columns_A NVARCHAR(MAX),
            @Columns_B NVARCHAR(MAX);
    SELECT TOP (1) @IntegrityObjectID_A = IntegrityObjectID_A,
                   @IntegrityObjectID_B = IntegrityObjectID_B,
                   @DatabaseName_A = DatabaseName_A,
                   @DatabaseName_B = DatabaseName_B,
                   @SchemaName_A = SchemaName_A,
                   @SchemaName_B = SchemaName_B,
                   @ObjectName_A = ObjectName_A,
                   @ObjectName_B = ObjectName_B
              FROM #IntegrityCompareObject ORDER BY IntegrityObjectID_A ASC, IntegrityObjectID_B ASC;
    DECLARE @ParameterColumn_A NVARCHAR(128) = (SELECT TOP(1) ColumnName_A FROM #IntegrityCompareObject WHERE IntegrityObjectID_A = @IntegrityObjectID_A AND IntegrityObjectID_B = @IntegrityObjectID_B AND IsParameter_A = 1);
    DECLARE @ParameterColumn_B NVARCHAR(128) = (SELECT TOP(1) ColumnName_B FROM #IntegrityCompareObject WHERE IntegrityObjectID_A = @IntegrityObjectID_A AND IntegrityObjectID_B = @IntegrityObjectID_B AND IsParameter_B = 1);

    SET @ObjectA = '[' + @DatabaseName_A + '].[' + @SchemaName_A + '].[' + @ObjectName_A + ']';
    SET @ObjectB = '[' + @DatabaseName_B + '].[' + @SchemaName_B + '].[' + @ObjectName_B + ']';

    -- Info Log Start --
    SET @StepID = @StepID + 1;
    SET @InfoMessage = 'Run Checks between ' + @ObjectA + ' and ' + @ObjectB;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    SET @Columns_A = STUFF((SELECT ',' + QUOTENAME(ColumnName_A) 
                              FROM #IntegrityCompareObject 
                             WHERE IntegrityObjectID_A = @IntegrityObjectID_A
                               AND IntegrityObjectID_B = @IntegrityObjectID_B
                             ORDER BY IntegrityCompareObjectID ASC
                                FOR XML PATH(''), TYPE
                              ).value('.', 'NVARCHAR(MAX)'),1,1,'');
    SET @Columns_B =  STUFF((SELECT ',' + QUOTENAME(ColumnName_B) 
                              FROM #IntegrityCompareObject 
                             WHERE IntegrityObjectID_A = @IntegrityObjectID_A
                               AND IntegrityObjectID_B = @IntegrityObjectID_B
                             ORDER BY IntegrityCompareObjectID ASC
                                FOR XML PATH(''), TYPE
                              ).value('.', 'NVARCHAR(MAX)'),1,1,'');
    IF OBJECT_ID(@ObjectA) IS NOT NULL AND OBJECT_ID(@ObjectB) IS NOT NULL BEGIN;
      SET @Command_A = N'
              SELECT ''A_NOT_B'' AS [ExceptDirection], ' + '''' + @ObjectA + ''''  + 'AS [ObjectA], ' + '''' + @ObjectB + ''''  + 'AS [ObjectB],' + @Columns_A + '
                FROM ' + @ObjectA + '
               ' + CASE WHEN @ParameterColumn_A IS NOT NULL THEN ' WHERE [' + @ParameterColumn_A + '] >= @LowerDateBound AND [' + @ParameterColumn_A + '] < @UpperDateBound' ELSE '' END + '
              EXCEPT
              SELECT ''A_NOT_B'' AS [ExceptDirection], ' + '''' + @ObjectA + ''''  + 'AS [ObjectA], ' + '''' + @ObjectB + ''''  + 'AS [ObjectB],' + @Columns_B + '
                FROM ' + @ObjectB + '
               ' + CASE WHEN @ParameterColumn_B IS NOT NULL THEN ' WHERE [' + @ParameterColumn_B + '] >= @LowerDateBound AND [' + @ParameterColumn_B + '] < @UpperDateBound' ELSE '' END;
      SET @Command_B = N'
              SELECT ''B_NOT_A'' AS [ExceptDirection], ' + '''' + @ObjectA + ''''  + 'AS [ObjectA], ' + '''' + @ObjectB + ''''  + 'AS [ObjectB],' + @Columns_B + '
                FROM ' + @ObjectB + '
               ' + CASE WHEN @ParameterColumn_B IS NOT NULL THEN ' WHERE [' + @ParameterColumn_B + '] >= @LowerDateBound AND [' + @ParameterColumn_B + '] < @UpperDateBound' ELSE '' END + '
              EXCEPT
              SELECT ''B_NOT_A'' AS [ExceptDirection], ' + '''' + @ObjectA + ''''  + 'AS [ObjectA], ' + '''' + @ObjectB + ''''  + 'AS [ObjectB],' + @Columns_A + '
                FROM ' + @ObjectA + '
               ' + CASE WHEN @ParameterColumn_A IS NOT NULL THEN ' WHERE [' + @ParameterColumn_A + '] >= @LowerDateBound AND [' + @ParameterColumn_A + '] < @UpperDateBound' ELSE '' END;
      SET @CheckQuery  = @Command_A +'
                         UNION ALL
	                     ' + @Command_B;
      SET @Command = N'
            SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
            ; WITH CTE_A AS (' + @Command_A + '
	  	    )SELECT @ValueA = (SELECT * FROM CTE_A FOR XML RAW,ELEMENTS XSINIL,BINARY BASE64 )
            ; WITH CTE_B AS (' + @Command_B + '
	  	    )SELECT @ValueB = (SELECT * FROM CTE_B FOR XML RAW,ELEMENTS XSINIL,BINARY BASE64 )
            SET TRANSACTION ISOLATION LEVEL READ COMMITTED;';
	  
      EXEC SP_ExecuteSQL @Command,
                         N'@ValueA XML OUTPUT, @ValueB XML OUTPUT, @LowerDateBound DATE, @UpperDateBound DATE',
                         @LowerDateBound = @LowerDateBound,
                         @UpperDateBound = @UpperDateBound,
                         @ValueA = @ValueA OUTPUT,
                         @ValueB = @ValueB OUTPUT;
    END; ELSE BEGIN;
      -- Info Log Start --
      IF OBJECT_ID(@ObjectA) IS NULL
        SET @InfoMessage = 'Object : ' + @ObjectA + ' Does not exist.';
      IF OBJECT_ID(@ObjectB) IS NULL
        SET @InfoMessage = ISNULL(@InfoMessage, '') + 'Object : ' + @ObjectB + ' Does not exist.'
      SET @InfoMessage = @InfoMessage + 'Skipping Check.';
      IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                      @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                      @ProcessTaskID = @ProcessTaskID,
                                                                      @ProcessTaskLogID = @ProcessTaskLogID,
                                                                      @InfoMessage = @InfoMessage,
                                                                      @Ordinal = @StepID;
    END;

    IF @ValueA IS NOT NULL OR @ValueB IS NOT NULL BEGIN;
	  IF @ParameterColumn_A IS NOT NULL OR @ParameterColumn_B IS NOT NULL
	    SET @CheckQuery = N' DECLARE @LowerDateBound DATE = ' + '''' + CONVERT(VARCHAR,@LowerDateBound,121) + '''' + ',
                                     @UpperDateBound DATE = ' + '''' + CONVERT(VARCHAR,@UpperDateBound,121) + '''' + ';
                         ' + @CheckQuery;
      INSERT INTO #Failure (
        IntegrityObjectID_A,
        IntegrityObjectID_B,
        IntegrityParameters,
        ValueA,
        ValueB,
        CheckQuery
      ) VALUES (@IntegrityObjectID_A, @IntegrityObjectID_B, @IntegrityParameters, @ValueA, @ValueB, @CheckQuery);
    END;
    DELETE FROM #IntegrityCompareObject
     WHERE IntegrityObjectID_A = @IntegrityObjectID_A
       AND IntegrityObjectID_B = @IntegrityObjectID_B;

    -- Info Log End --
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
  END;

  ------------------------
  -- WRITE TO MONITORING
  ------------------------
  INSERT INTO [Monitoring].[Integrity] (
    IntegrityObjectID_A,
    IntegrityObjectID_B,
    IntegrityParameters,
    ValueAExceptB,
    ValueBExceptA,
	CheckQuery,
    AlertID,
    InsertDate
  ) SELECT SRC.IntegrityObjectID_A,
           SRC.IntegrityObjectID_B,
           SRC.IntegrityParameters,
           SRC.ValueA,
           SRC.ValueB,
		   SRC.CheckQuery,
           0,
           @MonitoringTime
      FROM #Failure SRC
      LEFT JOIN [Monitoring].[Integrity] TRG
        ON SRC.IntegrityObjectID_A = TRG.IntegrityObjectID_A
       AND SRC.IntegrityObjectID_B = TRG.IntegrityObjectID_B
       AND @MonitoringTime BETWEEN TRG.[InsertDate] AND DATEADD(MINUTE, @TimeWindow, TRG.[InsertDate])
     WHERE TRG.IntegrityObjectID_A IS NULL;
  SET @RecCountFail = @@ROWCOUNT;
  ------------------------
  -- BUILD NOTIFICATIONS
  ------------------------
  IF @RecCountFail > 0
  BEGIN;
    DECLARE @AlertID INT;
    SET @AlertMessageHeader = N'(' + @MessageTime + N') CPT BI-RETENTION ' + @RunEnvironment + N' Daily Integrity - ('
                          + CAST(@RecCountFail AS VARCHAR(5)) + N') variance detected!'
  ---------------
  -- EMAIL
  ---------------
    IF @SendType = 'EMail' BEGIN;
      SET @AlertQuery= '
      SELECT CONVERT(VARCHAR(30), [InsertDate], 121) AS [InsertDate],
             [IntegrityParameters],
             [DatabaseName_A] + ''.'' + [SchemaName_A] + ''.'' + [ObjectName_A] AS [Object A],
             [DatabaseName_B] + ''.'' + [SchemaName_B] + ''.'' + [ObjectName_B] AS [Object B],
             [ValueAExceptB].value(''count(//row)'', ''INT'') AS [Effected Rows (A EXCEPT B)],
             [ValueBExceptA].value(''count(//row)'', ''INT'') AS [Effected Rows (B EXCEPT A)],
	  	   [IntegrityObjectID_A],
	  	   [IntegrityObjectID_B]
      FROM [Monitoring].[vIntegrityAlert]
      WHERE [AlertID] = 0';
      SET @AlertBodyOrder = ' ORDER BY IntegrityObjectID_A ASC, IntegrityObjectID_B ASC';
	  
      EXEC [Notification].[Convert_SQLQuery_ToHtml] @query = @AlertQuery,
                                                    @orderBy = @AlertBodyOrder,
                                                    @html = @AlertMessage OUTPUT;
	  
      SET @AlertMessage = @AlertMessageHeader + CHAR(10) + CHAR(13) + @AlertMessage;
    END;
  ---------------
  -- SMS
  ---------------
    IF @SendType = 'SMS' BEGIN;
      SET @AlertMessage = @AlertMessageHeader;
    END;
    BEGIN TRANSACTION;
      -- Set Notification --
      EXEC [Notification].[SetNotification]   @AlertDateTime = @NowTime,
                                              @Alertprocedure = @ProcedureName,
                                              @AlertType = @AlertType,
                                              @AlertRecipients = @ToNumbers_Fail,
                                              @AlertProfile = @ProfileName,
                                              @AlertFormat = @AlertFormat,
                                              @AlertSubject = @DefaultSubject,
                                              @AlertMessage = @AlertMessage,
                                              @AlertID = @AlertID OUTPUT;
       --Set all records as AlertID = @AlertID --
      UPDATE [Monitoring].[Integrity] WITH (ROWLOCK, READPAST)
        SET AlertID = @AlertID
        WHERE AlertID = 0 AND @AlertID IS NOT NULL;
    COMMIT;
  END;

  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION FINALIZE
  -------------------------------------------------------------------------------------------------
  Finalize:
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  ------------------------
  -- UPDATE VARS.
  ------------------------
  EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                            @ConfigGroupName = 'Monitoring',
                                            @ConfigName = 'LowerDateBound',
                                            @ConfigValue = @NewLowerBoundDate,
                                            @SelectOutput = 0;
  EXEC [Config].[SetVariable_ProcessTask]   @ProcessTaskID = @ProcessTaskID,
                                            @ConfigGroupName = 'Monitoring',
                                            @ConfigName = 'UpperDateBound',
                                            @ConfigValue = @NewUpperBoundDate,
                                            @SelectOutput = 0;
  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Task --
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 1;
  -- Info --
  SET @StepID = @StepID +1;
  SET @InfoMessage = 'Task for ' + @Taskname + ' Completed.';
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfo] @ProcessLogID = @ProcessLogID,
                                                                  @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                  @ProcessTaskID = @ProcessTaskID,
                                                                  @ProcessTaskLogID = @ProcessTaskLogID,
                                                                  @InfoMessage = @InfoMessage,
                                                                  @Ordinal = @StepID;

END TRY
BEGIN CATCH
  /*
    -- XACT_STATE:
     1 = Active transactions, CAN be committed or rolled back. Because of error, we rollback
     0 = NO Active transactions, CANNOT be committed or rolled back.
    -1 = Active transactions, CANNOT be committed but CAN be rolled back. Because of error, we rollback
  */
  IF XACT_STATE() <> 0
    ROLLBACK;
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  ------------------------
  -- COMPLETE INFO LOG
  ------------------------
  IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                     @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
  ------------------------
  -- COMPLETE LOG -- ERROR
  ------------------------
  EXEC [Logging].[LogProcessTaskEnd] @ProcessTaskLogID = @ProcessTaskLogID,
                                     @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                     @StatusCode = 2;
  THROW;
END CATCH;
END
GO
GO
GO
CREATE PROCEDURE [Monitoring].[Process_DailyIntegrity] AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-04-15
  -- Description: Monitor Daily Integrity
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @NowTime DATETIME2(7) = SYSUTCDATETIME();
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  -------------------------------
  -- CONFIG VARS.
  -------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @ProcessName VARCHAR(150) = 'Monitoring|DailyIntegrity',
          @ProcessLogID BIGINT,
          @ProcessLogCreatedMonth TINYINT;
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @ProcessID SMALLINT,
          @IsProcessEnabled BIT;
  EXEC [Config].[GetProcessStateByName] @ProcessName = @ProcessName, @ProcessID = @ProcessID OUTPUT, @IsEnabled = @IsProcessEnabled OUTPUT;
  -- IsEnabled = 0 --
  IF @IsProcessEnabled = 0
    RETURN; -- Nothing to do
  -------------------------------
  -- TASK OUTPUT VARS.
  -------------------------------
  -- PROCESS TASK --
  DECLARE @TaskID SMALLINT,
          @ProcessTaskLogID BIGINT;
  ------------------------
  -- CREATE LOG
  ------------------------
  EXEC [Logging].[LogProcessStart] @IsEnabled = @IsProcessEnabled, @ProcessID = @ProcessID,
                                   @ReuseOpenLog = 1,
                                   @ProcessLogID = @ProcessLogID OUTPUT,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth OUTPUT;
  -- No Log --
  IF @ProcessLogID IS NULL BEGIN;
    SET @ProcessLogID = -1;
    SET @InfoMessage = 'No ProcessLogID was returned from [Logging].[LogProcessStart]. Procedure ' + @ProcedureName + ' terminated.';
    THROW 50000, @InfoMessage, 0;
  END;
  -------------------------------------------------------------------------------------------------
  -- PROCESS
  -------------------------------------------------------------------------------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Monitoring].[IntegrityObjectCheck] @ProcessID = @ProcessID,
                                           @ProcessLogID = @ProcessLogID,
                                           @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                           @TaskID = @TaskID OUTPUT,
                                           @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;
  -------------------------------------------------------------------------------------------------
  -- PROCESS - CONTROLLER JOB DISABLED --
  -------------------------------------------------------------------------------------------------
  -- CLEAR PARAMS.
  SET @TaskID = NULL;
  SET @ProcessTaskLogID = NULL;
  -- RUN TASK
  EXEC [Monitoring].[Controller_JobDisabled] @ProcessID = @ProcessID,
                                             @ProcessLogID = @ProcessLogID,
                                             @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                             @TaskID = @TaskID OUTPUT,
                                             @ProcessTaskLogID = @ProcessTaskLogID OUTPUT;  
  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Process
  EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @StatusCode = 1;

  END TRY
  BEGIN CATCH
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    -- CREATE ERROR LOG ENTRIES
    DECLARE @ErrorNumber INTEGER = ERROR_NUMBER(),
            @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
            @ErrorLine INTEGER = ERROR_LINE(),
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    ------------------------
    -- COMPLETE LOG -- ERROR
    ------------------------
    -- PROCESS --
    EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                   @StatusCode = 2;
    -- LOG ERROR --
    EXEC [Logging].[LogError] @ProcessID = @ProcessID,
                              @ProcessLogID = @ProcessLogID,
                              @ErrorNumber = @ErrorNumber,
                              @ErrorProcedure = @ErrorProcedure,
                              @ErrorLine = @ErrorLine,
                              @ErrorMessage = @ErrorMessage;
    THROW;
  END CATCH;
END;
GO
GO
/* End of File ********************************************************************************************************************/