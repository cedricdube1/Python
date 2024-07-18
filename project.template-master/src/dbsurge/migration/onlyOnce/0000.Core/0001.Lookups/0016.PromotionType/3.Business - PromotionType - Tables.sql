/************************************************************************
* Script     : 3.Business - Promotion - Tables.sql
* Created By : PromotionType
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PromotionType] (
  -- Standard Columns --
  [PromotionTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_PromotionType] PRIMARY KEY CLUSTERED ([PromotionTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [PromotionTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_PromotionType] UNIQUE NONCLUSTERED (
    [PromotionTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[PromotionType] ON;
  INSERT INTO [dbo].[PromotionType] ([PromotionTypeID], [CaptureLogID], [Operation], [ModifiedDate], [PromotionTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[PromotionType] OFF;


/* End of File ********************************************************************************************************************/