/************************************************************************
* Script     : 3.Business - PlayerOfferWager - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PlayerOfferWager] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOfferWager_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOffer] ([HubPlayerOfferID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOfferWager] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [ClientID] INT NULL,
  [ModuleID] INT NULL,
  [GameID] INT NULL,
  [PlayerGroupBehaviourID] INT NULL,
  [TransactionUTCDateTime] DATETIME2 NULL,
  [TransactionUTCDate] DATE NULL,
  [UserTransnumber] INT NULL, -- ??
  [TotalBalance] DECIMAL(19,4) NULL,
  [WagerAmount] DECIMAL(19,4) NULL,  
  [PayoutAmount] DECIMAL(19,4) NULL,
  [CashBalance]  DECIMAL(19,4) NULL,
  [BonusBalance] DECIMAL(19,4) NULL,
  [TheoreticalPayoutPercentage] DECIMAL(19,4) NULL,
  [BalanceAfterLastPositiveChange] DECIMAL(19,4) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOfferWager] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOfferWager] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOfferWager] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [ClientID],
  [ModuleID],
  [GameID],
  [PlayerGroupBehaviourID],
  [TransactionUTCDateTime],
  [TransactionUTCDate],
  [UserTransnumber], -- ??
  [TotalBalance],
  [WagerAmount],  
  [PayoutAmount],
  [CashBalance],
  [BonusBalance],
  [TheoreticalPayoutPercentage],
  [BalanceAfterLastPositiveChange]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOfferWager]
  ADD CONSTRAINT [FK_PlayerOfferWager_Game] FOREIGN KEY ([GameID]) REFERENCES [dbo].[Game] ([GameID]);
ALTER TABLE [dbo].[PlayerOfferWager]
  ADD CONSTRAINT [FK_PlayerOfferWager_PlayerGroupBehaviour] FOREIGN KEY ([PlayerGroupBehaviourID]) REFERENCES [dbo].[PlayerGroupBehaviour] ([PlayerGroupBehaviourID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[PlayerOfferWager] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO


/* End of File ********************************************************************************************************************/