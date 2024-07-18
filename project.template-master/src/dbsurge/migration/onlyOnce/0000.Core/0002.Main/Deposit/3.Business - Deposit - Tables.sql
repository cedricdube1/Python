/************************************************************************
* Script     : 3.Business - Deposit - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[HubDeposit] (
  -- Standard Columns --
  [HubDepositID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubDeposit] PRIMARY KEY CLUSTERED ([HubDepositID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [GamingSystemID] INT NULL,
  [UserID] INT NULL,
  [TransactionUTCDateTime] DATETIME2(7) NULL
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubDeposit] (
  [GamingSystemID] ASC,
  [UserID] ASC,
  [TransactionUTCDateTime] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO


CREATE TABLE [dbo].[Deposit] (
  -- Standard Columns --
  [HubDepositID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_Deposit_HubDeposit] FOREIGN KEY ([HubDepositID], [SourceSystemID]) REFERENCES [dbo].[HubDeposit] ([HubDepositID], [SourceSystemID]),
  CONSTRAINT [PK_Deposit] PRIMARY KEY CLUSTERED (
    [HubDepositID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [DepositTypeID] INT NULL,
  [DepositMethodID] INT NULL,
  [TransactionStatusID] INT NULL, --References Status table
  [PlayerCurrencyCode] CHAR(3) NULL,
  [OperatorCurrencyCode] CHAR(3) NULL,
  [TransactionID] BIGINT NULL, -- ??
  [TransactionUTCDateTime] DATETIME2(7) NULL,
  [TransactionUTCDate] DATE NULL,
  [IsSuccess] BIT NULL,
  [PlayerToOperatorCurrencyExchangeRate] DECIMAL(20,5) NULL,
  [CurrencyValue] DECIMAL(19,4) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[Deposit] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[Deposit] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_IsSuccess_TransactionUTCDateTime] ON [dbo].[Deposit] (
--  [IsSuccess] ASC,
--  [TransactionUTCDateTime] ASC
--) INCLUDE (
--  [HubDepositID],
--  [SourceSystemID],
--  [HubPlayerID],
--  [DepositMethodID],
--  [CurrencyValue]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[Deposit] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [DepositTypeID],
  [DepositMethodID],
  [TransactionStatusID], --References Status table
  [PlayerCurrencyCode],
  [OperatorCurrencyCode],
  [TransactionID], -- ??
  [TransactionUTCDateTime],
  [TransactionUTCDate],
  [IsSuccess],
  [PlayerToOperatorCurrencyExchangeRate],
  [CurrencyValue]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[Deposit]
  ADD CONSTRAINT [FK_Deposit_DepositType] FOREIGN KEY ([DepositTypeID]) REFERENCES [dbo].[DepositType] ([DepositTypeID]);
ALTER TABLE [dbo].[Deposit]
  ADD CONSTRAINT [FK_Deposit_DepositMethod] FOREIGN KEY ([DepositMethodID]) REFERENCES [dbo].[DepositMethod] ([DepositMethodID]);
ALTER TABLE [dbo].[Deposit]
  ADD CONSTRAINT [FK_Deposit_Status] FOREIGN KEY ([TransactionStatusID]) REFERENCES [dbo].[Status] ([StatusID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubDeposit] (
  [HubDepositID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[Deposit] (
  [HubDepositID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/