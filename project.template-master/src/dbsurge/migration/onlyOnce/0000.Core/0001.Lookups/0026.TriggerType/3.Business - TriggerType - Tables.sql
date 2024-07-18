/************************************************************************
* Script     : 3.Business - TriggerType - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-13
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[TriggerType] (
  -- Standard Columns --
  [TriggerTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_TriggerType] PRIMARY KEY CLUSTERED ([TriggerTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [TriggerTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_TriggerType] UNIQUE NONCLUSTERED (
    [TriggerTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[TriggerType] ON;
  INSERT INTO [dbo].[TriggerType] ([TriggerTypeID], [CaptureLogID], [Operation], [ModifiedDate], [TriggerTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[TriggerType] OFF;


/* End of File ********************************************************************************************************************/