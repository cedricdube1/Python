/************************************************************************
* Script     : 3.Business - TournamentTemplate - Tables.sql
* Created By : Hector Prakke
* Created On : 2021-09-21
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[TournamentTemplate] (
  -- Standard Columns --
  [TournamentTemplateID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_TournamentTemplate] PRIMARY KEY CLUSTERED ([TournamentTemplateID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [TournamentTemplateName] VARCHAR(255) NOT NULL,
  [TournamentTemplateDescription] VARCHAR(255) NOT NULL,
  CONSTRAINT [UK1_TournamentTemplate] UNIQUE NONCLUSTERED (
    [TournamentTemplateName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[TournamentTemplate] ON;
  INSERT INTO [dbo].[TournamentTemplate] ([TournamentTemplateID], [CaptureLogID], [Operation], [ModifiedDate], [TournamentTemplateName], [TournamentTemplateDescription])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown', 'Unknown');
SET IDENTITY_INSERT [dbo].[TournamentTemplate] OFF;


/* End of File ********************************************************************************************************************/