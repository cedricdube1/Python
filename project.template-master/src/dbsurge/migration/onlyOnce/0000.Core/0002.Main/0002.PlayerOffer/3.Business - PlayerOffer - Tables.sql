/************************************************************************
* Script     : 3.Business - PlayerOffer - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[HubPlayerOffer] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubPlayerOffer] PRIMARY KEY CLUSTERED ([HubPlayerOfferID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [PromoGUID] VARCHAR(36) NULL,
  [OfferGUID] VARCHAR(36) NULL,
  [UserID] INT NULL,
  [GamingSystemID] INT NULL
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubPlayerOffer] (
  [PromoGUID] ASC,
  [OfferGUID] ASC,
  [UserID] ASC,
  [GamingSystemID] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_UID_GSID] ON [dbo].[HubPlayerOffer] (
  [UserID] ASC,
  [GamingSystemID] ASC
) INCLUDE (
  [HubPlayerOfferID],
  [SourceSystemID],
  [PromoGUID],
  [OfferGUID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[PlayerOffer] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOffer_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOffer] ([HubPlayerOfferID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOffer] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [HubPlayerEligibilityID] BINARY(32) NULL,
  [RewardTypeID] INT NULL,
  [Coupon] INT NULL,
  [Percentage] INT NULL,
  [FreeSpins] INT NULL,
  [TierIndex] INT NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOffer] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOffer] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

--CREATE NONCLUSTERED INDEX [IDX_HubPlayerEligibilityID] ON [dbo].[PlayerOffer] (
--  [HubPlayerEligibilityID] ASC,
--  [SourceSystemID] ASC
--) INCLUDE (
--  [HubPlayerOfferID],
--  [RewardTypeID],
--  [Coupon],
--  [Percentage],
--  [FreeSpins],
--  [TierIndex]
--)  WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOffer] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [HubPlayerEligibilityID],
  [RewardTypeID],
  [Coupon],
  [Percentage],
  [FreeSpins],
  [TierIndex]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO


-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOffer]
  ADD CONSTRAINT [FK_PlayerOffer_RewardType] FOREIGN KEY ([RewardTypeID]) REFERENCES [dbo].[RewardType] ([RewardTypeID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubPlayerOffer] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[PlayerOffer] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/