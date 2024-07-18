/************************************************************************
* Script     : 3.Business - TournamentGroup - Tables.sql
* Created By : Hector Prakke
* Created On : 2021-09-21
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[TournamentGroup] (
  -- Standard Columns --
  [TournamentGroupID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_TournamentGroup] PRIMARY KEY CLUSTERED ([TournamentGroupID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [TournamentGroupName] VARCHAR(20) NOT NULL,
  CONSTRAINT [UK1_TournamentGroup] UNIQUE NONCLUSTERED (
    [TournamentGroupName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[TournamentGroup] ON;
  INSERT INTO [dbo].[TournamentGroup] ([TournamentGroupID], [CaptureLogID], [Operation], [ModifiedDate], [TournamentGroupName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[TournamentGroup] OFF;


/* End of File ********************************************************************************************************************/