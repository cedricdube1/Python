/***********************************************************************************************************************************
* Script      : 0.Notification - Drop All Objects.sql                                                                              *
* Created By  : Cedric Dube                                                                                                          *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- DROP PROCEDURE IF EXISTSS --

DROP PROCEDURE IF EXISTS [Notification].[SendMail];
DROP PROCEDURE IF EXISTS [Notification].[SendSMS];
DROP PROCEDURE IF EXISTS [Notification].[Convert_SQLQuery_ToHtml];
GO
DROP PROCEDURE IF EXISTS [Notification].[SetNotification];
DROP PROCEDURE IF EXISTS [Notification].[SetRecipient];
DROP PROCEDURE IF EXISTS [Notification].[Process_Alerting];
GO

-- DROP FUNCTION IF EXISTSS --
DROP FUNCTION IF EXISTS [Notification].[GetRecipientList];
GO 

-- DROP VIEW IF EXISTSS --
DROP VIEW IF EXISTS [Notification].[vAlertSent];
DROP VIEW IF EXISTS [Notification].[vAlertToSend];
GO
-- DROP TABLES --
DROP TABLE IF EXISTS [Notification].[AlertSent];
DROP TABLE IF EXISTS [Notification].[Alert];
DROP TABLE IF EXISTS [Notification].[Recipient];
DROP TABLE IF EXISTS [Notification].[SendFormat];
DROP TABLE IF EXISTS [Notification].[SendProfile];
GO 

/* End of File ********************************************************************************************************************/