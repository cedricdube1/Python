/************************************************************************
* Script     : 5.PlayerOffer - Staging.sql
* Created By : Cedric Dube
* Created On : 2021-09-09
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps(Pre) : 1 > Functions
*            :   1.1 > HubPlayerOfferHash
* Steps(post): 2 > Procedures
*            :     3.1 > Extract_PlayerOffer (handled by Common, no need to specify here)
*            :     3.2 > Stage_PlayerOffer
*            :     3.3 > Load_PlayerOffer
*            :     3.4 > Process_PlayerOffer
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
-- HubPlayerOfferHash
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOffer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'HubPlayerOfferHash',
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
'@GamingSystemID INT,
  @OfferGUID VARCHAR(36),
  @PromoGUID VARCHAR(36),
  @UserID INT';

SET @CodeObjectExecutionOptions =
'RETURNS BINARY(32) 
  WITH SCHEMABINDING';

SET @CodeObject = 
'BEGIN;
  DECLARE @HashKey BINARY(32);
  SET @HashKey = CAST(HASHBYTES(''SHA2_256'',
                                       TRY_CAST(@GamingSystemID AS VARCHAR)
									   +''-''+
                                       TRY_CAST(@OfferGUID AS VARCHAR)
									   +''-''+
                                       TRY_CAST(@PromoGUID AS VARCHAR)
                                       +''-''+
                                       TRY_CAST(@UserID AS VARCHAR)									   
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
-- Stage_PlayerOffer
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOffer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Stage_PlayerOffer',
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
'Stage Surge PlayerOffer from Delta keys.';

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
		[HubPlayerEligibilityID],
        [RewardTypeName],
        [Coupon],
        [Percentage],
        [FreeSpins],
        [TierIndex]
      ) SELECT -- PROCESS --
               @ProcessLogID,
               [OfferDetailsID],
               COALESCE([InsertedDateTime], @NowTime),
               @SourceSystemID,
               @OriginSystemID,
               -- KEYS --
               ISNULL([PromoGUID],''0-0-0-0-0''),
               ISNULL([TierGUID],''0-0-0-0-0''),
			   ISNULL([UserID], -1),
			   ISNULL([GamingSystemID], -1),
               ISNULL([Surge].[HubPlayerOfferHash] ([GamingSystemID], [TierGUID], [PromoGUID], [UserID]),@DefaultHubID) AS [HubPlayerOfferID],
               -- ATTRIBUTES --
               -- Relationships --
			   ISNULL([Surge].[HubPlayerHash] ([GamingSystemID], [UserID]),@DefaultHubID) AS [HubPlayerID],
			   ISNULL([Surge].[HubPlayerEligibilityHash] ([EligibilityGUID], [GamingSystemID], [PromoGUID], [UserID]),@DefaultHubID) AS [HubPlayerEligibilityID],
			   LEFT(ISNULL([RewardType], ''Unknown''), 50),
               ISNULL([Coupon], 0),
               ISNULL([Percentage], 0),
			   ISNULL([FreeSpins], 0),
			   ISNULL([TierIndex], 0)
          FROM #ExtractDelta_{StreamVariant}_{Stream} [CT]
         INNER JOIN [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}] [STBL]
            ON [CT].[PayloadID] = [STBL].[OfferDetailsID]
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
-- Load_PlayerOffer
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOffer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Load_PlayerOffer',
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
'Stage Surge PlayerOffer from Delta keys.';

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
    -- Update EligibilityGuid
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''#Stage_Surge_PlayerOffer'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Update HubEligibilityID to:  '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      UPDATE a
      SET     HubPlayerEligibilityID = b.HubPlayerEligibilityID
      FROM    #Stage_Surge_PlayerOffer a WITH (NOLOCK)
	  JOIN    dbo.vw_PlayerEligibility b WITH (NOLOCK) ON b.GamingSystemID = a.GamingSystemID AND b.UserID = a.UserID AND b.PromoGUID = a.PromoGUID
      WHERE   a.HubPlayerEligibilityID <>  b.HubPlayerEligibilityID AND b.PromotionTypeName IN (''DailyBonus'', ''Acquisition'');
      SET @UpdateCount = @@ROWCOUNT;
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID, @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID, @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount, @UpdateCount = @UpdateCount, @MergeCount = @MergeCount;
    COMMIT;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth, 
                                                                       @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
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
         FROM #Stage_Surge_PlayerOffer PLD
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
        FROM #Stage_Surge_PlayerOffer PLD
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
    -- PlayerOffer
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.PlayerOffer'';
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
      MERGE dbo.PlayerOffer AS Tgt
      USING (SELECT PLD.HubPlayerOfferID,
                    PLD.SourceSystemID,
                    PLD.OriginSystemID,
                    PLD.CaptureLogID,
                    PLD.ModifiedDate,
                    PLD.HubPlayerID,
                    PLD.HubPlayerEligibilityID,
                    ISNULL(RT.RewardTypeID, -1) AS [RewardTypeID],
                    PLD.Coupon,
                    PLD.Percentage,
                    PLD.FreeSpins,
                    PLD.TierIndex
               FROM #Stage_Surge_PlayerOffer PLD
               LEFT JOIN [dbo].[RewardType] RT WITH (NOLOCK)
                 ON PLD.[RewardTypeName] = RT.[RewardTypeName]
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
            Tgt.HubPlayerEligibilityID = Src.HubPlayerEligibilityID,
            Tgt.RewardTypeID = Src.RewardTypeID,
            Tgt.Coupon = Src.Coupon,
            Tgt.Percentage = Src.Percentage,
            Tgt.FreeSpins = Src.FreeSpins,
            Tgt.TierIndex = Src.TierIndex
      WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            HubPlayerOfferID,
            SourceSystemID,
            OriginSystemID,
            CaptureLogID,
            Operation,
            ModifiedDate,
            HubPlayerID,
            HubPlayerEligibilityID,
            RewardTypeID,
            Coupon,
            Percentage,
            FreeSpins,
            TierIndex
        )
        VALUES (
            Src.HubPlayerOfferID,
            Src.SourceSystemID,
            Src.OriginSystemID,
            Src.CaptureLogID,
            ''I'',
            Src.ModifiedDate,
            Src.HubPlayerID,
            Src.HubPlayerEligibilityID,
            Src.RewardTypeID,
            Src.Coupon,
            Src.Percentage,
            Src.FreeSpins,
            Src.TierIndex
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
-- Process_PlayerOffer
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'PlayerOffer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Process_PlayerOffer',
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
	[UserID] [INT] NOT NULL,
	[GamingSystemID] [INT] NOT NULL,
    [HubPlayerOfferID] BINARY(32) NOT NULL,
    INDEX [CIDX_Stage_{StreamVariant}_{Stream}] CLUSTERED (HubPlayerOfferID ASC, [SourceSystemID] ASC) WITH (FILLFACTOR = 100),
    -- ATTRIBUTES --
    -- Relationships --
    [HubPlayerID] [BINARY](32) NOT NULL,
	[HubPlayerEligibilityID] [BINARY](32) NOT NULL,
	[RewardTypeName] [VARCHAR](50) NOT NULL,
	[Coupon] [INT] NOT NULL,
	[Percentage] [INT] NOT NULL,
	[FreeSpins] [INT] NOT NULL,
	[TierIndex] [INT] NOT NULL,
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
        @Stream VARCHAR(50) = 'PlayerOffer',
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
                                    @ObjectName = ''dbo.RewardType'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.RewardType'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.HubPlayerOffer'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.HubPlayerOffer'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.PlayerOffer'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.PlayerOffer'',
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
        @Stream VARCHAR(50) = 'PlayerOffer',
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
    ) VALUES (1,  ''PlayerOffer'', ''Surge'', ''Function'',  ''Process'', ''HubPlayerOfferHash'', @Layer),
	         (2,  ''Any'', ''Any'', ''Table'',     ''Process'', ''{Stream}_Held'', @Layer),
             (3,  ''Any'', ''Any'', ''View'',     ''Process'', ''v{Stream}_HeldSummary'', @Layer),
             (4,  ''Any'', ''Surge'', ''Procedure'', ''Task'', ''Extract_{Stream}'', @Layer),
             (5,  ''PlayerOffer'', ''Surge'', ''Procedure'', ''Task'', ''Stage_PlayerOffer'', @Layer),
             (6, ''PlayerOffer'', ''Surge'', ''Procedure'', ''Task'', ''Load_PlayerOffer'', @Layer),
             (7, ''PlayerOffer'', ''Surge'', ''Procedure'', ''Process'', ''Process_PlayerOffer'', @Layer),
             (8, ''PlayerOffer'', ''Surge'', ''Script'',    ''Process'', ''Setup'', @Layer),
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