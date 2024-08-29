--STEP 1 FILE
/*****************************************************************************************************************************************************
* Script     : 1 - CREATE PARTITION file.sql                                                              *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                            *--
* Updated By : Cedric Dube                                                                                                                         *--
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

/* 1 Partitions *************************************************************************************************************************************/

-- Partition Function --
IF NOT EXISTS (SELECT * FROM Sys.Partition_Functions WHERE Name = N'PartFunc_dbo_CustomerSegmentBands_DT2')
  CREATE PARTITION FUNCTION [PartFunc_dbo_CustomerSegmentBands_DT2] ([DATETIME2])
    AS RANGE RIGHT FOR VALUES ( 
			N'2024-06-01 00:00:00.0000000',
			N'2024-07-01 00:00:00.0000000',
			N'2024-08-01 00:00:00.0000000',
			N'2024-09-01 00:00:00.0000000',
			N'2024-10-01 00:00:00.0000000',
			N'2024-11-01 00:00:00.0000000',
			N'2024-12-01 00:00:00.0000000')
GO

-- Partition Scheme --
IF NOT EXISTS (SELECT * FROM Sys.Partition_Schemes WHERE Name = N'PartScheme_dbo_CustomerSegmentBands_DT2')
  CREATE PARTITION SCHEME PartScheme_dbo_CustomerSegmentBands_DT2
    AS PARTITION PartFunc_dbo_CustomerSegmentBands_DT2
      ALL TO ([PRIMARY]);
GO


--ALTER PARTITION FUNCTION PartFunc_dbo_CustomerSegmentBands_DT2() SPLIT RANGE (CAST('2025-01-01' AS DATETIME2));
/* End of File **************************************************************************************************************************************/


