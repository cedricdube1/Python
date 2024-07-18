/************************************************************************
* Script     : 3.Business - ExcitementBand - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[ExcitementBand] (
  -- Standard Columns --
  [ExcitementBandID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_ExcitementBand] PRIMARY KEY CLUSTERED ([ExcitementBandID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ExcitementBandName] VARCHAR(20) NOT NULL
  CONSTRAINT [UK1_ExcitementBand] UNIQUE NONCLUSTERED (
    [ExcitementBandName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[ExcitementBand] ON;
  INSERT INTO [dbo].[ExcitementBand] ([ExcitementBandID], [CaptureLogID], [Operation], [ModifiedDate], [ExcitementBandName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[ExcitementBand] OFF;

/* End of File ********************************************************************************************************************/