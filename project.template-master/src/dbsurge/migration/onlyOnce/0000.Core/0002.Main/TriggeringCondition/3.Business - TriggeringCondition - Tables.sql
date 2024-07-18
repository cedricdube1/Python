/************************************************************************
* Script     : 3.Business - TriggeringCondition - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [dbo].[HubTriggeringCondition] (
  -- Standard Columns --
  [HubTriggeringConditionID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  [CreatedDate] DATETIME2 NOT NULL,
  CONSTRAINT [PK_HubTriggeringCondition] PRIMARY KEY CLUSTERED ([HubTriggeringConditionID] ASC, [SourceSystemID] ASC) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  -- Specific Columns --
  [GamingSystemID] INT NULL,
  [UserID] INT NULL,
  [TriggeredUTCDateTime] DATETIME2(7) NULL
) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IDX_Surge] ON [dbo].[HubTriggeringCondition] (
  [GamingSystemID] ASC,
  [UserID] ASC,
  [TriggeredUTCDateTime] ASC
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO

CREATE TABLE [dbo].[TriggeringCondition] (
  -- Standard Columns --
  [HubTriggeringConditionID] BINARY(32) NOT NULL,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_TriggeringCondition_HubTriggeringCondition] FOREIGN KEY ([HubTriggeringConditionID], [SourceSystemID]) REFERENCES [dbo].[HubTriggeringCondition] ([HubTriggeringConditionID], [SourceSystemID]),
  CONSTRAINT [PK_TriggeringCondition] PRIMARY KEY CLUSTERED (
    [HubTriggeringConditionID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [HubPlayerID] BINARY(32) NULL,
  [IdentifierID] INT NULL,
  [EventID] INT NULL,
  [TriggerResultID] INT NULL,  
  [StartUTCDateTime] DATETIME2(7) NULL,
  [StartUTCDate] DATE NULL,
  [TriggeredUTCDateTime] DATETIME2(7) NULL,
  [TriggeredUTCDate] DATE NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[TriggeringCondition] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[TriggeringCondition] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[TriggeringCondition] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [HubPlayerID],
  [IdentifierID],
  [EventID],
  [TriggerResultID],  
  [StartUTCDateTime],
  [StartUTCDate],
  [TriggeredUTCDateTime],
  [TriggeredUTCDate]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO

-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[TriggeringCondition]
  ADD CONSTRAINT [FK_TriggeringCondition_Identifier] FOREIGN KEY ([IdentifierID]) REFERENCES [dbo].[Identifier] ([IdentifierID]);
GO
ALTER TABLE [dbo].[TriggeringCondition]
  ADD CONSTRAINT [FK_TriggeringCondition_Event] FOREIGN KEY ([EventID]) REFERENCES [dbo].[Event] ([EventID]);
GO
ALTER TABLE [dbo].[TriggeringCondition]
  ADD CONSTRAINT [FK_TriggeringCondition_TriggerResult] FOREIGN KEY ([TriggerResultID]) REFERENCES [dbo].[TriggerResult] ([TriggerResultID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[HubTriggeringCondition] (
  [HubTriggeringConditionID],
  [SourceSystemID],
  [CreatedDate],
  [OriginSystemID],
  [CapturelogID]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1);
GO
INSERT INTO [dbo].[TriggeringCondition] (
  [HubTriggeringConditionID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/