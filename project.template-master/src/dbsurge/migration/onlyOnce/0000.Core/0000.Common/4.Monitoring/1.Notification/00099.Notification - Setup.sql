/***********************************************************************************************************************************
* Script      : 99.Notification - Setup.sql                                                                                        *
* Created By  : Cedric Dube                                                                                                          *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Process Alert                                                                                                  *
*             :  2. Notification - Recipient                                                                                       *
*             :  2. Notification - SendFormat                                                                                      *
*             :  2. Notification - SendProfile                                                                                     *
***********************************************************************************************************************************/
USE [dbSurge];
GO
/***********************************************************************************************************************************
-- Process --
***********************************************************************************************************************************/
IF NOT EXISTS (SELECT * FROM [Config].[Process] WHERE [ProcessName] = 'Notification|Alerting') BEGIN;
  SET IDENTITY_INSERT [Config].[Process] ON;
  INSERT INTO [Config].[Process] ([ProcessID], [ProcessName], [ProcessDescription], [IsEnabled]) VALUES(-100, 'Notification|Alerting', 'Send alert notifications via SMS or EMail', 1);
  SET IDENTITY_INSERT [Config].[Process] OFF;
END;
GO
/***********************************************************************************************************************************
-- Process Config --
***********************************************************************************************************************************/
-- No Specified Config
/***********************************************************************************************************************************
-- Recipient --
***********************************************************************************************************************************/
EXEC [Notification].[SetRecipient] @RecipientName = 'Cedric Dube',
                                   @MobileNumber = '27793091238',
                                   @EMailAddress = 'Cedric.dube@digioutsource.com',
                                   @SendSMS = 0,
                                   @SendEMail = 0,
                                   @Delete = 0;
GO

EXEC [Notification].[SetRecipient] @RecipientName = 'Pager Duty',
                                   @MobileNumber = '27000000000',
                                   @EMailAddress = 'igx-insights--escalations-email.01@digioutsource.pagerduty.com',
                                   @SendSMS = 1,
                                   @SendEMail = 0,
                                   @Delete = 0;
GO
EXEC [Notification].[SetRecipient] @RecipientName = 'IG Insights',
                                   @MobileNumber = '27000000000',
                                   @EMailAddress = 'iginsights@digioutsource.com',
                                   @SendSMS = 0,
                                   @SendEMail = 1,
                                   @Delete = 0;
GO
/***********************************************************************************************************************************
-- Send Format --
***********************************************************************************************************************************/
 IF NOT EXISTS (SELECT 1 FROM [Notification].[SendFormat] WHERE [Format] = 'TEXT')
   INSERT INTO [Notification].[SendFormat] ([Format])
     VALUES ('TEXT');
 IF NOT EXISTS (SELECT 1 FROM [Notification].[SendFormat] WHERE [Format] = 'HTML')
   INSERT INTO [Notification].[SendFormat] ([Format])
     VALUES ('HTML');
GO
/***********************************************************************************************************************************
-- Notification --
***********************************************************************************************************************************/
-- Send Profile --
 IF NOT EXISTS (SELECT 1 FROM [Notification].[SendProfile] WHERE SendType = 'Email' AND ProfileType = 'DEFAULT' AND ProfileName = 'ISAlerts Profile')
   INSERT INTO [Notification].[SendProfile] ([SendType], [ProfileType], [ProfileName], [DefaultSubject],[FromAddress])
     VALUES ('EMail', 'DEFAULT', 'ISAlerts Profile', 'Sent via SurgeETL, iGaming Insights PDM', 'iginsights@digioutsource.com');
 IF NOT EXISTS (SELECT 1 FROM [Notification].[SendProfile] WHERE SendType = 'SMS' AND ProfileType = 'DEFAULT' AND ProfileName = 'BulkSMS')
   INSERT INTO [Notification].[SendProfile] ([SendType], [ProfileType], [ProfileName], [DefaultSubject], [SendProvider], [FromAddress])
     --VALUES ('SMS', 'DEFAULT', 'BulkSMS', 'BINumbers#', 'bulksms.co.uk');
	 VALUES ('SMS', 'DEFAULT', 'ISAlerts Profile', 'Sent via SurgeETL, iGaming Insights PDM#', 'PagerDuty', 'iginsights@digioutsource.com');

 --UPDATE a
 --SET    a.[FromAddress] = 'iginsights@digioutsource.com'
 --FROM   [Notification].[SendProfile] A
 --WHERE a.SendType = 'Email' AND a.ProfileType = 'DEFAULT' AND a.ProfileName = 'ISAlerts Profile'

/* End of File ********************************************************************************************************************/

SELECT * FROM [Notification].[SendProfile]