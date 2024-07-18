/************************************************************************
* Script     : 3.Business - TriggerResult - Tables.sql
* Created By : Hector Prakke
* Created On : 2021-09-21
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[TriggerResult] (
  -- Standard Columns --
  [TriggerResultID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_TriggerResult] PRIMARY KEY CLUSTERED ([TriggerResultID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [TriggerResults] VARCHAR(2000) NOT NULL,
  [AdditionalData] VARCHAR(2000) NOT NULL--,
  --CONSTRAINT [UK1_TriggerResult] UNIQUE NONCLUSTERED (
  --  [TriggerResults] ASC
  --) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[TriggerResult] ON;
  INSERT INTO [dbo].[TriggerResult] ([TriggerResultID], [CaptureLogID], [Operation], [ModifiedDate], [TriggerResults], [AdditionalData])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown', 'Unknown');
SET IDENTITY_INSERT [dbo].[TriggerResult] OFF;


/* End of File ********************************************************************************************************************/