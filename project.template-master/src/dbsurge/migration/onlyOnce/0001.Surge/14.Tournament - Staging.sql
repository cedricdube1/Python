/************************************************************************
* Script     : 14.Tournament - Staging.sql
* Created By : Hector Prakke
* Created On : 2021-09-09
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps(Pre) : 1 > Functions
*            :   1.1 > HubTournamentHash
* Steps(post): 2 > Procedures
*            :     3.1 > Extract_Tournament (handled by Common, no need to specify here)
*            :     3.2 > Stage_Tournament
*            :     3.3 > Load_Tournament
*            :     3.4 > Process_Tournament
*            :   4 > Config
*            :     4.1 > Setup: Process
*            : 3 > Calling Scripts
*            :   3.1 > GetDeployment
************************************************************************/
USE [dbSurge]
GO
SET NOCOUNT ON;
-------------------------------------
-- Functions
-------------------------------------
------------------
-- HubTournamentHash
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Tournament',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'HubTournamentHash',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Function',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Hector Prakke',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Returns BINARY Hash value representing conformed provider keys.';

SET @CodeObjectHeader = 
'@OriginSystemID INT,
  @TournamentID INT';

SET @CodeObjectExecutionOptions =
'RETURNS BINARY(32) 
  WITH SCHEMABINDING';

SET @CodeObject = 
'BEGIN;
  DECLARE @HashKey BINARY(32);
  SET @HashKey = CAST(HASHBYTES(''SHA2_256'',
                                       TRY_CAST(@OriginSystemID AS VARCHAR)
                                       +''-''+
                                       TRY_CAST(@TournamentID AS VARCHAR)
                 ) AS BINARY(32));
  RETURN @HashKey;
END;';

EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

-------------------------------------
-- Procedures
-------------------------------------
------------------
-- Stage_Tournament
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Tournament',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Stage_Tournament',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Hector Prakke',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Stage Surge Tournament from Delta keys.';

SET @CodeObjectHeader = 
'@ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT,
  @ChangeDetected BIT OUTPUT';

SET @CodeObjectExecutionOptions =
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'{<StageTaskStatement_Header>}
  {<StageTaskStatement_IterationsHeader>}
    -------------------------------------------------------------------------------------------------
    -- PROCESS TO TABLES
    -------------------------------------------------------------------------------------------------
    SET @InsertCount = 0;
    SET @TargetObject = ''#Stage_{StreamVariant}_{Stream}'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process INSERT to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;

    BEGIN TRY
      SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
      INSERT INTO #Stage_{StreamVariant}_{Stream} (
        -- PROCESS --
        [CaptureLogID],
        [SourcePayloadID],
        [ModifiedDate],
        [SourceSystemID],
        [OriginSystemID],
        -- KEYS --
        [TournamentID],
        [HubTournamentID],
        -- ATTRIBUTES --
        -- Relationships --
        [ProductID],
        [GameName],
        [RegionName],
        [OperatorName],
        [StatusName],
        [TournamentTemplateName],
        [TournamentTemplateDescription],
        [TournamentGroupName],
        [CurrencyCode],
        -- Dates --
        [StartUTCDateTime],
        [EndUTCDateTime],
        -- Others --
        [MinNumberOfPlayers],
        [MaxNumberOfPlayers],
        [CoinValue],
        [IsNetwork]
      ) SELECT -- PROCESS --
               @ProcessLogID,
               [TournamentCreateID],
               COALESCE([InsertedDateTime], @NowTime),
               @SourceSystemID,
               @OriginSystemID,
               -- KEYS --
               ISNULL([TournamentID], -1),
               ISNULL([Surge].[HubTournamentHash] (@OriginSystemID, [TournamentID]),@DefaultHubID) AS [HubTournamentID],
               -- ATTRIBUTES --
               -- Relationships --
               ISNULL([ProductID], -1),
               ISNULL([GameName], ''Unknown''),
               ISNULL([Region], ''Unknown''),
               ISNULL(UPPER([Operator]), ''Unknown''),
               ISNULL([TournamentStatus], ''Unknown''),
               ISNULL([TournamentTemplateName], ''Unknown''),
               ISNULL([TournamentTemplateDescription], ''Unknown''),
               ISNULL(CAST([SurgeTournamentID] AS VARCHAR), ''Unknown''),
               ISNULL([CurrencyISOCode], ''UNK''),
               -- Dates --
               ISNULL([TournamentStartUTCDateTime], CAST(''1900-01-01'' AS DATETIME2)),
               ISNULL([TournamentEndUTCDateTime], CAST(''9999-12-31 23:59:59'' AS DATETIME2)),
               -- Others --
               ISNULL([MinNumberOfPlayers], 0),
               ISNULL([MaxNumberOfPlayers], 0),
               ISNULL([CoinValue], 0),
               ISNULL([IsNetwork], 0)
          FROM #ExtractDelta_{StreamVariant}_{Stream} [CT]
         INNER JOIN [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}] [STBL]
            ON [CT].[PayloadID] = [STBL].[TournamentCreateID]
           AND [CT].[PayloadID] BETWEEN @MinDeltaID AND @MaxDeltaID
         WHERE [CT].[DeltaID] >= @ProcessBatchBeginID AND [CT].[DeltaID] < @ProcessBatchEndID;
      SET @InsertCount = @@ROWCOUNT;    
      SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                            @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                            @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID,
                                                                            @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount;
    END TRY
    BEGIN CATCH
      SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
      THROW; -- Process caller will attend to ROLLBACK and logging
    END CATCH;
    {<StageTaskStatement_IterationsFooter>}
  {<StageTaskStatement_UpdateHeld>}
  {<StageTaskStatement_Footer>}';

EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- Load_Tournament
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Tournament',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Load_Tournament',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Hector Prakke',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Stage Surge Tournament from Delta keys.';

SET @CodeObjectHeader = 
'@ProcessID INT,
  @ProcessLogID BIGINT,
  @ProcessLogCreatedMonth TINYINT,
  @TaskID SMALLINT OUTPUT,
  @ProcessTaskLogID BIGINT OUTPUT,
  @ChangeDetected BIT OUTPUT';

SET @CodeObjectExecutionOptions =
'SET NOCOUNT ON;
  SET XACT_ABORT ON;';

SET @CodeObject = 
'{<LoadTaskStatement_Header>}
  {<LoadTaskStatement_IterationsHeader>}
    -------------------------------------------------------------------------------------------------
    -- PROCESS TO TABLES
    -------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------
    -- DEPENDENT INSERTS
    ----------------------------------------------------------------
    ----------------------------------
    -- GAME
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Game'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO [dbo].[Game] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [GameName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[GameName]
         FROM #Stage_Surge_Tournament PLD
         LEFT JOIN [dbo].[Game] GM
           ON PLD.[GameName] = GM.[GameName]
         WHERE GM.[GameID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[GameName];
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------
    -- REGION
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Region'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO [dbo].[Region] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [RegionName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[RegionName]
         FROM #Stage_Surge_Tournament PLD
         LEFT JOIN [dbo].[Region] RG
           ON PLD.[RegionName] = RG.[RegionName]
         WHERE RG.[RegionID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[RegionName];
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------
    -- OPERATOR
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Operator'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO [dbo].[Operator] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [OperatorName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[OperatorName]
         FROM #Stage_Surge_Tournament PLD
         LEFT JOIN [dbo].[Operator] OP
           ON PLD.[OperatorName] = OP.[OperatorName]
         WHERE OP.[OperatorID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[OperatorName];
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------
    -- STATUS
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Status'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO [dbo].[Status] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [StatusName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[StatusName]
         FROM #Stage_Surge_Tournament PLD
         LEFT JOIN [dbo].[Status] ST
           ON PLD.[StatusName] = ST.[StatusName]
         WHERE ST.[StatusID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[StatusName];
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------
    -- TOURNAMENT TEMPLATE
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TournamentTemplate'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      ;WITH CTE AS (
       SELECT PLD.[CaptureLogID],
              PLD.[ModifiedDate],
              PLD.[TournamentTemplateName],
              PLD.[TournamentTemplateDescription],
              ROW_NUMBER() OVER (PARTITION BY PLD.[TournamentTemplateName] ORDER BY PLD.[CaptureLogID] DESC, PLD.[ModifiedDate] DESC, PLD.[TournamentTemplateDescription] DESC) AS [RowNo]
         FROM #Stage_Surge_Tournament PLD
        WHERE PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
      )
	  MERGE [dbo].[TournamentTemplate] AS Tgt
      USING (SELECT [CaptureLogID],
                    [ModifiedDate],
                    [TournamentTemplateName] AS [TournamentTemplateName],
                    [TournamentTemplateDescription] AS [TournamentTemplateDescription]
               FROM CTE WHERE [RowNo] = 1) AS Src
        ON Tgt.[TournamentTemplateName] = Src.[TournamentTemplateName]
      WHEN MATCHED AND EXISTS (
            SELECT Src.TournamentTemplateDescription
            EXCEPT
            SELECT Tgt.TournamentTemplateDescription
      ) AND (Src.ModifiedDate >= Tgt.ModifiedDate OR tgt.TournamentTemplateDescription = ''Unknown'') 
        THEN
        UPDATE SET
            Tgt.CaptureLogID = Src.CaptureLogID,
            Tgt.Operation = ''U'',
            Tgt.ModifiedDate = Src.ModifiedDate,
            Tgt.TournamentTemplateDescription = Src.TournamentTemplateDescription
      WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            TournamentTemplateName,
            CaptureLogID,
            Operation,
            ModifiedDate,
            TournamentTemplateDescription
        )
        VALUES (
            Src.TournamentTemplateName,
            Src.CaptureLogID,
            ''I'',
            Src.ModifiedDate,
            Src.TournamentTemplateDescription
        );
      SET @MergeCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------
    -- TOURNAMENT GROUP
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TournamentGroup'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO [dbo].[TournamentGroup] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [TournamentGroupName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[TournamentGroupName]
         FROM #Stage_Surge_Tournament PLD
         LEFT JOIN [dbo].[TournamentGroup] TG
           ON PLD.[TournamentGroupName] = TG.[TournamentGroupName]
         WHERE TG.[TournamentGroupID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[TournamentGroupName];
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------------------------------------
    -- KEYS
    ----------------------------------------------------------------
    ----------------------------------
    -- HUB Tournament
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.HubTournament'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      INSERT INTO dbo.HubTournament (
        HubTournamentID,
        SourceSystemID,
        CreatedDate,
        OriginSystemID,
        CaptureLogID,
		TournamentID
      ) SELECT DISTINCT PLD.HubTournamentID,
                        PLD.SourceSystemID,
                        PLD.ModifiedDate,
                        PLD.OriginSystemID,
                        PLD.CaptureLogID,
                        PLD.TournamentID
        FROM #Stage_Surge_Tournament PLD
        LEFT JOIN dbo.HubTournament Hub
          ON PLD.HubTournamentID = Hub.HubTournamentID
         AND PLD.SourceSystemID = Hub.SourceSystemID
        WHERE Hub.HubTournamentID IS NULL
         AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID;
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    ----------------------------------------------------------------
    -- MERGE CHANGES
    ----------------------------------------------------------------
    ----------------------------------
    -- Tournament
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Tournament'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process to tables: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      MERGE dbo.Tournament AS Tgt
      USING (SELECT PLD.HubTournamentID,
                    PLD.SourceSystemID,
                    PLD.OriginSystemID,
                    PLD.CaptureLogID,
                    PLD.ModifiedDate,
                    PLD.ProductID,
                    ISNULL(GM.GameID, -1) AS [GameID],
                    ISNULL(RG.RegionID, -1) AS [RegionID],
                    ISNULL(OP.OperatorID, -1) AS [OperatorID],
                    ISNULL(ST.StatusID, -1) AS [StatusID],
                    ISNULL(TT.TournamentTemplateID, -1) AS [TournamentTemplateID],
                    ISNULL(TG.TournamentGroupID, -1) AS [TournamentGroupID],
                    PLD.CurrencyCode,
                    StartUTCDateTime,
                    CAST(StartUTCDateTime AS DATE) AS [StartUTCDate],
                    EndUTCDateTime,
                    CAST(EndUTCDateTime AS DATE) AS [EndUTCDate],
                    MinNumberOfPlayers,
                    MaxNumberOfPlayers,
                    CoinValue,
                    IsNetwork
               FROM #Stage_Surge_Tournament PLD
               LEFT JOIN [dbo].[Game] GM WITH (NOLOCK)
                 ON PLD.[GameName] = GM.[GameName]
               LEFT JOIN [dbo].[Region] RG WITH (NOLOCK)
                 ON PLD.[RegionName] = RG.[RegionName]
               LEFT JOIN [dbo].[Operator] OP WITH (NOLOCK)
                 ON PLD.[OperatorName] = OP.[OperatorName]
               LEFT JOIN [dbo].[Status] ST WITH (NOLOCK)
                 ON PLD.[StatusName] = ST.[StatusName]
               LEFT JOIN [dbo].[TournamentTemplate] TT WITH (NOLOCK)
                 ON PLD.[TournamentTemplateName] = TT.[TournamentTemplateName]
               LEFT JOIN [dbo].[TournamentGroup] TG WITH (NOLOCK)
                 ON PLD.[TournamentGroupName] = TG.[TournamentGroupName]
              WHERE PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
            )AS Src
        ON Tgt.HubTournamentID = Src.HubTournamentID
       AND Tgt.SourceSystemID = Src.SourceSystemID
      WHEN MATCHED AND Src.ModifiedDate >= Tgt.ModifiedDate
        THEN
        UPDATE SET
            Tgt.CaptureLogID = Src.CaptureLogID,
            Tgt.Operation = ''U'',
            Tgt.ModifiedDate = Src.ModifiedDate,
            Tgt.ProductID = Src.ProductID,
            Tgt.GameID = Src.GameID,
            Tgt.RegionID = Src.RegionID,
            Tgt.OperatorID = Src.OperatorID,
            Tgt.StatusID = Src.StatusID,
            Tgt.TournamentTemplateID = Src.TournamentTemplateID,
            Tgt.TournamentGroupID = Src.TournamentGroupID,
            Tgt.CurrencyCode = Src.CurrencyCode,
            Tgt.StartUTCDateTime = Src.StartUTCDateTime,
            Tgt.StartUTCDate = Src.StartUTCDate,
            Tgt.EndUTCDateTime = Src.EndUTCDateTime,
            Tgt.EndUTCDate = Src.EndUTCDate,
            Tgt.MinNumberOfPlayers = Src.MinNumberOfPlayers,
            Tgt.MaxNumberOfPlayers = Src.MaxNumberOfPlayers,
            Tgt.CoinValue = Src.CoinValue,
            Tgt.IsNetwork = Src.IsNetwork
      WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            HubTournamentID,
            SourceSystemID,
            OriginSystemID,
            CaptureLogID,
            Operation,
            ModifiedDate,
            ProductID,
            GameID,
            RegionID,
            OperatorID,
            StatusID,
            TournamentTemplateID,
            TournamentGroupID,
            CurrencyCode,
            StartUTCDateTime,
            StartUTCDate,
            EndUTCDateTime,
            EndUTCDate,
            MinNumberOfPlayers,
            MaxNumberOfPlayers,
            CoinValue,
            IsNetwork
        )
        VALUES (
            Src.HubTournamentID,
            Src.SourceSystemID,
            Src.OriginSystemID,
            Src.CaptureLogID,
            ''I'',
            Src.ModifiedDate,
            Src.ProductID,
            Src.GameID,
            Src.RegionID,
            Src.OperatorID,
            Src.StatusID,
            Src.TournamentTemplateID,
            Src.TournamentGroupID,
            Src.CurrencyCode,
            Src.StartUTCDateTime,
            Src.StartUTCDate,
            Src.EndUTCDateTime,
            Src.EndUTCDate,
            Src.MinNumberOfPlayers,
            Src.MaxNumberOfPlayers,
            Src.CoinValue,
            Src.IsNetwork
        );
      SET @MergeCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    {<LoadTaskStatement_IterationsFooter>}
  {<LoadTaskStatement_Footer>}';

EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
------------------
-- Process_Tournament
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Tournament',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Process_Tournament',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Hector Prakke',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'@CE_MinID : Minimum ID value from source payload table for start of ChangeExtract
 @BE_MinID : Minimum ID value from source payload table for start of BulkExtract range
 @BE_MaxID : Maximum ID value from source payload table for end of BulkExtract range
 @ManualKeys : A set of manual keys provided by user
 BulkExtract when specified by range will collect from existing source payload data for replay to source structured
 No parameters will result in standard CDO collection from source payload to source structured';

SET @CodeObjectHeader = 
'@CE_MinID BIGINT = NULL,
  @BE_MinID BIGINT = NULL,
  @BE_MaxID BIGINT = NULL,
  @ManualKeys [DataFlow].[PayloadID] READONLY';

SET @CodeObjectExecutionOptions =
'SET NOCOUNT ON;';

SET @CodeObject = 
'{<ProcessStatement_Header>}
  -------------------------------------------------------------------------------------------------
  -- PROCESS
  -------------------------------------------------------------------------------------------------
  ------------------------
  -- TEMP. TABLES -- 
  ------------------------
  {<ProcessStatement_ExtractDelta>}
  IF OBJECT_ID(''TempDB..#Stage_{StreamVariant}_{Stream}'') IS NOT NULL 
    DROP TABLE #Stage_{StreamVariant}_{Stream};
  CREATE TABLE #Stage_{StreamVariant}_{Stream}(
    [StageID] INT IDENTITY(1,1) NOT NULL,
    INDEX [IDX1_Stage_{StreamVariant}_{Stream}] NONCLUSTERED ([StageID] ASC) WITH (FILLFACTOR = 100),
    -- PROCESS --
    [CaptureLogID] BIGINT NOT NULL,
    [SourcePayloadID] BIGINT NOT NULL,
    [ModifiedDate] DATETIME2 NOT NULL,
    [SourceSystemID] INT NOT NULL,
    [OriginSystemID] INT NOT NULL,
    INDEX [IDX2_Stage_{StreamVariant}_{Stream}] NONCLUSTERED ([ModifiedDate] ASC, [SourcePayloadID] ASC) WITH (FILLFACTOR = 100),
    -- KEYS --
	[TournamentID] [INT] NOT NULL,
    [HubTournamentID] BINARY(32) NOT NULL,
    INDEX [CIDX_Stage_{StreamVariant}_{Stream}] CLUSTERED (HubTournamentID ASC, [SourceSystemID] ASC) WITH (FILLFACTOR = 100),
    -- ATTRIBUTES --
    -- Relationships --
    [ProductID] [INT] NOT NULL,
    [GameName] [VARCHAR](150) NOT NULL,
    [RegionName] [VARCHAR](50) NOT NULL,
    [OperatorName][VARCHAR](50) NOT NULL,
    [StatusName] [VARCHAR](50) NOT NULL,
    [TournamentTemplateName] [VARCHAR](255) NOT NULL,
    [TournamentTemplateDescription] [VARCHAR](255) NOT NULL,
    [TournamentGroupName] [VARCHAR](20) NOT NULL,
    [CurrencyCode] [CHAR](3) NOT NULL,
    -- Dates --
    [StartUTCDateTime] [DATETIME2] NOT NULL,
    [EndUTCDateTime] [DATETIME2] NOT NULL,
    -- Others --
    [MinNumberOfPlayers] [INT] NOT NULL,
    [MaxNumberOfPlayers] [INT] NOT NULL,
    [CoinValue] [INT] NOT NULL,
    [IsNetwork] [BIT] NOT NULL,
    [RowNo] [INT] NULL
  );
  {<ProcessStatement_CallExtract>}
  {<ProcessStatement_CallStage>}
  {<ProcessStatement_CallLoad>}
  {<ProcessStatement_Footer>}';

EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- Config
-------------------------------------
------------------
-- Process
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Tournament',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Setup',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Script',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Hector Prakke',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Setup Process, Task, Config and Service Broker Routes.';

SET @CodeObject = 
'DECLARE @ProcessID SMALLINT;
DECLARE @TaskID SMALLINT;
DECLARE @ProcessTaskID INT;
DECLARE @ExtractTypeID SMALLINT;
DECLARE @ExtractSourceID INT;
DECLARE @TopicName VARCHAR(50) = ''{Stream}'';
DECLARE @ProcessNamePart VARCHAR(100) = ''{ProcessNamePart}'';
DECLARE @ProcessDescription VARCHAR(250) = ''Process payload data for {Stream} from {StreamVariant}'';
DECLARE @ProcessName VARCHAR(150) = @TopicName + ''|'' + @ProcessNamePart;


/***********************************************************************************************************************************
-- Process --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = @ProcessName) BEGIN;
  INSERT INTO [Config].[Process] ([ProcessName], [ProcessDescription], [IsEnabled]) VALUES(@ProcessName, @ProcessDescription, 1);
END;
  SET @ProcessID = [Config].[GetProcessIDByName](@ProcessName);

/***********************************************************************************************************************************
-- Process Task --
***********************************************************************************************************************************/
-- SELECT * FROM [Config].[Task];
SET @TaskID = [Config].[GetTaskIDByName] (''Extract'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
SET @TaskID = [Config].[GetTaskIDByName] (''StageData'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
SET @TaskID = [Config].[GetTaskIDByName] (''LoadData'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTask] WHERE [ProcessID] = @ProcessID AND [TaskID] = @TaskID) BEGIN;
  INSERT INTO [Config].[ProcessTask] ([ProcessID], [TaskID], [IsEnabled]) VALUES(@ProcessID, @TaskID, 1);
END;
/***********************************************************************************************************************************
-- Extract Source --
***********************************************************************************************************************************/
-- SELECT * FROM [Config].[ExtractType]
SET @ExtractTypeID = (SELECT [ExtractTypeID] FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = ''CDO'');
IF NOT EXISTS (SELECT * FROM [Config].[ExtractSource] 
                WHERE [ExtractTypeID] = @ExtractTypeID 
                  AND [ExtractDatabase] = ''[{ExtractDatabase}]'' 
                  AND [ExtractObject] = ''{ExtractSchema}.{ExtractTableName}'' 
                  AND [TrackedColumn] = ''{CDOTrackedColumn}'') BEGIN;
  INSERT INTO [Config].[ExtractSource] ([ExtractTypeID], [ExtractDatabase], [ExtractObject], [TrackedColumn]) 
    VALUES(@ExtractTypeID, ''[{ExtractDatabase}]'', ''{ExtractSchema}.{ExtractTableName}'' , ''{CDOTrackedColumn}'');
END;
SET @ExtractTypeID = (SELECT [ExtractTypeID] FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = ''BUL'');
IF NOT EXISTS (SELECT * FROM [Config].[ExtractSource] 
                WHERE [ExtractTypeID] = @ExtractTypeID 
                  AND [ExtractDatabase] = ''[{ExtractDatabase}]'' 
                  AND [ExtractObject] = ''{ExtractSchema}.{ExtractTableName}'' 
                  AND [TrackedColumn] = ''{CDOTrackedColumn}'') BEGIN;
  INSERT INTO [Config].[ExtractSource] ([ExtractTypeID], [ExtractDatabase], [ExtractObject], [TrackedColumn]) 
    VALUES(@ExtractTypeID, ''[{ExtractDatabase}]'', ''{ExtractSchema}.{ExtractTableName}'' , ''{CDOTrackedColumn}'');
END;
/***********************************************************************************************************************************
-- Task Extract Source --
***********************************************************************************************************************************/
SET @ExtractTypeID = (SELECT [ExtractTypeID] FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = ''CDO'');
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''Extract'');
SET @ExtractSourceID = (SELECT [ExtractSourceID] FROM [Config].[ExtractSource] 
                         WHERE [ExtractTypeID] = @ExtractTypeID 
                           AND [ExtractDatabase] = ''[{ExtractDatabase}]'' 
                           AND [ExtractObject] = ''{ExtractSchema}.{ExtractTableName}'' 
                           AND [TrackedColumn] = ''{CDOTrackedColumn}'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTaskExtractSource] WHERE [ProcessTaskID] = @ProcessTaskID AND [ExtractSourceID] = @ExtractSourceID) BEGIN;
  INSERT INTO [Config].[ProcessTaskExtractSource] ( [ProcessTaskID], [ExtractSourceID]) VALUES(@ProcessTaskID, @ExtractSourceID);
END;

SET @ExtractTypeID = (SELECT [ExtractTypeID] FROM [Config].[ExtractType] WHERE [ExtractTypeCode] = ''BUL'');
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''Extract'');
SET @ExtractSourceID = (SELECT [ExtractSourceID] FROM [Config].[ExtractSource] 
                         WHERE [ExtractTypeID] = @ExtractTypeID 
                           AND [ExtractDatabase] = ''[{ExtractDatabase}]'' 
                           AND [ExtractObject] = ''{ExtractSchema}.{ExtractTableName}'' 
                           AND [TrackedColumn] = ''{CDOTrackedColumn}'');
IF NOT EXISTS (SELECT * FROM [Config].[ProcessTaskExtractSource] WHERE [ProcessTaskID] = @ProcessTaskID AND [ExtractSourceID] = @ExtractSourceID) BEGIN;
  INSERT INTO [Config].[ProcessTaskExtractSource] ( [ProcessTaskID], [ExtractSourceID]) VALUES(@ProcessTaskID, @ExtractSourceID);
END;
/***********************************************************************************************************************************
-- Task Config --
***********************************************************************************************************************************/
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''Extract'');
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''InfoDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''CaptureDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''StageData'');
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''InfoDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''CaptureDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Held'',
                                          @ConfigName = ''Disabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Held'',
                                          @ConfigName = ''Ignore'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Stage'',
                                          @ConfigName = ''BatchSize'',
                                          @ConfigValue = 250000,
                                          @Delete = 0;
SET @ProcessTaskID = [Config].[GetProcessTaskByName] (@ProcessID, ''LoadData'');
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''InfoDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Logging'',
                                          @ConfigName = ''CaptureDisabled'',
                                          @ConfigValue = 0,
                                          @Delete = 0;
EXEC [Config].[SetVariable_ProcessTask]   @SelectOutput = 0, @ProcessTaskID = @ProcessTaskID,
                                          @ConfigGroupName = ''Load'',
                                          @ConfigName = ''BatchSize'',
                                          @ConfigValue = 250000,
                                          @Delete = 0;

/***********************************************************************************************************************************
-- AppLock Config --
***********************************************************************************************************************************/
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Game'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Game'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Region'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Region'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.HubTournament'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.HubTournament'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Tournament'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Tournament'',
                                    @ConfigValue = 1000;

/***********************************************************************************************************************************
-- Service Broker Route --
***********************************************************************************************************************************/
-- NONE';

EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO
-------------------------------------
-- Calls
-------------------------------------
------------------
-- GetDeployment
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Tournament',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'GetDeployment',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Call',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Hector Prakke',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Generic call to GetDeployment which will generate deployment scripts.';

SET @CodeObject = 
'BEGIN TRY;
  -- Validate tags --
  DECLARE @StreamTag VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = ''{Stream}'');
  IF @StreamTag IS NULL
    THROW 50000, ''{Stream} Tag and Value must be provided. Terminating Procedure.'', 1;
  DECLARE @StreamVariantTag VARCHAR(50) = (SELECT TOP (1) [Value] FROM @ReplacementTags WHERE [Tag] = ''{StreamVariant}'');
  IF @StreamVariantTag IS NULL
    THROW 50000, ''{StreamVariant} Tag and Value must be provided. Terminating Procedure.'', 1;

    -- List of CodeObjects --
    DECLARE @GenerateList [CodeHouse].[GenerateCodeObjectList];
    INSERT INTO @GenerateList (
      [Ordinal],
      [Stream],
      [StreamVariant],
      [ObjectType],
      [CodeType],
      [CodeObjectName],
	  [ObjectLayer]
    ) VALUES (1,  ''Tournament'', ''Surge'', ''Function'',  ''Process'', ''HubTournamentHash'', @Layer),
	         (2,  ''Any'', ''Any'', ''Table'',     ''Process'', ''{Stream}_Held'', @Layer),
             (3,  ''Any'', ''Any'', ''View'',     ''Process'', ''v{Stream}_HeldSummary'', @Layer),
             (4,  ''Any'', ''Surge'', ''Procedure'', ''Task'', ''Extract_{Stream}'', @Layer),
             (5,  ''Tournament'', ''Surge'', ''Procedure'', ''Task'', ''Stage_Tournament'', @Layer),
             (6, ''Tournament'', ''Surge'', ''Procedure'', ''Task'', ''Load_Tournament'', @Layer),
             (7, ''Tournament'', ''Surge'', ''Procedure'', ''Process'', ''Process_Tournament'', @Layer),
             (8, ''Tournament'', ''Surge'', ''Script'',    ''Process'', ''Setup'', @Layer),
             (9, ''Any'', ''Any'', ''Script'',    ''Job'', ''Setup_LoopJob'', ''Any'');
    
    -- Components to use --
    DECLARE @ReplacementComponents [CodeHouse].[ReplacementComponent];
    -- Create/output deployment --
    EXEC [CodeHouse].[GenerateDeployment] @DeploymentName = @DeploymentName,
                                          @DeploymentNotes = @DeploymentNotes,
                                          @DeploymentSet = @DeploymentSet OUTPUT,
                                          @Layer = @Layer,
                                          @ReturnDropScript = @ReturnDropScript,
                                          @ReturnObjectScript = @ReturnObjectScript,
                                          @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript,
                                          @GenerateList = @GenerateList,
                                          @ReplacementTags = @ReplacementTags,
                                          @ReplacementComponents = @ReplacementComponents,
                                          @OnlyObjectTypes = @OnlyObjectTypes;
END TRY
BEGIN CATCH
  THROW
END CATCH;';

EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

/* End of File ********************************************************************************************************************/