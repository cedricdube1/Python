USE dbSurge
GO

------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.Brand
TRUNCATE TABLE dbo.Player
DELETE FROM dbo.HubPlayer
*/
EXEC dbSurge.Surge_MLT.Process_Player;
EXEC dbSurge.Surge_MIT.Process_Player;
SELECT * FROM dbo.Brand ORDER BY BrandName
SELECT TOP 1000 * FROM dbo.Player 
SELECT TOP 1000 * FROM dbo.HubPlayer 
SELECT TOP 1000 * FROM dbo.vw_Player WHERE RegistrationUTCDateTime > '2023-01-01'
------------------------------------------------------------------------

--TRUNCATE TABLE dbo.RewardType
EXEC dbSurge.Surge_MLT.Process_RewardType;
EXEC dbSurge.Surge_MIT.Process_RewardType;
SELECT * FROM dbo.RewardType
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.PlayerAcquisitionOffer
*/
EXEC dbSurge.Surge_MLT.Process_PlayerAcquisitionOffer;
EXEC dbSurge.Surge_MIT.Process_PlayerAcquisitionOffer;
SELECT * FROM dbo.PlayerAcquisitionOffer --ORDER BY completionUTCdate
SELECT * FROM dbo.Reason
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.PromotionType
TRUNCATE TABLE dbo.ProductType
TRUNCATE TABLE dbo.PlayerEligibility
DELETE FROM dbo.HubPlayerEligibility
*/
EXEC dbSurge.Surge_MLT.Process_PlayerEligibility;
EXEC dbSurge.Surge_MIT.Process_PlayerEligibility;
SELECT * FROM dbo.ProductType
SELECT * FROM dbo.PromotionType
SELECT TOP 10 * FROM dbo.vw_PlayerEligibility
--WHERE userIN 
SELECT * FROM dbo.HubPlayerEligibility
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.PlayerOffer
DELETE FROM dbo.HubPlayerOffer
*/
EXEC dbSurge.Surge_MLT.Process_PlayerOffer;
EXEC dbSurge.Surge_MIT.Process_PlayerOffer;
SELECT * FROM dbo.RewardType
SELECT * FROM dbo.PlayerOffer 
SELECT * FROM dbo.HubPlayerOffer 
SELECT TOP 10 * FROM dbo.vw_PlayerOffer 
------------------------------------------------------------------------

/*
TRUNCATE TABLE dbo.TriggerType
TRUNCATE TABLE dbo.ABTestGroup
TRUNCATE TABLE dbo.ExcitementBand
TRUNCATE TABLE dbo.ValueSegment
TRUNCATE TABLE dbo.PlayerGroupBehaviour
TRUNCATE TABLE dbo.PlayerOfferExperience
*/
EXEC dbSurge.Surge_MLT.Process_PlayerOfferExperience;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferExperience;
SELECT * FROM dbo.RewardType
SELECT * FROM dbo.TriggerType
SELECT * FROM dbo.ExcitementBand
SELECT * FROM dbo.ValueSegment
SELECT * FROM dbo.PlayerGroupBehaviour
SELECT * FROM dbo.Experience
SELECT * FROM dbo.ExperienceSeries
SELECT * FROM dbo.AdjustedPercentageSource
SELECT * FROM dbo.TimeOnDeviceCategory
SELECT TOP 10 * FROM dbo.vw_PlayerOfferExperience
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.AdminEventType
TRUNCATE TABLE dbo.AdminEvent
TRUNCATE TABLE dbo.BalanceType
TRUNCATE TABLE dbo.Adjustment
delete from dbo.HubAdjustment
*/
EXEC dbSurge.Surge_MLT.Process_Adjustment;
EXEC dbSurge.Surge_MIT.Process_Adjustment;
SELECT * FROM dbo.AdminEventType
SELECT * FROM dbo.AdminEvent ae ORDER BY ae.AdminEventName
WHERE ae.AdminEventName NOT LIKE '%DealBonus%'
		AND ae.AdminEventName NOT LIKE '%ACQ%'
		AND ae.AdminEventName NOT LIKE '%Daily%'
		AND ae.AdminEventName NOT LIKE '%Insession%'
		AND ae.AdminEventName NOT LIKE '%Dialect%'
		AND ae.AdminEventName NOT LIKE '%Lapsed%'
