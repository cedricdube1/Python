/************************************************************************
* Script     : 3.Business - Event - Tables.sql
* Created By : Cedric Dube
* Created On : 2022-02-18
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[Event] (
  -- Standard Columns --
  [EventID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED ([EventID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [EventName] VARCHAR(255) NOT NULL
  CONSTRAINT [UK1_Event] UNIQUE NONCLUSTERED (
    [EventName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[Event] ON;
  INSERT INTO [dbo].[Event] ([EventID], [CaptureLogID], [Operation], [ModifiedDate], [Eventname])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[Event] OFF;

/* End of File ********************************************************************************************************************/