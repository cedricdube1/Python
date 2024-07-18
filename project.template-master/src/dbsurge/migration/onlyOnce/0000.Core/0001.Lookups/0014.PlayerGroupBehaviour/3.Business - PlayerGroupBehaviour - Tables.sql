/************************************************************************
* Script     : 3.Business - PlayerGroupBehaviour - Tables.sql
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
CREATE TABLE [dbo].[PlayerGroupBehaviour] (
  -- Standard Columns --
  [PlayerGroupBehaviourID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_PlayerGroupBehaviour] PRIMARY KEY CLUSTERED ([PlayerGroupBehaviourID] ASC) WITH (FILLFACTOR = 100),
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [PlayerGroupBehaviourName] VARCHAR(50) NOT NULL
  CONSTRAINT [UK1_PlayerGroupBehaviour] UNIQUE NONCLUSTERED (
    [PlayerGroupBehaviourName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- INSERT DEFAULT --
SET IDENTITY_INSERT [dbo].[PlayerGroupBehaviour] ON;
  INSERT INTO [dbo].[PlayerGroupBehaviour] ([PlayerGroupBehaviourID], [CaptureLogID], [Operation], [ModifiedDate], [PlayerGroupBehaviourName])
    VALUES (-1, -1, 'I', CAST('1900-01-01' AS DATETIME2), 'Unknown');
SET IDENTITY_INSERT [dbo].[PlayerGroupBehaviour] OFF;

/* End of File ********************************************************************************************************************/