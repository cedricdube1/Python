/************************************************************************
* Script     : 3.Business - Experience - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Experience] (
  -- Standard Columns --
  [ExperienceID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Experience] PRIMARY KEY CLUSTERED ([ExperienceID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ExperienceName] VARCHAR(255) NOT NULL
  CONSTRAINT [UK1_Experience] UNIQUE NONCLUSTERED (
    [ExperienceName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Experience] ON;
  INSERT INTO [dbo].[Experience] ([ExperienceID], [CaptureLogID], [Operation], [ModifiedDate], [ExperienceName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Experience] OFF;

/* End of File ********************************************************************************************************************/