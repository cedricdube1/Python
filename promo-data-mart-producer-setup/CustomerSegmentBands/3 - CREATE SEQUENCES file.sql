--STEP 3 FILE
/*****************************************************************************************************************************************************
* Script     : 3 - CREATE SEQUENCES file.sql                                                              *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                            *--
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

USE [dbPublish]
GO

CREATE SEQUENCE dbo.CustomerSegmentBands_Sequence
  AS BIGINT START WITH 1 INCREMENT BY 1
  MINVALUE 1 NO MAXVALUE
  NO CYCLE NO CACHE;
GO

/* End of File **************************************************************************************************************************************/