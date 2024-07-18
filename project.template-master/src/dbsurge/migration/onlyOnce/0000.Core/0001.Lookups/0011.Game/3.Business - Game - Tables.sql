/************************************************************************
* Script     : 3.Business - MGSGame - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Game] (
  -- Standard Columns --
  [GameID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Game] PRIMARY KEY CLUSTERED ([GameID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [GameName] VARCHAR(150) NOT NULL
  CONSTRAINT [UK1_Game] UNIQUE NONCLUSTERED (
    [GameName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO


-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Game] ON;
  INSERT INTO [dbo].[Game] ([GameID], [CaptureLogID], [Operation], [ModifiedDate], [GameName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Game] OFF;


/* End of File ********************************************************************************************************************/