SELECT * FROM dbo.BalanceType
SELECT TOP 10 * FROM dbo.Adjustment
SELECT * FROM dbo.HubAdjustment
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.DepositType
TRUNCATE TABLE dbo.DepositMethod
TRUNCATE TABLE dbo.Status
TRUNCATE TABLE dbo.Deposit
delete from dbo.HubDeposit
*/
EXEC dbSurge.Surge_MLT.Process_Deposit;
EXEC dbSurge.Surge_MIT.Process_Deposit;
SELECT * FROM dbo.DepositType
SELECT * FROM dbo.DepositMethod ORDER BY DepositMethodName
SELECT * FROM dbo.Status
SELECT TOP 10 * FROM dbo.vw_Deposit
SELECT * FROM dbo.HubDeposit
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.Game
TRUNCATE TABLE dbo.[Trigger]
TRUNCATE TABLE dbo.PromotionType
TRUNCATE TABLE dbo.PlayerOfferFreeGame
*/
EXEC dbSurge.Surge_MLT.Process_PlayerOfferFreeGame;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferFreeGame;
SELECT * FROM dbo.Game
SELECT * FROM dbo.[Trigger]
SELECT * FROM dbo.PromotionType	
SELECT TOP 10 * FROM dbo.PlayerOfferFreeGame
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.PromotionType
TRUNCATE TABLE dbo.PlayerOfferConversion
*/
EXEC dbSurge.Surge_MLT.Process_PlayerOfferStatusAccept;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferStatusAccept;

EXEC dbSurge.Surge_MLT.Process_PlayerOfferStatusReject;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferStatusReject;
SELECT * FROM dbo.[Status]
SELECT * FROM dbo.PromotionType	ORDER BY CaptureLogID

DECLARE @SelectedDate DATETIME = GETDATE()-2
SELECT  s.StatusName, p.PromotionTypeName, a.* FROM dbo.vw_PlayerOfferStatus a
JOIN dbo.Status s ON s.StatusID = a.StatusID
JOIN dbo.PromotionType p ON p.PromotionTypeID = a.PromotionTypeID
WHERE GamingSystemID = 29
AND UserID = 3293766
AND a.StatusUTCDateTime >= @SelectedDate

SELECT  a.* FROM dbo.vw_PlayerOfferExperience a
WHERE GamingSystemID = 29
AND UserID = 3293766
AND a.CalculatedOnUTCDateTime >= @SelectedDate

SELECT  a.* FROM dbo.vw_PlayerEligibility a
WHERE GamingSystemID = 29
AND UserID = 3293766
AND a.StartUTCDateTime >= @SelectedDate
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.TournamentGroup
TRUNCATE TABLE dbo.Tournament
*/
EXEC dbSurge.Surge_MLT.Process_Tournament;
EXEC dbSurge.Surge_MIT.Process_Tournament;
SELECT * FROM dbo.Game	
SELECT * FROM dbo.Operator
SELECT * FROM dbo.Region
SELECT * FROM dbo.Status	
SELECT * FROM dbo.Tournament
SELECT * FROM dbo.TournamentGroup
SELECT * FROM dbo.Tournament ORDER BY startUTCDate
SELECT * FROM dbo.HubTournament
SELECT * FROM dbo.vw_Tournament WHERE TournamentGroupID =479
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.Event
TRUNCATE TABLE dbo.TriggerResult
TRUNCATE TABLE dbo.Identifier
TRUNCATE TABLE dbo.TriggeringCondition
TRUNCATE TABLE dbo.HubTournamentPlayer
*/
--EXEC dbSurge.Surge_MLT.Process_TournamentPlayer;
EXEC dbSurge.Surge_MLT.Process_TournamentPlayer;
EXEC dbSurge.Surge_MIT.Process_TournamentPlayer;
SELECT * FROM dbo.Status
SELECT * FROM dbo.TournamentTemplate 
SELECT * FROM dbo.TournamentGroup
SELECT * FROM dbo.HubTournamentPlayer 
SELECT * FROM dbo.TournamentPlayer	
SELECT TOP 10 * FROM dbo.vw_TournamentPlayer	WITH (nolock)
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.TournamentWager
*/
EXEC dbSurge.Surge_MLT.Process_TournamentWager;
EXEC dbSurge.Surge_MIT.Process_TournamentWager ;
SELECT * FROM dbo.TournamentWager
SELECT TOP 10 * FROM dbo.HubTournamentWager
SELECT TOP 10 * FROM dbo.TournamentWager  WHERE TournamentID = 14674 
ORDER BY GamingSystemID,UserID,WagerUTCDateTime
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.TournamentPlayer
*/
EXEC dbSurge.Surge_MLT.Process_TournamentInvitedPlayer;
EXEC dbSurge.Surge_MIT.Process_TournamentInvitedPlayer;
SELECT * FROM dbo.Status
SELECT * FROM dbo.TournamentTemplate
SELECT * FROM dbo.TournamentPlayer	
SELECT * FROM dbo.HubTournamentPlayer
SELECT * FROM dbo.vw_TournamentPlayer 
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.ValueSegment
TRUNCATE TABLE dbo.RewardType
TRUNCATE TABLE dbo.PromotionType
TRUNCATE TABLE dbo.PlayerOfferIncentive
*/
EXEC dbSurge.Surge_MLT.Process_PlayerOfferIncentive;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferIncentive;
SELECT * FROM dbo.ValueSegment
SELECT * FROM dbo.RewardType
SELECT * FROM dbo.PromotionType	
SELECT * FROM dbo.PlayerOfferIncentive
SELECT TOP 10 * FROM dbo.vw_PlayerOfferIncentive
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.Game
TRUNCATE TABLE dbo.PlayerGroupBehaviour
TRUNCATE TABLE dbo.PlayerOfferWager
*/
EXEC dbSurge.Surge_MLT.Process_PlayerOfferWager;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferWager;
SELECT * FROM dbo.Game ORDER BY  GameName
SELECT * FROM dbo.PlayerGroupBehaviour ORDER BY PlayerGroupBehaviourName
SELECT * FROM dbo.vw_PlayerOfferWager
------------------------------------------------------------------------

