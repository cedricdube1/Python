/************************************************************************
* Script     : 3.Business - DepositType - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-09-20
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[DepositType] (
  -- Standard Columns --
  [DepositTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_DepositType] PRIMARY KEY CLUSTERED ([DepositTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [DepositTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_DepositType] UNIQUE NONCLUSTERED (
    [DepositTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[DepositType] ON;
  INSERT INTO [dbo].[DepositType] ([DepositTypeID], [CaptureLogID], [Operation], [ModifiedDate], [DepositTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[DepositType] OFF;


/* End of File ********************************************************************************************************************/