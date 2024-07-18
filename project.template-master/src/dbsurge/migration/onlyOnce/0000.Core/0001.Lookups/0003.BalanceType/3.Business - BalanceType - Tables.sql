/************************************************************************
* Script     : 3.Business - BalanceType - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[BalanceType] (
  -- Standard Columns --
  [BalanceTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_BalanceType] PRIMARY KEY CLUSTERED ([BalanceTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [BalanceTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_BalanceType] UNIQUE NONCLUSTERED (
    [BalanceTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[BalanceType] ON;
  INSERT INTO [dbo].[BalanceType] ([BalanceTypeID], [CaptureLogID], [Operation], [ModifiedDate], [BalanceTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[BalanceType] OFF;

/* End of File ********************************************************************************************************************/