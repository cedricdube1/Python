/************************************************************************
* Script     : #Common - Tests - Clear Target Model.sql
* Created By : Hector Prakke
* Created On : 2021-09-23
* Execute On : As required.
* Execute As : N/A
* Execution  : As Required.
* Version    : 1.0
* Steps      : 1 > Cleanout
************************************************************************/
USE [dbSurge]
GO
/* Cleanout */

DECLARE @DefaultHubID BINARY(32) = 0x0000000000000000000000000000000000000000000000000000000000000000;
DECLARE @DefaultReferenceID INT = -1;
IF @@SERVERNAME ='CPTDEVDB02' AND DB_NAME() = 'dbSurge' BEGIN;
  -- DETAIL --
  DELETE [dbo].[Adjustment] WHERE HubAdjustmentID <> @DefaultHubID;
  DELETE [dbo].[Deposit] WHERE HubDepositID <> @DefaultHubID;
  DELETE [dbo].[Player] WHERE HubPlayerID <> @DefaultHubID;
  DELETE [dbo].[PlayerAcquisitionOffer] WHERE HubPlayerID <> @DefaultHubID;
  DELETE [dbo].[PlayerEligibility] WHERE HubPlayerEligibilityID <> @DefaultHubID;
  DELETE [dbo].[PlayerOffer] WHERE HubPlayerOfferID <> @DefaultHubID;
  DELETE [dbo].[PlayerOfferConversion] WHERE HubPlayerOfferID <> @DefaultHubID;
  DELETE [dbo].[PlayerOfferExperience] WHERE HubPlayerOfferID <> @DefaultHubID;
  DELETE [dbo].[PlayerOfferFreeGame] WHERE HubPlayerOfferID <> @DefaultHubID;
  DELETE [dbo].[PlayerOfferIncentive] WHERE HubPlayerOfferIncentiveID <> @DefaultHubID;
  DELETE [dbo].[PlayerOfferStatus] WHERE HubPlayerOfferID <> @DefaultHubID;
  DELETE [dbo].[Tournament] WHERE HubTournamentID <> @DefaultHubID;
  DELETE [dbo].[TournamentPlayer] WHERE HubTournamentPlayerID <> @DefaultHubID;
  DELETE [dbo].[TournamentWager] WHERE HubTournamentWagerID <> @DefaultHubID;
  DELETE [dbo].[PlayerOfferWager] WHERE HubPlayerOfferID <> @DefaultHubID;
  -- HUB --
  DELETE [dbo].[HubAdjustment] WHERE HubAdjustmentID <> @DefaultHubID;
  DELETE [dbo].[HubDeposit] WHERE HubDepositID <> @DefaultHubID;
  DELETE [dbo].[HubPlayer] WHERE HubPlayerID <> @DefaultHubID;
  DELETE [dbo].[HubPlayerEligibility] WHERE HubPlayerEligibilityID <> @DefaultHubID;
  DELETE [dbo].[HubPlayerOffer] WHERE HubPlayerOfferID <> @DefaultHubID;
  DELETE [dbo].[HubPlayerOfferIncentive] WHERE HubPlayerOfferIncentiveID <> @DefaultHubID;
  DELETE [dbo].[HubTournament] WHERE HubTournamentID <> @DefaultHubID;
  DELETE [dbo].[HubTournamentPlayer] WHERE HubTournamentPlayerID <> @DefaultHubID;
  DELETE [dbo].[HubTournamentWager] WHERE HubTournamentWagerID <> @DefaultHubID;
  -- REFERENCE --
  DELETE FROM [dbo].[AdminEvent] WHERE [AdminEventID] <> @DefaultReferenceID
  DELETE FROM [dbo].[AdminEventType] WHERE [AdminEventTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[BalanceType] WHERE [BalanceTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Brand] WHERE [BrandID] <> @DefaultReferenceID
  DELETE FROM [dbo].[DepositMethod] WHERE [DepositMethodID] <> @DefaultReferenceID
  DELETE FROM [dbo].[DepositType] WHERE [DepositTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[ExcitementBand] WHERE [ExcitementBandID] <> @DefaultReferenceID
  DELETE FROM [dbo].[ExperienceSeries] WHERE [ExperienceSeriesID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Game] WHERE [GameID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Operator] WHERE [OperatorID] <> @DefaultReferenceID
  DELETE FROM [dbo].[PlayerGroupBehaviour] WHERE [PlayerGroupBehaviourID] <> @DefaultReferenceID
  DELETE FROM [dbo].[ProductType] WHERE [ProductTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[PromotionType] WHERE [PromotionTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Reason] WHERE [ReasonID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Region] WHERE [RegionID] <> @DefaultReferenceID
  DELETE FROM [dbo].[RewardType] WHERE [RewardTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Status] WHERE [StatusID] <> @DefaultReferenceID
  DELETE FROM [dbo].[TournamentTemplate] WHERE [TournamentTemplateID] <> @DefaultReferenceID
  DELETE FROM [dbo].[Trigger] WHERE [TriggerID] <> @DefaultReferenceID
  DELETE FROM [dbo].[TriggerType] WHERE [TriggerTypeID] <> @DefaultReferenceID
  DELETE FROM [dbo].[ValueSegment] WHERE [ValueSegmentID] <> @DefaultReferenceID
  DELETE FROM [dbo].[TournamentGroup] WHERE [TournamentGroupID] <> @DefaultReferenceID
END;

/* End of File ********************************************************************************************************************/