/************************************************************************
* Script     : 3.Business - PlayerOfferFreeGame - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PlayerOfferFreeGame] (
  -- Standard Columns --
  [HubPlayerOfferID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerOfferFreeGame_HubPlayerOffer] FOREIGN KEY ([HubPlayerOfferID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerOffer] ([HubPlayerOfferID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerOfferFreeGame] PRIMARY KEY CLUSTERED (
    [HubPlayerOfferID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [GameID] INT NULL, --References Game
  [TriggerID] INT NULL,
  [PromotionTypeID] INT NULL,
  [NumberOfSpins] INT NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerOfferFreeGame] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerOfferFreeGame] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_HubPlayerID] ON [dbo].[PlayerOfferFreeGame] (
--  [HubPlayerID] ASC
--) INCLUDE (
--  [HubPlayerOfferID],
--  [SourceSystemID],
--  [GameID],
--  [PromotionTypeID],
--  [NumberOfSpins])
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerOfferFreeGame] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [GameID], --References Game
  [TriggerID] ,
  [PromotionTypeID],
  [NumberOfSpins]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerOfferFreeGame]
  ADD CONSTRAINT [FK_PlayerOfferFreeGame_RewardType] FOREIGN KEY ([GameID]) REFERENCES [dbo].[Game] ([GameID]);
ALTER TABLE [dbo].[PlayerOfferFreeGame]
  ADD CONSTRAINT [FK_PlayerOfferFreeGame_Trigger] FOREIGN KEY ([TriggerID]) REFERENCES [dbo].[Trigger] ([TriggerID]);
ALTER TABLE [dbo].[PlayerOfferFreeGame]
  ADD CONSTRAINT [FK_PlayerOfferFreeGame_PromotionType] FOREIGN KEY ([PromotionTypeID]) REFERENCES [dbo].[PromotionType] ([PromotionTypeID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[PlayerOfferFreeGame] (
  [HubPlayerOfferID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO


/* End of File ********************************************************************************************************************/