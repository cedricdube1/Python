/************************************************************************
* Script     : Dummy Source Tables.sql
* Created By : Cedric Dube
* Created On : 2023-07-05
* Execute On : CPTDEVDB02
* Execute As : N/A
* Execution  : As required.
************************************************************************
* Tables (X55)
************************************************************************
* dbReportingResource
************************************************************************
*            : 1 > PlayerRegistration (DONE)
*                  > dbo.SURGE_tblRegistration
*                  > dbo.SURGE_tblRegistration_MIT
*            : 2 > OfferDetails (DONE)
*                  > dbo.SURGE_tblOfferDetails
*                  > dbo.SURGE_tblOfferDetails_MIT
*                  > dbo.SURGE_tblPlayerIncentive
*                  > dbo.SURGE_tblPlayerIncentive_MIT
*                  > dbo.SURGE_tblEligibility
*                  > dbo.SURGE_tblEligibility_MIT
*                  > dbo.SURGE_tblAcquisitionCompletedOffers
*                  > dbo.SURGE_tblAcquisitionCompletedOffers_MIT
*                  > dbo.SURGE_tblExperienceResult
*                  > dbo.SURGE_tblExperienceResult_MIT
*                  > dbo.SURGE_tblConversionv3
*                  > dbo.SURGE_tblConversionv3_MIT
*                  > dbo.SURGE_tblDeposit
*                  > dbo.SURGE_tblDeposit_MIT
*                  > dbo.SURGE_tblFreeGamev3
*                  > dbo.SURGE_tblFreeGamev3_MIT
*                  > dbo.SURGE_tblOieRewardResult
*                  > dbo.SURGE_tblOieRewardResult_MIT
*                  > dbo.SURGE_tblOptinv3
*                  > dbo.SURGE_tblOptinv3_MIT
*                  > dbo.SURGE_tblOptinCancel
*                  > dbo.SURGE_tblOptinCancel_MIT
*            : 3 > PEXBalanceUpdate (DONE)
*                  > dbo.PEX_tblBalanceUpdate
*                  > dbo.PEX_tblBalanceUpdate_MIT
*            : 4 > PEXRewardType (DONE)
*                  > dbo.PEX_lupRewardType
*                  > dbo.PEX_lupRewardType_MIT
*            : 5 > TournamenList (DONE)
*                  > dbo.SURGE_tblTournamentSetup
*                  > dbo.SURGE_tblTournamentSetup_MIT
*            : 6 > TournamentSummary (DONE)
*                  > dbo.Surge_tblTournamentReport_MIT
*                  > dbo.Surge_tblTournamentReport_MLT
*            : 7 > TournamentWager (DONE)
*                  > dbo.SURGE_tblTournamentWager
*                  > dbo.SURGE_tblTournamentWager_MIT
*            : 8 > RMMTracking (DONE)
*                  > dbo.SURGE_tblRmmTracking
*                  > dbo.SURGE_tblRmmTracking_MIT
*            : 9 > TriggeringWager (DONE)
*                  > dbo.SURGE_tblTriggeringWager
*                  > dbo.SURGE_tblTriggeringWager_MIT
*            :10 > VPBActionTrigger (DONE)
*                  > dbo.SURGE_tblVpbActionTrigger
*                  > dbo.SURGE_tblVpbActionTrigger_MIT
*            :11 > RCMReport (DONE)
*                  > dbo.SURGE_tblRcmReport
*                  > dbo.SURGE_tblRcmReport_MIT
************************************************************************
* dbDWAlignment
************************************************************************
*            :12 > Currency (DONE)
*                  > dbo.dimCurrency
*            :13 > CurrencyConversion (DONE)
*                  > dbo.factCurrencyConversion
************************************************************************
* dbReportingResource
************************************************************************
*            :14 > TournamentPlayer (DONE)
*                  > dbo.SURGE_tblTournamentEligibleUser
*                  > dbo.SURGE_tblTournamentEligibleUser_MIT
*            :15 > PlayerBonusCredit (DONE)
*                  > dbo.SURGE_tblPlayerBonusCredit
*                  > dbo.SURGE_tblPlayerBonusCredit_MIT
*            :15 > TriggeringCondition (DONE)
*                  > dbo.SURGE_tblTriggerConditionsMet
*                  > dbo.SURGE_tblTriggerConditionsMet_MIT
************************************************************************/
USE [dbReportingResource]
GO


----------------------- DROPS --------------------------------
/*
  DROP TABLE IF EXISTS [dbo].[SURGE_tblRegistration];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblRegistration_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOfferDetails];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOfferDetails_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblPlayerIncentive];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblPlayerIncentive_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblEligibility];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblEligibility_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblAcquisitionCompletedOffers];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblAcquisitionCompletedOffers_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblExperienceResult];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblExperienceResult_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblConversionv3];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblConversionv3_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblDeposit];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblDeposit_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblFreeGamev3];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblFreeGamev3_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOieRewardResult];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOieRewardResult_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOptinv3];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOptinv3_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOptinCancel];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblOptinCancel_MIT];
  DROP TABLE IF EXISTS [dbo].[PEX_tblBalanceUpdate];
  DROP TABLE IF EXISTS [dbo].[PEX_tblBalanceUpdate_MIT];
  DROP TABLE IF EXISTS [dbo].[PEX_lupRewardType];
  DROP TABLE IF EXISTS [dbo].[PEX_lupRewardType_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTournamentSetup];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTournamentSetup_MIT];
  DROP TABLE IF EXISTS [dbo].[Surge_tblTournamentReport_MIT];
  DROP TABLE IF EXISTS [dbo].[Surge_tblTournamentReport_MLT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTournamentWager];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTournamentWager_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblRmmTracking];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblRmmTracking_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTriggeringWager];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTriggeringWager_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblVpbActionTrigger];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblVpbActionTrigger_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblRcmReport];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblRcmReport_MIT];
  DROP TABLE IF EXISTS [dbo].[dimCurrency];
  DROP TABLE IF EXISTS [dbo].[factCurrencyConversion];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTournamentEligibleUser];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTournamentEligibleUser_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblPlayerBonusCredit];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblPlayerBonusCredit_MIT];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTriggerConditionsMet];
  DROP TABLE IF EXISTS [dbo].[SURGE_tblTriggerConditionsMet_MIT];

  DROP SCHEMA [Dummy];
*/
----------------------- CREATES --------------------------------

--CREATE SCHEMA [Dummy]
--  AUTHORIZATION dbo;
--GO

