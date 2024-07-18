/***********************************************************************************************************************************
* Script      : 0.Monitoring - Held - Drop All Objects.sql                                                                         *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge];

GO

-- DROP PROCEDURE IF EXISTS --
DROP PROCEDURE IF EXISTS [Monitoring].[Process_Held];
DROP PROCEDURE IF EXISTS [Monitoring].[StagingHeld];
GO

-- DROP TABLE IF EXISTS --
DROP TABLE IF EXISTS [Monitoring].[Held];
GO

/* End of File ********************************************************************************************************************/