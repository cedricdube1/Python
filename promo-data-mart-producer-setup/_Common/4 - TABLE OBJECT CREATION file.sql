--STEP 4 FILE
/*****************************************************************************************************************************************************
* Script     : 4 - TABLE OBJECT CREATION file.sql                                                         *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                            *--
* Updated By : Cedric Dube                                                                                                                          *--
* Updated On : 2024-05-24                                                                                                                            *--
* Execute On : ALL Environments                                                                                                                      *--
* Execute As : Manual                                                                                                                                *--
* Execution  : Entire script once                                                                                                                    *--
* Object List ****************************************************************************************************************************************--
* 0 Drop All       : Yes                                                                                                                             *--
*				   : N/A																														     *--
*                  : N/A																														     *--
*                  : N/A                                                                                                                             *--
* Final Notes ****************************************************************************************************************************************--
* This script does not need to be populated at the start, As you discover all the objects you can list them down here.                          	 *--
*																																					 *--
*																														                             *--
*****************************************************************************************************************************************************/
USE dbPublish;
GO

SET NOCOUNT ON;
GO

CREATE TABLE [dbo].[ProcessError](
	[ErrorLogID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ProcessName] [VARCHAR](500) NULL,
	[ErrorProcedure] [NVARCHAR](128) NULL,
	[ErrorNumber] [INT] NULL,
	[ErrorLine] [INT] NULL,
	[ErrorMessage] [NVARCHAR](4000) NULL,
	[CreatedDateTime] [DATETIME2](7) NOT NULL,
 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
(
	[ErrorLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ProcessError] ADD  CONSTRAINT [DF_ErrorLog_CreatedDateTime]  DEFAULT (SYSUTCDATETIME()) FOR [CreatedDateTime]
GO

CREATE TYPE [dbo].[ConfirmEvents] AS TABLE(
     [EventPayloadID] [int] NOT NULL,
     [EventPayloadRecordID] [int] NOT NULL,
     [EventPayloadGenerated] [datetime2] NOT NULL,
     [ProduceEventConfirmed] [datetime2] NOT NULL,
     [ProduceEventMessageID] [uniqueidentifier] NOT NULL,
     PRIMARY KEY CLUSTERED  ([EventPayloadID], [EventPayloadRecordID])
)
GO

CREATE TABLE [dbo].[PublishError](
     [PublishErrorID] [INT] NOT NULL IDENTITY(1, 1),
     [ErrorTimeStamp] [DATETIME2] NOT NULL CONSTRAINT [DF1_PublishError] DEFAULT (SYSUTCDATETIME()),
     [EventPayloadID] [INT] NOT NULL,
     [EventPayloadRecordID] [INT] NOT NULL,
     [ProduceEventMessageID] [UNIQUEIDENTIFIER] NOT NULL,
     [ErrorProcedure] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
     [ErrorMessage] [NVARCHAR] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
     [ErrorSeverity] [TINYINT] NULL,
     [ErrorNumber] [INT] NULL,
     [ErrorLine] [INT] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[PublishError] ADD CONSTRAINT [PK_PublishError] PRIMARY KEY CLUSTERED ([PublishErrorID]) WITH (FILLFACTOR=100) ON [PRIMARY]

ALTER TABLE [dbo].[PublishError] ADD CONSTRAINT [UK1_PublishError] UNIQUE NONCLUSTERED ([EventPayloadID], [EventPayloadRecordID], [ProduceEventMessageID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tblPublishCDOIdentity](
	[ProcessName] [VARCHAR](100) NULL,
	[ProcessType] [VARCHAR](20) NULL,
	[Database] [VARCHAR](20) NULL,
	[TrackedColumn] [VARCHAR](20) NULL,
	[ExtractType] [VARCHAR](20) NULL,
	[ProcessStart] [DATETIME] NULL,
	[ProcessEnd] [DATETIME] NULL,
	[ProcessDuration] [INT] NULL,
	[MINModifiedDate] [DATETIME] NULL,
	[MAXModifiedDate] [DATETIME] NULL
) ON [PRIMARY]

CREATE CLUSTERED INDEX [IX1] ON [dbo].[tblPublishCDOIdentity]
(
	[ProcessName] ASC,
	[MINModifiedDate] ASC,
	[MAXModifiedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

USE dbMonitoring;
GO


CREATE TABLE [dbo].[ProducerRuntimeLog](
	[Procedure] [VARCHAR](250) NULL,
	[Step] [VARCHAR](250) NULL,
	[BatchTime] [DATETIME2](7) NULL,
	[DatetimeStamp] [DATETIME] NULL,
	[RowCount] [INT] NULL
) ON [PRIMARY]
GO

/* End of File **************************************************************************************************************************************/




