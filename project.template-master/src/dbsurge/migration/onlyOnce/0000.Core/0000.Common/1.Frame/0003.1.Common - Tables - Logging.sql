/****************************************************************************************************************************
* Script      : 3.Common - Tables - Logging.sql                                                                            *
* Created By  : Cedric Dube                                                                                               *
* Created On  : 2020-10-02                                                                                                  *
* Execute On  : As required.                                                                         *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO

-- JobLog --
GO
CREATE TABLE [Logging].[Job](
  [JobLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_JobLog] PRIMARY KEY CLUSTERED ([JobLogID] ASC, [JobLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [JobID] SMALLINT NOT NULL
  CONSTRAINT [FK_JobLog_Job] FOREIGN KEY ([JobID]) REFERENCES [Config].[Job] ([JobID]),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_JobLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [JobLogCreatedMonth] AS CAST(DATEPART(MONTH, [CreatedDateTime]) AS TINYINT) PERSISTED,
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_JobLog_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_JobLog_StatusCode] CHECK ([StatusCode] IN (0, 1, 2, 3)),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([JobLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_Job] ON [Logging].[Job] (
  [JobID] ASC,
  [StatusCode] ASC
) WITH (FILLFACTOR = 90);
GO

-- ProcessLog --
GO
CREATE TABLE [Logging].[Process](
  [ProcessLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ProcessLog] PRIMARY KEY CLUSTERED ([ProcessLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessID] SMALLINT NOT NULL
  CONSTRAINT [FK_Log_Process] FOREIGN KEY ([ProcessID]) REFERENCES [Config].[Process] ([ProcessID]),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_Log_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [ProcessLogCreatedMonth] AS CAST(DATEPART(MONTH, [CreatedDateTime]) AS TINYINT) PERSISTED,
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_Log_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_Log_StatusCode] CHECK ([StatusCode] IN (0, 1, 2, 3)),
  [SourceProcessLogID] BIGINT NULL,
  INDEX [IDX_SourceProcessLog] NONCLUSTERED ([SourceProcessLogID] ASC) WITH (FILLFACTOR = 90),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_Process] ON [Logging].[Process] (
  [ProcessID] ASC,
  [StatusCode] ASC
) WITH (FILLFACTOR = 90);
GO


-- TaskLog --
GO
CREATE TABLE [Logging].[ProcessTask](
  [ProcessTaskLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_TaskLog] PRIMARY KEY CLUSTERED ([ProcessTaskLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_TaskLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_TaskLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_TaskLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_TaskLog_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_TaskLog_StatusCode] CHECK ([StatusCode] IN (0, 1, 2, 3)),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLogID] ON [Logging].[ProcessTask] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC,
  [StatusCode] ASC
)  WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessTaskID] ON [Logging].[ProcessTask] (
  [ProcessTaskID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [StatusCode] ASC
) INCLUDE (
  [StartDateTime],
  [EndDateTime]
) WITH (FILLFACTOR = 90);
GO

-- BulkExtractByIDLog --
GO
CREATE TABLE [Logging].[BulkExtractByID](
  [BulkExtractByIDLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_BulkExtractByIDLog] PRIMARY KEY CLUSTERED ([BulkExtractByIDLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_BulkExtractByIDLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_BulkExtractByIDLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ProcessTaskLogID] BIGINT NOT NULL,
  CONSTRAINT [FK_BulkExtractByIDLog_ProcessTaskLog] FOREIGN KEY ([ProcessTaskLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[ProcessTask] ([ProcessTaskLogID], [ProcessLogCreatedMonth]),
  [TaskExtractSourceID] INT NOT NULL
  CONSTRAINT [FK_BulkExtractByIDLog_TaskExtractSource] FOREIGN KEY ([TaskExtractSourceID]) REFERENCES [Config].[ProcessTaskExtractSource] ([TaskExtractSourceID]),
  [MinSourceTableID] BIGINT NOT NULL,
  [MaxSourceTableID] BIGINT NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_BulkExtractByIDLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_BulkExtractByIDLog_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_BulkExtractByIDLog_StatusCode] CHECK ([StatusCode] IN (-1, 0, 1, 2, 3)),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLog] ON [Logging].[BulkExtractByID] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC,
  [StatusCode] ASC
)  WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessTask] ON [Logging].[BulkExtractByID] (
  [ProcessTaskID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [TaskExtractSourceID] ASC,
  [StatusCode] ASC
) INCLUDE (
  [MinSourceTableID],
  [MaxSourceTableID]
) WITH (FILLFACTOR = 90);
GO

-- BulkExtractByDateLog --
GO
CREATE TABLE [Logging].[BulkExtractByDate](
  [BulkExtractByDateLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_BulkExtractByDateLog] PRIMARY KEY CLUSTERED ([BulkExtractByDateLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_BulkExtractByDateLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_BulkExtractByDateLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ProcessTaskLogID] BIGINT NOT NULL,
  CONSTRAINT [FK_BulkExtractByDateLog_ProcessTaskLog] FOREIGN KEY ([ProcessTaskLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[ProcessTask] ([ProcessTaskLogID], [ProcessLogCreatedMonth]),
  [TaskExtractSourceID] INT NOT NULL
  CONSTRAINT [FK_BulkExtractByDateLog_TaskExtractSource] FOREIGN KEY ([TaskExtractSourceID]) REFERENCES [Config].[ProcessTaskExtractSource] ([TaskExtractSourceID]),
  [MinSourceDateTime] DATETIME2 NOT NULL,
  [MaxSourceDateTime] DATETIME2 NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_BulkExtractByDateLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_BulkExtractByDateLog_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_BulkExtractByDateLog_StatusCode] CHECK ([StatusCode] IN (-1, 0, 1, 2, 3)),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLog] ON [Logging].[BulkExtractByDate] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC,
  [StatusCode] ASC
)  WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessTask] ON [Logging].[BulkExtractByDate] (
  [ProcessTaskID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [TaskExtractSourceID] ASC,
  [StatusCode] ASC
) INCLUDE (
  [MinSourceDateTime],
  [MaxSourceDateTime]
) WITH (FILLFACTOR = 90);
GO

-- CDOExtractByIDLog --
GO
CREATE TABLE [Logging].[CDOExtractByID](
  [CDOExtractByIDLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_CDOExtractByIDLog] PRIMARY KEY CLUSTERED ([CDOExtractByIDLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_CDOExtractByIDLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_CDOExtractByIDLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ProcessTaskLogID] BIGINT NOT NULL,
  CONSTRAINT [FK_CDOExtractByIDLog_ProcessTaskLog] FOREIGN KEY ([ProcessTaskLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[ProcessTask] ([ProcessTaskLogID], [ProcessLogCreatedMonth]),
  [TaskExtractSourceID] INT NOT NULL
  CONSTRAINT [FK_CDOExtractByIDLog_TaskExtractSource] FOREIGN KEY ([TaskExtractSourceID]) REFERENCES [Config].[ProcessTaskExtractSource] ([TaskExtractSourceID]),
  [MinSourceTableID] BIGINT NOT NULL,
  [MaxSourceTableID] BIGINT NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_CDOExtractByIDLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_CDOExtractByIDLog_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_CDOExtractByIDLog_StatusCode] CHECK ([StatusCode] IN (-1, 0, 1, 2, 3)),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLog] ON [Logging].[CDOExtractByID] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC,
  [StatusCode] ASC
)  WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessTask] ON [Logging].[CDOExtractByID] (
  [ProcessTaskID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [TaskExtractSourceID] ASC,
  [StatusCode] ASC
) INCLUDE (
  [MinSourceTableID],
  [MaxSourceTableID]
) WITH (FILLFACTOR = 90);
GO

-- CDOExtractByDateLog --
GO
CREATE TABLE [Logging].[CDOExtractByDate](
  [CDOExtractByDateLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_CDOExtractByDateLog] PRIMARY KEY CLUSTERED ([CDOExtractByDateLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_CDOExtractByDateLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_CDOExtractByDateLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ProcessTaskLogID] BIGINT NOT NULL,
  CONSTRAINT [FK_CDOExtractByDateLog_ProcessTaskLog] FOREIGN KEY ([ProcessTaskLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[ProcessTask] ([ProcessTaskLogID], [ProcessLogCreatedMonth]),
  [TaskExtractSourceID] INT NOT NULL
  CONSTRAINT [FK_CDOExtractByDateLog_TaskExtractSource] FOREIGN KEY ([TaskExtractSourceID]) REFERENCES [Config].[ProcessTaskExtractSource] ([TaskExtractSourceID]),
  [MinSourceDateTime] DATETIME2 NOT NULL,
  [MaxSourceDateTime] DATETIME2 NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_CDOExtractByDateLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [StatusCode] TINYINT NOT NULL
  CONSTRAINT [DF_CDOExtractByDateLog_StatusCode] DEFAULT (0),
  CONSTRAINT [CK_CDOExtractByDateLog_StatusCode] CHECK ([StatusCode] IN (-1, 0, 1, 2, 3)),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLog] ON [Logging].[CDOExtractByDate] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC,
  [StatusCode] ASC
)  WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessTask] ON [Logging].[CDOExtractByDate] (
  [ProcessTaskID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [TaskExtractSourceID] ASC,
  [StatusCode] ASC
) INCLUDE (
  [MinSourceDateTime],
  [MaxSourceDateTime]
) WITH (FILLFACTOR = 90);
GO

-- TaskCaptureLog --
GO
CREATE TABLE [Logging].[ProcessTaskCapture](
  [ProcessTaskCaptureLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ProcessTaskCaptureLog] PRIMARY KEY CLUSTERED ([ProcessTaskCaptureLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_ProcessTaskCaptureLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_ProcessTaskCaptureLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ProcessTaskLogID] BIGINT NOT NULL,
  CONSTRAINT [FK_ProcessTaskCaptureLog_ProcessTaskLog] FOREIGN KEY ([ProcessTaskLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[ProcessTask] ([ProcessTaskLogID], [ProcessLogCreatedMonth]),
  [TargetObject] NVARCHAR(128) NOT NULL,
  [RaiseCount] INT NOT NULL,
  [MergeCount] INT NOT NULL,
  [InsertCount] INT NOT NULL,
  [UpdateCount] INT NOT NULL,
  [DeleteCount] INT NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_ProcessTaskCaptureLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLog] ON [Logging].[ProcessTaskCapture] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC
)  INCLUDE (
  [TargetObject],
  [RaiseCount],
  [MergeCount],
  [InsertCount],
  [UpdateCount],
  [DeleteCount]
) WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_EffectedObject] ON [Logging].[ProcessTaskCapture] (
  [TargetObject] ASC
) INCLUDE (
  [CreatedDateTime]
) WITH (FILLFACTOR = 90);
GO
ALTER TABLE [Logging].[ProcessTaskCapture] ADD [TargetObjectType] VARCHAR(10) NULL;
GO
CREATE NONCLUSTERED INDEX [IDX_EffectedObjectType] ON [Logging].[ProcessTaskCapture] (
  [TargetObjectType] ASC
) INCLUDE (
  [TargetObject],
  [CreatedDateTime]
) WITH (FILLFACTOR = 90);
GO
-- TaskInfoLog --
GO
CREATE TABLE [Logging].[ProcessTaskInfo](
  [ProcessTaskInfoLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_TaskInfoLog] PRIMARY KEY CLUSTERED ([ProcessTaskInfoLogID] ASC, [ProcessLogCreatedMonth] ASC) WITH (FILLFACTOR = 100),
  [ProcessLogID] BIGINT NOT NULL,
  [ProcessLogCreatedMonth] TINYINT NOT NULL,
  CONSTRAINT [FK_ProcessTaskInfoLog_ProcessLog] FOREIGN KEY ([ProcessLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[Process] ([ProcessLogID], [ProcessLogCreatedMonth]),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_ProcessTaskInfoLog_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ProcessTaskLogID] BIGINT NOT NULL,
  --CONSTRAINT [FK_ProcessTaskInfoLog_ProcessTaskLog] FOREIGN KEY ([ProcessTaskLogID], [ProcessLogCreatedMonth]) REFERENCES [Logging].[ProcessTask] ([ProcessTaskLogID], [ProcessLogCreatedMonth]),
  [Ordinal] INT NULL,
  [InfoMessage] VARCHAR(500) NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_TaskInfoLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  [StartDateTime] DATETIME2 NOT NULL,
  [EndDateTime] DATETIME2 NULL
) ON [PartScheme_Logging_MonthNumber] ([ProcessLogCreatedMonth]);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessLog] ON [Logging].[ProcessTaskInfo] (
  [ProcessLogID] ASC,
  [ProcessLogCreatedMonth] ASC,
  [ProcessTaskLogID] ASC
)  INCLUDE (
  [Ordinal]
) WITH (FILLFACTOR = 90);
GO

-- ErrorLog --
GO
CREATE TABLE [Logging].[Error](
  [ErrorLogID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogID] ASC) WITH (FILLFACTOR = 100),
  [ProcessID] SMALLINT NULL,
  [TaskID] SMALLINT NULL,
  [ProcessLogID] BIGINT NULL,
  [ProcessTaskLogID] BIGINT NULL,
  [ErrorNumber] INT NULL,
  [ErrorProcedure] NVARCHAR(128) NULL,
  [ErrorLine] INT NULL,
  [ErrorMessage] NVARCHAR (4000) NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_ErrorLog_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),  
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_Process] ON [Logging].[Error] (
  [ProcessID] ASC,
  [ProcessLogID] ASC
) WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ProcessTask] ON [Logging].[Error] (
  [TaskID] ASC,
  [ProcessTaskLogID] ASC
) WITH (FILLFACTOR = 90);
GO

-- ErrorPayloadXML --
GO
CREATE TABLE [Logging].[ErrorPayloadXML](
  [ErrorPayloadID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ErrorPayloadXML] PRIMARY KEY CLUSTERED ([ErrorPayloadID] ASC) WITH (FILLFACTOR = 100),
  [ErrorLogID] BIGINT NOT NULL,
  CONSTRAINT [FK_ErrorPayloadXML_ErrorLog] FOREIGN KEY ([ErrorLogID]) REFERENCES [Logging].[Error] ([ErrorLogID]),
  [ConversationHandle] UNIQUEIDENTIFIER NOT NULL,
  [ConversationID] UNIQUEIDENTIFIER NOT NULL,
  [ErrorPayload] XML NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_ErrorPayloadXML_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),  
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_ErrorLogID] ON [Logging].[ErrorPayloadXML] (
  [ErrorLogID] ASC
) WITH (FILLFACTOR = 90);
GO

-- ErrorPayloadJSON --
GO
CREATE TABLE [Logging].[ErrorPayloadJSON](
  [ErrorPayloadID] BIGINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ErrorPayloadJSON] PRIMARY KEY CLUSTERED ([ErrorPayloadID] ASC) WITH (FILLFACTOR = 100),
  [ErrorLogID] BIGINT NOT NULL
  CONSTRAINT [FK_ErrorPayloadJSON_ErrorLog] FOREIGN KEY ([ErrorLogID]) REFERENCES [Logging].[Error] ([ErrorLogID]),
  [ConversationHandle] UNIQUEIDENTIFIER NOT NULL,
  [ConversationID] UNIQUEIDENTIFIER NOT NULL,
  [ErrorPayload] NVARCHAR(MAX) NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_ErrorPayloadJSON_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),  
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_ErrorLogID] ON [Logging].[ErrorPayloadJSON] (
  [ErrorLogID] ASC
) WITH (FILLFACTOR = 90);
GO



/* End of File ********************************************************************************************************************/