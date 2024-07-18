/****************************************************************************************************************************
* Script      : 5.Notification - Views.sql                                                                                  *
* Created By  : Cedric Dube                                                                                               *
* Created On  : 2021-03-12                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO
CREATE VIEW [Notification].[vAlertSent]
AS
  SELECT ATS.AlertID,
         ATS.AlertProcedure,
         ATS.AlertDateTime,
         NAS.SentDate AS [SentDateTime],
         ATS.AlertType,
         ATS.AlertRecipients,
		 ATS.AlertProfile,
		 ATS.AlertFormat,
		 ATS.AlertSubject,
		 ATS.AlertMessage
    FROM [Notification].[Alert] ATS
   INNER JOIN [Notification].[AlertSent] NAS
      ON ATS.AlertID = NAS.AlertID;
GO
CREATE VIEW [Notification].[vAlertToSend]
AS
  SELECT ATS.AlertID,
         ATS.AlertProcedure,
         ATS.AlertDateTime,
         ATS.AlertType,
         ATS.AlertRecipients,
		 ATS.AlertProfile,
		 ATS.AlertFormat,
		 ATS.AlertSubject,
		 ATS.AlertMessage
    FROM [Notification].[Alert] ATS
   WHERE NOT EXISTS (SELECT 1 FROM [Notification].[AlertSent] NAS WHERE AlertID = ATS.AlertID);
GO
/* End of File ********************************************************************************************************************/