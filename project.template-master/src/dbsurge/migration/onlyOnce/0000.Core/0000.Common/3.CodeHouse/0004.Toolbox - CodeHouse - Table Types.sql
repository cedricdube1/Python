/************************************************************************
* Script     : 3.ToolBox - CodeHouse - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO


CREATE TYPE [CodeHouse].[ReplacementTag] AS TABLE (
  [Tag] VARCHAR(50) NOT NULL,
  [Value] NVARCHAR(MAX) NOT NULL,
  PRIMARY KEY CLUSTERED ([TAG] ASC)
);
GO
GO
CREATE TYPE [CodeHouse].[ReplacementComponent] AS TABLE (
  [Layer] VARCHAR(50) NOT NULL,
  [Stream] VARCHAR(50) NOT NULL,
  [StreamVariant] VARCHAR(50) NOT NULL,
  [CodeObjectName] NVARCHAR(128) NOT NULL,
  PRIMARY KEY CLUSTERED ([Layer] ASC, [Stream] ASC, [StreamVariant] ASC, [CodeObjectName] ASC)
);
GO
GO
CREATE TYPE [CodeHouse].[CodeObjectFullName] AS TABLE (
  [Ordinal] SMALLINT IDENTITY(1,1) NOT NULL,
  [DatabaseName] NVARCHAR(128) NOT NULL,
  [SchemaName] NVARCHAR(128) NULL,
  [CodeObjectName] NVARCHAR(128) NOT NULL
  INDEX [IDX] CLUSTERED ([DatabaseName] ASC, [SchemaName] ASC, [CodeObjectName] ASC)
);
GO
GO
CREATE TYPE [CodeHouse].[ObjectType] AS TABLE (
  [ObjectType] VARCHAR(50) NOT NULL
  INDEX [IDX] CLUSTERED ([ObjectType] ASC)
);
GO
GO
CREATE TYPE [CodeHouse].[GenerateCodeObjectList] AS TABLE (
  [Ordinal] SMALLINT NOT NULL,
  [Stream] VARCHAR(50) NOT NULL,
  [StreamVariant] VARCHAR(50) NOT NULL,
  [CodeObjectName] NVARCHAR(128) NULL,
  [ObjectLayer] VARCHAR(50) NULL,
  [ObjectType] VARCHAR(50) NULL,
  [CodeType] VARCHAR(50) NULL
  INDEX [IDX] CLUSTERED ([Stream] ASC, [StreamVariant] ASC, [ObjectType] ASC, [CodeType] ASC),
  INDEX [UK1] UNIQUE NONCLUSTERED ([Ordinal] ASC)
);
GO
/* End of File ********************************************************************************************************************/