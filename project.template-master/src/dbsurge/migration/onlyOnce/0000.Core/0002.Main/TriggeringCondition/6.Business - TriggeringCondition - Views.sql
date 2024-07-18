/************************************************************************
* Script     : 6.Business - TriggeringCondition - Views.sql
* Created By : Cedric Dube
* Created On : 2022-02-19
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_TriggeringCondition]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubTriggeringConditionID],
       [Hub].[SourceSystemID],       
       [Hub].[UserID],
       [Hub].[GamingSystemID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [Det].[HubPlayerID],
       [I].[IdentifierName],
       [E].[EventName],
       [T].[TriggerResults],  
       [Det].[StartUTCDateTime],
       [Det].[StartUTCDate],
       [Det].[TriggeredUTCDateTime],
       [Det].[TriggeredUTCDate]
FROM [dbo].[HubTriggeringCondition] [Hub]
INNER JOIN [dbo].[TriggeringCondition] [Det]
  ON [Hub].[HubTriggeringConditionID] = [Det].[HubTriggeringConditionID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Identifier] [I]
  ON [I].[IdentifierID] = [Det].[IdentifierID]
LEFT JOIN [dbo].[Event] [E]
  ON [E].[EventID] = [Det].[EventID]
LEFT JOIN [dbo].[TriggerResult] [T]
  ON [T].[TriggerResultID] = [Det].[TriggerResultID];
GO
/* End of File ********************************************************************************************************************/