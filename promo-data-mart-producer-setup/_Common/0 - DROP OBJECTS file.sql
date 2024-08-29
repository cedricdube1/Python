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

--SCHEMES

--SEQUENCES

--TABLES;
DROP TABLE [dbo].[ProcessError];
DROP TABLE [dbo].[PublishError];
DROP TABLE dbo.tblPublishCDOIdentity;

--TABLE TYPE
DROP TABLE dbo.ConfirmEvents;

--PROCEDURES
DROP PROCEDURE dbo.PublishErrorsBatch;



GO
