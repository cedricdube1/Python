--STEP 7 FILE
/*****************************************************************************************************************************************************
* Script     : 7 - PROCEDURE OBJECT CREATION file.sql                                                         *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                           *--
* Updated By : Cedric Dube                                                                                                                          *--
* Updated On : 2024-05-24                                                                                                                             *--
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


/* 7 Procedures *************************************************************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[usp_CustomerSegmentBands_Event] 
AS
-- =============================================
-- Author:		<Cedric Dube>
-- Create date: <30-07-2024>
-- Description:	<This proc packages all information for the salesforce promo marketing stuff into JSON and adds to a generic event table>
-- =============================================
BEGIN

	SET NOCOUNT ON;

DECLARE @MaxLastModified DATETIME = (SELECT MAX(LastModified) FROM dbStaging.dbo.CustomerSegmentBands WITH (NOLOCK))
DECLARE @LastModified DATETIME = (SELECT MAX(MAXModifiedDate) FROM dbPublish.dbo.tblPublishCDOIdentity WITH (NOLOCK))
DECLARE @Starttime DATETIME			= GETDATE() ,
 @ProcedureName VARCHAR(50)	= 'usp_CustomerSegmentBands_Event',
 @ProcessID             INT	= (SELECT ID FROM [dbStaging].[Lookup].[LupProcess] WITH (NOLOCK) WHERE Processname = 'usp_CustomerSegmentBands_Event')

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Start', @Starttime, GETDATE(), @@ROWCOUNT );

IF @MaxLastModified > @LastModified
BEGIN	

--======================================================================
--STEP 1: Insert info into temp table that contains only the new records
--======================================================================
IF OBJECT_ID('tempdb..#Targetlist') IS NOT NULL DROP TABLE #Targetlist
CREATE TABLE #Targetlist(
	[EventPayloadID]  VARCHAR(20) NULL,
    [EventPayloadRecordID]  VARCHAR(20) NULL,
    [EventPayloadGenerated]  VARCHAR(23),
    [NAME] VARCHAR(25),
    [Setup] VARCHAR(10),
    [ACTION] VARCHAR(10),
    [VERSION] VARCHAR(10),
	[CustomerID] VARCHAR(50) NULL,
	[BOSP] [VARCHAR](3) NULL,
	[CustomerMajoritySegment] VARCHAR(50)NULL,
	[LastModified] VARCHAR(23) NULL,
)

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Step 1', @Starttime, GETDATE(), @@ROWCOUNT );

INSERT INTO #Targetlist
(
[EventPayloadID]
,[EventPayloadRecordID]
,[EventPayloadGenerated]
,[NAME]
,[Setup]
,[ACTION]
,[VERSION]
,[CustomerID]
,[BOSP]
,[CustomerMajoritySegment]
,[LastModified]
)
SELECT 
	   NULL AS EventPayloadID,
	   ROW_NUMBER() OVER(ORDER BY GETDATE() DESC) AS EventPayloadRecordID,
	   CONVERT(VARCHAR(23),GETDATE(),121) AS EventPayloadGenerated,
	   'CustomerSegmentBands' AS Name,
	   'PRD' AS Setup,
	   'InsUpd' AS Action,
	   '1.0' AS Version,
	   CAST(a.CustomerID AS VARCHAR(50)) AS CustomerID,
       CAST(a.BOSP AS VARCHAR(50)) AS BOSP,
       CAST(a.CustomerMajoritySegment AS VARCHAR(50)) CustomerMajoritySegment,
       CONVERT(VARCHAR(23),a.lastModified,121) AS LastModified
FROM dbStaging.dbo.CustomerSegmentBands a WITH (NOLOCK)
WHERE a.lastModified > @LastModified
--01:26 (1097943 Rows Affected)

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Step 2', @Starttime, GETDATE(), @@ROWCOUNT );

--======================================================================
--STEP 2: Update the event payload id
--======================================================================
IF OBJECT_ID('tempdb..#tmpNextVal') IS NOT NULL DROP TABLE #tmpNextVal
SELECT NEXT VALUE FOR dbPublish.dbo.CustomerSegmentBands_Sequence AS NextVal
INTO #tmpNextVal

UPDATE a
SET a.EventPayloadID = (SELECT NextVal FROM #tmpNextVal)
--SELECT TOP 10 *
FROM #Targetlist a
--02:28

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Step 3', @Starttime, GETDATE(), @@ROWCOUNT );

BEGIN TRY
--======================================================================
--STEP 3: Build up the JSON string
--======================================================================
IF OBJECT_ID('tempdb..#EventPayload') IS NOT NULL DROP TABLE #EventPayload
SELECT
-- Standard Columns --
 a.EventPayloadID
,a.EventPayloadRecordID
,a.EventPayloadGenerated
------ TOPIC -------
,CONCAT('"Topic":{',
          '"Name":"'                                , Name                                  , '",',
          '"Setup":"'                               , Setup                                 , '",',
          '"Action":"'                              , Action                                , '",',
          '"Version":"'                             , Version                               , '"',
        '}'
       ) AS Topic
------ PAYLOAD -------
,CONCAT('"Payload":{',
          '"CustomerID":"'                          , CustomerID                            , '",',
          '"BOSP":"'                                , BOSP                                  , '",',
          '"CustomerMajoritySegment":"'             , CustomerMajoritySegment               , '",',
          '"LastModified":"'                        , LastModified                          , '"',
        '}'
       ) AS JSONPayload
-- ----- CORRELATE ------
,CONCAT('"Correlate":[',
        -- Event / dbPublish.dbo.CustomerSegmentBands_GenericEvent --
        '{"Class":"Event","Object":"dbPublish.dbo.CustomerSegmentBands_Event","Identifiers":[',
            '{"Column":"EventPayloadID","Value":'        , CAST(EventPayloadID AS VARCHAR(10))             ,  '},',
            '{"Column":"EventPayloadRecordID","Value":'  , CAST(EventPayloadRecordID AS VARCHAR(10))       ,  '},',
            '{"Column":"EventPayloadGenerated","Value":"', CONVERT(VARCHAR(27), EventPayloadGenerated, 121), '"}' ,
        ']},',
        -- Business / dbStaging.dbo.CustomerSegmentBands --
        '{"Class":"Business","Object":"dbStaging.dbo.CustomerSegmentBands","Identifiers":[',
            '{"Column":"CustomerID","Value":"'       , CustomerID                                                  ,  '"},',
            '{"Column":"BOSP","Value":"'             , BOSP                                                        ,  '"}',
        ']}',
        ']'
        ) AS JSONCorrelate
INTO #EventPayload
FROM #Targetlist a WITH (NOLOCK)

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Step 4', @Starttime, GETDATE(), @@ROWCOUNT );

--======================================================================
--STEP 5: Concat values together and insert into genric event table
--======================================================================


SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;	

INSERT INTO [dbo].[CustomerSegmentBands_Event]
(
EventPayloadID,
EventPayloadRecordID,
EventPayloadGenerated,
EventPayloadJSONString,
ProduceEventConfirmed,
ProduceEventMessageID
)
SELECT a.EventPayloadID,
       a.EventPayloadRecordID,
       a.EventPayloadGenerated,
CONCAT('{"Event":{', a.Topic, ',', REPLACE(LTRIM(RTRIM(a.JSONPayload)),'       "','"'),',', a.JSONCorrelate,  '}}') AS EventPayloadJSONString , 
NULL AS ProduceEventConfirmed,
NULL AS ProduceEventMessageID
FROM #EventPayload a
DECLARE @ROWCOUNT INT = @@ROWCOUNT
--01:21

COMMIT TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;	

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Step 5', @Starttime, GETDATE(), @@ROWCOUNT );

END TRY
BEGIN CATCH

	/*
		-- XACT_STATE:
		1 = Active transactions, CAN be committed or rolled back. Because of error, we rollback
		0 = NO Active transactions, CANNOT be committed or rolled back.
		-1 = Active transactions, CANNOT be committed but CAN be rolled back. Because of error, we rollback
	*/
	IF XACT_STATE() <> 0
		ROLLBACK;
		DECLARE @ProcName NVARCHAR(150)	= 'CustomerSegmentBands Segmentation',
		        @ErrProc NVARCHAR(128)		= ERROR_PROCEDURE(),
				@ErrMsg  NVARCHAR(4000)		= ERROR_MESSAGE(),
				@ErrNum  INT					= ERROR_NUMBER(),
				@ErrLn   INT					= ERROR_LINE();

	INSERT INTO [dbPublish].[dbo].[ProcessError]([ProcessName],[ErrorProcedure],[ErrorNumber],[ErrorLine],[ErrorMessage])
	SELECT @ProcName,@ErrProc, @ErrNum, @ErrLn,@ErrMsg 

	THROW;
	INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'Failure', @Starttime, GETDATE(), @@ROWCOUNT );

