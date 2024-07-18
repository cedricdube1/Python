/****************************************************************************************************************************
* Script      : 3.Notification - Tables.sql                                                                                 *
* Created By  : Cedric Dube                                                                                                   *
* Created On  : 2021-03-02                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE TABLE [Notification].[Recipient] (
  [RecipientName] NVARCHAR(80) NOT NULL,
  [MobileNumber] CHAR(11) NOT NULL,
  [EMailAddress] NVARCHAR(150) NOT NULL,
  CONSTRAINT [PK_Recipient] PRIMARY KEY CLUSTERED ([RecipientName] ASC, [MobileNumber] ASC, [EMailAddress] ASC) WITH (FILLFACTOR = 100),
  [SendSMS] BIT NOT NULL,
  [SendEMail] BIT NOT NULL,
) ON [PRIMARY];
GO
GO
CREATE TABLE [Notification].[SendProfile](
  [SendType] VARCHAR(10) NOT NULL,
  [ProfileType] VARCHAR(10) NOT NULL,
  [ProfileName] NVARCHAR(128) NOT NULL,
  [DefaultSubject] NVARCHAR(255) NULL,
  CONSTRAINT [PK_SendProfile] PRIMARY KEY CLUSTERED ([SendType] ASC, [ProfileName] ASC) WITH (FILLFACTOR = 100),
) ON [PRIMARY];
GO
ALTER TABLE [Notification].[SendProfile] ADD [SendProvider] NVARCHAR(128) NULL;
GO
ALTER TABLE [Notification].[SendProfile] ADD [FromAddress] NVARCHAR(128) NULL;
GO
GO
CREATE TABLE [Notification].[SendFormat] (
  [Format] VARCHAR(20) NOT NULL
  CONSTRAINT [PK_SendFormat] PRIMARY KEY CLUSTERED ([Format] ASC) WITH ( FILLFACTOR = 100),
) ON [PRIMARY];
GO
GO
CREATE TABLE [Notification].[Alert] (
  [AlertID] INT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_Alert] PRIMARY KEY CLUSTERED ([AlertID] ASC) WITH ( FILLFACTOR = 100),
  [AlertProcedure] NVARCHAR(128) NOT NULL,
  [AlertDateTime] DATETIME2(7) NOT NULL,
  [AlertType] VARCHAR(10) NOT NULL,
  [AlertRecipients] NVARCHAR(MAX) NOT NULL,
  [AlertProfile] NVARCHAR(128) NOT NULL,
  [AlertFormat] VARCHAR(20) NOT NULL,
  CONSTRAINT [FK_Alert_SendFormat] FOREIGN KEY ([AlertFormat]) REFERENCES [Notification].[SendFormat] ([Format]),
  [AlertSubject] NVARCHAR(128) NOT NULL,
  [AlertMessage] NVARCHAR(MAX) NOT NULL,
  CONSTRAINT [FK2_Alert_SendProfile] FOREIGN KEY ([AlertType], [AlertProfile]) REFERENCES [Notification].[SendProfile] ([SendType], [ProfileName]),
) ON [PRIMARY];
GO
GO
CREATE TABLE [Notification].[AlertSent] (
  [AlertID] INT NOT NULL,
  CONSTRAINT [PK_AlertSent] PRIMARY KEY CLUSTERED ([AlertID] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [FK_AlertSent_Alert] FOREIGN KEY ([AlertID]) REFERENCES [Notification].[Alert] ([AlertID]),
  [SentDate] DATETIME2(7) NOT NULL
) ON [PRIMARY];
GO

/* End of File ********************************************************************************************************************/