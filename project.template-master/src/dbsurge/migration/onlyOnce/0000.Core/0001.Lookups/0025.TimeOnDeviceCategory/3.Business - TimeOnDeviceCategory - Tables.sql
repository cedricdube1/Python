/************************************************************************
* Script     : 3.Business - TimeOnDeviceCategory - Tables.sql
* Created By : Cedric Dube
* Created On : 2022-01-25
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[TimeOnDeviceCategory] (
  -- Standard Columns --
  [TimeOnDeviceCategoryID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_TimeOnDeviceCategory] PRIMARY KEY CLUSTERED ([TimeOnDeviceCategoryID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [TimeOnDeviceCategoryName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_TimeOnDeviceCategory] UNIQUE NONCLUSTERED (
    [TimeOnDeviceCategoryName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[TimeOnDeviceCategory] ON;
  INSERT INTO [dbo].[TimeOnDeviceCategory] ([TimeOnDeviceCategoryID], [CaptureLogID], [Operation], [ModifiedDate], [TimeOnDeviceCategoryName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[TimeOnDeviceCategory] OFF;


/* End of File ********************************************************************************************************************/