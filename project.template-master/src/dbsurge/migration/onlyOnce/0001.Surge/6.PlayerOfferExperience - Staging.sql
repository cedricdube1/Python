/************************************************************************
* Script     : PlayerOfferExperience - Staging.sql
* Created By : Cedric Dube
* Created On : 2021-09-09
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps(Pre) : 1 > Functions
*            :   > None. User Plyer Offer Hub
* Steps(post): 2 > Procedures
*            :     3.1 > Extract_PlayerOfferExperience (handled by Common, no need to specify here)
*            :     3.2 > Stage_PlayerOfferExperience
*            :     3.3 > Load_PlayerOfferExperience
*            :     3.4 > Process_PlayerOfferExperience
*            :   4 > Config
*            :     4.1 > Setup: Process
*            : 3 > Calling Scripts
*            :   3.1 > GetDeployment
************************************************************************/
USE [dbSurge]
GO
SET NOCOUNT ON;
-------------------------------------
-- Procedures
-------------------------------------
------------------
-- Stage_PlayerOfferExperience
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOfferExperience',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Stage_PlayerOfferExperience',
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
'Stage Surge PlayerOfferExperience from Delta keys.';

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
        [PromoGUID],
        [OfferGUID],
        [UserID],
        [GamingSystemID],
        [HubPlayerOfferID],
        -- ATTRIBUTES --
        -- Relationships --
        [HubPlayerID],
        [AdjustedPercentageSourceName],
        [ExcitementBandName],
        [PlayerExperience],
        [PlayerExperienceSeries],
        [PlayerGroupBehaviourName],
        [RewardTypeName],
        [TimeOnDeviceCategoryName],
        [TriggerTypeName],
        [ValueSegmentName],
        -- Dates --
		[CalculatedOnUTCDateTime],
        -- Others --
        [ABTestGroup],
        [ABTestFactor],
        [BetSizeToBankRoll],
        [BankRoll],
        [MaxBankRoll],
        [NetWin],
        [GrossWin],
        [GrossMargin],
        [NCI],
        [SubsidisedMargin],
        [ExpectedSubsidisedMargin],
        [NetMargin],
        [ExpectedNetMargin],
        [RequiredSubsidisedMargin],
        [RequiredNCI],
        [NCIShortfall],
        [NCIBump] ,
        [PlayThroughPenalty],
        [PercentageScoreCasino],
        [CouponScoreCasino],
        [WagerAmount],
        [PayoutAmount],
        [DepositAmount],
        [WagerCount],
        [AveBetSize],
        [DepositCount],
        [CouponAdjustmentFactor],
        [BreakageFactor],
        [MinCouponAdjustmentFactor],
        [AdjustedPercentageScoreCasino],
        [AdjustedCouponScoreCasino],
        [TheoIncome],
        [TheoGrossMargin],
        [TheoGrossWin],
        [TheoPlayThrough],
        [PlayThrough],
        [Hits],
        [HitRate],
        [StdDevPayoutAmount],
        [VariancePayoutAmount],
        [StdDevWagers],
        [VarianceWagers],
        [NumberOfReloads],
        [NumberOfBumpUps],
        [BinaryValue],
        [MaxBumpsReached],
        [RowVer],
        [ExperienceFactor],
        [BinSum],
        [NCI2Purchase]
      ) SELECT -- PROCESS --
               @ProcessLogID,
               [ExperienceResultID],
               COALESCE([InsertedDateTime], @NowTime),
               @SourceSystemID,
               @OriginSystemID,
               -- KEYS --
               ISNULL([PromoGUID], ''0-0-0-0-0''),
               ISNULL([OfferGUID], ''0-0-0-0-0''),
			   ISNULL([UserID],-1),
			   ISNULL([GamingSystemID],-1),
               ISNULL([Surge].[HubPlayerOfferHash] ([GamingSystemID], [OfferGUID], [PromoGUID], [UserID]),@DefaultHubID) AS [HubPlayerOfferID],
               -- ATTRIBUTES --
               -- Relationships --
			   ISNULL([Surge].[HubPlayerHash] ([GamingSystemID], [UserID]),@DefaultHubID) AS [HubPlayerID],
			   LEFT(ISNULL([AdjustedPercentageSource], ''Unknown''), 50),
			   LEFT(ISNULL([ExcitementBand], ''Unknown''), 50),
			   LEFT(ISNULL([PlayerExperience], ''Unknown''), 255),
			   LEFT(ISNULL([PlayerExperienceSeries], ''Unknown''), 255),
			   LEFT(ISNULL([PlayerGroupBehaviour], ''Unknown''), 50),
			   LEFT(ISNULL([RewardType], ''Unknown''), 50),
			   LEFT(ISNULL([TimeOnDeviceCategory], ''Unknown''), 50),
			   LEFT(ISNULL([TriggerType], ''Unknown''), 50),
			   LEFT(ISNULL([ValueSegment], ''Unknown''), 50),
			   -- Dates --
			   ISNULL(TRY_CAST([CalculatedOn] AS DATETIME2), ''1900-01-01''),
			   -- Others --
               [ABTestGroup],
               TRY_CAST([ABTestFactor] AS INT),
               ISNULL([BetSizeToBankRoll], 0 ),
               ISNULL([BankRoll], 0 ),
               ISNULL([MaxBankRoll], 0 ),
               ISNULL([NetWin], 0 ),
               ISNULL([GrossWin], 0 ),
               ISNULL([GrossMargin], 0 ),
               ISNULL([NCI], 0 ),
               ISNULL([SubsidisedMargin], 0 ),
               ISNULL([ExpectedSubsidisedMargin], 0 ),
               ISNULL([NetMargin], 0 ),
               ISNULL([ExpectedNetMargin], 0 ),
               ISNULL([RequiredSubsidisedMargin], 0 ),
               ISNULL([RequiredNCI], 0 ),
               ISNULL([NCIShortfall], 0 ),
               ISNULL([NCIBump], 0 ),
               ISNULL([PlayThroughPenalty], 0 ),
               ISNULL([PercentageScoreCasino], 0 ),
               ISNULL([CouponScoreCasino], 0 ),
               ISNULL([WagerAmount], 0 ),
               ISNULL([PayoutAmount], 0 ),
               ISNULL([DepositAmount], 0 ),
               ISNULL(TRY_CAST([WagerCount] AS INT), 0 ),
               ISNULL([AveBetSize], 0 ),
               ISNULL(TRY_CAST([DepositCount] AS INT), 0 ),
               ISNULL([CouponAdjustmentFactor], 0 ),
               ISNULL([BreakageFactor], 0 ),
               ISNULL([MinCouponAdjustmentFactor], 0 ),
               ISNULL([AdjustedPercentageScoreCasino], 0 ),
               ISNULL([AdjustedCouponScoreCasino], 0 ),
               ISNULL([TheoIncome], 0 ),
               ISNULL([TheoGrossMargin], 0 ),
               ISNULL([TheoGrossWin], 0 ),
               ISNULL([TheoPlayThrough], 0 ),
               ISNULL([PlayThrough], 0 ),
               ISNULL([Hits], 0 ),
               ISNULL([HitRate], 0 ),
               ISNULL([StdDevPayoutAmount], 0 ),
               ISNULL([VariancePayoutAmount], 0 ),
               ISNULL([StdDevWagers], 0 ),
               ISNULL([VarianceWagers], 0 ),
               ISNULL([NumReloads], 0 ),
               ISNULL([NumBumpUps], 0 ),
               ISNULL([BinaryValue], 0 ),
               [MaxBumpsReached],
               ISNULL([RowVer], 0 ),
               ISNULL([ExperienceFactor], 0 ),
               ISNULL([BinSum], 0 ),
               ISNULL([NCI2Purchase], 0 )      
          FROM #ExtractDelta_{StreamVariant}_{Stream} [CT]
         INNER JOIN [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}] [STBL]
            ON [CT].[PayloadID] = [STBL].[ExperienceResultID]
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
-- Load_PlayerOfferExperience
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOfferExperience',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Load_PlayerOfferExperience',
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
'Stage Surge PlayerOfferExperience from Delta keys.';

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
    -- RewardType
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.RewardType'';
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
      INSERT INTO [dbo].[RewardType] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [RewardTypeName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[RewardTypeName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[RewardType] RT
           ON PLD.[RewardTypeName] = RT.[RewardTypeName]
         WHERE RT.[RewardTypeID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[RewardTypeName];
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
    -- AdjustedPercentageSource
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.AdjustedPercentageSource'';
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
      INSERT INTO [dbo].[AdjustedPercentageSource] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [AdjustedPercentageSourceName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[AdjustedPercentageSourceName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[AdjustedPercentageSource] RT
           ON PLD.[AdjustedPercentageSourceName] = RT.[AdjustedPercentageSourceName]
         WHERE RT.[AdjustedPercentageSourceID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[AdjustedPercentageSourceName];
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
    -- TriggerType
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TriggerType'';
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
      INSERT INTO [dbo].[TriggerType] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [TriggerTypeName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[TriggerTypeName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[TriggerType] TT
           ON PLD.[TriggerTypeName] = TT.[TriggerTypeName]
         WHERE TT.[TriggerTypeID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[TriggerTypeName];
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
    -- EXPERIENCE SERIES
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.ExperienceSeries'';
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
      INSERT INTO [dbo].[ExperienceSeries] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [ExperienceSeriesName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[PlayerExperienceSeries]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[ExperienceSeries] ES
           ON PLD.[PlayerExperienceSeries] = ES.[ExperienceSeriesName]
         WHERE ES.[ExperienceSeriesID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[PlayerExperienceSeries];
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
    -- EXPERIENCE
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.Experience'';
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
      INSERT INTO [dbo].[Experience] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [ExperienceName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[PlayerExperience]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[Experience] ES
           ON PLD.[PlayerExperience] = ES.[ExperienceName]
         WHERE ES.[ExperienceID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[PlayerExperience];
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
    -- ExcitementBand
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.ExcitementBand'';
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
      INSERT INTO [dbo].[ExcitementBand] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [ExcitementBandName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[ExcitementBandName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[ExcitementBand] EB
           ON PLD.[ExcitementBandName] = EB.[ExcitementBandName]
         WHERE EB.[ExcitementBandID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[ExcitementBandName];
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
    -- ValueSegment
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.ValueSegment'';
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
      INSERT INTO [dbo].[ValueSegment] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [ValueSegmentName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[ValueSegmentName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[ValueSegment] VS
           ON PLD.[ValueSegmentName] = VS.[ValueSegmentName]
         WHERE VS.[ValueSegmentID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[ValueSegmentName];
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
    -- PlayerGroupBehaviour
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.PlayerGroupBehaviour'';
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
      INSERT INTO [dbo].[PlayerGroupBehaviour] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [PlayerGroupBehaviourName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[PlayerGroupBehaviourName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[PlayerGroupBehaviour] PGB
           ON PLD.[PlayerGroupBehaviourName] = PGB.[PlayerGroupBehaviourName]
         WHERE PGB.[PlayerGroupBehaviourID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[PlayerGroupBehaviourName];
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
    -- TimeOnDeviceCategory
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TimeOnDeviceCategory'';
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
      INSERT INTO [dbo].[TimeOnDeviceCategory] (
        [CaptureLogID],
        [Operation],
        [ModifiedDate],
        [TimeOnDeviceCategoryName]
      ) SELECT PLD.[CaptureLogID],
               ''I'',
               MIN(PLD.[ModifiedDate]),
               PLD.[TimeOnDeviceCategoryName]
         FROM #Stage_Surge_PlayerOfferExperience PLD
         LEFT JOIN [dbo].[TimeOnDeviceCategory] TOD
           ON PLD.[TimeOnDeviceCategoryName] = TOD.[TimeOnDeviceCategoryName]
         WHERE TOD.[TimeOnDeviceCategoryID] IS NULL
          AND PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
         GROUP BY PLD.[CaptureLogID],
                  PLD.[TimeOnDeviceCategoryName];
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
    -- HUB PlayerOffer
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.HubPlayerOffer'';
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
      INSERT INTO dbo.HubPlayerOffer (
        HubPlayerOfferID,
        SourceSystemID,
        CreatedDate,
        OriginSystemID,
        CaptureLogID,
		PromoGUID,
		OfferGUID,
        UserID,
		GamingSystemID
      ) SELECT DISTINCT PLD.HubPlayerOfferID,
                        PLD.SourceSystemID,
                        PLD.ModifiedDate,
                        PLD.OriginSystemID,
                        PLD.CaptureLogID,
                        PLD.PromoGUID,
                        PLD.OfferGUID,
						PLD.UserID,
						PLD.GamingSystemID
        FROM #Stage_Surge_PlayerOfferExperience PLD
        LEFT JOIN dbo.HubPlayerOffer Hub
          ON PLD.HubPlayerOfferID = Hub.HubPlayerOfferID
         AND PLD.SourceSystemID = Hub.SourceSystemID
        WHERE Hub.HubPlayerOfferID IS NULL
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
    -- PlayerOfferExperience
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.PlayerOfferExperience'';
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
      MERGE dbo.PlayerOfferExperience AS Tgt
      USING (SELECT PLD.HubPlayerOfferID,
                    PLD.SourceSystemID,
                    PLD.OriginSystemID,
                    PLD.CaptureLogID,
                    PLD.ModifiedDate,
                    PLD.HubPlayerID,
                    ISNULL([A].[AdjustedPercentageSourceID], -1) AS [AdjustedPercentageSourceID],
                    ISNULL([EB].[ExcitementBandID], -1) AS [ExcitementBandID],
                    ISNULL([E].[ExperienceID], -1) AS [ExperienceID],
                    ISNULL([ES].[ExperienceSeriesID], -1) AS [ExperienceSeriesID],
                    ISNULL([PGB].[PlayerGroupBehaviourID], -1) AS [PlayerGroupBehaviourID],
                    ISNULL([RT].[RewardTypeID], -1) AS [RewardTypeID],
                    ISNULL([TOD].[TimeOnDeviceCategoryID], -1) AS [TimeOnDeviceCategoryID],
                    ISNULL([TT].[TriggerTypeID], -1) AS [TriggerTypeID],
                    ISNULL([VS].[ValueSegmentID], -1) AS [ValueSegmentID],
		            PLD.CalculatedOnUTCDateTime,
		            CAST(CalculatedOnUTCDateTime AS DATE) AS [CalculatedOnUTCDate],
                    PLD.[ABTestGroup],
                    PLD.[ABTestFactor],
                    PLD.[BetSizeToBankRoll],
                    PLD.[BankRoll],
                    PLD.[MaxBankRoll],
                    PLD.[NetWin],
                    PLD.[GrossWin],
                    PLD.[GrossMargin],
                    PLD.[NCI],
                    PLD.[SubsidisedMargin],
                    PLD.[ExpectedSubsidisedMargin],
                    PLD.[NetMargin],
                    PLD.[ExpectedNetMargin],
                    PLD.[RequiredSubsidisedMargin],
                    PLD.[RequiredNCI],
                    PLD.[NCIShortfall],
                    PLD.[NCIBump] ,
                    PLD.[PlayThroughPenalty],
                    PLD.[PercentageScoreCasino],
                    PLD.[CouponScoreCasino],
                    PLD.[WagerAmount],
                    PLD.[PayoutAmount],
                    PLD.[DepositAmount],
                    PLD.[WagerCount],
                    PLD.[AveBetSize],
                    PLD.[DepositCount],
                    PLD.[CouponAdjustmentFactor],
                    PLD.[BreakageFactor],
                    PLD.[MinCouponAdjustmentFactor],
                    PLD.[AdjustedPercentageScoreCasino],
                    PLD.[AdjustedCouponScoreCasino],
                    PLD.[TheoIncome],
                    PLD.[TheoGrossMargin],
                    PLD.[TheoGrossWin],
                    PLD.[TheoPlayThrough],
                    PLD.[PlayThrough],
                    PLD.[Hits],
                    PLD.[HitRate],
                    PLD.[StdDevPayoutAmount],
                    PLD.[VariancePayoutAmount],
                    PLD.[StdDevWagers],
                    PLD.[VarianceWagers],
                    PLD.[NumberOfReloads],
                    PLD.[NumberOfBumpUps],
                    PLD.[BinaryValue],
                    PLD.[MaxBumpsReached],
                    PLD.[RowVer],
                    PLD.[ExperienceFactor],
                    PLD.[BinSum],
                    PLD.[NCI2Purchase]
               FROM #Stage_Surge_PlayerOfferExperience PLD
               LEFT JOIN [dbo].[AdjustedPercentageSource] [A]
                 ON PLD.[AdjustedPercentageSourceName] = A.[AdjustedPercentageSourceName]
               LEFT JOIN [dbo].[ExcitementBand] [EB]
                 ON PLD.[ExcitementBandName] = EB.[ExcitementBandName]
               LEFT JOIN [dbo].[Experience] [E]
                 ON PLD.[PlayerExperience] = E.[ExperienceName]
               LEFT JOIN [dbo].[ExperienceSeries] [ES]
                 ON PLD.[PlayerExperienceSeries] = ES.[ExperienceSeriesName]
               LEFT JOIN [dbo].[PlayerGroupBehaviour] [PGB]
                 ON PLD.[PlayerGroupBehaviourName] = PGB.[PlayerGroupBehaviourName]
               LEFT JOIN [dbo].[RewardType] [RT]
                 ON PLD.[RewardTypeName] = RT.[RewardTypeName]
               LEFT JOIN [dbo].[TimeOnDeviceCategory] [TOD]
                 ON PLD.[TimeOnDeviceCategoryName] = TOD.[TimeOnDeviceCategoryName]
               LEFT JOIN [dbo].[TriggerType] [TT]
                 ON PLD.[TriggerTypeName] = TT.[TriggerTypeName]
               LEFT JOIN [dbo].[ValueSegment] [VS]
                 ON PLD.[ValueSegmentName] = VS.[ValueSegmentName]
              WHERE PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID
            )AS Src
        ON Tgt.HubPlayerOfferID = Src.HubPlayerOfferID
       AND Tgt.SourceSystemID = Src.SourceSystemID
      WHEN MATCHED AND Src.ModifiedDate >= Tgt.ModifiedDate
        THEN
        UPDATE SET
            Tgt.CaptureLogID = Src.CaptureLogID,
            Tgt.Operation = ''U'',
            Tgt.ModifiedDate = Src.ModifiedDate,
            Tgt.HubPlayerID = Src.HubPlayerID,
            Tgt.AdjustedPercentageSourceID = Src.AdjustedPercentageSourceID,
            Tgt.ExcitementBandID = Src.ExcitementBandID,
            Tgt.PlayerExperienceID = Src.ExperienceID,
            Tgt.PlayerExperienceSeriesID = Src.ExperienceSeriesID,
            Tgt.PlayerGroupBehaviourID = Src.PlayerGroupBehaviourID,
            Tgt.RewardTypeID = Src.RewardTypeID,
            Tgt.TimeOnDeviceCategoryID = Src.TimeOnDeviceCategoryID,
            Tgt.TriggerTypeID = Src.TriggerTypeID,
            Tgt.ValueSegmentID = Src.ValueSegmentID,
            Tgt.CalculatedOnUTCDateTime = Src.CalculatedOnUTCDateTime,
            Tgt.CalculatedOnUTCDate = Src.CalculatedOnUTCDate,
            Tgt.ABTestGroup = Src.ABTestGroup,
            Tgt.ABTestFactor = Src.ABTestFactor,
            Tgt.BetSizeToBankRoll = Src.BetSizeToBankRoll,
            Tgt.BankRoll = Src.BankRoll,
            Tgt.MaxBankRoll = Src.MaxBankRoll,
            Tgt.NetWin = Src.NetWin,
            Tgt.GrossWin = Src.GrossWin,
            Tgt.GrossMargin = Src.GrossMargin,
            Tgt.NCI = Src.NCI,
            Tgt.SubsidisedMargin = Src.SubsidisedMargin,
            Tgt.ExpectedSubsidisedMargin = Src.ExpectedSubsidisedMargin,
            Tgt.NetMargin = Src.NetMargin,
            Tgt.ExpectedNetMargin = Src.ExpectedNetMargin,
            Tgt.RequiredSubsidisedMargin = Src.RequiredSubsidisedMargin,
            Tgt.RequiredNCI = Src.RequiredNCI,
            Tgt.NCIShortfall = Src.NCIShortfall,
            Tgt.NCIBump = Src.NCIBump,
            Tgt.PlayThroughPenalty = Src.PlayThroughPenalty,
            Tgt.PercentageScoreCasino = Src.PercentageScoreCasino,
            Tgt.CouponScoreCasino = Src.CouponScoreCasino,
            Tgt.WagerAmount = Src.WagerAmount,
            Tgt.PayoutAmount = Src.PayoutAmount,
            Tgt.DepositAmount = Src.DepositAmount,
            Tgt.WagerCount = Src.WagerCount,
            Tgt.AveBetSize = Src.AveBetSize,
            Tgt.DepositCount = Src.DepositCount,
            Tgt.CouponAdjustmentFactor = Src.CouponAdjustmentFactor,
            Tgt.BreakageFactor = Src.BreakageFactor,
            Tgt.MinCouponAdjustmentFactor = Src.MinCouponAdjustmentFactor,
            Tgt.AdjustedPercentageScoreCasino = Src.AdjustedPercentageScoreCasino,
            Tgt.AdjustedCouponScoreCasino = Src.AdjustedCouponScoreCasino,
            Tgt.TheoIncome = Src.TheoIncome,
            Tgt.TheoGrossMargin = Src.TheoGrossMargin,
            Tgt.TheoGrossWin = Src.TheoGrossWin,
            Tgt.TheoPlayThrough = Src.TheoPlayThrough,
            Tgt.PlayThrough = Src.PlayThrough,
            Tgt.Hits = Src.Hits,
            Tgt.HitRate = Src.HitRate,
            Tgt.StdDevPayoutAmount = Src.StdDevPayoutAmount,
            Tgt.VariancePayoutAmount = Src.VariancePayoutAmount,
            Tgt.StdDevWagers = Src.StdDevWagers,
            Tgt.VarianceWagers = Src.VarianceWagers,
            Tgt.NumberOfReloads = Src.NumberOfReloads,
            Tgt.NumberOfBumpUps = Src.NumberOfBumpUps,
            Tgt.BinaryValue = Src.BinaryValue,
            Tgt.MaxBumpsReached = Src.MaxBumpsReached,
            Tgt.RowVer = Src.RowVer,
            Tgt.ExperienceFactor = Src.ExperienceFactor,
            Tgt.BinSum = Src.BinSum,
            Tgt.NCI2Purchase = Src.NCI2Purchase
      WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            HubPlayerOfferID,
            SourceSystemID,
            OriginSystemID,
            CaptureLogID,
            Operation,
            ModifiedDate,
            HubPlayerID,
            AdjustedPercentageSourceID,
            ExcitementBandID,
            PlayerExperienceID,
            PlayerExperienceSeriesID,
            PlayerGroupBehaviourID,
            RewardTypeID,
            TimeOnDeviceCategoryID,
            TriggerTypeID,
            ValueSegmentID,
            CalculatedOnUTCDateTime,
            CalculatedOnUTCDate,
            ABTestGroup,
            ABTestFactor,
            BetSizeToBankRoll,
            BankRoll,
            MaxBankRoll,
            NetWin,
            GrossWin,
            GrossMargin,
            NCI,
            SubsidisedMargin,
            ExpectedSubsidisedMargin,
            NetMargin,
            ExpectedNetMargin,
            RequiredSubsidisedMargin,
            RequiredNCI,
            NCIShortfall,
            NCIBump,
            PlayThroughPenalty,
            PercentageScoreCasino,
            CouponScoreCasino,
            WagerAmount,
            PayoutAmount,
            DepositAmount,
            WagerCount,
            AveBetSize,
            DepositCount,
            CouponAdjustmentFactor,
            BreakageFactor,
            MinCouponAdjustmentFactor,
            AdjustedPercentageScoreCasino,
            AdjustedCouponScoreCasino,
            TheoIncome,
            TheoGrossMargin,
            TheoGrossWin,
            TheoPlayThrough,
            PlayThrough,
            Hits,
            HitRate,
            StdDevPayoutAmount,
            VariancePayoutAmount,
            StdDevWagers,
            VarianceWagers,
            NumberOfReloads,
            NumberOfBumpUps,
            BinaryValue,
            MaxBumpsReached,
            RowVer,
            ExperienceFactor,
            BinSum,
            NCI2Purchase
        )
        VALUES (
            Src.HubPlayerOfferID,
            Src.SourceSystemID,
            Src.OriginSystemID,
            Src.CaptureLogID,
            ''I'',
            Src.ModifiedDate,
            Src.HubPlayerID,
            Src.AdjustedPercentageSourceID,
            Src.ExcitementBandID,
            Src.ExperienceID,
            Src.ExperienceSeriesID,
            Src.PlayerGroupBehaviourID,
            Src.RewardTypeID,
            Src.TimeOnDeviceCategoryID,
            Src.TriggerTypeID,
            Src.ValueSegmentID,
            Src.CalculatedOnUTCDateTime,
            Src.CalculatedOnUTCDate,
            Src.ABTestGroup,
            Src.ABTestFactor,
            Src.BetSizeToBankRoll,
            Src.BankRoll,
            Src.MaxBankRoll,
            Src.NetWin,
            Src.GrossWin,
            Src.GrossMargin,
            Src.NCI,
            Src.SubsidisedMargin,
            Src.ExpectedSubsidisedMargin,
            Src.NetMargin,
            Src.ExpectedNetMargin,
            Src.RequiredSubsidisedMargin,
            Src.RequiredNCI,
            Src.NCIShortfall,
            Src.NCIBump,
            Src.PlayThroughPenalty,
            Src.PercentageScoreCasino,
            Src.CouponScoreCasino,
            Src.WagerAmount,
            Src.PayoutAmount,
            Src.DepositAmount,
            Src.WagerCount,
            Src.AveBetSize,
            Src.DepositCount,
            Src.CouponAdjustmentFactor,
            Src.BreakageFactor,
            Src.MinCouponAdjustmentFactor,
            Src.AdjustedPercentageScoreCasino,
            Src.AdjustedCouponScoreCasino,
            Src.TheoIncome,
            Src.TheoGrossMargin,
            Src.TheoGrossWin,
            Src.TheoPlayThrough,
            Src.PlayThrough,
            Src.Hits,
            Src.HitRate,
            Src.StdDevPayoutAmount,
            Src.VariancePayoutAmount,
            Src.StdDevWagers,
            Src.VarianceWagers,
            Src.NumberOfReloads,
            Src.NumberOfBumpUps,
            Src.BinaryValue,
            Src.MaxBumpsReached,
            Src.RowVer,
            Src.ExperienceFactor,
            Src.BinSum,
            Src.NCI2Purchase
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
-- Process_PlayerOfferExperience
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOfferExperience',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Process_PlayerOfferExperience',
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
	[PromoGUID] [VARCHAR](36) NOT NULL,
	[OfferGUID] [VARCHAR](36) NOT NULL,
	[UserID] [INT] NULL,
	[GamingSystemID] [INT] NULL,
    [HubPlayerOfferID] BINARY(32) NOT NULL,
    INDEX [CIDX_Stage_{StreamVariant}_{Stream}] CLUSTERED (HubPlayerOfferID ASC, [SourceSystemID] ASC) WITH (FILLFACTOR = 100),
    -- ATTRIBUTES --
    -- Relationships --
    [HubPlayerID] [BINARY](32) NOT NULL,
    [AdjustedPercentageSourceName] [VARCHAR](50) NOT NULL,
	[ExcitementBandName] [VARCHAR](50) NOT NULL,
	[PlayerExperience] [VARCHAR](255) NOT NULL,
	[PlayerExperienceSeries] [VARCHAR](255) NOT NULL,
	[PlayerGroupBehaviourName] [VARCHAR](50) NOT NULL,
	[RewardTypename] [VARCHAR](50) NOT NULL,
	[TimeOnDeviceCategoryName] [VARCHAR](50) NOT NULL,
	[TriggerTypeName] [VARCHAR](50) NOT NULL,
	[ValueSegmentName] [VARCHAR](50) NOT NULL,	
	[CalculatedOnUTCDateTime] [DATETIME2](7) NOT NULL,
    [ABTestGroup] CHAR(1) NOT NULL,
    [ABTestFactor] INT NOT NULL,
    [BetSizeToBankRoll] DECIMAL(32,4) NOT NULL,
    [BankRoll] DECIMAL(32,4) NOT NULL,
    [MaxBankRoll] DECIMAL(32,4) NOT NULL,
    [NetWin] DECIMAL(32,4) NOT NULL,
    [GrossWin] DECIMAL(32,4) NOT NULL,
    [GrossMargin] DECIMAL(32,4) NOT NULL,
    [NCI] DECIMAL(32,4) NOT NULL,
    [SubsidisedMargin] DECIMAL(32,4) NOT NULL,
    [ExpectedSubsidisedMargin] DECIMAL(32,4) NOT NULL,
    [NetMargin] DECIMAL(32,4) NOT NULL,
    [ExpectedNetMargin] DECIMAL(32,4) NOT NULL,
    [RequiredSubsidisedMargin] DECIMAL(32,4) NOT NULL,
    [RequiredNCI] DECIMAL(32,4) NOT NULL,
    [NCIShortfall] DECIMAL(32,4) NOT NULL,
    [NCIBump] DECIMAL(32,4) NOT NULL,
    [PlayThroughPenalty] DECIMAL(32,4) NOT NULL,
    [PercentageScoreCasino] DECIMAL(32,4) NOT NULL,
    [CouponScoreCasino] DECIMAL(32,4) NOT NULL,
    [WagerAmount] DECIMAL(32,4) NOT NULL,
    [PayoutAmount] DECIMAL(32,4) NOT NULL,
    [DepositAmount] DECIMAL(32,4) NOT NULL,
    [WagerCount] INT NOT NULL,
    [AveBetSize] DECIMAL(32,4) NOT NULL,
    [DepositCount] INT NOT NULL,
    [CouponAdjustmentFactor] DECIMAL(32,4) NOT NULL,
    [BreakageFactor] DECIMAL(32,4) NOT NULL,
    [MinCouponAdjustmentFactor] DECIMAL(32,4) NOT NULL,
    [AdjustedPercentageScoreCasino] DECIMAL(32,4) NOT NULL,
    [AdjustedCouponScoreCasino] DECIMAL(32,4) NOT NULL,
    [TheoIncome] DECIMAL(32,4) NOT NULL,
    [TheoGrossMargin] DECIMAL(32,4) NOT NULL,
    [TheoGrossWin] DECIMAL(32,4) NOT NULL,
    [TheoPlayThrough] DECIMAL(32,4) NOT NULL,
    [PlayThrough] DECIMAL(32,4) NOT NULL,
    [Hits] INT NOT NULL,
    [HitRate] DECIMAL(32,4) NOT NULL,
    [StdDevPayoutAmount] DECIMAL(32,4) NOT NULL,
    [VariancePayoutAmount] DECIMAL(32,4) NOT NULL,
    [StdDevWagers] DECIMAL(32,4) NOT NULL,
    [VarianceWagers] DECIMAL(32,4) NOT NULL,
    [NumberOfReloads] INT NOT NULL,
    [NumberOfBumpUps] INT NOT NULL,
    [BinaryValue] INT NOT NULL,
    [MaxBumpsReached] BIT NOT NULL,
    [RowVer] INT NOT NULL,
    [ExperienceFactor] DECIMAL(32,4) NOT NULL,
    [BinSum] INT NOT NULL,
    [NCI2Purchase] DECIMAL(32,4) NOT NULL,
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
        @Stream VARCHAR(50) = 'PlayerOfferExperience',
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
                                    @ObjectName = ''dbo.PlayerGroupBehaviour'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.PlayerGroupBehaviour'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.TimeOnDeviceCategory'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.TimeOnDeviceCategory'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.RewardType'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.RewardType'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.TriggerType'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.TriggerType'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.AbTestGroup'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.AbTestGroup'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.ExcitementBand'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.ExcitementBand'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.ValueSegment'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.ValueSegment'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.HubPlayerOffer'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.HubPlayerOffer'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.PlayerOfferExperience'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.PlayerOfferExperience'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.Experience'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.Experience'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.ExperienceSeries'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.AdjustedPercentageSource'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.AdjustedPercentageSource'',
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
        @Stream VARCHAR(50) = 'PlayerOfferExperience',
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
    ) VALUES (1,  ''Any'', ''Any'', ''Table'',     ''Process'', ''{Stream}_Held'', @Layer),
             (2,  ''Any'', ''Any'', ''View'',     ''Process'', ''v{Stream}_HeldSummary'', @Layer),
             (3,  ''Any'', ''Surge'', ''Procedure'', ''Task'', ''Extract_{Stream}'', @Layer),
             (4,  ''PlayerOfferExperience'', ''Surge'', ''Procedure'', ''Task'', ''Stage_PlayerOfferExperience'', @Layer),
             (5, ''PlayerOfferExperience'', ''Surge'', ''Procedure'', ''Task'', ''Load_PlayerOfferExperience'', @Layer),
             (6, ''PlayerOfferExperience'', ''Surge'', ''Procedure'', ''Process'', ''Process_PlayerOfferExperience'', @Layer),
             (7, ''PlayerOfferExperience'', ''Surge'', ''Script'',    ''Process'', ''Setup'', @Layer),
             (8, ''Any'', ''Any'', ''Script'',    ''Job'', ''Setup_LoopJob'', ''Any'');
    
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