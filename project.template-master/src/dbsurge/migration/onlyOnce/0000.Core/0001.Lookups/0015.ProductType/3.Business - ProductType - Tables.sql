/************************************************************************
* Script     : 3.Business - ProductType - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[ProductType] (
  -- Standard Columns --
  [ProductTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED ([ProductTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ProductTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_ProductType] UNIQUE NONCLUSTERED (
    [ProductTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[ProductType] ON;
  INSERT INTO [dbo].[ProductType] ([ProductTypeID], [CaptureLogID], [Operation], [ModifiedDate], [ProductTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[ProductType] OFF;

/* End of File ********************************************************************************************************************/