/************************************************************************
* Script     : 3.Business - Adjustment - Tables.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[HubAdjustment] (
  -- Standard Columns --
  [HubAdjustmentID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubAdjustment] PRIMARY KEY CLUSTERED ([HubAdjustmentID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [BalanceUpdateID] BIGINT NULL,
  [TransactionNumber] BIGINT NULL,
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubAdjustment] (
  [BalanceUpdateID] ASC,
  [TransactionNumber] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO


CREATE TABLE [dbo].[Adjustment] (
  -- Standard Columns --
  [HubAdjustmentID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_Adjustment_HubAdjustment] FOREIGN KEY ([HubAdjustmentID], [SourceSystemID]) REFERENCES [dbo].[HubAdjustment] ([HubAdjustmentID], [SourceSystemID]),
  CONSTRAINT [PK_Adjustment] PRIMARY KEY CLUSTERED (
    [HubAdjustmentID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [AdminEventTypeID] INT NULL,
  [AdminEventID] INT NULL,
  [ModuleID] INT NULL,
  [BalanceTypeID] INT NULL,
  [PlayerCurrencyCode] CHAR(3) NULL,
  [OperatorCurrencyCode] CHAR(3) NULL,
  [TransactionUTCDateTime] DATETIME2 NULL,
  [TransactionUTCDate] DATE NULL,
  [PlayerToOperatorCurrencyExchangeRate] DECIMAL(20,5) NULL,
  [BalanceAfterLastPositiveChange] DECIMAL(19,4) NULL,
  [CashBalanceAfter] DECIMAL(19,4) NULL,
  [BonusBalanceAfter] DECIMAL(19,4) NULL,
  [CurrencyValue] DECIMAL(19,4) NULL,
  [IsBonusEvent] BIT NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[Adjustment] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[Adjustment] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_IsBonusEvent_TransactionUTCDateTime] ON [dbo].[Adjustment] (
--  [IsBonusEvent] ASC,
--  [TransactionUTCDateTime] ASC
--) INCLUDE (
--  [HubAdjustmentID],
--  [SourceSystemID],
--  [HubPlayerID],
--  [AdminEventTypeID],
--  [AdminEventID],
--  [CurrencyValue]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[Adjustment] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [AdminEventTypeID],
  [AdminEventID],
  [ModuleID],
  [BalanceTypeID],
  [PlayerCurrencyCode],
  [OperatorCurrencyCode],
  [TransactionUTCDateTime],
  [TransactionUTCDate],
  [PlayerToOperatorCurrencyExchangeRate],
  [BalanceAfterLastPositiveChange] ,
  [CashBalanceAfter],
  [BonusBalanceAfter],
  [CurrencyValue],
  [IsBonusEvent]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO


-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[Adjustment]
  ADD CONSTRAINT [FK_Adjustment_AdminEventType] FOREIGN KEY ([AdminEventTypeID]) REFERENCES [dbo].[AdminEventType] ([AdminEventTypeID]);
ALTER TABLE [dbo].[Adjustment]
  ADD CONSTRAINT [FK_Adjustment_AdminEvent] FOREIGN KEY ([AdminEventID]) REFERENCES [dbo].[AdminEvent] ([AdminEventID]);
ALTER TABLE [dbo].[Adjustment]
  ADD CONSTRAINT [FK_Adjustment_BalanceType] FOREIGN KEY ([BalanceTypeID]) REFERENCES [dbo].[BalanceType] ([BalanceTypeID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubAdjustment] (
  [HubAdjustmentID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[Adjustment] (
  [HubAdjustmentID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO
/* End of File ********************************************************************************************************************/