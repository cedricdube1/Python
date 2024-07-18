/***********************************************************************************************************************************
* Script      : 2.SQL Server Agent - Schedules.sql                                                                                 *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-12-17                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [MSDB]
GO
-- Oerator for sending emails --
EXEC dbo.sp_add_operator @name = N'iGaming Insights',  
                         @email_address  = N'iginsights@digioutsource.com';

/* End of File ********************************************************************************************************************/