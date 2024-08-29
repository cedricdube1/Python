/*****************************************************************************************************************************************************
* Script     : 0 - DROP OBJECT file.sql                                                                   *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                           *--
* Updated By : Cedric Dube                                                                                                                           *--
* Updated On : 2024-05-24                                                                                                                              *--
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

--PARTITIONS
IF EXISTS (SELECT * FROM Sys.Partition_Schemes WHERE Name = N'PartScheme_dbo_CustomerSegmentBands_DT2')
  DROP PARTITION SCHEME PartScheme_dbo_CustomerSegmentBands_DT2;
GO

--SCHEMES
IF EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_dbo_CustomerSegmentBands_DT2')
  DROP PARTITION FUNCTION PartFunc_dbo_CustomerSegmentBands_DT2;
GO

--SEQUENCES
DROP SEQUENCE dbo.CustomerSegmentBands_Sequence;

--TABLES;
DROP TABLE dbo.CustomerSegmentBands_Event;

--PROCEDURES
DROP PROCEDURE dbo.usp_CustomerSegmentBands_Event;
DROP PROCEDURE dbo.CustomerSegmentBands_ConfirmEventsPublished;
DROP PROCEDURE dbo.CustomerSegmentBands_FetchUnpublishedEvents;



GO
