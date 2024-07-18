/************************************************************************
* Script     : 3.Business - PlayerOfferConversion - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PlayerOfferConversion] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOfferConversion_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOffer] ([HubPlayerOfferID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOfferConversion] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [HubDepositID] BINARY(32) NULL,
  [HubPlayerBonusCreditID] BINARY(32) NULL,
  [PromotionTypeID] INT NULL,
  [ApplicationOnUTCDateTime] DATETIME2 NULL,
  [ApplicationOnUTCDate] DATE NULL,
  [TriggeredOnUTCDateTime] DATETIME2 NULL,
  [TriggeredOnUTCDate] DATE NULL,
  [DepositUTCDateTime] DATETIME2 NULL,
  [DepositUTCDate] DATE NULL,
  [DepositAmount] DECIMAL(19,4) NULL,
  [BonusAmount] DECIMAL(19,4) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOfferConversion] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOfferConversion] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_TriggeredOnUTCDateTime] ON [dbo].[PlayerOfferConversion] (
--  [TriggeredOnUTCDateTime] ASC
--) INCLUDE (
--  [HubPlayerOfferID],
--  [HubDepositID],
--  [SourceSystemID],
--  [ModifiedDate],
--  [PromotionTypeID],
--  [BonusAmount],
--  [DepositAmount],
--  [DepositUTCDateTime]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOfferConversion] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [HubDepositID],
  [HubPlayerBonusCreditID],
  [PromotionTypeID],
  [ApplicationOnUTCDateTime],
  [ApplicationOnUTCDate],
  [TriggeredOnUTCDateTime],
  [TriggeredOnUTCDate],
  [DepositUTCDateTime],
  [DepositUTCDate],
  [DepositAmount],
  [BonusAmount]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOfferConversion]
  ADD CONSTRAINT [FK_PlayerOfferConversion_PromotionType] FOREIGN KEY ([PromotionTypeID]) REFERENCES [dbo].[PromotionType] ([PromotionTypeID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[PlayerOfferConversion] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO


/* End of File ********************************************************************************************************************/

/*
--CHANGE FOR IGBI - ON Analysis01

ALTER TABLE [dbSurge].[dbo].[PlayerOfferConversion]
ADD
	[DepositAmount] DECIMAL(19,4) NULL,
	[DepositUTCDateTime] DATETIME2 NULL,
	[DepositUTCDate] DATE NULL ;
*/
