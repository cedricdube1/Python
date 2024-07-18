/************************************************************************
* Script     : 3.Business - Status - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Status] (
  -- Standard Columns --
  [StatusID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED ([StatusID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [StatusName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_Status] UNIQUE NONCLUSTERED (
    [StatusName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Status] ON;
  INSERT INTO [dbo].[Status] ([StatusID], [CaptureLogID], [Operation], [ModifiedDate], [StatusName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Status] OFF;


/* End of File ********************************************************************************************************************/