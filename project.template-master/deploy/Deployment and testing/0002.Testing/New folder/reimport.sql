USE dbSurge
GO

DECLARE @ManualKeys [DataFlow].[PayloadID];
INSERT INTO @ManualKeys (PayloadID)
VALUES 
(181876024),
(181876023),
(181876022),
(181876027),
(182013293),
(181880454)
--SELECT * FROM @ManualKeys
EXEC dbAnalysisRetention.Surge_MIT.Process_PlayerOffer @ManualKeys = @ManualKeys;

--EXEC dbAnalysisRetention.Surge_MIT.Process_PlayerOffer @BE_MinID =181876024, @BE_MaxID =  181880454;


