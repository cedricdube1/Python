/************************************************************************
* Script     : 3.Business - Region - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Region] (
  -- Standard Columns --
  [RegionID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Region] PRIMARY KEY CLUSTERED ([RegionID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [RegionName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_Region] UNIQUE NONCLUSTERED (
    [RegionName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Region] ON;
  INSERT INTO [dbo].[Region] ([RegionID], [CaptureLogID], [Operation], [ModifiedDate], [RegionName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Region] OFF;



/* End of File ********************************************************************************************************************/