/************************************************************************
* Script     : #Common - Tests - ManualKeys.sql
* Created By : Hector Prakke
* Created On : 2021-09-23
* Execute On : As required.
* Execute As : N/A
* Execution  : As Required. Runs tests using ManualKeys, top 1000 from source table
* Version    : 1.0
* Steps      : 1 > Player
*            : 2 > PlayerAcquisitionOffer
*            : 3 > RewardType
*            : 4 > PlayerEligibility
*            : 5 > PlayerOffer
*            : 6 > PlayerOfferExperience
*            : 7 > PlayerOfferFreeGame
*            : 8 > PlayerOfferStatusAccept
*            : 9 > PlayerOfferStatusReject
*            :10 > Deposit
*            :11 > PlayerOfferConversion
*            :12 > PlayerOfferIncentive
*            :13 > Adjustment
*            :14 > Tournament
*            :15 > TournamentPlayer
*            :16 > TournamentWager
*            :17 > PlayerOfferWager
*            :18 > TournamentInvitedPlayer
************************************************************************/
USE [dbSurge]
GO
DECLARE @MIT VARCHAR(10) = 'Surge_MIT';
DECLARE @MLT VARCHAR(10) = 'Surge_MLT';
DECLARE @Delim CHAR(1) = '|';
DECLARE @ProcessName_MIT VARCHAR(150),
        @ProcessName_MLT VARCHAR(150);
DECLARE @ProcessID_MIT INT,
        @ProcessID_MLT INT;
DECLARE @Stream VARCHAR(150);
-- INDICATE STREAM TO TEST --
DECLARE @TestStream VARCHAR(150);
-- SQL CMD FOR DYNAMIC EXEC --
  DECLARE @CMD NVARCHAR(MAX);

SET @TestStream = 'All';
--SET @TestStream = 'Player';
--SET @TestStream = 'PlayerAcquisitionOffer';
--SET @TestStream = 'RewardType';
--SET @TestStream = 'PlayerEligibility';
--SET @TestStream = 'PlayerOffer';
--SET @TestStream = 'PlayerOfferExperience';
--SET @TestStream = 'PlayerOfferFreeGame';
--SET @TestStream = 'PlayerOfferStatusAccept';
--SET @TestStream = 'PlayerOfferStatusReject';
--SET @TestStream = 'Deposit';
--SET @TestStream = 'PlayerOfferConversion';
--SET @TestStream = 'PlayerOfferIncentive';
--SET @TestStream = 'Adjustment';
--SET @TestStream = 'Tournament';
--SET @TestStream = 'TournamentPlayer';
--SET @TestStream = 'TournamentWager';
--SET @TestStream = 'PlayerOfferWager';
--SET @TestStream = 'TournamentInvitedPlayer';

/* Player */
SET @Stream = 'Player';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_Player;
END;

/* PlayerAcquisitionOffer */
SET @Stream = 'PlayerAcquisitionOffer';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerAcquisitionOffer;
END;
/* RewardType */
SET @Stream = 'RewardType';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.RewardType;
END;
/* PlayerEligibility */
SET @Stream = 'PlayerEligibility';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerEligibility;
END;
/* PlayerOffer */
SET @Stream = 'PlayerOffer';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOffer;
END;
/* PlayerOfferExperience */
SET @Stream = 'PlayerOfferExperience';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferExperience;
END;
/* PlayerOfferFreeGame */
SET @Stream = 'PlayerOfferFreeGame';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferFreeGame;
END;
/* PlayerOfferStatusAccept */
SET @Stream = 'PlayerOfferStatusAccept';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferStatus;
END;
/* PlayerOfferStatusReject */
SET @Stream = 'PlayerOfferStatusReject';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferStatus;
END;
/* Deposit */
SET @Stream = 'Deposit';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_Deposit;
END;
/* PlayerOfferConversion */
SET @Stream = 'PlayerOfferConversion';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferConversion;
END;
/* PlayerOfferIncentive */
SET @Stream = 'PlayerOfferIncentive';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferIncentive;
END;
/* Adjustment */
SET @Stream = 'Adjustment';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_Adjustment;
END;
/* Tournament */
SET @Stream = 'Tournament';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_Tournament;
END;
/* TournamentPlayer */
SET @Stream = 'TournamentPlayer';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_TournamentPlayer;
END;
/* TournamentWager */
SET @Stream = 'TournamentWager';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_TournamentWager;
END;

/* PlayerOfferWager */
SET @Stream = 'PlayerOfferWager';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_PlayerOfferWager;
END;

/* TournamentInvitedPlayer */
SET @Stream = 'TournamentInvitedPlayer';
IF @Stream = @TestStream OR @TestStream = 'All' BEGIN;
  -- SETUP --
  SET @ProcessName_MIT = CONCAT(@Stream, @Delim, @MIT);
  SET @ProcessName_MLT = CONCAT(@Stream, @Delim, @MLT); 
  SET @ProcessID_MIT  =Config.GetProcessIDByName (@ProcessName_MIT);
  SET @ProcessID_MLT =Config.GetProcessIDByName (@ProcessName_MLT);

  -- EXECUTE --

  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MIT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MIT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  SET @CMD = (SELECT TOP 1 '
                            DECLARE @ManualKeys [DataFlow].[PayloadID];
                            INSERT INTO @ManualKeys (PayloadID)
                            SELECT TOP 1000 [' + [TrackedColumn] + '] FROM ' + [ExtractDatabase] + '.' + [ExtractObject] + ';
                            EXEC Surge_MLT.Process_' + @Stream + ' @ManualKeys = @ManualKeys;'
                      FROM [Config].[vProcessTaskExtract]
                      WHERE ExtractObject IS NOT NULL 
                      AND ExtractTypeCode = 'CDO' 
                      AND ProcessName = @ProcessName_MLT
                      ORDER BY ExtractObject ASC, TrackedColumn ASC)
  EXEC sp_ExecuteSQL @CMD;
  
  -- PROCESS TRACE --
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTrace] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskLogID DESC;

  -- INFO LOGS --
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MIT
  UNION ALL
  SELECT * FROM [Logging].[vProcessTaskInfo] WHERE ProcessID = @ProcessID_MLT
  ORDER BY ProcessID ASC, ProcessLogID DESC, ProcessTaskInfoLogID DESC;
  
  -- TARGET --
  SELECT COUNT(1) FROM dbo.vw_TournamentPlayer TP INNER JOIN dbo.[Status] ST ON TP.StatusID = ST.StatusID WHERE ST.[StatusName] = 'Invited';
END;

/* End of File ********************************************************************************************************************/