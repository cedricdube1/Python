/************************************************************************
* Script     : 3.Business - PlayerOfferExperience - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PlayerOfferExperience] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOfferExperience_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOffer] ([HubPlayerOfferID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOfferExperience] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [AdjustedPercentageSourceID] INT NULL,
  [ExcitementBandID] INT NULL,
  [PlayerExperienceID] INT NULL,
  [PlayerExperienceSeriesID] INT NULL,
  [PlayerGroupBehaviourID] INT NULL,
  [RewardTypeID] INT NULL,
  [TimeOnDeviceCategoryID] INT NULL,
  [TriggerTypeID] INT NULL,
  [ValueSegmentID] INT NULL,
  [CalculatedOnUTCDateTime] DATETIME2 NULL,
  [CalculatedOnUTCDate] DATE NULL,
  [ABTestGroup] CHAR(1) NULL,
  [ABTestFactor] INT NULL,
  [BetSizeToBankRoll] DECIMAL(32,4) NULL,
  [BankRoll] DECIMAL(32,4) NULL,
  [MaxBankRoll] DECIMAL(32,4) NULL,
  [NetWin] DECIMAL(32,4) NULL,
  [GrossWin] DECIMAL(32,4) NULL,
  [GrossMargin] DECIMAL(32,4) NULL,
  [NCI] DECIMAL(32,4) NULL,
  [SubsidisedMargin] DECIMAL(32,4) NULL,
  [ExpectedSubsidisedMargin] DECIMAL(32,4) NULL,
  [NetMargin] DECIMAL(32,4) NULL,
  [ExpectedNetMargin] DECIMAL(32,4) NULL,
  [RequiredSubsidisedMargin] DECIMAL(32,4) NULL,
  [RequiredNCI] DECIMAL(32,4) NULL,
  [NCIShortfall] DECIMAL(32,4) NULL,
  [NCIBump] DECIMAL(32,4) NULL,
  [PlayThroughPenalty] DECIMAL(32,4) NULL,
  [PercentageScoreCasino] DECIMAL(32,4) NULL,
  [CouponScoreCasino] DECIMAL(32,4) NULL,
  [WagerAmount] DECIMAL(32,4) NULL,
  [PayoutAmount] DECIMAL(32,4) NULL,
  [DepositAmount] DECIMAL(32,4) NULL,
  [WagerCount] INT NULL,
  [AveBetSize] DECIMAL(32,4) NULL,
  [DepositCount] INT NULL,
  [CouponAdjustmentFactor] DECIMAL(32,4) NULL,
  [BreakageFactor] DECIMAL(32,4) NULL,
  [MinCouponAdjustmentFactor] DECIMAL(32,4) NULL,
  [AdjustedPercentageScoreCasino] DECIMAL(32,4) NULL,
  [AdjustedCouponScoreCasino] DECIMAL(32,4) NULL,
  [TheoIncome] DECIMAL(32,4) NULL,
  [TheoGrossMargin] DECIMAL(32,4) NULL,
  [TheoGrossWin] DECIMAL(32,4) NULL,
  [TheoPlayThrough] DECIMAL(32,4) NULL,
  [PlayThrough] DECIMAL(32,4) NULL,
  [Hits] INT NULL,
  [HitRate] DECIMAL(32,4) NULL,
  [StdDevPayoutAmount] DECIMAL(32,4) NULL,
  [VariancePayoutAmount] DECIMAL(32,4) NULL,
  [StdDevWagers] DECIMAL(32,4) NULL,
  [VarianceWagers] DECIMAL(32,4) NULL,
  [NumberOfReloads] INT NULL,
  [NumberOfBumpUps] INT NULL,
  [BinaryValue] INT NULL,
  [MaxBumpsReached] BIT NULL,
  [RowVer] INT NULL,
  [ExperienceFactor] DECIMAL(32,4) NULL,
  [BinSum] INT NULL,
  [NCI2Purchase] DECIMAL(32,4) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOfferExperience] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOfferExperience] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX__ HubPlayerID_CalculatedOnUTCDateTime] ON [dbo].[PlayerOfferExperience] (
--  [HubPlayerID] ASC,
--  [CalculatedOnUTCDateTime] ASC
--)  WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOfferExperience] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [AdjustedPercentageSourceID],
  [ExcitementBandID],
  [PlayerExperienceID],
  [PlayerExperienceSeriesID],
  [PlayerGroupBehaviourID],
  [RewardTypeID],
  [TimeOnDeviceCategoryID],
  [TriggerTypeID] ,
  [ValueSegmentID],
  [CalculatedOnUTCDateTime],
  [CalculatedOnUTCDate],
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
  [NCIBump],
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
  [MinCouponAdjustmentFactor] ,
  [AdjustedPercentageScoreCasino],
  [AdjustedCouponScoreCasino] ,
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
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_RewardType] FOREIGN KEY ([RewardTypeID]) REFERENCES [dbo].[RewardType] ([RewardTypeID]);
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_TriggerType] FOREIGN KEY ([TriggerTypeID]) REFERENCES [dbo].[TriggerType] ([TriggerTypeID]);
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_ExcitementBand] FOREIGN KEY ([ExcitementBandID]) REFERENCES [dbo].[ExcitementBand] ([ExcitementBandID]);
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_ValueSegment] FOREIGN KEY ([ValueSegmentID]) REFERENCES [dbo].[ValueSegment] ([ValueSegmentID]);
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_PlayerGroupBehaviour] FOREIGN KEY ([PlayerGroupBehaviourID]) REFERENCES [dbo].[PlayerGroupBehaviour] ([PlayerGroupBehaviourID]);
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_TimeOnDeviceCategory] FOREIGN KEY ([TimeOnDeviceCategoryID]) REFERENCES [dbo].[TimeOnDeviceCategory] ([TimeOnDeviceCategoryID]);
ALTER TABLE [dbo].[PlayerOfferExperience]
  ADD CONSTRAINT [FK_PlayerOfferExperience_PlayerExperienceSeries] FOREIGN KEY ([PlayerExperienceSeriesID]) REFERENCES [dbo].[ExperienceSeries] ([ExperienceSeriesID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[PlayerOfferExperience] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO


/* End of File ********************************************************************************************************************/