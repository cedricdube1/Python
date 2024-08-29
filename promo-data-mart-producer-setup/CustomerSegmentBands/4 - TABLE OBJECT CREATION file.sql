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

CREATE TABLE [dbo].[CustomerSegmentBands_Event](
    [EventPayloadID] [int] NOT NULL,
    [EventPayloadRecordID] [int] NOT NULL,
    [EventPayloadGenerated] [datetime2] NOT NULL,
    [EventPayloadJSONString] [varchar] (2560) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProduceEventConfirmed] [datetime2] NULL,
    [ProduceEventMessageID] [uniqueidentifier] NULL
) ON [PartScheme_dbo_CustomerSegmentBands_DT2] ([EventPayloadGenerated])
WITH(DATA_COMPRESSION = PAGE)

ALTER TABLE [dbo].[CustomerSegmentBands_Event] ADD CONSTRAINT [PK_dbo_CustomerSegmentBands_Event] PRIMARY KEY CLUSTERED ([EventPayloadID], [EventPayloadRecordID], [EventPayloadGenerated]) WITH (FILLFACTOR=100, DATA_COMPRESSION = PAGE) ON [PartScheme_dbo_CustomerSegmentBands_DT2] ([EventPayloadGenerated])

--CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCSI1_dbo_CustomerSegmentBands_Event] ON [dbo].[CustomerSegmentBands_Event] ([ProduceEventConfirmed], [ProduceEventMessageID]) ON [PartScheme_dbo_CustomerSegmentBands_DT2] ([EventPayloadGenerated])

ALTER TABLE [dbo].[CustomerSegmentBands_Event] SET ( LOCK_ESCALATION = AUTO )
GO

DECLARE @ProcessName VARCHAR(100) = 'CustomerSegmentBands'
DECLARE @ProcessType VARCHAR(20) = 'Publish Data'
DECLARE @Database VARCHAR(20)  = 'dbPublish'
DECLARE @TrackedColumn VARCHAR(20) = 'LastModified'
DECLARE @ExtractType VARCHAR(20) = 'Changed Data Object'
DECLARE @Processstart DATETIME = CAST(GETDATE() AS DATETIME)
DECLARE @ProcessEnd DATETIME = CAST(GETDATE() AS DATETIME)
DECLARE @NewMinModified DATETIME = DATEADD(HOUR,2 ,(SELECT MIN(LastModified) FROM dbStaging.dbo.CustomerSegmentBands WITH (NOLOCK)))
DECLARE @NewMaxModified DATETIME = DATEADD(HOUR,1 ,(SELECT MIN(LastModified) FROM dbStaging.dbo.CustomerSegmentBands WITH (NOLOCK)))


INSERT INTO dbPublish.dbo.tblPublishCDOIdentity (ProcessName, ProcessType, [Database], TrackedColumn, ExtractType, ProcessStart, ProcessEnd,ProcessDuration, MINModifiedDate, MAXModifiedDate)
SELECT @ProcessName, @ProcessType, @Database, @TrackedColumn, @ExtractType, @ProcessStart, @ProcessEnd,0,@NewMinModified,@NewMaxModified

SELECT *FROM dbPublish.dbo.tblPublishCDOIdentity WHERE ProcessName = @ProcessName
/* End of File **************************************************************************************************************************************/




