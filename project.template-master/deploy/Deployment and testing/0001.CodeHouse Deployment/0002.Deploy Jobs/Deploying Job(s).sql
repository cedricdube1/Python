USE [dbSurge]
GO

--DECLARE @ProcessID INT = [Config].[GetProcessIDByName] ('RewardType|Surge_MLT');
--DECLARE @JobID INT = (SELECT JobID FROM Config.Job WITH (NOLOCK) WHERE ProcessID = @ProcessID);
--EXEC [Config].[GetJob_ServerAgentScript] @JobID,
--@CreateAsEnabled = 0, -- DEFAULT = 0
--@PrintFileHeader = 1, -- DEFAULT = 1
--@PrintFileFooter = 1, --DEFAULT = 1
--@EmailOperatorName = 'iGaming Insights' 

DECLARE @JobList Config.JobID
INSERT INTO @JobList
SELECT JobID FROM Config.Job;
--SELECT * FROM @JobList
EXEC [Config].[GetMultiJob_ServerAgentScript] @JobList,
@CreateAsEnabled = 0, -- DEFAULT = 0
@PrintFileHeader = 1, -- DEFAULT = 1
@PrintFileFooter = 1, --DEFAULT = 1
@EmailOperatorName = 'iGaming Insights' 

SELECT * FROM Config.Job;

--SELECT * FROM Config.JobQueue;
--SELECT * FROM Config.vJob;

