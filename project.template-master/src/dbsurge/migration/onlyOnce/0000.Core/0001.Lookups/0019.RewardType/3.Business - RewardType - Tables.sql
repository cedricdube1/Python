/************************************************************************
* Script     : 3.Business - RewardType - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[RewardType] (
  -- Standard Columns --
  [RewardTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_RewardType] PRIMARY KEY CLUSTERED ([RewardTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [RewardTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_RewardType] UNIQUE NONCLUSTERED (
    [RewardTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[RewardType] ON;
  INSERT INTO [dbo].[RewardType] ([RewardTypeID], [CaptureLogID], [Operation], [ModifiedDate], [RewardTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[RewardType] OFF;


/* End of File ********************************************************************************************************************/