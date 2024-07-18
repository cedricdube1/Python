/************************************************************************
* Script     : 3.Business - PlayerEligibility - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[HubPlayerEligibility] (
  -- Standard Columns --
  [HubPlayerEligibilityID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubPlayerEligibility] PRIMARY KEY CLUSTERED ([HubPlayerEligibilityID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [PromoGUID] VARCHAR(36) NULL,
  [EligibilityGUID] VARCHAR(36) NULL,
  [UserID] INT NULL,
  [GamingSystemID] INT NULL
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubPlayerEligibility] (
  [PromoGUID] ASC,
  [EligibilityGUID] ASC,
  [UserID] ASC,
  [GamingSystemID] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE NONCLUSTERED INDEX [IDX_UID_GSID] ON [dbo].[HubPlayerEligibility] (
  [UserID] ASC,
  [GamingSystemID] ASC
) INCLUDE (
  [HubPlayerEligibilityID],
  [SourceSystemID],
  [PromoGUID],
  [EligibilityGUID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[PlayerEligibility] (
  -- Standard Columns --
  [HubPlayerEligibilityID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerEligibility_HubPlayerEligibility] FOREIGN KEY ([HubPlayerEligibilityID], [SourceSystemID]) REFERENCES [dbo].[HubPlayerEligibility] ([HubPlayerEligibilityID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerEligibility] PRIMARY KEY CLUSTERED (
    [HubPlayerEligibilityID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [ProductTypeID] INT NULL,
  [PromotionTypeID] INT NULL,
  [StartUTCDateTime] DATETIME2 NULL,
  [StartUTCDate] DATE NULL,
  [EndUTCDateTime] DATETIME2 NULL,
  [EndUTCDate] DATE NULL,
  [TriggeredOnUTCDateTime] DATETIME2 NULL,
  [TriggeredOnUTCDate] DATE NULL,
  [IsAutoOptIn] BIT NULL,
  [TierCount] INT NULL,
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerEligibility] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerEligibility] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_HubPlayerID_SourceSystemID_ProductTypeID] ON [dbo].[PlayerEligibility] (  
--  [HubPlayerID] ASC,
--  [SourceSystemID] ASC,
--  [PromotionTypeID] ASC
--) INCLUDE (
--  [HubPlayerEligibilityID],
--  [ProductTypeID]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerEligibility] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [ProductTypeID],
  [PromotionTypeID],
  [StartUTCDateTime],
  [StartUTCDate],
  [EndUTCDateTime],
  [EndUTCDate],
  [TriggeredOnUTCDateTime],
  [TriggeredOnUTCDate],
  [IsAutoOptIn],
  [TierCount]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO
-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerEligibility]
  ADD CONSTRAINT [FK_PlayerEligibility_ProductType] FOREIGN KEY ([ProductTypeID]) REFERENCES [dbo].[ProductType] ([ProductTypeID]);
ALTER TABLE [dbo].[PlayerEligibility]
  ADD CONSTRAINT [FK_PlayerEligibility_PromotionType] FOREIGN KEY ([PromotionTypeID]) REFERENCES [dbo].[PromotionType] ([PromotionTypeID]);
GO
-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubPlayerEligibility] (
  [HubPlayerEligibilityID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[PlayerEligibility] (
  [HubPlayerEligibilityID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/