EXEC dbSurge.Surge_MLT.Process_PlayerOfferConversion;
EXEC dbSurge.Surge_MIT.Process_PlayerOfferConversion;
SELECT * FROM dbo.Game ORDER BY  GameName
SELECT * FROM dbo.PlayerGroupBehaviour ORDER BY PlayerGroupBehaviourName
SELECT TOP 10 * FROM dbo.vw_PlayerOfferConversion 

------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.AdminEvent
TRUNCATE TABLE dbo.PlayerBonusCredit
TRUNCATE TABLE dbo.HubPlayerBonusCredit
*/
--EXEC dbSurge.Surge_MLT.Process_PlayerBonusCredit @CE_MinID = 56305106;
--EXEC dbSurge.Surge_MIT.Process_PlayerBonusCredit @CE_MinID = 56305106;
SELECT * FROM dbo.AdminEvent order BY AdminEventName
SELECT * FROM dbo.PlayerBonusCredit
SELECT * FROM dbo.HubPlayerBonusCredit
------------------------------------------------------------------------
------------------------------------------------------------------------
/*
TRUNCATE TABLE dbo.Event
TRUNCATE TABLE dbo.TriggerResult
TRUNCATE TABLE dbo.Identifier
TRUNCATE TABLE dbo.TriggeringCondition
TRUNCATE TABLE dbo.HubTriggeringCondition

*/
--EXEC dbSurge.Surge_MLT.Process_TriggeringCondition @CE_MinID = 20697504;
--EXEC dbSurge.Surge_MIT.Process_TriggeringCondition @CE_MinID = 40924252;
SELECT * FROM dbo.Event 
SELECT * FROM dbo.TriggerResult
SELECT * FROM dbo.Identifier
SELECT * FROM dbo.HubTriggeringCondition
SELECT * FROM dbo.TriggeringCondition
SELECT * FROM dbo.vw_TriggeringCondition

------------------------------------------------------------------------
SELECT * FROM dbSurge.Logging.vProcessTaskCapture WITH (NOLOCK)
WHERE processname = 'Player|Surge_MLT'
ORDER BY ProcessTaskCaptureLogID DESC

SELECT * FROM dbSurge.logging.vProcessTaskInfo WITH (NOLOCK)
WHERE processname = 'Player|Surge_MIT'
--ORDER BY ProcessTaskInfoLogID DESC;
ORDER BY ProcessLogID DESC, ProcessTaskInfoLogID DESC;

