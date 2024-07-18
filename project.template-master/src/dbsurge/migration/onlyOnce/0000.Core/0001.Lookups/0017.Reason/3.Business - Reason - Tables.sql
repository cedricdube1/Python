/************************************************************************
* Script     : 3.Business - Reason - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Reason] (
  -- Standard Columns --
  [ReasonID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Reason] PRIMARY KEY CLUSTERED ([ReasonID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [Reason] VARCHAR(255) NOT NULL
  CONSTRAINT [UK1_Reason] UNIQUE NONCLUSTERED (
    [Reason] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO


-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Reason] ON;
  INSERT INTO [dbo].[Reason] ([ReasonID], [CaptureLogID], [Operation], [ModifiedDate], [Reason])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Reason] OFF;



/* End of File ********************************************************************************************************************/