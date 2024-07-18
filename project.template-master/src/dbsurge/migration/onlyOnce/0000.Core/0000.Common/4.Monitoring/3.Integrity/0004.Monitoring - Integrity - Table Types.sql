/****************************************************************************************************************************
* Script      : 4.Monitoring - Table Types.sql                                                                              *
* Created By  : Cedric Dube                                                                                               *
* Created On  : 2021-04-15                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE TYPE [Monitoring].[IntegrityObjectColumnSet] AS TABLE(
  ColumnName NVARCHAR(128) NOT NULL,
  IsParameter BIT NOT NULL
  PRIMARY KEY NONCLUSTERED (ColumnName ASC)
);
GO
GO
CREATE TYPE [Monitoring].[IntegrityCompareObjectSet] AS TABLE(
  ColumnName_A NVARCHAR(128) NOT NULL,
  ColumnName_B NVARCHAR(128) NOT NULL,
  IsEnabled BIT NOT NULL
  PRIMARY KEY NONCLUSTERED (ColumnName_A ASC, ColumnName_B ASC)
);
GO
/* End of File ********************************************************************************************************************/