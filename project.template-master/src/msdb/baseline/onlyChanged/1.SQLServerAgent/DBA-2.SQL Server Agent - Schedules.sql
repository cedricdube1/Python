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
-- Single default schedule, applicable to all non-scheduled jobs, to auto-restart on server startup --
EXEC dbo.sp_add_schedule @schedule_name = N'Raptor Auto Start',  
                         @freq_type = 64;

/* End of File ********************************************************************************************************************/