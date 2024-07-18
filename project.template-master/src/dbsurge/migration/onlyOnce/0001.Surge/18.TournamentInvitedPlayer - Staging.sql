/************************************************************************
* Script     : 15.TournamentInvitedPlayer - Staging.sql
* Created By : Cedric Dube
* Created On : 2021-09-09
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps(Pre) : 1 > Functions
*            :   1.1 > None. Uses TournamentPlayer
* Steps(post): 2 > Procedures
*            :     3.1 > Extract_TournamentInvitedPlayer (handled by Common, no need to specify here)
*            :     3.2 > Stage_TournamentInvitedPlayer
*            :     3.3 > Load_TournamentInvitedPlayer
*            :     3.4 > Process_TournamentInvitedPlayer
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
-- Stage_TournamentInvitedPlayer
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'TournamentInvitedPlayer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Stage_TournamentInvitedPlayer',
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
'Stage Surge TournamentInvitedPlayer from Delta keys.';

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
		[IsCurrent],
        -- KEYS --
        [TournamentID],
        [GamingSystemID],
        [UserID],
        [HubTournamentPlayerID],
        -- ATTRIBUTES --
        -- Relationships --
        [HubTournamentID],
        [HubPlayerID],
        [StatusName]
      ) SELECT -- PROCESS --
               @ProcessLogID,
               [TournamentEligibleUserID],
               COALESCE([InsertedDateTime], @NowTime),
               @SourceSystemID,
               @OriginSystemID,
			   1 AS [IsCurrent],
               -- KEYS --
               ISNULL([TournamentID], -1),
               ISNULL([GamingSystemID], -1),
               ISNULL([UserID], -1),
               ISNULL([Surge].[HubTournamentPlayerHash] ([GamingSystemID], @OriginSystemID, [TournamentID], [UserID]),@DefaultHubID) AS [HubTournamentPlayerID],
               -- ATTRIBUTES --
               -- Relationships --
               ISNULL([Surge].[HubTournamentHash] (@OriginSystemID, [TournamentID]),@DefaultHubID) AS [HubTournamentID],
               ISNULL([Surge].[HubPlayerHash] ([GamingSystemID], [UserID]),@DefaultHubID) AS [HubPlayerID],
               [Status]
          FROM #ExtractDelta_{StreamVariant}_{Stream} [CT]
         INNER JOIN [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}] [STBL]
            ON [CT].[PayloadID] = [STBL].[TournamentEligibleUserID]
           AND [CT].[PayloadID] BETWEEN @MinDeltaID AND @MaxDeltaID
         WHERE [CT].[DeltaID] >= @ProcessBatchBeginID AND [CT].[DeltaID] < @ProcessBatchEndID
           AND [STBL].[Status] IS NOT NULL; -- Only include players with a relevant status related to a tournament
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
  -------------------------------
  -- UPDATE HELD ROWS
  -------------------------------
  IF @HeldEntriesDisabled = 0 BEGIN;
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Update Held entries.'';
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID,
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID,
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @TargetObject = ''{HeldSchema}.{Stream}_Held'';

    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      -- Update Processed Held --
      UPDATE HK
        SET  Processed = 1,
             ProcessedDate = @NowTime,
             ProcessedTaskLogID = @ProcessTaskLogID
        FROM #Stage_{StreamVariant}_{Stream} HT
       INNER JOIN [{HeldSchema}].[{Stream}_Held] HK
          ON HT.SourcePayloadID = HK.PayloadID
         AND HT.SourceSystemID = HK.SourceSystemID
         AND HT.OriginSystemID = HK.OriginSystemID
       WHERE HK.Processed = 0; -- In #HoldingTable, so has passed Held conditions
       SET @UpdateCount = @@ROWCOUNT;
	  
      -- Insert Held --
      INSERT INTO [{HeldSchema}].[{Stream}_Held] (
        PayloadID,
        SourceSystemID,
        OriginSystemID,
        HeldProcessTaskLogID
      ) SELECT DISTINCT CT.PayloadID,
                        @SourceSystemID,
                        @OriginSystemID,
                        @ProcessTaskLogID
          FROM #ExtractDelta_{StreamVariant}_{Stream} CT-- In Batch and view but...
         INNER JOIN [{ExtractDatabase}].[{ExtractSchema}].[{ExtractTableName}] [STBL]
            ON [CT].[PayloadID] = [STBL].[TournamentEligibleUserID]
          LEFT JOIN #Stage_{StreamVariant}_{Stream} HT
            ON CT.PayloadID = HT.SourcePayloadID
          LEFT JOIN [{HeldSchema}].[{Stream}_Held] HK
            ON CT.PayloadID = HK.PayloadID
           AND HK.SourceSystemID = @SourceSystemID
           AND HK.OriginSystemID = @OriginSystemID
         WHERE HT.SourcePayloadID IS NULL -- ...Not in #HoldingTable AND ...
           AND HK.PayloadID IS NULL -- ...Not in Held table
           AND [STBL].[Status] IS NOT NULL; -- Only included players with a relevant status related to a tournament
      SET @InsertCount = @@ROWCOUNT;
      -- RELEASE THE APP. LOCK --
      EXEC [sp_ReleaseAppLock] @Resource = @TargetObject; 
      -- Capture Counts
      IF @CaptureLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskCapture] @ProcessLogID = @ProcessLogID,
                                                                            @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                            @ProcessTaskID = @ProcessTaskID,
                                                                            @ProcessTaskLogID = @ProcessTaskLogID,
                                                                            @TargetObject = @TargetObject,
                                                                            @InsertCount = @InsertCount,
                                                                            @UpdateCount = @UpdateCount;
	  
      -- Info Log End --
      IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoEnd] @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID;
    COMMIT;
  END;
  {<StageTaskStatement_Footer_TournamentPlayer>}';

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
-- Load_TournamentInvitedPlayer
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'TournamentInvitedPlayer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Load_TournamentInvitedPlayer',
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
'Stage Surge TournamentInvitedPlayer from Delta keys.';

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
         FROM #Stage_Surge_TournamentInvitedPlayer PLD
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
    {<LoadTaskStatement_InsertReference_HubPlayer>}
	{<LoadTaskStatement_InsertReference_Player>} 
    ----------------------------------------------------------------
    -- KEYS
    ----------------------------------------------------------------
    ----------------------------------
    -- HUB TournamentInvitedPlayer
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.HubTournamentPlayer'';
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
      INSERT INTO dbo.HubTournamentPlayer (
        HubTournamentPlayerID,
        SourceSystemID,
        CreatedDate,
        OriginSystemID,
        CaptureLogID,
		TournamentID,
        GamingSystemID,
        UserID
      ) SELECT DISTINCT PLD.HubTournamentPlayerID,
                        PLD.SourceSystemID,
                        PLD.ModifiedDate,
                        PLD.OriginSystemID,
                        PLD.CaptureLogID,
                        PLD.TournamentID,
                        PLD.GamingSystemID,
                        PLD.UserID
        FROM #Stage_Surge_TournamentInvitedPlayer PLD
        LEFT JOIN dbo.HubTournamentPlayer Hub
          ON PLD.HubTournamentPlayerID = Hub.HubTournamentPlayerID
         AND PLD.SourceSystemID = Hub.SourceSystemID
        WHERE Hub.HubTournamentPlayerID IS NULL
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
    -- INSERT NEW
    ----------------------------------------------------------------
    ----------------------------------
    -- TournamentPlayer
    ----------------------------------
	----------------------------------
    --INSERT NEW RECORD AS ISCURRENT If NO RECORDS EXIST FROM TournamentPlayer STREAM
    ----------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TournamentPlayer'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process as IsCurrent if no record exist to: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>} 
	  INSERT INTO [dbo].[TournamentPlayer] (
        HubTournamentPlayerID,
        SourceSystemID,
		OriginSystemID,
		CaptureLogID,
		ModifiedDate,
        IsCurrent,
        FromDate,
        Todate,        
        Operation,        
        HubTournamentID,
        HubPlayerID,
		    SessionProductID,
        StatusID,
        TournamentTemplateID,
        CurrencyCode,
        Score,
        LeaderBoardPosition,
        IsCompleteLeaderboard,
        PrizeAmount
      ) SELECT DISTINCT PLD.HubTournamentPlayerID,
               PLD.SourceSystemID,
               PLD.OriginSystemID,
               PLD.CaptureLogID,
               PLD.ModifiedDate,
               PLD.IsCurrent,
               PLD.ModifiedDate AS [FromDate],
               TRY_CAST(''9999-12-31 23:59:59'' AS DATETIME2) AS [ToDate],
			         ''I'',
               PLD.HubTournamentID,
               PLD.HubPlayerID,
			         0 AS [SessionProductID],
               ISNULL(ST.StatusID, -1) AS [StatusID],
               -- ONLY DEFAULTS FOLLOW. ONLY STATUS AVAILABLE FROM SOURCE --
               -1 AS [TournamentTemplateID],
               ''UNK'' AS [CurrencyCode],
               0 AS [Score],
               0 AS [LeaderBoardPosition],
               0 AS [IsCompleteLeaderboard],
               0 AS [PrizeAmount]
         FROM #Stage_Surge_TournamentInvitedPlayer PLD
         LEFT JOIN [dbo].[Status] ST WITH (NOLOCK)
           ON PLD.[StatusName] = ST.[StatusName]
         LEFT JOIN [dbo].[TournamentPlayer] TP
           ON PLD.[HubTournamentPlayerID] = TP.[HubTournamentPlayerID]
		  AND PLD.[SourceSystemID] = TP.[SourceSystemID]
        WHERE TP.[HubTournamentPlayerID] IS NULL
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

	--------------------------------------------------------------------------------------------------------
    --INSERT NEW RECORD AS NOT ISCURRENT IF RECORDS ALREADY EXIST FROM TournamentPlayer STREAM
	--------------------------------------------------------------------------------------------------------
	SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TournamentPlayer'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Process as not IsCurrent if records exist to: '' + @TargetObject;
    IF @InfoLoggingDisabled = 0 EXEC [Logging].[LogProcessTaskInfoStart] @ProcessLogID = @ProcessLogID, 
                                                                         @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                                                         @ProcessTaskID = @ProcessTaskID,
                                                                         @ProcessTaskLogID = @ProcessTaskLogID, 
                                                                         @InfoMessage = @InfoMessage,
                                                                         @Ordinal = @StepID,
                                                                         @ProcessTaskInfoLogID = @ProcessTaskInfoLogID OUTPUT;
    BEGIN TRANSACTION;
      {<ApplockStatement_GetLock>}
      WITH CTE AS (SELECT PLD.HubTournamentPlayerID,
                          PLD.SourceSystemID,
                          PLD.OriginSystemID,
                          PLD.CaptureLogID,
                          PLD.ModifiedDate,
                          0 AS IsCurrent,
                          PLD.ModifiedDate AS [FromDate],
                          TRY_CAST(''9999-12-31 23:59:59'' AS DATETIME2) AS [ToDate],
                          ''I'' AS Operation,
                          PLD.HubTournamentID,
                          PLD.HubPlayerID,
			                    0 AS [SessionProductID],
                          ISNULL(ST.StatusID, -1) AS [StatusID],
                          -- ONLY DEFAULTS FOLLOW. ONLY STATUS AVAILABLE FROM SOURCE --
                          -1 AS [TournamentTemplateID],
                          ''UNK'' AS [CurrencyCode],
                          0 AS [Score],
                          0 AS [LeaderBoardPosition],
                          0 AS [IsCompleteLeaderboard],
                          0 AS [PrizeAmount]
                  FROM #Stage_Surge_TournamentInvitedPlayer PLD
                  LEFT JOIN [dbo].[Status] ST WITH (NOLOCK)
                    ON PLD.[StatusName] = ST.[StatusName] 
                 WHERE PLD.[StageID] >= @ProcessBatchBeginID AND PLD.[StageID] < @ProcessBatchEndID 
		  ) 
		   INSERT INTO [dbo].[TournamentPlayer] (
                       HubTournamentPlayerID,
                       SourceSystemID,
                       OriginSystemID,
                       CaptureLogID,
                       ModifiedDate,
                       IsCurrent,
                       FromDate,
                       Todate,        
                       Operation,        
                       HubTournamentID,
                       HubPlayerID,
                       SessionProductID,
                       StatusID,
                       TournamentTemplateID,
                       CurrencyCode,
                       Score,
                       LeaderBoardPosition,
                       IsCompleteLeaderboard,
                       PrizeAmount
                )
		        SELECT SRC.HubTournamentPlayerID,
                       SRC.SourceSystemID,
                       SRC.OriginSystemID,
                       SRC.CaptureLogID,
                       SRC.ModifiedDate,
                       SRC.IsCurrent,
                       SRC.[FromDate],
                       SRC.[ToDate],
                       SRC.Operation,
                       SRC.HubTournamentID,
                       SRC.HubPlayerID,
                       SRC.SessionProductID,
                       SRC.StatusID,
                       -- ONLY DEFAULTS FOLLOW. ONLY STATUS AVAILABLE FROM SOURCE --
                       SRC.TournamentTemplateID,
                       SRC.CurrencyCode,
                       SRC.Score,
                       SRC.LeaderBoardPosition,
                       SRC.IsCompleteLeaderboard,
                       SRC.PrizeAmount		         
		         FROM CTE SRC
		         LEFT OUTER JOIN [dbo].[TournamentPlayer] TP
                   ON  SRC.[HubTournamentPlayerID] = tp.[HubTournamentPlayerID] 
                  AND  SRC.[SourceSystemID] = tp.[SourceSystemID] 
		          AND  SRC.[StatusID] = tp.[StatusID]
                 WHERE TP.StatusID IS NULL
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
    -- Update Todate column for historical data
    ----------------------------------------------------------------
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET @InsertCount = 0;
    SET @UpdateCount = 0;
    SET @MergeCount = 0;
    SET @TargetObject = ''dbo.TournamentPlayer'';
    -- Info Log Start --
    SET @StepID = @StepID +1;
    SET @InfoMessage = ''Update Todate column for historical data: '' + @TargetObject;
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
          SELECT STG.IsCurrent,
                 STG.HubTournamentPlayerID,
                 STG.SourceSystemID,
                 STG.FromDate,
                 STG.ToDate,
	      	   LEAD([FromDate],1,TRY_CAST(''9999-12-31 23:59:59'' AS DATETIME2)) OVER (PARTITION BY  STG.HubTournamentPlayerID, STG.SourceSystemID ORDER BY FromDate) AS NextStatusFromdate
          FROM [dbo].[TournamentPlayer] STG
		  WHERE STG.ModifiedDate >= CONVERT(DateTime, DATEDIFF(DAY, 0, GETDATE()-60))
         ) UPDATE CTE
		SET Todate = NextStatusFromdate
		WHERE ToDate = ''9999-12-31 23:59:59''
		AND IsCurrent <> 1;
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
-- Process_TournamentInvitedPlayer
------------------
DECLARE @Layer VARCHAR(50) = 'Staging',
        @Stream VARCHAR(50) = 'TournamentInvitedPlayer',
        @StreamVariant VARCHAR(50) = 'Surge',
        @CodeObjectName NVARCHAR(128) = 'Process_TournamentInvitedPlayer',
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
	[IsCurrent] BIT NOT NULL,
    --INDEX [IDX2_Stage_{StreamVariant}_{Stream}] NONCLUSTERED ([ModifiedDate] ASC, [SourcePayloadID] ASC) WITH (FILLFACTOR = 100),
    -- KEYS --
	[TournamentID] [INT] NOT NULL,
	[GamingSystemID] [INT] NOT NULL,
	[UserID] [INT] NOT NULL,
    [HubTournamentPlayerID] BINARY(32) NOT NULL,
    INDEX [CIDX_Stage_{StreamVariant}_{Stream}] CLUSTERED (HubTournamentPlayerID ASC, [SourceSystemID] ASC) WITH (FILLFACTOR = 100),
    -- ATTRIBUTES --
    -- Relationships --
    [HubTournamentID] [BINARY](32) NOT NULL,
    [HubPlayerID] [BINARY](32) NOT NULL,
    [StatusName] [VARCHAR](50) NOT NULL,
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
        @Stream VARCHAR(50) = 'TournamentInvitedPlayer',
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
                                    @ObjectName = ''dbo.HubTournamentPlayer'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.HubTournamentPlayer'',
                                    @ConfigValue = 1000;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Retry'',
                                    @ObjectName = ''dbo.TournamentPlayer'',
                                    @ConfigValue = 100;
EXEC [Config].[SetVariable_AppLock] @ConfigName = ''Timeout'',
                                    @ObjectName = ''dbo.TournamentPlayer'',
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
        @Stream VARCHAR(50) = 'TournamentInvitedPlayer',
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
             (4,  ''TournamentInvitedPlayer'', ''Surge'', ''Procedure'', ''Task'', ''Stage_TournamentInvitedPlayer'', @Layer),
             (5, ''TournamentInvitedPlayer'', ''Surge'', ''Procedure'', ''Task'', ''Load_TournamentInvitedPlayer'', @Layer),
             (6, ''TournamentInvitedPlayer'', ''Surge'', ''Procedure'', ''Process'', ''Process_TournamentInvitedPlayer'', @Layer),
             (7, ''TournamentInvitedPlayer'', ''Surge'', ''Script'',    ''Process'', ''Setup'', @Layer),
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