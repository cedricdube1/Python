/************************************************************************
* Script     : 3.Business - Identifier - Tables.sql
* Created By : Cedric Dube
* Created On : 2022-02-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Identifier] (
  -- Standard Columns --
  [IdentifierID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Identifier] PRIMARY KEY CLUSTERED ([IdentifierID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [IdentifierName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_Identifier] UNIQUE NONCLUSTERED (
    [IdentifierName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Identifier] ON;
  INSERT INTO [dbo].[Identifier] ([IdentifierID], [CaptureLogID], [Operation], [ModifiedDate], [IdentifierName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Identifier] OFF;


/* End of File ********************************************************************************************************************/