/************************************************************************
* Script     : 3.Business - PlayerOfferIncentive - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO


CREATE TABLE [dbo].[HubPlayerOfferIncentive] (
  -- Standard Columns --
  [HubPlayerOfferIncentiveID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubPlayerOfferIncentive] PRIMARY KEY CLUSTERED ([HubPlayerOfferIncentiveID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [PromoGUID] VARCHAR(36) NULL,
  [OfferGUID] VARCHAR(36) NULL,
  [UserID] INT NULL,
  [GamingSystemID] INT NULL,
  [RewardTypeName] VARCHAR(50) NULL
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubPlayerOfferIncentive] (
  [PromoGUID] ASC,
  [OfferGUID] ASC,
  [UserID] ASC,
  [GamingSystemID] ASC,
  [RewardTypeName] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO


CREATE TABLE [dbo].[PlayerOfferIncentive] (
  -- Standard Columns --
  [HubPlayerOfferIncentiveID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOfferIncentive_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferIncentiveID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOfferIncentive] ([HubPlayerOfferIncentiveID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOfferIncentive] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferIncentiveID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerOfferID] BINARY(32) NULL,
  [HubPlayerID] BINARY(32) NULL,
  [PromotionTypeID] INT NULL,
  [RewardTypeID] INT NULL,
  [ValueSegmentID] INT NULL,
  [RewardUTCDateTime] DATETIME2(7) NULL,
  [RewardUTCDate] DATE NULL,
  [BinSum] INT NULL,
  [ReloadMax] INT NULL,
  [ReloadCount] INT NULL,
  [CouponValue] INT NULL,
  [PercentageMatch] INT NULL,
  [LevelFreeSpinCoupon] INT NULL,

) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOfferIncentive] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOfferIncentive] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_RewardUTCDateTime] ON [dbo].[PlayerOfferIncentive] (
--  [RewardUTCDateTime] ASC
--) INCLUDE (
--  [HubPlayerOfferIncentiveID],
--  [SourceSystemID],
--  [HubPlayerID],
--  [RewardTypeID],
--  [LevelFreeSpinCoupon]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
--CREATE NONCLUSTERED INDEX [IDX_HubPlayerOfferID] ON [dbo].[PlayerOfferIncentive] (
--  [HubPlayerOfferID] ASC,
--  [SourceSystemID] ASC
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOfferIncentive] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerOfferID],
  [HubPlayerID],
  [PromotionTypeID],
  [RewardTypeID],
  [ValueSegmentID],
  [RewardUTCDateTime],
  [RewardUTCDate],
  [BinSum],
  [ReloadMax] ,
  [ReloadCount],
  [CouponValue],
  [PercentageMatch],
  [LevelFreeSpinCoupon]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOfferIncentive]
  ADD CONSTRAINT [FK_PlayerOfferIncentive_PromotionType] FOREIGN KEY ([PromotionTypeID]) REFERENCES [dbo].[PromotionType] ([PromotionTypeID]);
ALTER TABLE [dbo].[PlayerOfferIncentive]
  ADD CONSTRAINT [FK_PlayerOfferIncentive_RewardType] FOREIGN KEY ([RewardTypeID]) REFERENCES [dbo].[RewardType] ([RewardTypeID]);
ALTER TABLE [dbo].[PlayerOfferIncentive]
  ADD CONSTRAINT [FK_PlayerOfferIncentive_ValueSegment] FOREIGN KEY ([ValueSegmentID]) REFERENCES [dbo].[ValueSegment] ([ValueSegmentID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubPlayerOfferIncentive] (
  [HubPlayerOfferIncentiveID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[PlayerOfferIncentive] (
  [HubPlayerOfferIncentiveID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/