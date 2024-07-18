/****************************************************************************************************************************
* Script      : 3.Monitoring - Integrity - Tables.sql                                                                       *
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
CREATE TABLE [Monitoring].[IntegrityObject] (
  [IntegrityObjectID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_IntegrityObject] PRIMARY KEY CLUSTERED ([IntegrityObjectID] ASC) WITH (FILLFACTOR = 100),
  [DatabaseName] NVARCHAR(128) NOT NULL,
  [SchemaName] NVARCHAR(128) NOT NULL,
  [ObjectName] NVARCHAR(128) NOT NULL,
  CONSTRAINT [UK1_IntegrityObject] UNIQUE NONCLUSTERED ([DatabaseName] ASC, [SchemaName] ASC, [ObjectName] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO
GO
CREATE TABLE [Monitoring].[IntegrityObjectColumn] (
  [IntegrityObjectColumnID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_IntegrityObjectColumn] PRIMARY KEY CLUSTERED ([IntegrityObjectColumnID] ASC) WITH (FILLFACTOR = 100),
  [IntegrityObjectID] INT NOT NULL,
  CONSTRAINT [FK1_IntegrityObjectColumn_IntegrityObject] FOREIGN KEY ([IntegrityObjectID]) REFERENCES [Monitoring].[IntegrityObject] ([IntegrityObjectID]),
  [ColumnName] NVARCHAR(128) NOT NULL,
  [IsParameter] BIT NOT NULL
  CONSTRAINT [DF_IntegrityObjectColumn_IsParameter] DEFAULT (0),
  CONSTRAINT [UK1_IntegrityObjectColumn] UNIQUE NONCLUSTERED ([IntegrityObjectID] ASC, [ColumnName] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO
GO
CREATE TABLE [Monitoring].[IntegrityCompareObject] (
  [IntegrityCompareObjectID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_IntegrityCompareObject] PRIMARY KEY CLUSTERED ([IntegrityCompareObjectID] ASC) WITH (FILLFACTOR = 100),
  [IntegrityObjectID_A] INT NOT NULL,
  CONSTRAINT [FK1_IntegrityCompareObject_IntegrityObject] FOREIGN KEY ([IntegrityObjectID_A]) REFERENCES [Monitoring].[IntegrityObject] ([IntegrityObjectID]),
  [IntegrityObjectID_B] INT NOT NULL,
  CONSTRAINT [FK2_IntegrityCompareObject_IntegrityObject] FOREIGN KEY ([IntegrityObjectID_B]) REFERENCES [Monitoring].[IntegrityObject] ([IntegrityObjectID]),
  [IntegrityObjectColumnID_A] INT NOT NULL,
  CONSTRAINT [FK3_IntegrityCompareObject_IntegrityObjectColumn] FOREIGN KEY ([IntegrityObjectColumnID_A]) REFERENCES [Monitoring].[IntegrityObjectColumn] ([IntegrityObjectColumnID]),
  [IntegrityObjectColumnID_B] INT NOT NULL,
  CONSTRAINT [FK4_IntegrityCompareObject_IntegrityObjectColumn] FOREIGN KEY ([IntegrityObjectColumnID_B]) REFERENCES [Monitoring].[IntegrityObjectColumn] ([IntegrityObjectColumnID]),
  [IsEnabled] BIT NOT NULL
  CONSTRAINT [DF_IntegrityCompareObject_Enabled] DEFAULT (0),
  CONSTRAINT [UK1_IntegrityCompareObject] UNIQUE NONCLUSTERED ([IntegrityObjectID_A] ASC, [IntegrityObjectID_B] ASC, [IntegrityObjectColumnID_A] ASC, [IntegrityObjectColumnID_B] ASC) WITH (FILLFACTOR = 90)
) ON [PRIMARY];
GO
GO
CREATE TABLE [Monitoring].[Integrity] (
  [IntegrityObjectID_A] INT NOT NULL,
  [IntegrityObjectID_B] INT NOT NULL,
  CONSTRAINT [FK1_Integrity_IntegrityObject] FOREIGN KEY ([IntegrityObjectID_A]) REFERENCES [Monitoring].[IntegrityObject] ([IntegrityObjectID]),
  CONSTRAINT [FK2_Integrity_IntegrityObject] FOREIGN KEY ([IntegrityObjectID_B]) REFERENCES [Monitoring].[IntegrityObject] ([IntegrityObjectID]),
  [IntegrityParameters] NVARCHAR(1000) NULL,
  [ValueAExceptB] XML NULL,
  [ValueBExceptA] XML NULL,
  [CheckQuery] NVARCHAR(MAX) NULL,
  [AlertID] [INT] NULL
  CONSTRAINT [DF_Integrity_Reported] DEFAULT (0),
  [InsertDate] DATETIME2(7) NULL
) ON [PRIMARY];
GO
CREATE CLUSTERED INDEX [IDX_Integrity_Reported]
ON [Monitoring].[Integrity] (
  [AlertID]
) WITH (FILLFACTOR = 90);
GO


/* End of File ********************************************************************************************************************/