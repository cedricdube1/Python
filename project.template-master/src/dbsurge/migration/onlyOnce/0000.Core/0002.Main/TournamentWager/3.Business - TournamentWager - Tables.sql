/************************************************************************
* Script     : 3.Business - TournamentWager - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-05-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

/* Hub & Detail Tables */

CREATE TABLE [dbo].[HubTournamentWager] (
  -- Standard Columns --
  [HubTournamentWagerID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubTournamentWager] PRIMARY KEY CLUSTERED ([HubTournamentWagerID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [TournamentID] INT NULL,
  [GamingSystemID] INT NULL,
  [UserID] INT NULL,
  [UserTransNumber] INT NULL
) ON [PRIMARY]; 
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubTournamentWager] (
  [TournamentID] ASC,
  [GamingSystemID] ASC,
  [UserID] ASC,
  [UserTransNumber] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[TournamentWager] (
  -- Standard Columns --
  [HubTournamentWagerID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_TournamentWager_HubTournamentWager] FOREIGN KEY ([HubTournamentWagerID], [SourceSystemID]) REFERENCES [dbo].[HubTournamentWager] ([HubTournamentWagerID], [SourceSystemID]),
  CONSTRAINT [PK_TournamentWager] PRIMARY KEY CLUSTERED (
    [HubTournamentWagerID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns -- 
  [HubTournamentID] BINARY(32) NULL,
  [HubPlayerID] BINARY(32) NULL,
  [ModuleId] INT NULL, 
  [ClientId] INT NULL, 
  [CountryCode] CHAR(3) NULL,
  [WagerUTCDateTime] DATETIME2 NULL,
  [WagerUTCDate] DATE NULL,
  [WagerAmount] DECIMAL (19,4) NULL,
  [PayoutAmount] DECIMAL (19,4) NULL,
  [CashBalance] DECIMAL (19,4) NULL,
  [MinBetAmount] DECIMAL (19,4) NULL,
  [MaxBetAmount] DECIMAL (19,4) NULL
) ON [PRIMARY]; 
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[TournamentWager] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[TournamentWager] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[TournamentWager] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubTournamentID],
  [HubPlayerID],
  [ModuleId], 
  [ClientId], 
  [CountryCode],
  [WagerUTCDateTime],
  [WagerUTCDate],
  [WagerAmount],
  [PayoutAmount],
  [CashBalance],
  [MinBetAmount],
  [MaxBetAmount]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO
                                                                                                                                                                                                                                    
-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubTournamentWager] (
  [HubTournamentWagerID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[TournamentWager] (
  [HubTournamentWagerID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/