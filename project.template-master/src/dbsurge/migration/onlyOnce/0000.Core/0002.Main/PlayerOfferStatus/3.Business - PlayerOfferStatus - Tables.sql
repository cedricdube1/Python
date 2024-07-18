/************************************************************************
* Script     : 3.Business - PlayerOfferStatus - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PlayerOfferStatus] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOfferStatus_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOffer] ([HubPlayerOfferID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOfferStatus] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [StatusID] INT NULL,
  [PromotionTypeID] INT NULL,
  [StatusUTCDateTime] DATETIME2 NULL,
  [StatusUTCDate] DATE NULL,
  [OfferEndUTCDateTime] DATETIME2 NULL,
  [OfferEndUTCDate] DATE NULL,
  [CurrentTier] INT NULL,
  [MaxTier] INT NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOfferStatus] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOfferStatus] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_HubPlayerID_StatusUTCDateTime] ON [dbo].[PlayerOfferStatus] (
--  [HubPlayerID] ASC,
--  [StatusUTCDateTime] ASC
--) INCLUDE (
--  [HubPlayerOfferID],
--  [SourceSystemID],  
--  [StatusID],
--  [PromotionTypeID],
--  [CurrentTier],
--  [MaxTier]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOfferStatus] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [StatusID],
  [PromotionTypeID],
  [StatusUTCDateTime],
  [StatusUTCDate],
  [OfferEndUTCDateTime],
  [OfferEndUTCDate],
  [CurrentTier],
  [MaxTier]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOfferStatus]
  ADD CONSTRAINT [FK_PlayerOfferStatus_Status] FOREIGN KEY ([StatusID]) REFERENCES [dbo].[Status] ([StatusID]);
ALTER TABLE [dbo].[PlayerOfferStatus]
  ADD CONSTRAINT [FK_PlayerOfferStatus_PromotionType] FOREIGN KEY ([PromotionTypeID]) REFERENCES [dbo].[PromotionType] ([PromotionTypeID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[PlayerOfferStatus] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO


/* End of File ********************************************************************************************************************/