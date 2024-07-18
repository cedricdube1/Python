/************************************************************************
* Script     : 3.Business - DepositMethod - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[DepositMethod] (
  -- Standard Columns --
  [DepositMethodID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_DepositMethod] PRIMARY KEY CLUSTERED ([DepositMethodID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [DepositMethodName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_DepositMethod] UNIQUE NONCLUSTERED (
    [DepositMethodName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[DepositMethod] ON;
  INSERT INTO [dbo].[DepositMethod] ([DepositMethodID], [CaptureLogID], [Operation], [ModifiedDate], [DepositMethodName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[DepositMethod] OFF;

/* End of File ********************************************************************************************************************/