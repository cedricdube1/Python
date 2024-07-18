/***********************************************************************************************************************************
* Script      : 1.SQL Server Agent - Categories.sql                                                                                *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-12-17                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [MSDB]
GO
DECLARE @CategoryName NVARCHAR(128);
DECLARE @Environment CHAR(3) = CASE WHEN @@SERVERNAME IN ('CPTDEVDB02','CPTDEVDB10') THEN 'DEV'
                                    WHEN @@SERVERNAME IN ('ANALYSIS01','CPTAOLSTN10','CPTAODB10A','CPTAODB10B') THEN 'PRD'
                               ELSE 'DEV' END;
--IF @Environment = 'UNK' BEGIN;
--  THROW 50000, 'Unknown Environment. Terminating', 1;
--  SET NOEXEC ON;
--END;



--EXEC dbo.sp_delete_category @class=N'JOB',    
--                         @name=@CategoryName; 
--GO 


SET @CategoryName  = 'IGP - IN - Operational';
EXEC dbo.sp_add_category @class=N'JOB',  
                         @type=N'LOCAL',  
                         @name=@CategoryName;  
GO

/* End of File ********************************************************************************************************************/