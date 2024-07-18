/************************************************************************
* Script     : 3.Business - ValueSegment - Tables.sql
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
CREATE TABLE [dbo].[ValueSegment] (
  -- Standard Columns --
  [ValueSegmentID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_ValueSegment] PRIMARY KEY CLUSTERED ([ValueSegmentID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [ValueSegmentName] VARCHAR(20) NOT NULL  
  CONSTRAINT [UK1_ValueSegment] UNIQUE NONCLUSTERED (
    [ValueSegmentName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[ValueSegment] ON;
  INSERT INTO [dbo].[ValueSegment] ([ValueSegmentID], [CaptureLogID], [Operation], [ModifiedDate], [ValueSegmentName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[ValueSegment] OFF;


/* End of File ********************************************************************************************************************/