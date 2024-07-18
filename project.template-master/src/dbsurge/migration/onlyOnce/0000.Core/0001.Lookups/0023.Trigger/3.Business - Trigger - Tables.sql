/************************************************************************
* Script     : 3.Business - Trigger - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-09-02
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[Trigger] (
  -- Standard Columns --
  [TriggerID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Trigger] PRIMARY KEY CLUSTERED ([TriggerID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [TriggerName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_Trigger] UNIQUE NONCLUSTERED (
    [TriggerName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Trigger] ON;
  INSERT INTO [dbo].[Trigger] ([TriggerID], [CaptureLogID], [Operation], [ModifiedDate], [TriggerName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Trigger] OFF;


/* End of File ********************************************************************************************************************/