/****************************************************************************************************************************
* Script      : 3.Common - Tables - Config.sql                                                                             *
* Created By  : Cedric Dube                                                                                               *
* Created On  : 2020-10-02                                                                                                  *
* Execute On  : As required.                                                                         *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO

-- Process --
GO
CREATE TABLE [Config].[Process](
  [ProcessID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_Process] PRIMARY KEY CLUSTERED ([ProcessID] ASC) WITH (FILLFACTOR = 100),
  [ProcessName] VARCHAR(150) NOT NULL,
  [ProcessDescription] VARCHAR(250) NOT NULL,
  [IsEnabled] BIT NOT NULL
  CONSTRAINT [DF_Process_Enabled] DEFAULT (1),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_Process_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_Process] UNIQUE NONCLUSTERED (
    [ProcessName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO

GO
CREATE TABLE [Config].[Job](
  [JobID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_Job] PRIMARY KEY CLUSTERED ([JobID] ASC) WITH (FILLFACTOR = 100),
  [ProcessID] SMALLINT NOT NULL
  CONSTRAINT [DF_Job_Process] DEFAULT (-1),
  CONSTRAINT [FK_Job_Process] FOREIGN KEY ([ProcessID]) REFERENCES [Config].[Process] ([ProcessID]),
  [JobName] VARCHAR(150) NOT NULL,
  [JobDescription] VARCHAR(250) NOT NULL,
  [JobCategory] NVARCHAR(128) NOT NULL,
  [JobOwner] NVARCHAR(128) NOT NULL,
  [JobScheduleName] NVARCHAR(128) NULL,
  [IsEnabled] BIT NOT NULL
  CONSTRAINT [DF_Job_Enabled] DEFAULT (1),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_Job_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_Job] UNIQUE NONCLUSTERED (
    [JobName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
ALTER TABLE [Config].[Job] ADD [IsLoopJob] BIT NOT NULL
  CONSTRAINT [DF_Job_IsLoopJob] DEFAULT (1);
ALTER TABLE [Config].[Job] ADD [IsControllerJob] BIT NOT NULL
  CONSTRAINT [DF_Job_IsControllerJob] DEFAULT (0);
ALTER TABLE [Config].[Job] ADD [IsRunnable] BIT NOT NULL
  CONSTRAINT [DF_Job_IsRunnable] DEFAULT (1);
GO
-- Job Creation Parameters --
GO
CREATE TABLE [Config].[JobCreationParameters](
  [JobID] SMALLINT NOT NULL
  CONSTRAINT [PK_JobCreationParameters] PRIMARY KEY CLUSTERED ([JobID] ASC, [Parameter] ASC) WITH (FILLFACTOR = 100),
  [Parameter] VARCHAR(150) NOT NULL,
  [ParameterDataType] VARCHAR(50) NOT NULL,
  [ParameterValue] NVARCHAR(1000) NULL,
  CONSTRAINT [FK_JobCreationParameters_Job] FOREIGN KEY ([JobID]) REFERENCES [Config].[Job] ([JobID]),
) ON [PRIMARY]
GO
-- Job Queue --
CREATE TABLE [Config].[JobQueue](
  [JobID] SMALLINT NOT NULL
  CONSTRAINT [PK_JobQueue] PRIMARY KEY CLUSTERED ([JobID] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [FK_JobQueue_Job] FOREIGN KEY ([JobID]) REFERENCES [Config].[Job] ([JobID]),
  [EarliestNextExecution] DATETIME NOT NULL, -- Intentionally use DATETIME, no need for greater precision
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_JobQueue_CreatedDateTime] DEFAULT (SYSDATETIME()), -- Intentionally uses system time
) ON [PRIMARY]
GO
-- Job Step--
GO
CREATE TABLE [Config].[JobStep](
  [JobStepID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_JobStep] PRIMARY KEY CLUSTERED ([JobStepID] ASC) WITH (FILLFACTOR = 100),
  [JobID] SMALLINT NOT NULL
  CONSTRAINT [FK_JobStep_Job] FOREIGN KEY ([JobID]) REFERENCES [Config].[Job] ([JobID]),
  [JobStepOrdinal] SMALLINT NOT NULL,
  [JobStepName] VARCHAR(150) NOT NULL,
  [DatabaseName] NVARCHAR(128) NOT NULL,
  [Command] NVARCHAR(MAX) NOT NULL,
  [OnSuccessAction] INT NOT NULL,
  [OnSuccessOrdinal] INT NULL,
  [RetryAttempts] INT NOT NULL,
  [RetryInterval] INT NULL,
  [OnFailAction] INT NULL,
  [OnFailOrdinal] INT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_JobStep_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_JobStep] UNIQUE NONCLUSTERED (
    [JobID] ASC,
	[JobStepOrdinal] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
-- Task Type --
GO
CREATE TABLE [Config].[TaskType](
  [TaskTypeID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_TaskType] PRIMARY KEY CLUSTERED ([TaskTypeID] ASC) WITH (FILLFACTOR = 100),
  [TaskTypeCode] CHAR(3) NOT NULL,
  [TaskTypeName] VARCHAR(150) NOT NULL,
  [TaskTypeDescription] VARCHAR(250) NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_TaskType_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_TaskType] UNIQUE NONCLUSTERED (
    [TaskTypeCode]ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
-- Task --
GO
CREATE TABLE [Config].[Task](
  [TaskID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([TaskID] ASC) WITH (FILLFACTOR = 100),
  [TaskTypeID] SMALLINT NOT NULL
  CONSTRAINT [FK_Task_TaskType] FOREIGN KEY ([TaskTypeID]) REFERENCES [Config].[TaskType] ([TaskTypeID]),
  [TaskName] VARCHAR(150) NOT NULL,
  [TaskDescription] VARCHAR(250) NOT NULL
  CONSTRAINT [DF_Task_Enabled] DEFAULT (1),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_Task_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_Task] UNIQUE NONCLUSTERED (
    [TaskName] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TaskTypeID] ON [Config].[TaskType] (
  [TaskTypeID] ASC
) WITH (FILLFACTOR = 90);
GO

-- Extract Type --
GO
CREATE TABLE [Config].[ExtractType](
  [ExtractTypeID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ExtractType] PRIMARY KEY CLUSTERED ([ExtractTypeID] ASC) WITH (FILLFACTOR = 100),
  [ExtractTypeCode] CHAR(3) NOT NULL,
  [ExtractTypeName] VARCHAR(150) NOT NULL,
  [ExtractTypeDescription] VARCHAR(250) NOT NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_ExtractType_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_ExtractType] UNIQUE NONCLUSTERED (
    [ExtractTypeCode]ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
-- Extract Source --
GO
CREATE TABLE [Config].[ExtractSource](
  [ExtractSourceID] SMALLINT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_Extract] PRIMARY KEY CLUSTERED ([ExtractSourceID] ASC) WITH (FILLFACTOR = 100),
  [ExtractTypeID] SMALLINT NOT NULL
  CONSTRAINT [FK_Extract_ExtractType] FOREIGN KEY ([ExtractTypeID]) REFERENCES [Config].[ExtractType] ([ExtractTypeID]),
  [ExtractDatabase] NVARCHAR(128) NOT NULL,
  [ExtractObject] NVARCHAR(128) NOT NULL,
  [TrackedColumn] NVARCHAR(128) NULL,
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_Extract_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_Extract] UNIQUE NONCLUSTERED (
    [ExtractTypeID] ASC,
    [ExtractObject] ASC,
    [TrackedColumn] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ExtractTypeID] ON [Config].[ExtractType] (
  [ExtractTypeID] ASC
) WITH (FILLFACTOR = 90);
GO

-- ProcessTask --
GO
CREATE TABLE [Config].[ProcessTask](
  [ProcessTaskID] INT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_ProcessTask] PRIMARY KEY CLUSTERED ([ProcessTaskID] ASC) WITH (FILLFACTOR = 100),
  [ProcessID] SMALLINT NOT NULL
  CONSTRAINT [FK_ProcessTask_Process] FOREIGN KEY ([ProcessID]) REFERENCES [Config].[Process] ([ProcessID]),
  [TaskID] SMALLINT NOT NULL
  CONSTRAINT [FK_ProcessTask_Task] FOREIGN KEY ([TaskID]) REFERENCES [Config].[Task] ([TaskID]),
  [IsEnabled] BIT NOT NULL
  CONSTRAINT [DF_ProcessTask_Enabled] DEFAULT (1),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_ProcessTask_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_ProcessTask] UNIQUE NONCLUSTERED (
    [ProcessID] ASC,
    [TaskID] ASC,
    [IsEnabled] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO

-- TaskExtractSource --
GO
CREATE TABLE [Config].[ProcessTaskExtractSource](
  [TaskExtractSourceID] INT IDENTITY(1,1) NOT NULL
  CONSTRAINT [PK_TaskExtract] PRIMARY KEY CLUSTERED ([TaskExtractSourceID] ASC) WITH (FILLFACTOR = 100),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_TaskExtract_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ExtractSourceID] SMALLINT NOT NULL
  CONSTRAINT [FK_TaskExtract_ExtractSource] FOREIGN KEY ([ExtractSourceID]) REFERENCES [Config].[ExtractSource] ([ExtractSourceID]),
  [CreatedDateTime] DATETIME2 NOT NULL
  CONSTRAINT [DF_TaskExtract_CreatedDateTime] DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT [UK1_TaskExtract] UNIQUE NONCLUSTERED (
    [ProcessTaskID] ASC,
    [ExtractSourceID] ASC
  ) WITH (FILLFACTOR = 90)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ExtractSource] ON [Config].[ProcessTaskExtractSource] (
  [ExtractSourceID] ASC
) WITH (FILLFACTOR = 90);
GO

-- ConfigGroup --
GO
CREATE TABLE [Config].[VariableGroup] (
  [ConfigGroupID] SMALLINT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_ConfigGroup] PRIMARY KEY CLUSTERED ([ConfigGroupID]) WITH (FILLFACTOR = 100),
  [ConfigGroupName] VARCHAR (150) NOT NULL
  CONSTRAINT [UK1_ConfigGroup] UNIQUE NONCLUSTERED ([ConfigGroupName] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- Config --
GO
CREATE TABLE [Config].[Variable] (
  [ConfigID] INT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_Config] PRIMARY KEY CLUSTERED ([ConfigID]) WITH (FILLFACTOR = 100),
  [ConfigGroupID] SMALLINT NOT NULL
  CONSTRAINT [FK_Config_Group] FOREIGN KEY ([ConfigGroupID]) REFERENCES [Config].[VariableGroup] ([ConfigGroupID]),
  [ConfigName] VARCHAR (150) NOT NULL
  CONSTRAINT [UK1_Config] UNIQUE NONCLUSTERED ([ConfigName] ASC, [ConfigGroupID] ASC) WITH (FILLFACTOR = 90),
  [ConfigDataType] VARCHAR(50) NOT NULL,
  [ConfigDefaultValue] VARCHAR (150) NOT NULL,
  [Description] VARCHAR(500) NOT NULL
) ON [PRIMARY];
GO

-- Job Config --
GO
CREATE TABLE [Config].[JobVariable] (
  [JobConfigID] INT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_JobConfig] PRIMARY KEY CLUSTERED ([JobConfigID]) WITH (FILLFACTOR = 100),
  [JobID] SMALLINT NOT NULL
  CONSTRAINT [FK_JobConfig_Job] FOREIGN KEY ([JobID]) REFERENCES [Config].[Job] ([JobID]),
  [ConfigID] INT NOT NULL
  CONSTRAINT [FK_JobConfig_Config] FOREIGN KEY ([ConfigID]) REFERENCES [Config].[Variable] ([ConfigID]),
  [ConfigValue] VARCHAR (150) NOT NULL,
  CONSTRAINT [UK1_JobConfig] UNIQUE NONCLUSTERED ([JobID] ASC, [ConfigID] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- Applock Config --
GO
CREATE TABLE [Config].[AppLockVariable] (
  [ApplockConfigID] INT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_ApplockConfig] PRIMARY KEY CLUSTERED ([ApplockConfigID]) WITH (FILLFACTOR = 100),
  [ConfigID] INT NOT NULL
  CONSTRAINT [FK_ApplockConfig_Config] FOREIGN KEY ([ConfigID]) REFERENCES [Config].[Variable] ([ConfigID]),
  [ObjectName] NVARCHAR(128) NOT NULL,
  [ConfigValue] VARCHAR (150) NOT NULL,
  CONSTRAINT [UK1_ApplockConfig] UNIQUE NONCLUSTERED ([ObjectName] ASC, [ConfigID] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- Process Config --
GO
CREATE TABLE [Config].[ProcessVariable] (
  [ProcessConfigID] INT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_ProcessConfig] PRIMARY KEY CLUSTERED ([ProcessConfigID]) WITH (FILLFACTOR = 100),
  [ProcessID] SMALLINT NOT NULL
  CONSTRAINT [FK_ProcessConfig_Process] FOREIGN KEY ([ProcessID]) REFERENCES [Config].[Process] ([ProcessID]),
  [ConfigID] INT NOT NULL
  CONSTRAINT [FK_ProcessConfig_Config] FOREIGN KEY ([ConfigID]) REFERENCES [Config].[Variable] ([ConfigID]),
  [ConfigValue] VARCHAR (150) NOT NULL,
  CONSTRAINT [UK1_ProcessConfig] UNIQUE NONCLUSTERED ([ProcessID] ASC, [ConfigID] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

-- Task Config --
GO
CREATE TABLE [Config].[ProcessTaskVariable] (
  [TaskConfigID] INT IDENTITY(1, 1) NOT NULL,
  CONSTRAINT [PK_TaskConfig] PRIMARY KEY CLUSTERED ([TaskConfigID]) WITH (FILLFACTOR = 100),
  [ProcessTaskID] INT NOT NULL
  CONSTRAINT [FK_TaskConfig_ProcessTask] FOREIGN KEY ([ProcessTaskID]) REFERENCES [Config].[ProcessTask] ([ProcessTaskID]),
  [ConfigID] INT NOT NULL
  CONSTRAINT [FK_TaskConfig_Config] FOREIGN KEY ([ConfigID]) REFERENCES [Config].[Variable] ([ConfigID]),
  [ConfigValue] VARCHAR (150) NOT NULL,
  CONSTRAINT [UK1_TaskConfig] UNIQUE NONCLUSTERED ([ProcessTaskID] ASC, [ConfigID] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO

/* End of File ********************************************************************************************************************/