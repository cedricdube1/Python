/************************************************************************
* Script     : 3.Business - Player - Tables.sql
* Created By : Hector Prakke
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[HubPlayer] (
  -- Standard Columns --
  [HubPlayerID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubPlayer] PRIMARY KEY CLUSTERED ([HubPlayerID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [GamingSystemID] INT NULL,
  [UserID] INT NULL,
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubPlayer] (
  [GamingSystemID] ASC,
  [UserID] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[Player] (
  -- Standard Columns --
  [HubPlayerID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_Player_HubPlayer] FOREIGN KEY ([HubPlayerID], [SourceSystemID]) REFERENCES [dbo].[HubPlayer] ([HubPlayerID], [SourceSystemID]),
  CONSTRAINT [PK_Player] PRIMARY KEY CLUSTERED (
    [HubPlayerID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ProductID] INT NULL,
  [SessionProductID] INT NULL,
  [CountryLongCode] CHAR(3) NULL,
  [StateCode] VARCHAR(3) NULL,
  [BrandID] INT NULL,
  [CurrencyCode] CHAR(3) NULL,
  [RegistrationUTCDateTime] DATETIME2 NULL,
  [RegistrationUTCDate] DATE NULL,
  [IPAddress] VARCHAR(45) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[Player] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[Player] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[Player] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [ProductID],
  [SessionProductID],
  [CountryLongCode],
  [StateCode],
  [BrandID],
  [CurrencyCode],
  [RegistrationUTCDateTime],
  [RegistrationUTCDate],
  [IPAddress]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[Player]
  ADD CONSTRAINT [FK_Player_Brand] FOREIGN KEY ([BrandID]) REFERENCES [dbo].[Brand] ([BrandID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubPlayer] (
  [HubPlayerID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[Player] (
  [HubPlayerID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/