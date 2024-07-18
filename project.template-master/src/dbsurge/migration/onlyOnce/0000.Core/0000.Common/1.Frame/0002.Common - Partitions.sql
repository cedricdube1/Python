/***********************************************************************************************************************************
* Script      : 2.Common - Partitions.sql                                                                                         *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO
-- BY MONTH --
GO
--IF NOT EXISTS (SELECT * FROM sys.partition_functions WHERE [Name] = 'PartFunc_Month')
--  CREATE PARTITION FUNCTION [PartFunc_Month] (DATETIME2)
--  AS RANGE RIGHT FOR VALUES (
--    '1900-01-01', '2022-07-01','2022-08-01','2022-09-01','2022-10-01','2022-11-01','2022-12-01','2023-01-01','2023-02-01','2023-03-01','2023-04-01','2023-05-01', '2023-06-01', '2023-07-01'
--  );
-- BY YEAR --
GO
--IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE [Name] = 'PartFunc_Year')
--  CREATE PARTITION FUNCTION [PartFunc_Year] (DATETIME2)
--  AS RANGE RIGHT FOR VALUES (
--   '1900-01-01',  '2022-01-01', '2023-01-01'
--  );
-- BY MONTH NUMBER
GO
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE [Name] = 'PartFunc_MonthNumber')
  CREATE PARTITION FUNCTION [PartFunc_MonthNumber](TINYINT) 
  AS RANGE LEFT FOR VALUES (
   1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,12
  )
GO
GO
--IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE [Name] = 'PartFunc_Date')
--  CREATE PARTITION FUNCTION [PartFunc_Date] (DATETIME2)
--  AS RANGE RIGHT FOR VALUES (
--    '1900-01-01 00:00:00', 
--	'2020-08-24 00:00:00', '2020-08-25 00:00:00', '2020-08-26 00:00:00', '2020-08-27 00:00:00', '2020-08-28 00:00:00', '2020-08-29 00:00:00', '2020-08-30 00:00:00', '2020-08-31 00:00:00',
--    '2020-09-01 00:00:00', '2020-09-02 00:00:00', '2020-09-03 00:00:00', '2020-09-04 00:00:00', '2020-09-05 00:00:00', '2020-09-06 00:00:00', '2020-09-07 00:00:00', '2020-09-08 00:00:00', 
--    '2020-09-09 00:00:00', '2020-09-10 00:00:00', '2020-09-11 00:00:00', '2020-09-12 00:00:00', '2020-09-13 00:00:00', '2020-09-14 00:00:00', '2020-09-15 00:00:00', '2020-09-16 00:00:00', 
--    '2020-09-17 00:00:00', '2020-09-18 00:00:00', '2020-09-19 00:00:00', '2020-09-20 00:00:00', '2020-09-21 00:00:00', '2020-09-22 00:00:00', '2020-09-23 00:00:00', '2020-09-24 00:00:00', 
--    '2020-09-25 00:00:00', '2020-09-26 00:00:00', '2020-09-27 00:00:00', '2020-09-28 00:00:00', '2020-09-29 00:00:00', '2020-09-30 00:00:00',
--    '2020-10-01 00:00:00', '2020-10-02 00:00:00', '2020-10-03 00:00:00', '2020-10-04 00:00:00', '2020-10-05 00:00:00', '2020-10-06 00:00:00',
--    '2020-10-07 00:00:00', '2020-10-08 00:00:00', '2020-10-09 00:00:00', '2020-10-10 00:00:00', '2020-10-11 00:00:00', '2020-10-12 00:00:00',
--    '2020-10-13 00:00:00', '2020-10-14 00:00:00', '2020-10-15 00:00:00', '2020-10-16 00:00:00', '2020-10-17 00:00:00', '2020-10-18 00:00:00',
--    '2020-10-19 00:00:00', '2020-10-20 00:00:00', '2020-10-21 00:00:00', '2020-10-22 00:00:00', '2020-10-23 00:00:00', '2020-10-24 00:00:00', 
--    '2020-10-25 00:00:00', '2020-10-26 00:00:00', '2020-10-27 00:00:00', '2020-10-28 00:00:00', '2020-10-29 00:00:00', '2020-10-30 00:00:00', '2020-10-31 00:00:00',
--    '2020-11-01 00:00:00', '2020-11-02 00:00:00', '2020-11-03 00:00:00', '2020-11-04 00:00:00', '2020-11-05 00:00:00', '2020-11-06 00:00:00',
--    '2020-11-07 00:00:00', '2020-11-08 00:00:00', '2020-11-09 00:00:00', '2020-11-10 00:00:00', '2020-11-11 00:00:00', '2020-11-12 00:00:00',
--    '2020-11-13 00:00:00', '2020-11-14 00:00:00', '2020-11-15 00:00:00', '2020-11-16 00:00:00', '2020-11-17 00:00:00', '2020-11-18 00:00:00',
--    '2020-11-19 00:00:00', '2020-11-20 00:00:00', '2020-11-21 00:00:00', '2020-11-22 00:00:00', '2020-11-23 00:00:00', '2020-11-24 00:00:00', 
--    '2020-11-25 00:00:00', '2020-11-26 00:00:00', '2020-11-27 00:00:00', '2020-11-28 00:00:00', '2020-11-29 00:00:00', '2020-11-30 00:00:00',
--    '2020-12-01 00:00:00', '2020-12-02 00:00:00', '2020-12-03 00:00:00', '2020-12-04 00:00:00', '2020-12-05 00:00:00', '2020-12-06 00:00:00',
--    '2020-12-07 00:00:00', '2020-12-08 00:00:00', '2020-12-09 00:00:00', '2020-12-10 00:00:00', '2020-12-11 00:00:00', '2020-12-12 00:00:00',
--    '2020-12-13 00:00:00', '2020-12-14 00:00:00', '2020-12-15 00:00:00', '2020-12-16 00:00:00', '2020-12-17 00:00:00', '2020-12-18 00:00:00',
--    '2020-12-19 00:00:00', '2020-12-20 00:00:00', '2020-12-21 00:00:00', '2020-12-22 00:00:00', '2020-12-23 00:00:00', '2020-12-24 00:00:00', 
--    '2020-12-25 00:00:00', '2020-12-26 00:00:00', '2020-12-27 00:00:00', '2020-12-28 00:00:00', '2020-12-29 00:00:00', '2020-12-30 00:00:00', '2020-12-31 00:00:00'
--  );

-- Partition Schemes --
GO
IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE [Name] = 'PartScheme_Logging_MonthNumber')
  CREATE PARTITION SCHEME [PartScheme_Logging_MonthNumber] AS PARTITION [PartFunc_MonthNumber] 
  ALL TO ([PRIMARY])
GO

--IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE [Name] = 'PartScheme_Surge_Year')
--  CREATE PARTITION SCHEME [PartScheme_Surge_Year] AS PARTITION [PartFunc_Year] 
--  ALL TO ([PRIMARY])

----Check partition specified correctly
SELECT F.name, R.*
    FROM sys.partition_functions F WITH (NOLOCK)
   INNER JOIN sys.partition_range_VALUES R WITH (NOLOCK) 
      ON R.function_id = F.function_id
   WHERE F.[Name] = 'PartFunc_MonthNumber';

SELECT * FROM sys.partition_schemes WHERE [Name] = 'PartFunc_MonthNumber'



/* End of File ********************************************************************************************************************/