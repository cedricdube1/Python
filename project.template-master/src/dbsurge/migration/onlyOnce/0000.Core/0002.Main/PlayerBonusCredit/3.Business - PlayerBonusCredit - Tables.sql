/************************************************************************
* Script     : 3.Business - PlayerBonusCredit - Tables.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[HubPlayerBonusCredit] (
  -- Standard Columns --
  [HubPlayerBonusCreditID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubPlayerBonusCredit] PRIMARY KEY CLUSTERED ([HubPlayerBonusCreditID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [TriggerID] VARCHAR(36) NULL,
  [UserID] INT NULL,
  [GamingSystemID] INT NULL
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubPlayerBonusCredit] (
  [TriggerID] ASC,
  [UserID] ASC,
  [GamingSystemID] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO


CREATE TABLE [dbo].[PlayerBonusCredit] (
  -- Standard Columns --
  [HubPlayerBonusCreditID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerBonusCredit_HubPlayerBonusCredit] FOREIGN KEY ([HubPlayerBonusCreditID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerBonusCredit] ([HubPlayerBonusCreditID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerBonusCredit] PRIMARY KEY CLUSTERED (
    [HubPlayerBonusCreditID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [AdminEventID] INT NULL,
  [IsSuccess] BIT NULL,
  [CallCount] INT NULL,  
  [CalledOnUTCDateTime] DATETIME2 NULL,
  [CalledOnUTCDate] DATE NULL,
  [ExpireOnUTCDateTime] DATETIME2 NULL,
  [ExpireOnUTCDate] DATE NULL,
  [TriggeredOnUTCDateTime] DATETIME2 NULL,
  [TriggeredOnUTCDate] DATE NULL,
  [BonusAmount] DECIMAL(19,4) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerBonusCredit] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerBonusCredit] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_IsBonusEvent_TransactionUTCDateTime] ON [dbo].[PlayerBonusCredit] (
--  [IsBonusEvent] ASC,
--  [TransactionUTCDateTime] ASC
--) INCLUDE (
--  [HubPlayerBonusCreditID],
--  [SourceSystemID],
--  [HubPlayerID],
--  [AdminEventTypeID],
--  [AdminEventID],
--  [CurrencyValue]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerBonusCredit] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [AdminEventID],
  [IsSuccess],
  [CallCount],  
  [CalledOnUTCDateTime],
  [CalledOnUTCDate],
  [ExpireOnUTCDateTime],
  [ExpireOnUTCDate],
  [TriggeredOnUTCDateTime],
  [TriggeredOnUTCDate],
  [BonusAmount]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerBonusCredit]
  ADD CONSTRAINT [FK_PlayerBonusCredit_AdminEvent] FOREIGN KEY ([AdminEventID]) REFERENCES [dbo].[AdminEvent] ([AdminEventID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubPlayerBonusCredit] (
  [HubPlayerBonusCreditID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[PlayerBonusCredit] (
  [HubPlayerBonusCreditID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO
/* End of File ********************************************************************************************************************/