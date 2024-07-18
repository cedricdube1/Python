/************************************************************************
* Script     : 6.Business - PlayerOfferExperience - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerOfferExperience]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerOfferID],
       [Hub].[SourceSystemID],
       [Hub].[PromoGUID],
       [Hub].[OfferGUID],
       [Hub].[UserID],
       [Hub].[GamingSystemID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [A].[AdjustedPercentageSourceName],
       [EB].[ExcitementBandName],
       [E].[ExperienceName] [PlayerExperience],
       [ES].[ExperienceSeriesName] [PlayerExperienceSeries],
       [PGB].[PlayerGroupBehaviourName],
       [R].[RewardTypeName],
       [TOD].[TimeOnDeviceCategoryName],
       [TT].[TriggerTypeName],
       [v].[ValueSegmentName],
       [Det].[CalculatedOnUTCDateTime],
       [Det].[CalculatedOnUTCDate],
       [Det].[ABTestGroup],
       [Det].[ABTestFactor],
       [Det].[BetSizeToBankRoll],
       [Det].[BankRoll],
       [Det].[MaxBankRoll],
       [Det].[NetWin],
       [Det].[GrossWin],
       [Det].[GrossMargin],
       [Det].[NCI],
       [Det].[SubsidisedMargin],
       [Det].[ExpectedSubsidisedMargin],
       [Det].[NetMargin],
       [Det].[ExpectedNetMargin],
       [Det].[RequiredSubsidisedMargin],
       [Det].[RequiredNCI],
       [Det].[NCIShortfall],
       [Det].[NCIBump] ,
       [Det].[PlayThroughPenalty],
       [Det].[PercentageScoreCasino],
       [Det].[CouponScoreCasino],
       [Det].[WagerAmount],
       [Det].[PayoutAmount],
       [Det].[DepositAmount],
       [Det].[WagerCount],
       [Det].[AveBetSize],
       [Det].[DepositCount],
       [Det].[CouponAdjustmentFactor],
       [Det].[BreakageFactor],
       [Det].[MinCouponAdjustmentFactor],
       [Det].[AdjustedPercentageScoreCasino],
       [Det].[AdjustedCouponScoreCasino],
       [Det].[TheoIncome],
       [Det].[TheoGrossMargin],
       [Det].[TheoGrossWin],
       [Det].[TheoPlayThrough],
       [Det].[PlayThrough],
       [Det].[Hits],
       [Det].[HitRate],
       [Det].[StdDevPayoutAmount],
       [Det].[VariancePayoutAmount],
       [Det].[StdDevWagers],
       [Det].[VarianceWagers],
       [Det].[NumberOfReloads],
       [Det].[NumberOfBumpUps],
       [Det].[BinaryValue],
       [Det].[MaxBumpsReached],
       [Det].[RowVer],
       [Det].[ExperienceFactor],
       [Det].[BinSum],
       [Det].[NCI2Purchase]
FROM [dbo].[HubPlayerOffer] [Hub]
INNER JOIN [dbo].[PlayerOfferExperience] [Det]
  ON [Hub].[HubPlayerOfferID] = [Det].[HubPlayerOfferID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[AdjustedPercentageSource] [A]
  ON [A].[AdjustedPercentageSourceID] = [Det].[AdjustedPercentageSourceID]
LEFT JOIN [dbo].[ExcitementBand] [EB]
  ON [EB].[ExcitementBandID] = [Det].[ExcitementBandID]
LEFT JOIN [dbo].[Experience] [E]
  ON [E].[ExperienceID] = [Det].[PlayerExperienceID]
LEFT JOIN [dbo].[ExperienceSeries] [ES]
  ON [ES].[ExperienceSeriesID] = [Det].[PlayerExperienceSeriesID]
LEFT JOIN [dbo].[PlayerGroupBehaviour] [PGB]
  ON [PGB].[PlayerGroupBehaviourID] = [Det].[PlayerGroupBehaviourID]
LEFT JOIN [dbo].[RewardType] [R]
  ON [R].[RewardTypeID] = [Det].[RewardTypeID]
LEFT JOIN [dbo].[TimeOnDeviceCategory] [TOD]
  ON [TOD].[TimeOnDeviceCategoryID] = [Det].[TimeOnDeviceCategoryID]
LEFT JOIN [dbo].[TriggerType] [TT]
  ON [TT].[TriggerTypeID] = [Det].[TriggerTypeID]
LEFT JOIN [dbo].[ValueSegment] [V]
  ON [V].[ValueSegmentID] = [Det].[ValueSegmentID];

GO




/* End of File ********************************************************************************************************************/