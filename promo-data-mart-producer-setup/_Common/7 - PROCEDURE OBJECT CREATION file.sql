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
CREATE OR ALTER PROCEDURE [dbo].[PublishErrorsBatch] (
  -- Events Tab. --
  @PublishEvents  dbo.ConfirmEvents READONLY
  -- Error Pars. --
 ,@ErrorProcedure NVARCHAR(128)
 ,@ErrorMessage   NVARCHAR(4000)
 ,@ErrorSeverity  TINYINT
 ,@ErrorNumber    INT
 ,@ErrorLine      INT
  -- Output Count --
 ,@RowCount       INT = 0 OUTPUT
) /*WITH RECOMPILE*/ AS
---------------------------------------------------------------------------------------------------
-- Description : Inserts a batch of entries / rows into the Publish Error table.
-- Events Tab. : PublishEvents  : table of type dbo.ConfirmEvent
-- Error Pars. : ErrorProcedure : value returned by ERROR_PROCEDURE() function
--             : ErrorMessage   : value returned by ERROR_MESSAGE() function
--             : ErrorSeverity  : value returned by ERROR_SEVERITY() function
--             : ErrorNumber    : value returned by ERROR_NUMBER() function
--             : ErrorLine      : value returned by ERROR_LINE() function
---------------------------------------------------------------------------------------------------
BEGIN;
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN TRY;
  BEGIN TRANSACTION;
    INSERT INTO dbo.PublishError (
      -- Event Cols. --
      EventPayloadID,
      EventPayloadRecordID,
      ProduceEventMessageID,
      -- Error Cols. --
      ErrorProcedure,
      ErrorMessage,
      ErrorSeverity,
      ErrorNumber,
      ErrorLine
    ) SELECT -- Event Cols. --
             EventPayloadID
            ,EventPayloadRecordID
            ,ProduceEventMessageID
             -- Error Vars. --
            ,@ErrorProcedure
            ,@ErrorMessage
            ,@ErrorSeverity
            ,@ErrorNumber
            ,@ErrorLine
      FROM @PublishEvents;
  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
  IF (XACT_STATE() <> 0) ROLLBACK TRANSACTION;
  THROW;
END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_AutoPartitionAdd]
AS 

IF  EOMONTH(GETDATE()) =  CAST(GETDATE() AS DATE)
 BEGIN 


DECLARE       @Starttime DATETIME			= GETDATE(),
              @ProcedureName VARCHAR(50)	= 'usp_AutoPartitionAdd'

DECLARE  --@NewMaxDateKey INT = CONVERT(VARCHAR(8), DATEADD(DAY, 1, EOMONTH(GETDATE(), -1)), 112) 
		 @NewMaxDate DATETIME = DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
		,@StartOfMonth DATETIME	= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-1), 0)
        ,@CurrentMaxDate_CustomerSegmentBands DATETIME = (SELECT CAST(MAX(VALUE) AS DATETIME) FROM sys.partition_functions F WITH (NOLOCK) LEFT JOIN sys.partition_range_VALUES R WITH (NOLOCK) ON R.Function_Id = F.Function_Id WHERE F.[Name] = 'PartFunc_dbo_CustomerSegmentBands_DT2')

--SELECT @NewMaxDate 'NEW', @CurrentMaxDate 'CURRENT'


/****** CustomerSegmentBands ******/
IF @NewMaxDate > @CurrentMaxDate_CustomerSegmentBands 
  BEGIN
	ALTER PARTITION SCHEME [PartScheme_dbo_CustomerSegmentBands_DT2] NEXT USED [FG_DATA_01];
	ALTER PARTITION FUNCTION PartFunc_dbo_CustomerSegmentBands_DT2() SPLIT RANGE (CAST(@StartOfMonth AS DATETIME));
  END;


END 





/* End of File **************************************************************************************************************************************/








