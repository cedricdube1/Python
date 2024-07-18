/************************************************************************
* Script     : 6.Business - PlayerBonusCredit - Views.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerBonusCredit]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerBonusCreditID],
       [Hub].[SourceSystemID],
       [Hub].[TriggerID],
       [Hub].[UserID],
	   [Hub].[GamingSystemID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [A].[AdminEventName],
       [Det].[IsSuccess],
       [Det].[CallCount],  
       [Det].[CalledOnUTCDateTime],
       [Det].[CalledOnUTCDate],
       [Det].[ExpireOnUTCDateTime],
       [Det].[ExpireOnUTCDate],
       [Det].[TriggeredOnUTCDateTime],
       [Det].[TriggeredOnUTCDate],
       [Det].[BonusAmount]
FROM [dbo].[HubPlayerBonusCredit] [Hub]
INNER JOIN [dbo].[PlayerBonusCredit] [Det]
  ON [Hub].[HubPlayerBonusCreditID] = [Det].[HubPlayerBonusCreditID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[AdminEvent] [A]
  ON [A].[AdminEventID] = [Det].[AdminEventID];
GO


/* End of File ********************************************************************************************************************/