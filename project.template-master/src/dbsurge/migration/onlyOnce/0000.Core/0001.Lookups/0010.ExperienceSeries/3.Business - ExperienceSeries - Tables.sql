/************************************************************************
* Script     : 3.Business - ExperienceSeries - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[ExperienceSeries] (
  -- Standard Columns --
  [ExperienceSeriesID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_ExperienceSeries] PRIMARY KEY CLUSTERED ([ExperienceSeriesID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ExperienceSeriesName] VARCHAR(255) NOT NULL
  CONSTRAINT [UK1_ExperienceSeries] UNIQUE NONCLUSTERED (
    [ExperienceSeriesName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[ExperienceSeries] ON;
  INSERT INTO [dbo].[ExperienceSeries] ([ExperienceSeriesID], [CaptureLogID], [Operation], [ModifiedDate], [ExperienceSeriesName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[ExperienceSeries] OFF;

/* End of File ********************************************************************************************************************/