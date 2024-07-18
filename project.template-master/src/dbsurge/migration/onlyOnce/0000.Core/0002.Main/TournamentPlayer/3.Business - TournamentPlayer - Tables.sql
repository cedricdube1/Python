/************************************************************************
* Script     : 3.Business - TournamentPlayer - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

/* Hub & Detail Tables */

CREATE TABLE [dbo].[HubTournamentPlayer] (
  -- Standard Columns --
  [HubTournamentPlayerID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubTournamentPlayer] PRIMARY KEY CLUSTERED ([HubTournamentPlayerID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [TournamentID] INT NULL,
  [GamingSystemID] INT NULL,
  [UserID] INT NULL
) ON [PRIMARY]; 
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubTournamentPlayer] (
  [TournamentID] ASC,
  [GamingSystemID] ASC,
  [UserID] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[TournamentPlayer] (
  -- Standard Columns --
  [TournamentPlayerKey] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_TournamentPlayer] PRIMARY KEY CLUSTERED ([TournamentPlayerKey] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 100),
  [HubTournamentPlayerID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [IsCurrent] BIT NOT NULL,
  [FromDate] DATETIME2 NOT NULL,
  [ToDate] DATETIME2 NOT NULL,
  CONSTRAINT [FK1_TournamentPlayer_HubTournamentPlayer] FOREIGN KEY ([HubTournamentPlayerID], [SourceSystemID]) REFERENCES [dbo].[HubTournamentPlayer] ([HubTournamentPlayerID], [SourceSystemID]),

  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns -- 
  [HubTournamentID] BINARY(32) NULL,
  [HubPlayerID] BINARY(32) NULL,
  [SessionProductID] INT NULL, 
  [StatusID] INT NULL, 
  [TournamentTemplateID] INT NULL, 
  [CurrencyCode] CHAR(3) NULL,
  [LeaderBoardPosition] INT NULL,
  [IsCompleteLeaderboard] BIT NULL,
  [Score] INT NULL,
  [PrizeAmount] DECIMAL (19,4) NULL
) ON [PRIMARY]; 
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[TournamentPlayer] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[TournamentPlayer] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
--CREATE UNIQUE NONCLUSTERED INDEX [UK1_TournamentPlayer] ON  [dbo].[TournamentPlayer](
--    [HubTournamentPlayerID] ASC,
--    [SourceSystemID] ASC,
--    [FromDate] ASC,
--    [ToDate] ASC
--  ) WHERE [IsCurrent]  = 1 WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 100);
--GO
--CREATE NONCLUSTERED INDEX [IDX_HubTournamentPlayer] ON [dbo].[TournamentPlayer] ([HubTournamentPlayerID],[SourceSystemID])
--INCLUDE ([ModifiedDate],[HubPlayerID],[StatusID],[CurrencyCode],[LeaderBoardPosition],[Score],[PrizeAmount])
--GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[TournamentPlayer] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubTournamentID],
  [HubPlayerID],
  [SessionProductID], 
  [StatusID], 
  [TournamentTemplateID], 
  [CurrencyCode],
  [LeaderBoardPosition],
  [IsCompleteLeaderboard],
  [Score],
  [PrizeAmount]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

                                                                                                                                                                                                                                    
-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[TournamentPlayer]
  ADD CONSTRAINT [FK_TournamentPlayer_Status] FOREIGN KEY ([StatusID]) REFERENCES [dbo].[Status] ([StatusID]);
ALTER TABLE [dbo].[TournamentPlayer]
  ADD CONSTRAINT [FK_TournamentPlayer_TournamentTemplate] FOREIGN KEY ([TournamentTemplateID]) REFERENCES [dbo].[TournamentTemplate] ([TournamentTemplateID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubTournamentPlayer] (
  [HubTournamentPlayerID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
SET IDENTITY_INSERT [dbo].[TournamentPlayer] ON;
INSERT INTO [dbo].[TournamentPlayer] (
  [TournamentPlayerKey],
  [HubTournamentPlayerID],
  [SourceSystemID],
  [IsCurrent],
  [FromDate],
  [ToDate],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (-1, 0x0000000000000000000000000000000000000000000000000000000000000000, -1, -1, '1900-01-01', '9999-12-31', '1900-01-01', -1, -1, 'I');
GO
SET IDENTITY_INSERT [dbo].[TournamentPlayer] OFF;
/* End of File ********************************************************************************************************************/


/**********************************************************************************************
--For Analysis01 only

ALTER TABLE [dbo].[TournamentPlayer]
	ADD [SessionProductID] INT NULL;

UPDATE [dbo].[TournamentPlayer]
SET [SessionProductID] = 0
WHERE [SessionProductID] IS NULL;
**********************************************************************************************/

