/************************************************************************
* Script     : 3.Business - Tournament - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-04
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

/* Hub & Detail Tables */

CREATE TABLE [dbo].[HubTournament] (
  -- Standard Columns --
  [HubTournamentID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubTournament] PRIMARY KEY CLUSTERED ([HubTournamentID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL, -- Part of Hub in this case
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [TournamentID] INT NULL
) ON [PRIMARY]; 
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubTournament] (
  [TournamentID] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[Tournament] (
  -- Standard Columns --
  [HubTournamentID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_Tournament_HubTournament] FOREIGN KEY ([HubTournamentID], [SourceSystemID]) REFERENCES [dbo].[HubTournament] ([HubTournamentID], [SourceSystemID]),
  CONSTRAINT [PK_Tournament] PRIMARY KEY CLUSTERED (
    [HubTournamentID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ProductID] INT NULL,
  [GameID] INT NULL, --References Game
  [RegionID] INT NULL, --References Region
  [OperatorID] INT NULL, --References Operator
  [StatusID] INT, --References Status
  [TournamentTemplateID] INT NULL, -- References TournamentTemplate
  [TournamentGroupID] INT NULL, -- References TournamentGroup
  [CurrencyCode] CHAR(3) NULL,
  [StartUTCDateTime] DATETIME2 NULL,
  [StartUTCDate] DATE NULL,
  [EndUTCDateTime] DATETIME2 NULL,
  [EndUTCDate] DATE NULL,
  [MinNumberOfPlayers] INT  NULL,
  [MaxNumberOfPlayers] INT NULL,
  [CoinValue] INT NULL,
  [IsNetwork] BIT NULL
) ON [PRIMARY]; 
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[Tournament] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[Tournament] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE NONCLUSTERED INDEX [IDX_StartUTCDateTime] ON [dbo].[Tournament] (  
--  [StartUTCDateTime] ASC
--) INCLUDE (
--  [HubTournamentID],
--  [SourceSystemID],
--  [GameID],
--  [RegionID],
--  [TournamentGroupID],
--  [TournamentTemplateID],
--  [IsNetwork]
--) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[Tournament] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [ProductID],
  [GameID], --References Game
  [RegionID], --References Region
  [OperatorID], --References Operator
  [StatusID], --References Status
  [TournamentTemplateID], -- References TournamentTemplate
  [TournamentGroupID], -- References TournamentGroup
  [CurrencyCode],
  [StartUTCDateTime],
  [StartUTCDate],
  [EndUTCDateTime],
  [EndUTCDate],
  [MinNumberOfPlayers],
  [MaxNumberOfPlayers],
  [CoinValue],
  [IsNetwork]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO
                                                                                                                                                                                                                                    
-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[Tournament]
  ADD CONSTRAINT [FK_Tournament_Game] FOREIGN KEY ([GameID]) REFERENCES [dbo].[Game] ([GameID]);
ALTER TABLE [dbo].[Tournament]
  ADD CONSTRAINT [FK_Tournament_Region] FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Region] ([RegionID]);
ALTER TABLE [dbo].[Tournament]
  ADD CONSTRAINT [FK_Tournament_Operator] FOREIGN KEY ([OperatorID]) REFERENCES [dbo].[Operator] ([OperatorID]);
ALTER TABLE [dbo].[Tournament]
  ADD CONSTRAINT [FK_Tournament_Status] FOREIGN KEY ([StatusID]) REFERENCES [dbo].[Status] ([StatusID]);
ALTER TABLE [dbo].[Tournament]
  ADD CONSTRAINT [FK_Tournament_TournamentTemplate] FOREIGN KEY ([TournamentTemplateID]) REFERENCES [dbo].[TournamentTemplate] ([TournamentTemplateID]);
ALTER TABLE [dbo].[Tournament]
  ADD CONSTRAINT [FK_Tournament_TournamentGroup] FOREIGN KEY ([TournamentGroupID]) REFERENCES [dbo].[TournamentGroup] ([TournamentGroupID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubTournament] (
  [HubTournamentID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[Tournament] (
  [HubTournamentID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/