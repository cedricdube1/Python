/****************************************************************************************************************************
* Script      : 3.Monitoring - Tables.sql                                                                                   *
* Created By  : Cedric Dube                                                                                   *
* Created On  : 2021-03-02                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [Monitoring].[SQLServerAgentControllerJobDisabled] (
  [SQLServerAgentJobID] UNIQUEIDENTIFIER NOT NULL,
  [ConfigJobID] SMALLINT NOT NULL,
  [JobName] NVARCHAR(128) NOT NULL,
  [LastRunStartDateTime] DATETIME2(7) NULL,
  [LastRunEndDateTime] DATETIME2(7) NULL,
  [AlertID] [INT] NULL
  CONSTRAINT [DF_SQLServerAgentControllerJobDisabled_Reported] DEFAULT (0),
  [InsertDate] DATETIME2(7) NULL
) ON [PRIMARY];
GO
CREATE CLUSTERED INDEX [IDX_SQLServerAgentControllerJobDisabled]
ON [Monitoring].[SQLServerAgentControllerJobDisabled] (
  [ConfigJobID] ASC,
  [LastRunEndDateTime] ASC
) WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_SQLServerAgentControllerJobDisabled_Reported]
ON [Monitoring].[SQLServerAgentControllerJobDisabled] (
  [AlertID]
) WITH (FILLFACTOR = 90);
GO
GO
CREATE TABLE [Monitoring].[SQLServerAgentJobFailure] (
  [JobID] UNIQUEIDENTIFIER NOT NULL,
  [JobName] NVARCHAR(128) NOT NULL,
  [Category] NVARCHAR(128) NOT NULL,
  [LastRunDateTime] DATETIME2(7) NULL,
  [LastRunStatus] VARCHAR(20)NULL,
  [LastRunDuration (HH:MM:SS)] VARCHAR(30) NULL,
  [LastRunStatusMessage] NVARCHAR(4000) NULL,
  [NextRunDateTime] DATETIME2(7) NULL,
  [AlertID] [INT] NULL
  CONSTRAINT [DF_SqlServerAgentJobFailure_Reported] DEFAULT (0),
  [InsertDate] DATETIME2(7) NULL
) ON [PRIMARY];
GO
CREATE CLUSTERED INDEX [IDX_SQLServerAgentJobFailure]
ON [Monitoring].[SQLServerAgentJobFailure] (
  [JobID] ASC,
  [LastRunDateTime] ASC
) WITH (FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_SQLServerAgentJobFailure_Reported]
ON [Monitoring].[SQLServerAgentJobFailure] (
  [AlertID]
) WITH (FILLFACTOR = 90);
GO

/* End of File ********************************************************************************************************************/