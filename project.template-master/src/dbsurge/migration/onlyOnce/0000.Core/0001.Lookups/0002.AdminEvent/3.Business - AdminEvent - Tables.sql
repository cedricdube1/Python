/************************************************************************
* Script     : 3.Business - AdminEvent - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-07-27
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[AdminEventType] (
  -- Standard Columns --
  [AdminEventTypeID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_AdminEventType] PRIMARY KEY CLUSTERED ([AdminEventTypeID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [AdminEventTypeName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_AdminEventType] UNIQUE NONCLUSTERED (
    [AdminEventTypeName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO


GO
CREATE TABLE [dbo].[AdminEvent] (
  -- Standard Columns --
  [AdminEventID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_AdminEvent] PRIMARY KEY CLUSTERED ([AdminEventID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [AdminEventName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_AdminEvent] UNIQUE NONCLUSTERED (
    [AdminEventName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[AdminEventType] ON;
  INSERT INTO [dbo].[AdminEventType] ([AdminEventTypeID], [CaptureLogID], [Operation], [ModifiedDate], [AdminEventTypeName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[AdminEventType] OFF;

SET IDENTITY_INSERT [dbo].[AdminEvent] ON;
  INSERT INTO [dbo].[AdminEvent] ([AdminEventID], [CaptureLogID], [Operation], [ModifiedDate], [AdminEventName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[AdminEvent] OFF;

/* End of File ********************************************************************************************************************/