END CATCH;


--======================================================================
--STEP 6: Add a record to the CDO identity table to show what we processed
--======================================================================
--DECLARE @ProcessStart DATETIME = GETDATE()
DECLARE @ProcessName VARCHAR(100)
DECLARE @ProcessType VARCHAR(20)
DECLARE @Database VARCHAR(20)
DECLARE @TrackedColumn VARCHAR(20)
DECLARE @ExtractType VARCHAR(20)
DECLARE @ProcessEnd DATETIME
DECLARE @NewMinModified DATETIME
DECLARE @NewMaxModified DATETIME
DECLARE @ProcessDuration INT

SET @ProcessName = 'CustomerSegmentBands'
SET @ProcessType = 'Publish Data'
SET @Database = 'dbPublish'
SET @TrackedColumn = 'LastModified'
SET @ExtractType = 'Changed Data Object'
SET @ProcessEnd = GETDATE()
SET @NewMinModified = (SELECT MAX(MAXModifiedDate) FROM dbPublish.dbo.tblPublishCDOIdentity WITH (NOLOCK))
SET @NewMaxModified = (SELECT MAX(LastModified) FROM #Targetlist WITH (NOLOCK))
SET @ProcessDuration = DATEDIFF(MINUTE,@Starttime,@ProcessEnd)


INSERT INTO dbPublish.dbo.tblPublishCDOIdentity (ProcessName, ProcessType, [Database], TrackedColumn, ExtractType, ProcessStart, ProcessEnd,ProcessDuration, MINModifiedDate, MAXModifiedDate)
SELECT @ProcessName, @ProcessType, @Database, @TrackedColumn, @ExtractType, @Starttime, @ProcessEnd,@ProcessDuration,@NewMinModified,@NewMaxModified

END

INSERT INTO [dbStaging].[Logging].[ProcessRuntimeLog] VALUES  ( @ProcessID, @ProcedureName, 'End', @Starttime, GETDATE(), @@ROWCOUNT );


END
GO

CREATE OR ALTER PROCEDURE [dbo].[CustomerSegmentBands_FetchUnpublishedEvents] (
  @PublishBatchSize INT = 2000
) /*WITH RECOMPILE*/ AS
---------------------------------------------------------------------------------------------------
-- Description : Fetch Unpublished Events method called by a Generic Producer.
-- Parameters : PublishBatchSize : The size of the batch to publish in a single call.
---------------------------------------------------------------------------------------------------
BEGIN;
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN TRY;
  /* Constants */
  --DECLARE @PublishBatchSize INT = 2000
  DECLARE @SysUTCDT2 DATETIME2 = SYSUTCDATETIME(); -- {SUDT}
  DECLARE @Procedure NVARCHAR(50)         = 'CustomerSegmentBands_FetchUnpublishedEvents'
  DECLARE @BatchTime DATETIME             = GETDATE()

  INSERT INTO [dbMonitoring].[dbo].[ProducerRuntimeLog] SELECT @Procedure, 'Start', @BatchTime, GETDATE(), @@ROWCOUNT 

  /* Variables */
  DECLARE @EventPayloadID INT;
  DECLARE @EventPayloadGenerated DATETIME2;

  /* Processing */
  -- Pop. Vars. > Update / Return --
  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    -- EventPayloadID : Minimum --
    SELECT @EventPayloadID = MIN(EventPayloadID)
    FROM dbo.CustomerSegmentBands_Event
    WHERE ProduceEventConfirmed IS NULL
     AND  ProduceEventMessageID IS NULL;
    -- EventPayloadGenerated : Related Minimum --
    SELECT @EventPayloadGenerated = MIN(EventPayloadGenerated)
    FROM dbo.CustomerSegmentBands_Event
    WHERE EventPayloadID = @EventPayloadID
     AND  ProduceEventConfirmed IS NULL
     AND  ProduceEventMessageID IS NULL;
    -- Update / Return : Transaction --
    BEGIN TRANSACTION;
      UPDATE TopGenEvt
      -- Produce Event Confirmed : Update --
      SET ProduceEventConfirmed = @SysUTCDT2
      -- Generic Event : Return --
      OUTPUT Inserted.EventPayloadID
            ,Inserted.EventPayloadRecordID
            ,CONVERT(VARCHAR(27), Inserted.EventPayloadGenerated, 121) AS EventPayloadGenerated
            ,Inserted.EventPayloadJSONString
            ,CONVERT(VARCHAR(27), Inserted.ProduceEventConfirmed, 121) AS ProduceEventConfirmed
      FROM (-- Publish Batch Size : Select Top --
            SELECT TOP (@PublishBatchSize)
                   -- Standard Columns --
                   EventPayloadID
                  ,EventPayloadRecordID
                  ,EventPayloadGenerated
                  ,EventPayloadJSONString
                   -- Producer Columns --
                  ,ProduceEventConfirmed
            FROM dbo.CustomerSegmentBands_Event
            WHERE EventPayloadID = @EventPayloadID
             AND  EventPayloadGenerated = @EventPayloadGenerated
             AND  ProduceEventConfirmed IS NULL
             AND  ProduceEventMessageID IS NULL
            ORDER BY EventPayloadID
                    ,EventPayloadRecordID
           ) TopGenEvt
      WHERE EventPayloadID = TopGenEvt.EventPayloadID
       AND  EventPayloadRecordID = TopGenEvt.EventPayloadRecordID
       AND  EventPayloadGenerated = TopGenEvt.EventPayloadGenerated;
    COMMIT TRANSACTION;
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END TRY
BEGIN CATCH
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  THROW;
END CATCH;

INSERT INTO [dbMonitoring].[dbo].[ProducerRuntimeLog] SELECT @Procedure, 'End', @BatchTime, GETDATE(), @@ROWCOUNT

END;
GO

CREATE OR ALTER PROCEDURE [dbo].[CustomerSegmentBands_ConfirmEventsPublished] (
  @ConfirmEvents dbo.ConfirmEvents READONLY
) /*WITH RECOMPILE*/ AS
---------------------------------------------------------------------------------------------------
-- Description : Confirm Events Published method called by a Generic Producer.
-- Parameters : ConfirmEvents : A table type for Confirmed Events.
---------------------------------------------------------------------------------------------------
BEGIN;
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN TRY;
  /* Constants */
  DECLARE @SourceSchema SYSNAME		= N'dbo'
         ,@SourceTable  SYSNAME		= N'CustomerSegmentBands_Event';
  DECLARE @Procedure NVARCHAR(50)	= 'CustomerSegmentBands_ConfirmEventsPublished'
  DECLARE @BatchTime DATETIME		= GETDATE()

  INSERT INTO [dbMonitoring].[dbo].[ProducerRuntimeLog] SELECT @Procedure, 'Start', @BatchTime, GETDATE(), @@ROWCOUNT 

  /* Variables */
  DECLARE @ThrowMsg NVARCHAR(2048) =
    N'The table '+@SourceSchema+N'.'+@SourceTable+N' does not exist. Redirecting to the table dbo.PublishError.';

  /* Validation */
  IF (NOT EXISTS (SELECT 1
                  FROM INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_SCHEMA = @SourceSchema
                   AND  TABLE_NAME   = @SourceTable )) THROW 50000, @ThrowMsg, 1;

  /* Processing */
  -- Confirm Events : Transaction --
  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    BEGIN TRANSACTION;
      UPDATE GenEvt
      SET ProduceEventMessageID = ConEvt.ProduceEventMessageID
      FROM dbo.CustomerSegmentBands_Event AS GenEvt
      INNER JOIN @ConfirmEvents AS ConEvt
        ON  ConEvt.EventPayloadID = GenEvt.EventPayloadID
       AND  ConEvt.EventPayloadRecordID = GenEvt.EventPayloadRecordID
       AND  ConEvt.EventPayloadGenerated = GenEvt.EventPayloadGenerated
       --AND  GenEvt.ProduceEventConfirmed = GenEvt.ProduceEventConfirmed
	   AND  ConEvt.ProduceEventConfirmed = GenEvt.ProduceEventConfirmed
      WHERE GenEvt.ProduceEventMessageID IS NULL;
    COMMIT TRANSACTION;
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END TRY
BEGIN CATCH
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  IF (XACT_STATE() <> 0) ROLLBACK TRANSACTION;
  DECLARE @ErrorProcedure NVARCHAR(128)  = ERROR_PROCEDURE()
         ,@ErrorMessage   NVARCHAR(4000) = ERROR_MESSAGE()
         ,@ErrorSeverity  TINYINT        = ERROR_SEVERITY()
         ,@ErrorNumber    INT            = ERROR_NUMBER()
         ,@ErrorLine      INT            = ERROR_LINE();
  -- Publish Events Error : Batch --
  EXEC dbo.PublishErrorsBatch             -- Events Tab. --
                                          @PublishEvents  = @ConfirmEvents
                                          -- Error Vars. --
                                         ,@ErrorProcedure = @ErrorProcedure
                                         ,@ErrorMessage   = @ErrorMessage
                                         ,@ErrorSeverity  = @ErrorSeverity
                                         ,@ErrorNumber    = @ErrorNumber
                                         ,@ErrorLine      = @ErrorLine;
  THROW;
END CATCH;

INSERT INTO [dbMonitoring].[dbo].[ProducerRuntimeLog] SELECT @Procedure, 'End', @BatchTime, GETDATE(), @@ROWCOUNT

END;
GO



/* End of File **************************************************************************************************************************************/








