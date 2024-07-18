/************************************************************************
* Script     : 6.Business - PlayerAcquisitionOffer - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE VIEW [dbo].[vw_PlayerAcquisitionOffer]
  WITH SCHEMABINDING
AS
SELECT [Hub].[HubPlayerID],
       [Hub].[SourceSystemID],
       [Hub].[GamingSystemID],
       [Hub].[UserID],
       [Det].[OriginSystemID],
       [Det].[CaptureLogID],
       [Det].[Operation],
       [Det].[ModifiedDate],
       -- Specific Cols. --
       [R].[Reason],
       [Det].[RegistrationUTCDateTime],
       [Det].[RegistrationUTCDate],
       [Det].[CompletionUTCDateTime],
       [Det].[CompletionUTCDate],
       [Det].[NumberOfConversions],
       [Det].[NumberOfDeposits]
FROM [dbo].[HubPlayer] [Hub]
INNER JOIN [dbo].[PlayerAcquisitionOffer] [Det]
  ON [Hub].[HubPlayerID] = [Det].[HubPlayerID]
 AND [Hub].[SourceSystemID] = [Det].[SourceSystemID]
LEFT JOIN [dbo].[Reason] [R]
  ON [R].[ReasonID] = [Det].[CompletionReasonID];
GO

/* End of File ********************************************************************************************************************/

