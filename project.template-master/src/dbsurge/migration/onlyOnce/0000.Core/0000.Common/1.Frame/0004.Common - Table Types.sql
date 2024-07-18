/****************************************************************************************************************************
* Script      : 4.Common - Table Types.sql                                                                                 *
* Created By  : Cedric Dube                                                                                               *
* Created On  : 2020-10-02                                                                                                  *
* Execute On  : As required.                                                                         *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO

GO
CREATE TYPE [DataFlow].[Payload] AS TABLE(
  [EventUTCDateTimeStamp] DATETIME2 NOT NULL,
  [PayloadID] BIGINT NOT NULL
  PRIMARY KEY NONCLUSTERED ([EventUTCDateTimeStamp] ASC, [PayloadID] ASC)
);
GO
GO
CREATE TYPE [DataFlow].[PayloadDate] AS TABLE(
  [PayloadDate] DATETIME2 NOT NULL
  PRIMARY KEY NONCLUSTERED ([PayloadDate])
);
GO
GO
CREATE TYPE [DataFlow].[PayloadID] AS TABLE(
  [PayloadID] BIGINT NOT NULL
  PRIMARY KEY NONCLUSTERED ([PayloadID])
);
GO
GO
CREATE TYPE [DataFlow].[CaptureLogID] AS TABLE(
  [CaptureLogID] BIGINT NOT NULL
  PRIMARY KEY NONCLUSTERED ([CaptureLogID])
);
GO
GO
CREATE TYPE [Config].[JobID] AS TABLE(
  [JobID] SMALLINT NOT NULL
  PRIMARY KEY NONCLUSTERED ([JobID])
);
GO
GO
CREATE TYPE [DataFlow].[JobQueueList] AS TABLE(
  [JobID] SMALLINT NOT NULL,
  [Enqueue] BIT NOT NULL,
  [StatusCode] TINYINT NULL,
  [JobReportTime] DATETIME NULL,
  [EarliestNextExecution] DATETIME NULL
  PRIMARY KEY NONCLUSTERED ([JobID])
);
GO
/* End of File ********************************************************************************************************************/