SELECT *
FROM logging.vProcessTrace 
WHERE processname = 'Player|Surge_MIT'
ORDER BY ProcessTaskCaptureLogID DESC;

SELECT * FROM logging.vProcessTaskInfo
WHERE TaskName = 'Extract' AND InfoMessage = 'No new data detected at Source. Exiting.'
ORDER BY ProcessTaskInfoLogID DESC;
--54327138

SELECT TOP 50 * FROM dbSurge.Logging.vError WITH (NOLOCK)
WHERE ProcessID = 1 ORDER BY ErrorDate DESC

SELECT * FROM Logging.vCDOExtractByID WITH (NOLOCK) ORDER BY ProcessLogID DESC;
SELECT * FROM Logging.vCDOExtractByID WITH (NOLOCK) where processname = 'Player|Surge_MIT' ORDER BY ProcessLogID DESC;
SELECT * FROM Logging.BulkExtractByID WITH (NOLOCK) where ProcessTaskID = 101 ORDER BY ProcessLogID DESC;
SELECT * FROM Logging.BulkExtractByID WITH (NOLOCK) where ProcessTaskID = 89 ORDER BY ProcessLogID DESC;

SELECT * FROM Logging.vCDOExtractByID WITH (NOLOCK) WHERE LogStatus =  'Overridden' ORDER BY ProcessLogID DESC;
SELECT * FROM Logging.vCDOExtractByID WITH (NOLOCK) WHERE LogStatus =  'InComplete' ORDER BY ProcessLogID DESC;
SELECT * FROM Logging.vCDOExtractByID WITH (NOLOCK) WHERE LogStatus =  'Error' ORDER BY ProcessLogID DESC;
--UPDATE Logging.CDOExtractByID 
--SET StatusCode = 3
--WHERE ProcessTaskLogID = 348701


SELECT * FROM dbSurge.Config.AppLockVariable WITH (NOLOCK)
SELECT * FROM dbSurge.Config.Variable WITH (NOLOCK)



SELECT * FROM Logging.vCDOExtractByID WITH (NOLOCK) where ProcessID = 15 ORDER BY ProcessLogID DESC;


--SELECT * FROM Config.vJobQueue WHERE JobID IN( 112, 96)

--Notifications
SELECT * FROM [Notification].[Recipient]
SELECT * FROM [Notification].[SendProfile]
SELECT * FROM [Notification].[Alert]
SELECT * FROM [Notification].[AlertSent]

--UPDATE dbSurge.config.job
--SET IsEnabled = 0
--WHERE JobID IN (20,23, 38, 41)


--Jobs
SELECT * FROM config.job ORDER BY ProcessID
SELECT * FROM config.vjob WHERE JobID IN (56, 76)
SELECT * FROM Config.vJobQueue WHERE JobName LIKE '%PlayerofferEx%';
SELECT * FROM [Monitoring].[vSQLServerAgentControllerJobState]
SELECT * FROM [Monitoring].[vSQLServerAgentFailedJob] WHERE JobName LIKE 'Raptor%'

SELECT * FROM [Config].[JobVariable] WHERE JobID IN (54, 74)

SELECT TOP 10 * FROM Logging.BulkExtractByID WITH (NOLOCK) 
WHERE ProcessTaskID = 20 ORDER BY ProcessLogID DESC;

sp_help '[Surge_MLT].[Load_PlayerOfferConversion]'
sp_helpText '[Surge_MLT].[Load_PlayerOfferConversion]'

--UPDATE config.job 
--SET IsEnabled = 0
--WHERE JobID IN (56,76)

UPDATE [Config].[JobVariable] 
SET ConfigValue = '00:15:00'
WHERE JobID IN (7, 8)
 
  
--Batchsize
EXEC [Config].[SetVariable_ProcessTask] @ProcessTaskID = 21,
@ConfigGroupName = 'Stage',
@ConfigName = 'BatchSize',
@ConfigValue = 2000000,
@Delete = 0;
EXEC [Config].[SetVariable_ProcessTask] @ProcessTaskID = 22,
@ConfigGroupName = 'Load',
@ConfigName = 'BatchSize',
@ConfigValue = 2000000,
@Delete = 0;

SELECT * FROM Config.vProcessTask  WHERE ProcessName = 'PlayerOfferExperience|Surge_MIT'






