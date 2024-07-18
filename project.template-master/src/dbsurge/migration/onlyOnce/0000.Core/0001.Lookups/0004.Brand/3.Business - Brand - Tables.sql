/************************************************************************
* Script     : 3.Business - Brand - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Brand] (
  -- Standard Columns --
  [BrandID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Brand] PRIMARY KEY CLUSTERED ([BrandID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [BrandName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_Brand] UNIQUE NONCLUSTERED (
    [BrandName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Brand] ON;
  INSERT INTO [dbo].[Brand] ([BrandID], [CaptureLogID], [Operation], [ModifiedDate], [BrandName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Brand] OFF;


/* End of File ********************************************************************************************************************/