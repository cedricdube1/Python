/************************************************************************
* Script     : 3.Business - AdjustedPercentageSource - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[AdjustedPercentageSource] (
  -- Standard Columns --
  [AdjustedPercentageSourceID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_AdjustedPercentageSource] PRIMARY KEY CLUSTERED ([AdjustedPercentageSourceID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [AdjustedPercentageSourceName] VARCHAR(255) NOT NULL
  CONSTRAINT [UK1_AdjustedPercentageSource] UNIQUE NONCLUSTERED (
    [AdjustedPercentageSourceName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[AdjustedPercentageSource] ON;
  INSERT INTO [dbo].[AdjustedPercentageSource] ([AdjustedPercentageSourceID], [CaptureLogID], [Operation], [ModifiedDate], [AdjustedPercentageSourceName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[AdjustedPercentageSource] OFF;

/* End of File ********************************************************************************************************************/