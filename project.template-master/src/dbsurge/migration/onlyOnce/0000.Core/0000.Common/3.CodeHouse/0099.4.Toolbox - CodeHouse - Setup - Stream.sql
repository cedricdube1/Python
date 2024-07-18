/************************************************************************
* Script     : 99.1.ToolBox - CodeHouse - Setup - Stream.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

-- Stream --
DECLARE @Stream VARCHAR(50);

SET @Stream = 'Any';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'Adjustment';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'Deposit';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'Player';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerAcquisitionOffer';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerEligibility';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOffer';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOfferConversion';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOfferExperience';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOfferFreeGame';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOfferIncentive';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOfferStatus';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;
SET @Stream = 'PlayerOfferStatusReject';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;
SET @Stream = 'PlayerOfferStatusAccept';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerOfferWager';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'Tournament';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'TournamentPlayer';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'TournamentWager';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'RewardType';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'TournamentInvitedPlayer';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'PlayerBonusCredit';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

SET @Stream = 'TriggeringCondition';
EXEC [CodeHouse].[SetStream] @Stream = @Stream;

-- CHECK --
SELECT * FROM [CodeHouse].[Stream];
GO
/* End of File ********************************************************************************************************************/