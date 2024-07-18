/************************************************************************
* Script     : 13.Adjustment - Staging.sql
* Created By : Cedric Dube
* Created On : 2021-09-16
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps(Pre) : 1 > Functions
*            :   1.1 > HubAdjustmentHash
* Steps(post): 2 > Procedures
*            :     3.1 > Extract_Adjustment (handled by Common, no need to specify here)
*            :     3.2 > Stage_Adjustment
*            :     3.3 > Load_Adjustment
*            :     3.4 > Process_Adjustment
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
-- HubAdjustmentHash
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Adjustment',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'HubAdjustmentHash',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Function',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Cedric Dube',
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
'@BalanceUpdateID BIGINT,
 @TransactionNumber BIGINT';

SET @CodeObjectExecutionOptions =
'RETURNS BINARY(32) 
  WITH SCHEMABINDING';

SET @CodeObject = 
'BEGIN;
  DECLARE @HashKey BINARY(32);
  SET @HashKey = CAST(HASHBYTES(''SHA2_256'',
                                       TRY_CAST(@BalanceUpdateID AS VARCHAR)
                                       +''-''+
                                       TRY_CAST(@TransactionNumber AS VARCHAR)									   
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
-- Stage_Adjustment
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Adjustment',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Stage_Adjustment',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Stage Surge Adjustment from Delta keys.';

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
        [BalanceUpdateID],
		[TransactionNumber],
        [HubAdjustmentID],
        -- ATTRIBUTES --
        -- Relationships --
        [UserID],
		[GamingSystemID],
        [HubPlayerID],
		[AdminEventTypeName],
		[AdminEventName],
		[ModuleID],
		[BalanceTypeName],
		[TransactionUTCDateTime],
		[PlayerCurrencyCode],
		[OperatorCurrencyCode],
		[PlayerToOperatorCurrencyExchangeRate],
        [BalanceAfterLastPositiveChange],
		[CashBalanceAfter],
		[BonusBalanceAfter],
		[CurrencyValue],
		[IsBonusEvent]
      ) SELECT -- PROCESS --
               @ProcessLogID,
               [BalanceUpdateID],
               COALESCE([UtcEventTime],[eventTime],[InsertedDateTime], @NowTime),
               @SourceSystemID,
               @OriginSystemID,
               -- KEYS --
               ISNULL([BalanceUpdateID],-1),
               ISNULL([AdminEventTransactionNumber],-1),
               ISNULL([Surge].[HubAdjustmentHash] ([BalanceUpdateID], [AdminEventTransactionNumber]),@DefaultHubID) AS [HubAdjustmentID],
               -- ATTRIBUTES --
               -- Relationships --
			   ISNULL([UserID], -1),
			   ISNULL([GamingSystemID], -1),
			   ISNULL([Surge].[HubPlayerHash] ([GamingSystemID], [UserID]),@DefaultHubID) AS [HubPlayerID],
			   LEFT(ISNULL([AdminEventType], ''Unknown''), 50),
			   LEFT(ISNULL([AdminEvent], ''Unknown''), 50),
			   ISNULL([ModuleID], -1),
			   LEFT(ISNULL([BalanceType], ''Unknown''), 50),
			   COALESCE(TRY_CAST([UTCEventTime] AS DATETIME2), TRY_CAST([EventTime] AS DATETIME2), ''1900-01-01''),
			   LEFT(ISNULL([CurrencyIsoCode], ''---''), 3),
			   LEFT(ISNULL([OperatorCurrencyIsoCode], ''---''), 3),
			   ISNULL([PlayerToOperatorExchangeRate], 0),
               ISNULL([BalanceAfterLastPositiveChange], 0),
			   ISNULL([CashBalanceAfterEvent], 0),
			   ISNULL([BonusBalanceAfterEvent], 0),
			   ISNULL([ChangeAmount], 0),
			   [IsBonusEvent]
          FROM #ExtractDelta_{StreamVariant}_{Stream} [CT]
         INNER JOIN [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}] [STBL]
            ON [CT].[PayloadID] = [STBL].[BalanceUpdateID]
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
-- Load_Adjustment
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Adjustment',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Load_Adjustment',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Task',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Stage Surge Adjustment from Delta keys.';

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
    -- AdminEventType
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.AdminEventType'';
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
      INSERT INTO [dbo].[AdminEventType] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [AdminEventTypeName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[AdminEventTypeName]
         FROM #Stage_Surge_Adjustment PLD
         LEFT JOIN [dbo].[AdminEventType] AET
           ON PLD.[AdminEventTypeName] = AET.[AdminEventTypeName]
         WHERE AET.[AdminEventTypeID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[AdminEventTypeName];
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
    -- AdminEvent
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.AdminEvent'';
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
      INSERT INTO [dbo].[AdminEvent] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [AdminEventName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[AdminEventName]
         FROM #Stage_Surge_Adjustment PLD
         LEFT JOIN [dbo].[AdminEvent] AE
           ON PLD.[AdminEventName] = AE.[AdminEventName]
         WHERE AE.[AdminEventID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[AdminEventName];
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
    -- BalanceType
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.BalanceType'';
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
      INSERT INTO [dbo].[BalanceType] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [BalanceTypeName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[BalanceTypeName]
         FROM #Stage_Surge_Adjustment PLD
         LEFT JOIN [dbo].[BalanceType] BT
           ON PLD.[BalanceTypeName] = BT.[BalanceTypeName]
         WHERE BT.[BalanceTypeID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[BalanceTypeName];
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
    {<LoadTaskStatement_InsertReference_HubPlayer>}
    {<LoadTaskStatement_InsertReference_Player>}
    ----------------------------------------------------------------
    -- KEYS
    ----------------------------------------------------------------
    ----------------------------------
    -- HUB Adjustment
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.HubAdjustment'';
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
      INSERT INTO dbo.HubAdjustment (
        HubAdjustmentID,
        SourceSystemID,
        CreatedDate,
        OriginSystemID,
        CaptureLogID,
		BalanceUpdateID,
		TransactionNumber
      ) SELECT DISTINCT PLD.HubAdjustmentID,
                        PLD.SourceSystemID,
                        PLD.ModifiedDate,
                        PLD.OriginSystemID,
                        PLD.CaptureLogID,
                        PLD.BalanceUpdateID,
                        PLD.TransactionNumber
        FROM #Stage_Surge_Adjustment PLD
        LEFT JOIN dbo.HubAdjustment Hub
          ON PLD.HubAdjustmentID = Hub.HubAdjustmentID
         AND PLD.SourceSystemID = Hub.SourceSystemID
        WHERE Hub.HubAdjustmentID IS NULL
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
    -- Adjustment
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Adjustment'';
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
      MERGE dbo.Adjustment AS Tgt
      USING (SELECT PLD.HubAdjustmentID,
                    PLD.SourceSystemID,
                    PLD.OriginSystemID,
                    PLD.CaptureLogID,
                    PLD.ModifiedDate,
                    PLD.HubPlayerID,
                    ISNULL(AET.AdminEventTypeID, -1) AS [AdminEventTypeID],
					ISNULL(AE.AdminEventID, -1) AS [AdminEventID],
					PLD.ModuleID,
					ISNULL(BT.BalanceTypeID, -1) AS [BalanceTypeID],
                    CAST(PLD.TransactionUTCDateTime AS DATE) AS [TransactionUTCDate],
                    PLD.TransactionUTCDateTime,
                    PLD.PlayerCurrencyCode,
                    PLD.OperatorCurrencyCode,
					PLD.PlayerToOperatorCurrencyExchangeRate,
                    PLD.BalanceAfterLastPositiveChange,
                    PLD.CashBalanceAfter,
                    PLD.BonusBalanceAfter,
                    PLD.CurrencyValue,
                    PLD.IsBonusEvent
               FROM #Stage_Surge_Adjustment PLD
               LEFT JOIN [dbo].[AdminEventType] AET WITH (NOLOCK)
                 ON PLD.[AdminEventTypeName] = AET.[AdminEventTypeName]
			   LEFT JOIN [dbo].[AdminEvent] AE WITH (NOLOCK)
                 ON PLD.[AdminEventName] = AE.[AdminEventName]
			   LEFT JOIN [dbo].[BalanceType] BT WITH (NOLOCK)
                 ON PLD.[BalanceTypeName] = BT.[BalanceTypeName]
              WHERE PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
            )AS Src
        ON Tgt.HubAdjustmentID = Src.HubAdjustmentID
       AND Tgt.SourceSystemID = Src.SourceSystemID
      WHEN MATCHED AND Src.ModifiedDate >= Tgt.ModifiedDate
        THEN
        UPDATE SET
            Tgt.CaptureLogID = Src.CaptureLogID,
            Tgt.Operation = ''U'',
            Tgt.ModifiedDate = Src.ModifiedDate,
            Tgt.HubPlayerID = Src.HubPlayerID,
            Tgt.AdminEventTypeID = Src.AdminEventTypeID,
			Tgt.AdminEventID = Src.AdminEventID,
			Tgt.ModuleID = Src.ModuleID,
			Tgt.BalanceTypeID = Src.BalanceTypeID,
            Tgt.TransactionUTCDate = Src.TransactionUTCDate,
            Tgt.TransactionUTCDateTime = Src.TransactionUTCDateTime,
            Tgt.PlayerCurrencyCode = Src.PlayerCurrencyCode,
            Tgt.OperatorCurrencyCode = Src.OperatorCurrencyCode,
			Tgt.PlayerToOperatorCurrencyExchangeRate = Src.PlayerToOperatorCurrencyExchangeRate,
            Tgt.BalanceAfterLastPositiveChange = Src.BalanceAfterLastPositiveChange,
            Tgt.CashBalanceAfter = Src.CashBalanceAfter,
            Tgt.BonusBalanceAfter = Src.BonusBalanceAfter,
            Tgt.CurrencyValue = Src.CurrencyValue,
            Tgt.IsBonusEvent = Src.IsBonusEvent
      WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            HubAdjustmentID,
            SourceSystemID,
            OriginSystemID,
            CaptureLogID,
            Operation,
            ModifiedDate,
            HubPlayerID,
            AdminEventTypeID,
			AdminEventID,
			ModuleID,
			BalanceTypeID,
            TransactionUTCDate,
            TransactionUTCDateTime,
            PlayerCurrencyCode,
            OperatorCurrencyCode,
			PlayerToOperatorCurrencyExchangeRate,
            BalanceAfterLastPositiveChange,
            CashBalanceAfter,
            BonusBalanceAfter,
            CurrencyValue,
            IsBonusEvent
        )
        VALUES (
            Src.HubAdjustmentID,
            Src.SourceSystemID,
            Src.OriginSystemID,
            Src.CaptureLogID,
            ''I'',
            Src.ModifiedDate,
            Src.HubPlayerID,
            Src.AdminEventTypeID,
			Src.AdminEventID,
			Src.ModuleID,
		    Src.BalanceTypeID,
            Src.TransactionUTCDate,
            Src.TransactionUTCDateTime,
            Src.PlayerCurrencyCode,
            Src.OperatorCurrencyCode,
			Src.PlayerToOperatorCurrencyExchangeRate,
            Src.BalanceAfterLastPositiveChange,
            Src.CashBalanceAfter,
            Src.BonusBalanceAfter,
            Src.CurrencyValue,
            Src.IsBonusEvent
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
-- Process_Adjustment
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'Adjustment',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Process_Adjustment',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Procedure',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Cedric Dube',
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
	[BalanceUpdateID] BIGINT NOT NULL,
	[TransactionNumber] BIGINT NOT NULL,
    [HubAdjustmentID] BINARY(32) NOT NULL,
    INDEX [CIDX_Stage_{StreamVariant}_{Stream}] CLUSTERED (HubAdjustmentID ASC, [SourceSystemID] ASC) WITH (FILLFACTOR = 100),
    -- ATTRIBUTES --
    -- Relationships --
	[UserID] [INT] NOT NULL,
	[GamingSystemID] [INT] NOT NULL,
    [HubPlayerID] [BINARY](32) NOT NULL,
	[AdminEventTypeName] VARCHAR(50) NOT NULL,
	[AdminEventName] VARCHAR(50) NOT NULL,
	[ModuleID] [INT] NOT NULL,
	[BalanceTypeName] VARCHAR(50) NOT NULL,
	[PlayerCurrencyCode] [CHAR](3) NOT NULL,
	[OperatorCurrencyCode] [CHAR](3) NOT NULL,
    -- Dates --
	[TransactionUTCDateTime] [DATETIME2](7) NOT NULL,
    -- Others --
	[PlayerToOperatorCurrencyExchangeRate] [DECIMAL](20, 5) NOT NULL,
	[BalanceAfterLastPositiveChange] [DECIMAL](19, 4) NOT NULL,
	[CashBalanceAfter] [DECIMAL](19, 4) NOT NULL,
	[BonusBalanceAfter] [DECIMAL](19, 4) NOT NULL,
	[CurrencyValue] [DECIMAL](19, 4) NOT NULL,
	[IsBonusEvent] [BIT] NOT NULL,
    [RowNo] INT NULL
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
        @Stream VARCHAR(50) = 'Adjustment',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Setup',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Script',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Cedric Dube',
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
                                    @ObjectName = ''dbo.HubPlayer'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.HubPlayer'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Player'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Player'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.AdminEventType'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.AdminEventType'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.AdminEvent'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.AdminEvent'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Module'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Module'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.BalanceType'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.BalanceType'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.HubAdjustment'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.HubAdjustment'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Adjustment'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Adjustment'',
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
        @Stream VARCHAR(50) = 'Adjustment',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'GetDeployment',
        @VersionType CHAR(5) = 'Major',
		@ObjectType VARCHAR(50) = 'Call',
		@CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Cedric Dube',
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
    ) VALUES (1,  ''Adjustment'', ''Surge'', ''Function'',  ''Process'', ''HubAdjustmentHash'', @Layer),
	         (2,  ''Any'', ''Any'', ''Table'',     ''Process'', ''{Stream}_Held'', @Layer),
             (3,  ''Any'', ''Any'', ''View'',     ''Process'', ''v{Stream}_HeldSummary'', @Layer),
             (4,  ''Any'', ''Surge'', ''Procedure'', ''Task'', ''Extract_{Stream}'', @Layer),
             (5,  ''Adjustment'', ''Surge'', ''Procedure'', ''Task'', ''Stage_Adjustment'', @Layer),
             (6, ''Adjustment'', ''Surge'', ''Procedure'', ''Task'', ''Load_Adjustment'', @Layer),
             (7, ''Adjustment'', ''Surge'', ''Procedure'', ''Process'', ''Process_Adjustment'', @Layer),
             (8, ''Adjustment'', ''Surge'', ''Script'',    ''Process'', ''Setup'', @Layer),
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