---------------------------
-- 1 > PlayerRegistration
---------------------------
GO
CREATE TABLE [dbo].[SURGE_tblRegistration](
	[gamingSystemId] [bigint] NULL,
	[sessionId] [bigint] NULL,
	[sessionProductId] [bigint] NULL,
	[productId] [bigint] NULL,
	[userName] [varchar](max) NULL,
	[userId] [bigint] NULL,
	[brandName] [varchar](max) NULL,
	[ipAddress] [varchar](max) NULL,
	[ipCountryLongCode] [varchar](max) NULL,
	[stateShortCode] [varchar](max) NULL,
	[currencyIsoCode] [varchar](max) NULL,
	[playerTypeId] [bigint] NULL,
	[utcEventTime] [varchar](max) NULL,
	[ticksEventTime] [bigint] NULL,
	[operatorId] [bigint] NULL,
	[eventTime] [datetime] NULL,
	[RegistrationID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblRegistrationNEW] PRIMARY KEY CLUSTERED 
(
	[RegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SURGE_tblRegistration] ADD  CONSTRAINT [DF__tblRegist__Inser__4B973090]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

CREATE TABLE [dbo].[SURGE_tblRegistration_MIT](
	[gamingSystemId] [bigint] NULL,
	[sessionId] [bigint] NULL,
	[sessionProductId] [bigint] NULL,
	[productId] [bigint] NULL,
	[userName] [varchar](max) NULL,
	[userId] [bigint] NULL,
	[brandName] [varchar](max) NULL,
	[ipAddress] [varchar](max) NULL,
	[ipCountryLongCode] [varchar](max) NULL,
	[stateShortCode] [varchar](max) NULL,
	[currencyIsoCode] [varchar](max) NULL,
	[playerTypeId] [bigint] NULL,
	[utcEventTime] [varchar](max) NULL,
	[ticksEventTime] [bigint] NULL,
	[operatorId] [bigint] NULL,
	[eventTime] [datetime] NULL,
	[RegistrationID] [bigint] NOT NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SURGE_tblRegistration_MIT] PRIMARY KEY CLUSTERED 
(
	[RegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO
---------------------------
-- 2 > OfferDetails
---------------------------

/****** Object:  Table [dbo].[SURGE_tblAcquisitionCompletedOffers]    Script Date: 7/27/2021 1:50:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblAcquisitionCompletedOffers](
	[Id] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[SessionProductId] [int] NOT NULL,
	[GamingSystemId] [int] NULL,
	[RegistrationDate] [datetime] NULL,
	[CompletionReason] [nvarchar](500) NULL,
	[TotalConversions] [int] NOT NULL,
	[CompletetionDate] [datetime] NULL,
	[TotalDeposits] [int] NOT NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_ID11111] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblAcquisitionCompletedOffers_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblAcquisitionCompletedOffers_MIT](
	[Id] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[SessionProductId] [int] NOT NULL,
	[GamingSystemId] [int] NULL,
	[RegistrationDate] [datetime] NULL,
	[CompletionReason] [nvarchar](500) NULL,
	[TotalConversions] [int] NOT NULL,
	[CompletetionDate] [datetime] NULL,
	[TotalDeposits] [int] NOT NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_ID1111] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblConversionv3]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblConversionv3](
	[ConversionId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[PromoType] [varchar](200) NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[ProductId] [int] NULL,
	[CurrencyCouponValue] [float] NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[InitialBalance] [float] NULL,
	[DepositAmount] [money] NULL,
	[DepositDateTime] [datetime] NULL,
	[BonusAmount] [money] NULL,
	[ReloadCount] [int] NULL,
	[ReloadMaxReached] [bit] NULL,
	[ExpireOn] [datetime] NULL,
	[ApplicationOn] [datetime] NULL,
	[PlayerExperienceSeries] [varchar](max) NULL,
	[CurrencyCode] [varchar](200) NULL,
	[CountryLongCode] [varchar](50) NULL,
	[SessionProductId] [int] NULL,
	[TriggeredOn] [datetime] NULL,
	[TriggerId] [varchar](max) NULL,
	[InsertedDateTime] [datetime] NULL,
	[DepositTicksEventTime] [bigint] NULL,
 CONSTRAINT [PK_tblConversionv3] PRIMARY KEY CLUSTERED 
(
	[ConversionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblConversionv3_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblConversionv3_MIT](
	[ConversionId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[PromoType] [varchar](200) NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[ProductId] [int] NULL,
	[CurrencyCouponValue] [float] NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[InitialBalance] [float] NULL,
	[DepositAmount] [money] NULL,
	[DepositDateTime] [datetime] NULL,
	[BonusAmount] [money] NULL,
	[ReloadCount] [int] NULL,
	[ReloadMaxReached] [bit] NULL,
	[ExpireOn] [datetime] NULL,
	[ApplicationOn] [datetime] NULL,
	[PlayerExperienceSeries] [varchar](max) NULL,
	[CurrencyCode] [varchar](200) NULL,
	[CountryLongCode] [varchar](50) NULL,
	[SessionProductId] [int] NULL,
	[TriggeredOn] [datetime] NULL,
	[TriggerId] [varchar](max) NULL,
	[InsertedDateTime] [datetime] NULL,
	[DepositTicksEventTime] [bigint] NULL,
 CONSTRAINT [PK_SURGE_tblConversionv3_MIT] PRIMARY KEY CLUSTERED 
(
	[ConversionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblDeposit]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblDeposit](
	[gamingSystemId] [bigint] NULL,
	[userName] [varchar](max) NULL,
	[userId] [bigint] NULL,
	[productId] [bigint] NULL,
	[sessionProductId] [bigint] NULL,
	[sessionId] [bigint] NULL,
	[currencyIsoCode] [varchar](max) NULL,
	[operatorCurrencyIsoCode] [varchar](max) NULL,
	[playerToOperatorExchangeRate] [money] NULL,
	[depositAmount] [money] NULL,
	[depositType] [varchar](max) NULL,
	[depositMethod] [varchar](max) NULL,
	[balanceAfterDeposit] [money] NULL,
	[isSuccess] [bigint] NULL,
	[ticksEventTime] [bigint] NULL,
	[eventTime] [datetime] NULL,
	[operatorId] [int] NULL,
	[DepositID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[utcEventTime] [varchar](max) NULL,
	[gatewayId] [bigint] NULL,
	[gatewayName] [varchar](255) NULL,
	[countryLongCode] [varchar](100) NULL,
	[languageCode] [varchar](20) NULL,
	[sessionCountryLongCode] [varchar](100) NULL,
	[sessionLanguageCode] [varchar](20) NULL,
	[numDepositsTotal] [float] NULL,
	[totalDepositsAmount] [float] NULL,
	[transactionId] [bigint] NULL,
	[transactionStatus] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblDepositNEW] PRIMARY KEY CLUSTERED 
(
	[DepositID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblDeposit_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblDeposit_MIT](
	[gamingSystemId] [bigint] NULL,
	[userName] [varchar](max) NULL,
	[userId] [bigint] NULL,
	[productId] [bigint] NULL,
	[sessionProductId] [bigint] NULL,
	[sessionId] [bigint] NULL,
	[currencyIsoCode] [varchar](max) NULL,
	[operatorCurrencyIsoCode] [varchar](max) NULL,
	[playerToOperatorExchangeRate] [money] NULL,
	[depositAmount] [money] NULL,
	[depositType] [varchar](max) NULL,
	[depositMethod] [varchar](max) NULL,
	[balanceAfterDeposit] [money] NULL,
	[isSuccess] [bigint] NULL,
	[ticksEventTime] [bigint] NULL,
	[eventTime] [datetime] NULL,
	[operatorId] [int] NULL,
	[DepositID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[utcEventTime] [varchar](max) NULL,
	[gatewayId] [bigint] NULL,
	[gatewayName] [varchar](255) NULL,
	[countryLongCode] [varchar](100) NULL,
	[languageCode] [varchar](20) NULL,
	[sessionCountryLongCode] [varchar](100) NULL,
	[sessionLanguageCode] [varchar](20) NULL,
	[numDepositsTotal] [float] NULL,
	[totalDepositsAmount] [float] NULL,
	[transactionId] [bigint] NULL,
	[transactionStatus] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SURGE_tblDeposit_MIT7] PRIMARY KEY CLUSTERED 
(
	[DepositID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblEligibility]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblEligibility](
	[EligibilityId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[ProductType] [varchar](max) NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[CreateDateTime] [datetime] NULL,
	[PromoType] [varchar](200) NULL,
	[AutoOptin] [bit] NULL,
	[TierCount] [int] NULL,
	[ProductId] [int] NULL,
	[PromoGuid] [varchar](max) NULL,
	[TriggeredOn] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
	[EligibilityGuid] [varchar](50) NULL,
	[PromoName] [varchar](100) NULL,
 CONSTRAINT [PK_tblEligibility] PRIMARY KEY CLUSTERED 
(
	[EligibilityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblEligibility_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblEligibility_MIT](
	[EligibilityId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[ProductType] [varchar](max) NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[CreateDateTime] [datetime] NULL,
	[PromoType] [varchar](200) NULL,
	[AutoOptin] [bit] NULL,
	[TierCount] [int] NULL,
	[ProductId] [int] NULL,
	[PromoGuid] [varchar](max) NULL,
	[TriggeredOn] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
	[EligibilityGuid] [varchar](50) NULL,
	[PromoName] [varchar](100) NULL,
 CONSTRAINT [PK_SURGE_tblEligibility_MIT] PRIMARY KEY CLUSTERED 
(
	[EligibilityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblExperienceResult]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblExperienceResult](
	[ExperienceResultId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CalculatedOn] [datetime] NULL,
	[PlayerKey] [int] NULL,
	[CustomerKey] [int] NULL,
	[AbTestGroup] [varchar](max) NULL,
	[AbTestFactor] [float] NULL,
	[BetSizeToBankRoll] [float] NULL,
	[BankRoll] [float] NULL,
	[MaxBankRoll] [float] NULL,
	[NetWin] [float] NULL,
	[GrossWin] [float] NULL,
	[GrossMargin] [float] NULL,
	[Nci] [float] NULL,
	[SubsidisedMargin] [float] NULL,
	[ExpectedSubsidisedMargin] [float] NULL,
	[NetMargin] [float] NULL,
	[ExpectedNetMargin] [float] NULL,
	[RequiredSubsidisedMargin] [float] NULL,
	[RequiredNci] [float] NULL,
	[NciShortfall] [float] NULL,
	[NciBump] [float] NULL,
	[PlayThroughPenalty] [float] NULL,
	[PlayerGroupBehaviour] [varchar](max) NULL,
	[PercentageScoreCasino] [float] NULL,
	[CouponScoreCasino] [float] NULL,
	[WagerAmount] [float] NULL,
	[PayoutAmount] [float] NULL,
	[DepositAmount] [float] NULL,
	[WagerCount] [float] NULL,
	[AveBetSize] [float] NULL,
	[DepositCount] [float] NULL,
	[CouponAdjustmentFactor] [float] NULL,
	[BreakageFactor] [float] NULL,
	[MinCouponAdjustmentFactor] [float] NULL,
	[AdjustedPercentageScoreCasino] [float] NULL,
	[AdjustedCouponScoreCasino] [float] NULL,
	[PercentageMatch] [float] NULL,
	[CouponScore] [float] NULL,
	[TheoIncome] [float] NULL,
	[TheoGrossMargin] [float] NULL,
	[TheoGrossWin] [float] NULL,
	[TheoPlayThrough] [float] NULL,
	[PlayThrough] [float] NULL,
	[ExcitementBand] [varchar](max) NULL,
	[Hits] [int] NULL,
	[HitRate] [float] NULL,
	[StdDevPayoutAmount] [float] NULL,
	[VariancePayoutAmount] [float] NULL,
	[StdDevWagers] [float] NULL,
	[VarianceWagers] [float] NULL,
	[NumBumpUps] [int] NULL,
	[NumReloads] [int] NULL,
	[PlayerExperienceSeries] [varchar](max) NULL,
	[PlayerExperience] [varchar](max) NULL,
	[BinaryValue] [int] NULL,
	[MaxBumpsReached] [bit] NULL,
	[ValueSegment] [varchar](max) NULL,
	[RewardType] [varchar](max) NULL,
	[TriggerType] [varchar](max) NULL,
	[RowVer] [int] NULL,
	[ExperienceFactor] [float] NULL,
	[BinSum] [int] NULL,
	[OfferGuid] [varchar](max) NULL,
	[GamingSystemId] [int] NULL,
	[PromoGuid] [varchar](max) NULL,
	[UserId] [int] NULL,
	[InsertedDateTime] [datetime] NULL,
	[TimeOnDeviceCategory] [varchar](20) NULL,
	[NCI2Purchase] [float] NULL,
	[AdjustedPercentageSource] [varchar](64) NULL,
 CONSTRAINT [PK_SURGE_tblExperienceResult] PRIMARY KEY CLUSTERED 
(
	[ExperienceResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblExperienceResult_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblExperienceResult_MIT](
	[ExperienceResultId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CalculatedOn] [datetime] NULL,
	[PlayerKey] [int] NULL,
	[CustomerKey] [int] NULL,
	[AbTestGroup] [varchar](max) NULL,
	[AbTestFactor] [float] NULL,
	[BetSizeToBankRoll] [float] NULL,
	[BankRoll] [float] NULL,
	[MaxBankRoll] [float] NULL,
	[NetWin] [float] NULL,
	[GrossWin] [float] NULL,
	[GrossMargin] [float] NULL,
	[Nci] [float] NULL,
	[SubsidisedMargin] [float] NULL,
	[ExpectedSubsidisedMargin] [float] NULL,
	[NetMargin] [float] NULL,
	[ExpectedNetMargin] [float] NULL,
	[RequiredSubsidisedMargin] [float] NULL,
	[RequiredNci] [float] NULL,
	[NciShortfall] [float] NULL,
	[NciBump] [float] NULL,
	[PlayThroughPenalty] [float] NULL,
	[PlayerGroupBehaviour] [varchar](max) NULL,
	[PercentageScoreCasino] [float] NULL,
	[CouponScoreCasino] [float] NULL,
	[WagerAmount] [float] NULL,
	[PayoutAmount] [float] NULL,
	[DepositAmount] [float] NULL,
	[WagerCount] [float] NULL,
	[AveBetSize] [float] NULL,
	[DepositCount] [float] NULL,
	[CouponAdjustmentFactor] [float] NULL,
	[BreakageFactor] [float] NULL,
	[MinCouponAdjustmentFactor] [float] NULL,
	[AdjustedPercentageScoreCasino] [float] NULL,
	[AdjustedCouponScoreCasino] [float] NULL,
	[PercentageMatch] [float] NULL,
	[CouponScore] [float] NULL,
	[TheoIncome] [float] NULL,
	[TheoGrossMargin] [float] NULL,
	[TheoGrossWin] [float] NULL,
	[TheoPlayThrough] [float] NULL,
	[PlayThrough] [float] NULL,
	[ExcitementBand] [varchar](max) NULL,
	[Hits] [int] NULL,
	[HitRate] [float] NULL,
	[StdDevPayoutAmount] [float] NULL,
	[VariancePayoutAmount] [float] NULL,
	[StdDevWagers] [float] NULL,
	[VarianceWagers] [float] NULL,
	[NumBumpUps] [int] NULL,
	[NumReloads] [int] NULL,
	[PlayerExperienceSeries] [varchar](max) NULL,
	[PlayerExperience] [varchar](max) NULL,
	[BinaryValue] [int] NULL,
	[MaxBumpsReached] [bit] NULL,
	[ValueSegment] [varchar](max) NULL,
	[RewardType] [varchar](max) NULL,
	[TriggerType] [varchar](max) NULL,
	[RowVer] [int] NULL,
	[ExperienceFactor] [float] NULL,
	[BinSum] [int] NULL,
	[OfferGuid] [varchar](max) NULL,
	[GamingSystemId] [int] NULL,
	[PromoGuid] [varchar](max) NULL,
	[UserId] [int] NULL,
	[InsertedDateTime] [datetime] NULL,
	[TimeOnDeviceCategory] [varchar](20) NULL,
	[NCI2Purchase] [float] NULL,
	[AdjustedPercentageSource] [varchar](64) NULL,
 CONSTRAINT [PK_tblExperienceResult] PRIMARY KEY CLUSTERED 
(
	[ExperienceResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblFreeGamev3]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblFreeGamev3](
	[FreeId] [int] NOT NULL,
	[Spins] [int] NULL,
	[FreeGameName] [varchar](max) NULL,
	[FreeGameId] [int] NULL,
	[FreeGameGuid] [varchar](50) NULL,
	[Trigger] [varchar](max) NULL,
	[OfferGuid] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
	[UserId] [int] NULL,
	[PromoGuid] [varchar](255) NULL,
	[GamingSystemId] [int] NULL,
	[PromoType] [varchar](50) NULL,
 CONSTRAINT [PK_tblFreeGamev3] PRIMARY KEY CLUSTERED 
(
	[FreeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblFreeGamev3_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblFreeGamev3_MIT](
	[FreeId] [int] NOT NULL,
	[Spins] [int] NULL,
	[FreeGameName] [varchar](max) NULL,
	[FreeGameId] [int] NULL,
	[FreeGameGuid] [varchar](50) NULL,
	[Trigger] [varchar](max) NULL,
	[OfferGuid] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
	[UserId] [int] NULL,
	[PromoGuid] [varchar](255) NULL,
	[GamingSystemId] [int] NULL,
	[PromoType] [varchar](50) NULL,
 CONSTRAINT [PK_tblFreeGamev3_MIT] PRIMARY KEY CLUSTERED 
(
	[FreeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOfferDetails]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOfferDetails](
	[OfferDetailsId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PromoGuid] [varchar](50) NULL,
	[TierGuid] [varchar](50) NULL,
	[RewardType] [varchar](20) NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[FreeSpins] [float] NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[InsertedDateTime] [datetime] NULL,
	[MinDeposit] [float] NULL,
	[TierIndex] [int] NULL,
	[EligibilityGuid] [varchar](50) NULL,
 CONSTRAINT [PK_tblOfferDetails] PRIMARY KEY CLUSTERED 
(
	[OfferDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOfferDetails_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOfferDetails_MIT](
	[OfferDetailsId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PromoGuid] [varchar](50) NULL,
	[TierGuid] [varchar](50) NULL,
	[RewardType] [varchar](20) NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[FreeSpins] [float] NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[InsertedDateTime] [datetime] NULL,
	[MinDeposit] [float] NULL,
	[TierIndex] [int] NULL,
	[EligibilityGuid] [varchar](50) NULL,
 CONSTRAINT [PK_SURGE_tblOfferDetails_MIT] PRIMARY KEY CLUSTERED 
(
	[OfferDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOieRewardResult]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOieRewardResult](
	[OieRewardResultId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ActionResult] [varchar](max) NULL,
	[CallDuration] [varchar](max) NULL,
	[OieId] [int] NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[PlayerKey] [int] NULL,
	[ReloadCount] [int] NULL,
	[RewardType] [varchar](max) NULL,
	[PromoType] [varchar](max) NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[CalledOnUtc] [datetime] NULL,
	[OieTrackingGuid] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
	[SessionProductId] [int] NULL,
 CONSTRAINT [PK_tblOieRewardResult] PRIMARY KEY CLUSTERED 
(
	[OieRewardResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOieRewardResult_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOieRewardResult_MIT](
	[OieRewardResultId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ActionResult] [varchar](max) NULL,
	[CallDuration] [varchar](max) NULL,
	[OieId] [int] NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[PlayerKey] [int] NULL,
	[ReloadCount] [int] NULL,
	[RewardType] [varchar](max) NULL,
	[PromoType] [varchar](max) NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[CalledOnUtc] [datetime] NULL,
	[OieTrackingGuid] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
	[SessionProductId] [int] NULL,
 CONSTRAINT [PK_tblOieRewardResult_MIT] PRIMARY KEY CLUSTERED 
(
	[OieRewardResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOptinCancel]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOptinCancel](
	[OptinCancelId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PromoGuid] [varchar](50) NULL,
	[PromoType] [varchar](20) NULL,
	[EndDateTime] [datetime] NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[PlayerId] [int] NULL,
	[GamingServerId] [int] NULL,
	[SessionProductId] [int] NULL,
	[CurrentTier] [int] NULL,
	[MaxTiers] [int] NULL,
	[CurrencyCouponValue] [int] NULL,
	[InsertedDateTime] [datetime] NULL,
	[OfferGuid] [varchar](max) NULL,
 CONSTRAINT [PK_tblOptinCancel] PRIMARY KEY CLUSTERED 
(
	[OptinCancelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOptinCancel_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOptinCancel_MIT](
	[OptinCancelId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PromoGuid] [varchar](50) NULL,
	[PromoType] [varchar](20) NULL,
	[EndDateTime] [datetime] NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[PlayerId] [int] NULL,
	[GamingServerId] [int] NULL,
	[SessionProductId] [int] NULL,
	[CurrentTier] [int] NULL,
	[MaxTiers] [int] NULL,
	[CurrencyCouponValue] [int] NULL,
	[InsertedDateTime] [datetime] NULL,
	[OfferGuid] [varchar](max) NULL,
 CONSTRAINT [PK_SURGE_tblOptinCancel_MIT] PRIMARY KEY CLUSTERED 
(
	[OptinCancelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOptinv3]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOptinv3](
	[Optinv3Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[PromoType] [varchar](200) NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[PlayerId] [int] NULL,
	[GamingServerId] [int] NULL,
	[SessionProductId] [int] NULL,
	[CurrentTier] [int] NULL,
	[MaxTiers] [int] NULL,
	[CurrencyCouponValue] [int] NULL,
	[EndDateTime] [datetime] NULL,
	[ApplicationDate] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblOptinv3] PRIMARY KEY CLUSTERED 
(
	[Optinv3Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblOptinv3_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblOptinv3_MIT](
	[Optinv3Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[PromoType] [varchar](200) NULL,
	[Coupon] [float] NULL,
	[Percentage] [float] NULL,
	[PlayerId] [int] NULL,
	[GamingServerId] [int] NULL,
	[SessionProductId] [int] NULL,
	[CurrentTier] [int] NULL,
	[MaxTiers] [int] NULL,
	[CurrencyCouponValue] [int] NULL,
	[EndDateTime] [datetime] NULL,
	[ApplicationDate] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SURGE_tblOptinv3_MIT] PRIMARY KEY CLUSTERED 
(
	[Optinv3Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblPlayerIncentive]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblPlayerIncentive](
	[PlayerIncentiveId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CustomerKey] [int] NULL,
	[GamingSystemId] [int] NULL,
	[PlayerKey] [int] NULL,
	[SessionProductId] [int] NULL,
	[UserId] [int] NULL,
	[PromoGuid] [varchar](max) NULL,
	[OfferGuid] [varchar](max) NULL,
	[ReloadMax] [int] NULL,
	[ReloadCount] [int] NULL,
	[SessionEndDateTime] [datetime] NULL,
	[RewardType] [varchar](max) NULL,
	[ValueSegment] [varchar](max) NULL,
	[ScenarioVersion] [varchar](max) NULL,
	[CalculationVersion] [varchar](max) NULL,
	[RewardDateTime] [datetime] NULL,
	[CouponValue] [float] NULL,
	[PromoType] [varchar](max) NULL,
	[PercentageMatch] [float] NULL,
	[BinSum] [int] NULL,
	[FreeSpinsValue] [float] NULL,
	[InsertedDateTime] [datetime] NULL,
	[LevelFreeSpinCoupon] [float] NULL,
 CONSTRAINT [PK_tblPlayerIncentive] PRIMARY KEY CLUSTERED 
(
	[PlayerIncentiveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblPlayerIncentive_MIT]    Script Date: 7/27/2021 1:50:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblPlayerIncentive_MIT](
	[PlayerIncentiveId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CustomerKey] [int] NULL,
	[GamingSystemId] [int] NULL,
	[PlayerKey] [int] NULL,
	[SessionProductId] [int] NULL,
	[UserId] [int] NULL,
	[PromoGuid] [varchar](max) NULL,
	[OfferGuid] [varchar](max) NULL,
	[ReloadMax] [int] NULL,
	[ReloadCount] [int] NULL,
	[SessionEndDateTime] [datetime] NULL,
	[RewardType] [varchar](max) NULL,
	[ValueSegment] [varchar](max) NULL,
	[ScenarioVersion] [varchar](max) NULL,
	[CalculationVersion] [varchar](max) NULL,
	[RewardDateTime] [datetime] NULL,
	[CouponValue] [float] NULL,
	[PromoType] [varchar](max) NULL,
	[PercentageMatch] [float] NULL,
	[BinSum] [int] NULL,
	[FreeSpinsValue] [float] NULL,
	[InsertedDateTime] [datetime] NULL,
	[LevelFreeSpinCoupon] [float] NULL,
 CONSTRAINT [PK_tblPlayerIncentive_MIT] PRIMARY KEY CLUSTERED 
(
	[PlayerIncentiveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SURGE_tblConversionv3] ADD  CONSTRAINT [DF__tblConver__Inser__0BB1B5A5]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblConversionv3_MIT] ADD  CONSTRAINT [DF__tblConver__Inser__038683F8]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblDeposit] ADD  CONSTRAINT [DF__tblDeposi__Inser__0E8E2250]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblDeposit_MIT] ADD  CONSTRAINT [DF__tblDeposi__Inser__0662F0A3]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblEligibility] ADD  CONSTRAINT [DF__tblEligib__Inser__2759D01A]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblEligibility_MIT] ADD  CONSTRAINT [DF__tblEligib__Inser__178D7CA5]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblExperienceResult] ADD  CONSTRAINT [DF__tblExperi__Inser__2A363CC5]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblExperienceResult_MIT] ADD  CONSTRAINT [DF__tblExperi__Inser__1A69E950]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblFreeGamev3] ADD  CONSTRAINT [DF__tblFreeGa__Inser__33BFA6FF]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblFreeGamev3_MIT] ADD  CONSTRAINT [DF__tblFreeGa__Inser__23F3538A]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblOieRewardResult] ADD  CONSTRAINT [DF__tblOieRew__Inser__6C390A4C]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblOieRewardResult_MIT] ADD  CONSTRAINT [DF__tblOieRew__Inser__6D9742D9]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblOptinv3] ADD  CONSTRAINT [DF__tblOptinv__Inser__40257DE4]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblOptinv3_MIT] ADD  CONSTRAINT [DF__tblOptinv__Inser__30592A6F]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblPlayerIncentive] ADD  CONSTRAINT [DF__tblPlayer__Inser__47C69FAC]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblPlayerIncentive_MIT] ADD  CONSTRAINT [DF__tblPlayer__Inser__37FA4C37]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO



---------------------------
-- 3 > PEXBalanceUpdate
---------------------------
/****** Object:  Table [dbo].[PEX_tblBalanceUpdate]    Script Date: 7/27/2021 3:43:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PEX_tblBalanceUpdate](
	[GamingSystemId] [bigint] NULL,
	[UserName] [varchar](max) NULL,
	[UserId] [bigint] NULL,
	[ProductId] [bigint] NULL,
	[SessionProductId] [bigint] NULL,
	[SessionId] [bigint] NULL,
	[SessionGuid] [varchar](max) NULL,
	[CurrencyIsoCode] [varchar](max) NULL,
	[OperatorCurrencyIsoCode] [varchar](max) NULL,
	[PlayerToOperatorExchangeRate] [money] NULL,
	[ModuleId] [bigint] NULL,
	[ModuleName] [varchar](max) NULL,
	[AdminEventId] [bigint] NULL,
	[AdminEvent] [varchar](max) NULL,
	[AdminEventTypeId] [bigint] NULL,
	[AdminEventType] [varchar](max) NULL,
	[BalanceTypeId] [bigint] NULL,
	[BalanceType] [varchar](max) NULL,
	[ChangeAmount] [money] NULL,
	[AdminEventTransactionNumber] [bigint] NULL,
	[CashBalanceAfterEvent] [money] NULL,
	[BonusBalanceAfterEvent] [money] NULL,
	[BalanceAfterLastPositiveChange] [money] NULL,
	[IsBonusEvent] [bigint] NULL,
	[UtcEventTime] [varchar](max) NULL,
	[TicksEventTime] [bigint] NULL,
	[CountryLongCode] [varchar](max) NULL,
	[LanguageCode] [varchar](max) NULL,
	[SessionCountryLongCode] [varchar](max) NULL,
	[SessionLanguageCode] [varchar](max) NULL,
	[OperatorId] [bigint] NULL,
	[eventTime] [datetime] NULL,
	[BalanceUpdateID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblBalanceUpdateNEW] PRIMARY KEY CLUSTERED 
(
	[BalanceUpdateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PEX_tblBalanceUpdate_MIT]    Script Date: 7/27/2021 3:43:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PEX_tblBalanceUpdate_MIT](
	[GamingSystemId] [bigint] NULL,
	[UserName] [varchar](max) NULL,
	[UserId] [bigint] NULL,
	[ProductId] [bigint] NULL,
	[SessionProductId] [bigint] NULL,
	[SessionId] [bigint] NULL,
	[SessionGuid] [varchar](max) NULL,
	[CurrencyIsoCode] [varchar](max) NULL,
	[OperatorCurrencyIsoCode] [varchar](max) NULL,
	[PlayerToOperatorExchangeRate] [money] NULL,
	[ModuleId] [bigint] NULL,
	[ModuleName] [varchar](max) NULL,
	[AdminEventId] [bigint] NULL,
	[AdminEvent] [varchar](max) NULL,
	[AdminEventTypeId] [bigint] NULL,
	[AdminEventType] [varchar](max) NULL,
	[BalanceTypeId] [bigint] NULL,
	[BalanceType] [varchar](max) NULL,
	[ChangeAmount] [money] NULL,
	[AdminEventTransactionNumber] [bigint] NULL,
	[CashBalanceAfterEvent] [money] NULL,
	[BonusBalanceAfterEvent] [money] NULL,
	[BalanceAfterLastPositiveChange] [money] NULL,
	[IsBonusEvent] [bigint] NULL,
	[UtcEventTime] [varchar](max) NULL,
	[TicksEventTime] [bigint] NULL,
	[CountryLongCode] [varchar](max) NULL,
	[LanguageCode] [varchar](max) NULL,
	[SessionCountryLongCode] [varchar](max) NULL,
	[SessionLanguageCode] [varchar](max) NULL,
	[OperatorId] [bigint] NULL,
	[eventTime] [datetime] NULL,
	[BalanceUpdateID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_PEX_tblBalanceUpdate_MIT] PRIMARY KEY CLUSTERED 
(
	[BalanceUpdateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[PEX_tblBalanceUpdate] ADD  CONSTRAINT [DF__tblBalanc__Inser__05F8DC4F]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[PEX_tblBalanceUpdate_MIT] ADD  CONSTRAINT [DF__tblBalanc__Inser__7DCDAAA2]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO
---------------------------
-- 4 > PEXRewardType
---------------------------
/****** Object:  Table [dbo].[PEX_lupRewardType]    Script Date: 7/27/2021 3:45:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PEX_lupRewardType](
	[RewardTypeId] [int] NOT NULL,
	[RewardType] [varchar](50) NOT NULL,
 CONSTRAINT [PK__lupRewar__4C9321598DC40B92] PRIMARY KEY CLUSTERED 
(
	[RewardTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PEX_lupRewardType_MIT]    Script Date: 7/27/2021 3:45:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PEX_lupRewardType_MIT](
	[RewardTypeId] [int] NOT NULL,
	[RewardType] [varchar](50) NOT NULL,
 CONSTRAINT [PK__lupRewar__4C932159C5534599] PRIMARY KEY CLUSTERED 
(
	[RewardTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
---------------------------
-- 5 > TournamenList
---------------------------
/****** Object:  Table [dbo].[SURGE_tblTournamentSetup]    Script Date: 7/27/2021 1:54:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTournamentSetup](
	[TournamentCreateId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentTemplateName] [varchar](100) NULL,
	[TournamentTemplateDescription] [varchar](max) NULL,
	[TournamentId] [int] NULL,
	[ProductId] [int] NULL,
	[MinNumberOfPlayers] [int] NULL,
	[MaxNumberOfPlayers] [int] NULL,
	[CurrencyIsoCode] [varchar](3) NULL,
	[CoinValue] [bigint] NULL,
	[TournamentStartUtcDateTime] [datetime] NULL,
	[TournamentEndUtcDateTime] [datetime] NULL,
	[StartNotificationOffSet] [int] NULL,
	[EndNotificationOffSet] [int] NULL,
	[ScheduledJobId] [varchar](50) NULL,
	[TournamentStatus] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
	[SurgeTournamentId] [int] NULL,
	[IsNetwork] [bit] NULL,
	[Operator] [varchar](50) NULL,
	[Region] [varchar](10) NULL,
	[GameName] [varchar](150) NULL,
 CONSTRAINT [PK_TournamentCreate1] PRIMARY KEY CLUSTERED 
(
	[TournamentCreateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblTournamentSetup_MIT]    Script Date: 7/27/2021 1:54:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTournamentSetup_MIT](
	[TournamentCreateId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentTemplateName] [varchar](100) NULL,
	[TournamentTemplateDescription] [varchar](max) NULL,
	[TournamentId] [int] NULL,
	[ProductId] [int] NULL,
	[MinNumberOfPlayers] [int] NULL,
	[MaxNumberOfPlayers] [int] NULL,
	[CurrencyIsoCode] [varchar](3) NULL,
	[CoinValue] [bigint] NULL,
	[TournamentStartUtcDateTime] [datetime] NULL,
	[TournamentEndUtcDateTime] [datetime] NULL,
	[StartNotificationOffSet] [int] NULL,
	[EndNotificationOffSet] [int] NULL,
	[ScheduledJobId] [varchar](50) NULL,
	[TournamentStatus] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
	[SurgeTournamentId] [int] NULL,
	[IsNetwork] [bit] NULL,
	[Operator] [varchar](50) NULL,
	[Region] [varchar](10) NULL,
	[GameName] [varchar](150) NULL,
 CONSTRAINT [PK_TournamentCreate] PRIMARY KEY CLUSTERED 
(
	[TournamentCreateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


---------------------------
-- 6 > TournamentSummary
---------------------------

/****** Object:  Table [dbo].[SURGE_tblTournamentReport_MIT]    Script Date: 7/27/2021 3:12:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTournamentReport_MIT](
	[tblTournamentReportId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentId] [int] NULL,
	[TournamentTemplateName] [varchar](100) NULL,
	[TournamentTemplateDescription] [varchar](250) NULL,
	[TournamentStatus] [varchar](150) NULL,
	[TournamentStartUtcDateTime] [datetime] NULL,
	[TournamentEndUtcDateTime] [datetime] NULL,
	[TakedownUtcDateTime] [datetime] NULL,
	[TournamentRegistrationUtcDateTime] [datetime] NULL,
	[TournamentCancelUtcDateTime] [datetime] NULL,
	[MinNumberOfPlayers] [int] NULL,
	[MaxNumberOfPlayers] [int] NULL,
	[PlayerScore] [decimal](18, 0) NULL,
	[LeaderBoardPosition] [int] NULL,
	[TournamentPrize] [varchar](150) NULL,
	[TournamentPrizeTemplateName] [varchar](500) NULL,
	[IsCompleteLeaderboard] [bit] NULL,
	[TournamentInvitedUtcDateTme] [datetime] NULL,
	[TournamentClaimUtcDateTme] [datetime] NULL,
	[TournamentRegisteredUtcDateTme] [datetime] NULL,
	[TournamentEligibleUtcDateTme] [datetime] NULL,
	[GamingSystemId] [int] NULL,
	[OfferProductId] [int] NULL,
	[ProductId] [int] NOT NULL,
	[SessionProductId] [int] NULL,
	[UserId] [int] NULL,
	[PlayerTournamentStatus] [varchar](100) NULL,
	[AutoOptin] [bit] NULL,
	[AutoOptinUtcDatetime] [datetime] NULL,
	[CurrencyIsoCode] [varchar](3) NULL,
	[PromoGuid] [varchar](40) NULL,
	[PromoName] [varchar](150) NULL,
	[PromoType] [varchar](50) NULL,
	[GameCleanedId] [int] NULL,
	[GameName] [varchar](150) NULL,
	[LanguageCode] [varchar](3) NULL,
	[EndNotificationOffSet] [int] NULL,
	[StartNotificationOffSet] [int] NULL,
	[TournamentCreateDateTime] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
	[Region] [varchar](10) NULL,
	[Operator] [varchar](5) NULL,
 CONSTRAINT [PK_tblTournamentReport_MIT] PRIMARY KEY CLUSTERED 
(
	[tblTournamentReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Surge_tblTournamentReport_MLT]    Script Date: 7/27/2021 3:12:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Surge_tblTournamentReport_MLT](
	[tblTournamentReportId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentId] [int] NULL,
	[TournamentTemplateName] [varchar](100) NULL,
	[TournamentTemplateDescription] [varchar](250) NULL,
	[TournamentStatus] [varchar](150) NULL,
	[TournamentStartUtcDateTime] [datetime] NULL,
	[TournamentEndUtcDateTime] [datetime] NULL,
	[TakedownUtcDateTime] [datetime] NULL,
	[TournamentRegistrationUtcDateTime] [datetime] NULL,
	[TournamentCancelUtcDateTime] [datetime] NULL,
	[MinNumberOfPlayers] [int] NULL,
	[MaxNumberOfPlayers] [int] NULL,
	[PlayerScore] [decimal](18, 0) NULL,
	[LeaderBoardPosition] [int] NULL,
	[TournamentPrize] [varchar](150) NULL,
	[TournamentPrizeTemplateName] [varchar](500) NULL,
	[IsCompleteLeaderboard] [bit] NULL,
	[TournamentInvitedUtcDateTme] [datetime] NULL,
	[TournamentClaimUtcDateTme] [datetime] NULL,
	[TournamentRegisteredUtcDateTme] [datetime] NULL,
	[TournamentEligibleUtcDateTme] [datetime] NULL,
	[GamingSystemId] [int] NULL,
	[OfferProductId] [int] NULL,
	[ProductId] [int] NOT NULL,
	[SessionProductId] [int] NULL,
	[UserId] [int] NULL,
	[PlayerTournamentStatus] [varchar](100) NULL,
	[AutoOptin] [bit] NULL,
	[AutoOptinUtcDatetime] [datetime] NULL,
	[CurrencyIsoCode] [varchar](3) NULL,
	[PromoGuid] [varchar](40) NULL,
	[PromoName] [varchar](150) NULL,
	[PromoType] [varchar](50) NULL,
	[GameCleanedId] [int] NULL,
	[GameName] [varchar](150) NULL,
	[LanguageCode] [varchar](3) NULL,
	[EndNotificationOffSet] [int] NULL,
	[StartNotificationOffSet] [int] NULL,
	[TournamentCreateDateTime] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
	[Region] [varchar](10) NULL,
	[Operator] [varchar](5) NULL,
 CONSTRAINT [PK_tblTournamentReportid] PRIMARY KEY CLUSTERED 
(
	[tblTournamentReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
---------------------------
-- 7 > TournamentWager
---------------------------
/****** Object:  Table [dbo].[SURGE_tblTournamentWager]    Script Date: 7/27/2021 3:20:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTournamentWager](
	[TournamentWagerId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentId] [int] NULL,
	[UtcEventTime] [datetime] NULL,
	[ProductId] [int] NULL,
	[ModuleId] [int] NULL,
	[ClientId] [int] NULL,
	[UserTransNumber] [int] NULL,
	[SessionGuid] [varchar](40) NULL,
	[CountryLongCode] [varchar](3) NULL,
	[WagerAmount] [float] NULL,
	[PayoutAmount] [float] NULL,
	[CashBalance] [float] NULL,
	[MinBetAmount] [float] NULL,
	[MaxBetAmount] [float] NULL,
	[TotalWagerAmount] [float] NULL,
	[TotalPayoutAmount] [float] NULL,
	[UserId] [int] NULL,
	[TournamentUtcEndDate] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
	[GamingSystemId] [int] NULL,
	[CalculatedMinBetAmount] [float] NULL,
 CONSTRAINT [PK_tblTournamentWager] PRIMARY KEY CLUSTERED 
(
	[TournamentWagerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[SURGE_tblTournamentWager_MIT]    Script Date: 7/27/2021 3:20:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTournamentWager_MIT](
	[TournamentWagerId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentId] [int] NULL,
	[UtcEventTime] [datetime] NULL,
	[ProductId] [int] NULL,
	[ModuleId] [int] NULL,
	[ClientId] [int] NULL,
	[UserTransNumber] [int] NULL,
	[SessionGuid] [varchar](40) NULL,
	[CountryLongCode] [varchar](3) NULL,
	[WagerAmount] [float] NULL,
	[PayoutAmount] [float] NULL,
	[CashBalance] [float] NULL,
	[MinBetAmount] [float] NULL,
	[MaxBetAmount] [float] NULL,
	[TotalWagerAmount] [float] NULL,
	[TotalPayoutAmount] [float] NULL,
	[UserId] [int] NULL,
	[TournamentUtcEndDate] [datetime] NULL,
	[InsertedDateTime] [datetime] NULL,
	[GamingSystemId] [int] NULL,
	[CalculatedMinBetAmount] [float] NULL,
 CONSTRAINT [PK_tblTournamentWager_MIT] PRIMARY KEY CLUSTERED 
(
	[TournamentWagerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


---------------------------
-- 8 > RMMTracking
---------------------------
/****** Object:  Table [dbo].[SURGE_tblRmmTracking]    Script Date: 7/27/2021 3:23:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblRmmTracking](
	[GamingSystemId] [bigint] NULL,
	[UserName] [varchar](max) NULL,
	[UserId] [bigint] NULL,
	[ProductId] [bigint] NULL,
	[SessionProductId] [bigint] NULL,
	[SessionId] [bigint] NULL,
	[SessionGuid] [varchar](max) NULL,
	[SessionClientTypeId] [bigint] NULL,
	[RmmMessageTransactionId] [bigint] NULL,
	[RmmMessageId] [bigint] NULL,
	[RmmActionTypeId] [bigint] NULL,
	[RmmActionType] [varchar](max) NULL,
	[RmmMessageGuid] [varchar](max) NULL,
	[UtcEventTime] [varchar](max) NULL,
	[TicksEventTime] [bigint] NULL,
	[CountryLongCode] [varchar](max) NULL,
	[LanguageCode] [varchar](max) NULL,
	[SessionCountryLongCode] [varchar](max) NULL,
	[SessionLanguageCode] [varchar](max) NULL,
	[OperatorId] [bigint] NULL,
	[EventTime] [datetime] NULL,
	[RmmTrackingID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[playerResponseTypeId] [bigint] NULL,
	[playerResponseType] [varchar](255) NULL,
	[RmmTrackingGUID] [varchar](40) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblRmmTrackingNEW] PRIMARY KEY CLUSTERED 
(
	[RmmTrackingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblRmmTracking_MIT]    Script Date: 7/27/2021 3:23:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblRmmTracking_MIT](
	[GamingSystemId] [bigint] NULL,
	[UserName] [varchar](max) NULL,
	[UserId] [bigint] NULL,
	[ProductId] [bigint] NULL,
	[SessionProductId] [bigint] NULL,
	[SessionId] [bigint] NULL,
	[SessionGuid] [varchar](max) NULL,
	[SessionClientTypeId] [bigint] NULL,
	[RmmMessageTransactionId] [bigint] NULL,
	[RmmMessageId] [bigint] NULL,
	[RmmActionTypeId] [bigint] NULL,
	[RmmActionType] [varchar](max) NULL,
	[RmmMessageGuid] [varchar](max) NULL,
	[UtcEventTime] [varchar](max) NULL,
	[TicksEventTime] [bigint] NULL,
	[CountryLongCode] [varchar](max) NULL,
	[LanguageCode] [varchar](max) NULL,
	[SessionCountryLongCode] [varchar](max) NULL,
	[SessionLanguageCode] [varchar](max) NULL,
	[OperatorId] [bigint] NULL,
	[EventTime] [datetime] NULL,
	[RmmTrackingID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[playerResponseTypeId] [bigint] NULL,
	[playerResponseType] [varchar](255) NULL,
	[RmmTrackingGUID] [varchar](40) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SURGE_tblRmmTracking_MIT] PRIMARY KEY CLUSTERED 
(
	[RmmTrackingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SURGE_tblRmmTracking] ADD  CONSTRAINT [DF__tblRmmTra__Inser__4E739D3B]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblRmmTracking_MIT] ADD  CONSTRAINT [DF__tblRmmTra__Inser__3DB3258D]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO
---------------------------
-- 9 > TriggeringWager
---------------------------
/****** Object:  Table [dbo].[SURGE_tblTriggeringWager]    Script Date: 7/27/2021 3:26:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTriggeringWager](
	[TriggeringWagerId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BalanceThresholdEventId] [varchar](max) NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[SessionProductId] [int] NULL,
	[ClientId] [int] NULL,
	[ModuleId] [int] NULL,
	[EventTime] [datetime] NULL,
	[TotalBalance] [float] NULL,
	[WagerAmount] [float] NULL,
	[PayoutAmount] [float] NULL,
	[CashBalance] [float] NULL,
	[BonusBalance] [float] NULL,
	[PlayerKey] [int] NULL,
	[CustomerKey] [int] NULL,
	[PlayerBehaviourGroup] [varchar](max) NULL,
	[TheoreticalPayoutPercentage] [float] NULL,
	[BalanceAfterLastPositiveChange] [float] NULL,
	[MgsUniqueGameName] [varchar](max) NULL,
	[UserTransnumber] [int] NULL,
	[SessionGuid] [varchar](max) NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblTriggeringWager] PRIMARY KEY CLUSTERED 
(
	[TriggeringWagerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblTriggeringWager_MIT]    Script Date: 7/27/2021 3:26:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblTriggeringWager_MIT](
	[TriggeringWagerId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BalanceThresholdEventId] [varchar](max) NULL,
	[UserId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[SessionProductId] [int] NULL,
	[ClientId] [int] NULL,
	[ModuleId] [int] NULL,
	[EventTime] [datetime] NULL,
	[TotalBalance] [float] NULL,
	[WagerAmount] [float] NULL,
	[PayoutAmount] [float] NULL,
	[CashBalance] [float] NULL,
	[BonusBalance] [float] NULL,
	[PlayerKey] [int] NULL,
	[CustomerKey] [int] NULL,
	[PlayerBehaviourGroup] [varchar](max) NULL,
	[TheoreticalPayoutPercentage] [float] NULL,
	[BalanceAfterLastPositiveChange] [float] NULL,
	[MgsUniqueGameName] [varchar](max) NULL,
	[UserTransnumber] [int] NULL,
	[SessionGuid] [varchar](max) NULL,
	[OfferGuid] [varchar](max) NULL,
	[PromoGuid] [varchar](max) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SURGE_tblTriggeringWager_MIT] PRIMARY KEY CLUSTERED 
(
	[TriggeringWagerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SURGE_tblTriggeringWager] ADD  CONSTRAINT [DF__tblTrigge__Inser__515009E6]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblTriggeringWager_MIT] ADD  CONSTRAINT [DF__tblTrigge__Inser__408F9238]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO
---------------------------
-- 10 > VPBActionTrigger
---------------------------
/****** Object:  Table [dbo].[SURGE_tblVpbActionTrigger]    Script Date: 7/27/2021 3:28:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblVpbActionTrigger](
	[vpbActionTriggerId] [bigint] NOT NULL,
	[gamingSystemId] [int] NULL,
	[userId] [int] NULL,
	[socketId] [int] NULL,
	[routerId] [int] NULL,
	[productId] [int] NULL,
	[sessionId] [bigint] NULL,
	[sessionGuid] [varchar](max) NULL,
	[sessionClientTypeId] [int] NULL,
	[sessionProductId] [int] NULL,
	[currencyIsoCode] [varchar](10) NULL,
	[operatorCurrencyIsoCode] [varchar](10) NULL,
	[playerToOperatorExchangeRate] [money] NULL,
	[playerGroups] [varchar](max) NULL,
	[utcEventTime] [varchar](32) NULL,
	[ticksEventTime] [bigint] NULL,
	[actionTriggerId] [int] NULL,
	[vpbRuleGuid] [varchar](max) NULL,
	[eventTypeId] [int] NULL,
	[eventTypeName] [varchar](255) NULL,
	[actionTypeId] [int] NULL,
	[actionTypeName] [varchar](255) NULL,
	[rmmMessageGuid] [varchar](max) NULL,
	[playerMovedGroup] [int] NULL,
	[depositAmount] [money] NULL,
	[awardAmount] [money] NULL,
	[operatorId] [int] NULL,
	[RmmTrackingGUID] [varchar](40) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblVpbActionTrigger_MIT]    Script Date: 7/27/2021 3:28:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblVpbActionTrigger_MIT](
	[vpbActionTriggerId] [bigint] NOT NULL,
	[gamingSystemId] [int] NULL,
	[userId] [int] NULL,
	[socketId] [int] NULL,
	[routerId] [int] NULL,
	[productId] [int] NULL,
	[sessionId] [bigint] NULL,
	[sessionGuid] [varchar](max) NULL,
	[sessionClientTypeId] [int] NULL,
	[sessionProductId] [int] NULL,
	[currencyIsoCode] [varchar](10) NULL,
	[operatorCurrencyIsoCode] [varchar](10) NULL,
	[playerToOperatorExchangeRate] [money] NULL,
	[playerGroups] [varchar](max) NULL,
	[utcEventTime] [varchar](32) NULL,
	[ticksEventTime] [bigint] NULL,
	[actionTriggerId] [int] NULL,
	[vpbRuleGuid] [varchar](max) NULL,
	[eventTypeId] [int] NULL,
	[eventTypeName] [varchar](255) NULL,
	[actionTypeId] [int] NULL,
	[actionTypeName] [varchar](255) NULL,
	[rmmMessageGuid] [varchar](max) NULL,
	[playerMovedGroup] [int] NULL,
	[depositAmount] [money] NULL,
	[awardAmount] [money] NULL,
	[operatorId] [int] NULL,
	[RmmTrackingGUID] [varchar](40) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_SURGE_tblVpbActionTrigger_MIT] PRIMARY KEY CLUSTERED 
(
	[vpbActionTriggerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SURGE_tblVpbActionTrigger] ADD  CONSTRAINT [DF__tblVpbAct__Inser__53385258]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO

ALTER TABLE [dbo].[SURGE_tblVpbActionTrigger_MIT] ADD  CONSTRAINT [DF__tblVpbAct__Inser__4277DAAA]  DEFAULT (getutcdate()) FOR [InsertedDateTime]
GO
---------------------------
-- 11 > RCMReport
---------------------------
/****** Object:  Table [dbo].[SURGE_tblRcmReport]    Script Date: 7/27/2021 3:29:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblRcmReport](
	[RcmReportId] [bigint] NOT NULL,
	[EventDateTime] [datetime2](7) NOT NULL,
	[TicksEventTime] [bigint] NOT NULL,
	[UserId] [bigint] NOT NULL,
	[SessionProductId] [int] NOT NULL,
	[GamingSystemId] [int] NULL,
	[MessageId] [uniqueidentifier] NOT NULL,
	[MessageStatusId] [int] NOT NULL,
	[MessageStatus] [char](50) NOT NULL,
	[PromoType] [char](20) NULL,
	[RewardType] [char](50) NULL,
	[LanguageCode] [char](3) NULL,
	[PromoGuid] [uniqueidentifier] NULL,
	[OfferGuid] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[RcmReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SURGE_tblRcmReport_MIT]    Script Date: 7/27/2021 3:29:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SURGE_tblRcmReport_MIT](
	[RcmReportId] [bigint] NOT NULL,
	[EventDateTime] [datetime2](7) NOT NULL,
	[TicksEventTime] [bigint] NOT NULL,
	[UserId] [bigint] NOT NULL,
	[SessionProductId] [int] NOT NULL,
	[GamingSystemId] [int] NULL,
	[MessageId] [uniqueidentifier] NOT NULL,
	[MessageStatusId] [int] NOT NULL,
	[MessageStatus] [char](50) NOT NULL,
	[PromoType] [char](20) NULL,
	[RewardType] [char](50) NULL,
	[LanguageCode] [char](3) NULL,
	[PromoGuid] [uniqueidentifier] NULL,
	[OfferGuid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_SURGE_tblRcmReport_MIT] PRIMARY KEY CLUSTERED 
(
	[RcmReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
---------------------------
-- 12 > Currency
---------------------------
/****** Object:  Table [dbo].[dimCurrency]    Script Date: 7/27/2021 3:48:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dimCurrency](
	[currencyKey] [int] IDENTITY(1,1) NOT NULL,
	[PTSCurrencyID] [int] NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[CurrencyCode] [char](10) NULL,
	[CurrencyDesc] [varchar](255) NULL,
	[CurrencySymbol] [nvarchar](20) NULL,
	[CurrencySymbolSide] [bit] NULL,
 CONSTRAINT [dimCurrency_PK] PRIMARY KEY CLUSTERED 
(
	[currencyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[dimCurrency] ADD  CONSTRAINT [DF__dimCurren__Curre__6D980E30]  DEFAULT ((0)) FOR [CurrencySymbolSide]
GO
---------------------------
-- 13 > CurrencyConversion
---------------------------
/****** Object:  Table [dbo].[factCurrencyConversion]    Script Date: 7/27/2021 3:49:21 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[factCurrencyConversion](
--	[CurrencyConversionKey] [int] IDENTITY(1,1) NOT NULL,
--	[ConversionDateKey] [int] NULL,
--	[SourceCurrencyKey] [int] NULL,
--	[DestinationCurrencyKey] [int] NULL,
--	[SourceDestinationExchRate] [decimal](20, 5) NULL,
--	[DestinationSourceExchRate] [decimal](20, 5) NULL,
--	[SourceLocationId] [int] NULL,
--	[cdcCaptureLogID] [int] NULL
--)
--GO
---------------------------
-- 14 > TournamentPlayer
---------------------------
GO
CREATE TABLE [dbo].[SURGE_tblTournamentEligibleUser](
	[TournamentEligibleUserId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[ProductId] [int] NULL,
	[UserId] [int] NULL,
	[Status] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblTournamentEligibleUser] PRIMARY KEY CLUSTERED 
(
	[TournamentEligibleUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

GO
CREATE TABLE [dbo].[SURGE_tblTournamentEligibleUser_MIT](
	[TournamentEligibleUserId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TournamentId] [int] NULL,
	[GamingSystemId] [int] NULL,
	[ProductId] [int] NULL,
	[UserId] [int] NULL,
	[Status] [varchar](50) NULL,
	[InsertedDateTime] [datetime] NULL,
 CONSTRAINT [PK_tblTournamentEligibleUser_MIT] PRIMARY KEY CLUSTERED 
(
	[TournamentEligibleUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[SURGE_tblPlayerBonusCredit](
	[PlayerBonusCreditId] [BIGINT] NOT NULL,
	[AccountNumber] [VARCHAR](MAX) NULL,
	[UserId] [BIGINT] NULL,
	[GamingSystemId] [BIGINT] NULL,
	[ProductId] [BIGINT] NULL,
	[SessionProductId] [BIGINT] NULL,
	[Amount] [FLOAT] NULL,
	[IsSuccess] [BIT] NULL,
	[CalledOn] [DATETIME] NULL,
	[CallCount] [INT] NULL,
	[AdminEventId] [BIGINT] NULL,
	[AdminEventDescription] [VARCHAR](MAX) NULL,
	[ExpireOn] [DATETIME] NULL,
	[TriggeredOn] [DATETIME] NULL,
	[TriggerId] [VARCHAR](MAX) NULL,
	[InsertedDateTime] [DATETIME] NULL
 CONSTRAINT [PK_tblPlayerBonusCredit] PRIMARY KEY CLUSTERED 
(
	[PlayerBonusCreditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[SURGE_tblPlayerBonusCredit_MIT](
	[PlayerBonusCreditId] [BIGINT] NOT NULL,
	[AccountNumber] [VARCHAR](MAX) NULL,
	[UserId] [BIGINT] NULL,
	[GamingSystemId] [BIGINT] NULL,
	[ProductId] [BIGINT] NULL,
	[SessionProductId] [BIGINT] NULL,
	[Amount] [FLOAT] NULL,
	[IsSuccess] [BIT] NULL,
	[CalledOn] [DATETIME] NULL,
	[CallCount] [INT] NULL,
	[AdminEventId] [BIGINT] NULL,
	[AdminEventDescription] [VARCHAR](MAX) NULL,
	[ExpireOn] [DATETIME] NULL,
	[TriggeredOn] [DATETIME] NULL,
	[TriggerId] [VARCHAR](MAX) NULL,
	[InsertedDateTime] [DATETIME] NULL
 CONSTRAINT [PK_tblPlayerBonusCredit_MIT] PRIMARY KEY CLUSTERED 
(
	[PlayerBonusCreditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[SURGE_tblTriggerConditionsMet](
	[id] [INT] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [INT] NULL,
	[GamingSystemId] [INT] NULL,
	[Identifier] [VARCHAR](150) NULL,
	[StartDate] [VARCHAR](50) NULL,
	[TriggeredDate] [VARCHAR](50) NULL,
	[GenerateEvent] [VARCHAR](500) NULL,
	[Results] [VARCHAR](MAX) NULL,
	[AdditionalData] [VARCHAR](MAX) NULL,
 CONSTRAINT [PK_tbltriggerconditionsmet] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[SURGE_tblTriggerConditionsMet_MIT](
	[id] [INT] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [INT] NULL,
	[GamingSystemId] [INT] NULL,
	[Identifier] [VARCHAR](150) NULL,
	[StartDate] [VARCHAR](50) NULL,
	[TriggeredDate] [VARCHAR](50) NULL,
	[GenerateEvent] [VARCHAR](500) NULL,
	[Results] [VARCHAR](MAX) NULL,
	[AdditionalData] [VARCHAR](MAX) NULL,
 CONSTRAINT [PK_tbltriggerconditionsmet1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


/* End of File ********************************************************************************************************************/