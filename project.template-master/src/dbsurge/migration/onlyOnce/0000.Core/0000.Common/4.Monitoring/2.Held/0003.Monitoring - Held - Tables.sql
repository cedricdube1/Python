/****************************************************************************************************************************
* Script      : 3.Monitoring - Held - Tables.sql                                                                            *
* Created By  : Cedric Dube                                                                                               *
* Created On  : 2021-03-02                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO

GO
CREATE TABLE [Monitoring].[Held] (
  [HeldDatabase] NVARCHAR(128) NOT NULL,
  [HeldTableSchema] NVARCHAR(128) NOT NULL,
  [HeldTableName] NVARCHAR(128) NOT NULL,
  [HeldView] NVARCHAR(255) NULL,
  [HeldCount] INT NOT NULL
  CONSTRAINT [DF_Held_Count] DEFAULT (0),
  [EarliestHeldDate] DATETIME2 NOT NULL,
  [LatestHeldDate] DATETIME2 NOT NULL,
  [AlertID] [INT] NULL
  CONSTRAINT [DF_Held_Reported] DEFAULT (0),
  [InsertDate] DATETIME2(7) NULL
) ON [PRIMARY];
GO
CREATE NONCLUSTERED INDEX [IDX_Held_Reported]
ON [Monitoring].[Held] (
  [AlertID]
) WITH (FILLFACTOR = 90);
GO
/* End of File ********************************************************************************************************************/