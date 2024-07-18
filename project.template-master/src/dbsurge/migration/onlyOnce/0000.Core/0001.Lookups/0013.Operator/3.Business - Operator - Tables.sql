/************************************************************************
* Script     : 3.Business - Operator - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-09-21
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Operator] (
  -- Standard Columns --
  [OperatorID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Operator] PRIMARY KEY CLUSTERED ([OperatorID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [OperatorName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_Operator] UNIQUE NONCLUSTERED (
    [OperatorName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Operator] ON;
  INSERT INTO [dbo].[Operator] ([OperatorID], [CaptureLogID], [Operation], [ModifiedDate], [OperatorName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Operator] OFF;


/* End of File ********************************************************************************************************************/