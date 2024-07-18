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

GO
CREATE TABLE [CodeHouse].[ObjectType_History] (
  [ObjectTypeID] SMALLINT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [ObjectType] VARCHAR(50) NOT NULL, -- 
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[ObjectType] (
  [ObjectTypeID] SMALLINT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_ObjectType] PRIMARY KEY CLUSTERED ([ObjectTypeID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [ObjectType] VARCHAR(50) NOT NULL, -- Procedure
  CONSTRAINT [UK_ObjectType] UNIQUE NONCLUSTERED([ObjectType] ASC) WITH (FILLFACTOR = 100),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_ObjectType] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[ObjectType_History]));
GO

-- CodeType
GO
CREATE TABLE [CodeHouse].[CodeType_History] (
  [CodeTypeID] SMALLINT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [CodeType] VARCHAR(50) NOT NULL, -- 
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[CodeType] (
  [CodeTypeID] SMALLINT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_CodeType] PRIMARY KEY CLUSTERED ([CodeTypeID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [CodeType] VARCHAR(50) NOT NULL, -- CodeObject
  CONSTRAINT [UK_CodeType] UNIQUE NONCLUSTERED([CodeType] ASC) WITH (FILLFACTOR = 100),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_CodeType] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[CodeType_History]));
GO

-- Layer
GO
CREATE TABLE [CodeHouse].[Layer_History] (
  [LayerID] SMALLINT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [Layer] VARCHAR(50) NOT NULL,
  [DatabaseName] NVARCHAR(128) NOT NULL,
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[Layer] (
  [LayerID] SMALLINT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_Layer] PRIMARY KEY CLUSTERED ([LayerID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [Layer] VARCHAR(50) NOT NULL, -- Source
  [DatabaseName] NVARCHAR(128) NOT NULL, -- dbSource
  CONSTRAINT [UK_Layer] UNIQUE NONCLUSTERED([Layer] ASC) WITH (FILLFACTOR = 100),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_Layer] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[Layer_History]));
GO

-- Stream
GO
CREATE TABLE [CodeHouse].[Stream_History] (
  [StreamID] SMALLINT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [Stream] VARCHAR(50) NOT NULL, -- 
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[Stream] (
  [StreamID] SMALLINT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_Stream] PRIMARY KEY CLUSTERED ([StreamID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [Stream] VARCHAR(50) NOT NULL, -- Source
  CONSTRAINT [UK_Stream] UNIQUE NONCLUSTERED([Stream] ASC) WITH (FILLFACTOR = 100),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_Stream] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[Stream_History]));
GO

-- StreamVariant
GO
CREATE TABLE [CodeHouse].[StreamVariant_History] (
  [StreamVariantID] SMALLINT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [StreamVariant] VARCHAR(50) NOT NULL, -- 
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[StreamVariant] (
  [StreamVariantID] SMALLINT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_StreamVariant] PRIMARY KEY CLUSTERED ([StreamVariantID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [StreamVariant] VARCHAR(50) NOT NULL, -- Source
  CONSTRAINT [UK_StreamVariant] UNIQUE NONCLUSTERED([StreamVariant] ASC) WITH (FILLFACTOR = 100),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_StreamVariant] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[StreamVariant_History]));
GO

-- CodeObject
GO
CREATE TABLE [CodeHouse].[CodeObject_History] (
  [CodeObjectID] INT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [LayerID] SMALLINT NOT NULL, -- Source
  [StreamID] SMALLINT NOT NULL, -- Adjustment
  [StreamVariantID] SMALLINT NOT NULL, -- Pala
  [CodeVersion] DECIMAL(9,1) NOT NULL,
  [ObjectTypeID] SMALLINT NOT NULL,
  [CodeTypeID] SMALLINT NOT NULL,
  [CodeObjectName] NVARCHAR(128) NOT NULL,
  [Author] NVARCHAR(128) NOT NULL,
  [Remark] VARCHAR(1000) NOT NULL,
  [CodeObjectRemark] NVARCHAR(2000) NULL,
  [CodeObjectHeader] NVARCHAR(2000) NULL,
  [CodeObjectExecutionOptions] NVARCHAR(1000) NULL,
  [CodeObject] NVARCHAR(MAX) NOT NULL, -- 
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[CodeObject] (
  [CodeObjectID] INT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_CodeObject] PRIMARY KEY CLUSTERED ([CodeObjectID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [LayerID] SMALLINT NOT NULL, -- Source
  [StreamID] SMALLINT NOT NULL, -- Adjustment
  [StreamVariantID] SMALLINT NOT NULL, -- Pala
  [CodeVersion] DECIMAL(9,1) NOT NULL,
  [ObjectTypeID] SMALLINT NOT NULL,
  [CodeTypeID] SMALLINT NOT NULL,
  [CodeObjectName] NVARCHAR(128) NOT NULL,
  CONSTRAINT [UK1_CodeObject] UNIQUE NONCLUSTERED([LayerID] ASC, [StreamID] ASC, [StreamVariantID] ASC, [CodeObjectName] ASC) WITH (FILLFACTOR = 100),
  [Author] NVARCHAR(128) NOT NULL,
  [Remark] VARCHAR(1000) NOT NULL,
  [CodeObjectRemark] NVARCHAR(2000) NULL,
  [CodeObjectHeader] NVARCHAR(2000) NULL,
  [CodeObjectExecutionOptions] NVARCHAR(1000) NULL,
  [CodeObject] NVARCHAR(MAX) NOT NULL,
  CONSTRAINT [FK_CodeObject_ObjectType] FOREIGN KEY ([ObjectTypeID]) REFERENCES [CodeHouse].[ObjectType] ([ObjectTypeID]),
  CONSTRAINT [FK_CodeObject_CodeType] FOREIGN KEY ([CodeTypeID]) REFERENCES [CodeHouse].[CodeType] ([CodeTypeID]),
  CONSTRAINT [FK_CodeObject_Layer] FOREIGN KEY ([LayerID]) REFERENCES [CodeHouse].[Layer] ([LayerID]),
  CONSTRAINT [FK_CodeObject_Stream] FOREIGN KEY ([StreamID]) REFERENCES [CodeHouse].[Stream] ([StreamID]),
  CONSTRAINT [FK_CodeObject_StreamVariant] FOREIGN KEY ([StreamVariantID]) REFERENCES [CodeHouse].[StreamVariant] ([StreamVariantID]),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_CodeObject] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[CodeObject_History]));
GO

-- Tag
GO
CREATE TABLE [CodeHouse].[Tag_History] (
  [TagID] SMALLINT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [Tag] VARCHAR(50) NOT NULL,
  [Description] VARCHAR(150) NOT NULL,
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[Tag] (
  [TagID] SMALLINT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_Tag] PRIMARY KEY CLUSTERED ([TagID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [Tag] VARCHAR(50) NOT NULL,
  [Description] VARCHAR(150) NOT NULL,
  CONSTRAINT [UK_Tag] UNIQUE NONCLUSTERED([Tag] ASC) WITH (FILLFACTOR = 100),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_Tag] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[Tag_History]));
GO

GO
CREATE TABLE [CodeHouse].[CodeObjectTag] (
  [CodeObjectID] INT NOT NULL,
  [TagID] SMALLINT NOT NULL,
  CONSTRAINT [PK_CodeObjectTag] PRIMARY KEY CLUSTERED ([CodeObjectID] ASC, [TagID] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [FK_CodeObjectTag_CodeObject] FOREIGN KEY ([CodeObjectID]) REFERENCES [CodeHouse].[CodeObject] ([CodeObjectID]),
  CONSTRAINT [FK_CodeObjectTag_Tag] FOREIGN KEY ([TagID]) REFERENCES [CodeHouse].[Tag] ([TagID]),
) ON [PRIMARY]
GO

GO
CREATE TABLE [CodeHouse].[CodeObjectComponent] (
  [CodeObjectID] INT NOT NULL,
  [ComponentCodeObjectID] INT NOT NULL,
  CONSTRAINT [PK_CodeObjectComponent] PRIMARY KEY CLUSTERED ([CodeObjectID] ASC, [ComponentCodeObjectID] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [FK_CodeObjectComponent_CodeObject] FOREIGN KEY ([CodeObjectID]) REFERENCES [CodeHouse].[CodeObject] ([CodeObjectID]),
  CONSTRAINT [FK_CodeObjectComponent_ComponentCodeObject] FOREIGN KEY ([ComponentCodeObjectID]) REFERENCES [CodeHouse].[CodeObject] ([CodeObjectID]),
) ON [PRIMARY]
GO

GO
CREATE TABLE [CodeHouse].[Deployment_History] (
  [DeploymentID] INT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [DeploymentServer] NVARCHAR(128) NOT NULL,
  [DeploymentSet] UNIQUEIDENTIFIER NOT NULL,
  [DeploymentStatus] CHAR(1) NOT NULL,
  [LayerID] SMALLINT NOT NULL,
  [StreamID] SMALLINT NOT NULL,
  [StreamVariantID] SMALLINT NOT NULL,
  [CodeVersion] DECIMAL(9,1) NOT NULL,
  [ObjectTypeID] SMALLINT NOT NULL,
  [CodeTypeID] SMALLINT NOT NULL,
  [CodeObjectID] INT NOT NULL,
  [ObjectSchema] NVARCHAR(128) NULL,
  [ObjectName] NVARCHAR(128) NOT NULL,
  [DeploymentOrdinal] SMALLINT NOT NULL,
  [DropScript] NVARCHAR(MAX) NULL,
  [ObjectScript] NVARCHAR(MAX) NULL,
  [ExtendedPropertiesScript] NVARCHAR(MAX) NULL,
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[Deployment] (
  [DeploymentID] INT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_Deployment] PRIMARY KEY CLUSTERED ([DeploymentID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [DeploymentServer] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_Deployment] DEFAULT (@@SERVERNAME),
  [DeploymentSet] UNIQUEIDENTIFIER NOT NULL,
  [DeploymentStatus] CHAR(1) NOT NULL
    CONSTRAINT [DF2_Deployment] DEFAULT ('U'),
    CONSTRAINT [CK1_Deployment] CHECK ([DeploymentStatus] IN ('U','F','S')), --Unactioned|Failed|Succeeded
  [LayerID] SMALLINT NOT NULL,
  [StreamID] SMALLINT NOT NULL,
  [StreamVariantID] SMALLINT NOT NULL,
  [CodeVersion] DECIMAL(9,1) NOT NULL,
  [ObjectTypeID] SMALLINT NOT NULL,
  [CodeTypeID] SMALLINT NOT NULL,
  [CodeObjectID] INT NOT NULL,
  [ObjectSchema] NVARCHAR(128) NULL,
  [ObjectName] NVARCHAR(128) NOT NULL,
  [DeploymentOrdinal] SMALLINT NOT NULL,
  [DropScript] NVARCHAR(MAX) NULL,
  [ObjectScript] NVARCHAR(MAX) NULL,
  [ExtendedPropertiesScript] NVARCHAR(MAX) NULL,
  CONSTRAINT [FK_Deployment_ObjectType] FOREIGN KEY ([ObjectTypeID]) REFERENCES [CodeHouse].[ObjectType] ([ObjectTypeID]),
  CONSTRAINT [FK_Deployment_CodeType] FOREIGN KEY ([CodeTypeID]) REFERENCES [CodeHouse].[CodeType] ([CodeTypeID]),
  CONSTRAINT [FK_Deployment_Layer] FOREIGN KEY ([LayerID]) REFERENCES [CodeHouse].[Layer] ([LayerID]),
  CONSTRAINT [FK_Deployment_Stream] FOREIGN KEY ([StreamID]) REFERENCES [CodeHouse].[Stream] ([StreamID]),
  CONSTRAINT [FK_Deployment_StreamVariant] FOREIGN KEY ([StreamVariantID]) REFERENCES [CodeHouse].[StreamVariant] ([StreamVariantID]),
  CONSTRAINT [FK_Deployment_CodeObject] FOREIGN KEY ([CodeObjectID]) REFERENCES [CodeHouse].[CodeObject] ([CodeObjectID]),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF3_Deployment] DEFAULT (SYSTEM_USER),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[Deployment_History]));
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK1] ON [CodeHouse].[Deployment] (
  [DeploymentSet],
  [LayerID],
  [StreamID],
  [StreamVariantID],
  [CodeVersion],
  [ObjectTypeID],
  [CodeTypeID],
  [CodeObjectID]
) WITH (FILLFACTOR = 90);
GO

GO
CREATE TABLE [CodeHouse].[DeploymentError] (
  [DeploymentErrorID] INT IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_DeploymentError] PRIMARY KEY CLUSTERED ([DeploymentErrorID] ASC) WITH (FILLFACTOR = 100),
  [DeploymentID] INT NOT NULL,
  CONSTRAINT [FK_DeploymentError_Deployment] FOREIGN KEY ([DeploymentID]) REFERENCES [CodeHouse].[Deployment] ([DeploymentID]),
  [ErrorMessage] NVARCHAR(4000),
  [CreatedDateTime] DATETIME2 NOT NULL
    CONSTRAINT [DF1_DeploymentError] DEFAULT SYSUTCDATETIME()
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCIDX1] ON [CodeHouse].[DeploymentError] (
  [DeploymentID]
) INCLUDE (ErrorMessage, CreatedDateTime, DeploymentErrorID) WITH (FILLFACTOR = 90);
GO


GO
CREATE TABLE [CodeHouse].[DeploymentTag] (
  [DeploymentSet] UNIQUEIDENTIFIER NOT NULL,
  [TagID] SMALLINT NOT NULL,
  CONSTRAINT [PK_DeploymentTag] PRIMARY KEY CLUSTERED ([DeploymentSet] ASC, [TagID] ASC) WITH (FILLFACTOR = 100),
  [TagValue] NVARCHAR(MAX) NOT NULL
  CONSTRAINT [FK_DeploymentTag_Tag] FOREIGN KEY ([TagID]) REFERENCES [CodeHouse].[Tag] ([TagID]),
) ON [PRIMARY]
GO

GO
CREATE TABLE [CodeHouse].[DeploymentComponent] (
  [DeploymentSet] UNIQUEIDENTIFIER NOT NULL,
  [CodeObjectID] INT NOT NULL,
  CONSTRAINT [PK_DeploymentComponent] PRIMARY KEY CLUSTERED ([DeploymentSet] ASC, [CodeObjectID] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [FK_DeploymentComponent_CodeObject] FOREIGN KEY ([CodeObjectID]) REFERENCES [CodeHouse].[CodeObject] ([CodeObjectID]),
) ON [PRIMARY]
GO

GO
CREATE TABLE [CodeHouse].[DeploymentDocument] (
  [DeploymentSet] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [PK_DeploymentDocument] PRIMARY KEY CLUSTERED ([DeploymentSet] ASC) WITH (FILLFACTOR = 100),
  [DeploymentName] NVARCHAR(128) NOT NULL,
  [Notes] NVARCHAR(MAX) NOT NULL
) ON [PRIMARY]
GO

GO
CREATE TABLE [CodeHouse].[DeploymentGroup_History] (
  [DeploymentGroupID] INT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [Ordinal] SMALLINT NOT NULL,
  [DeploymentGroupName] NVARCHAR(128) NOT NULL,
  -- If using existing deployment --
  [DeploymentSet] UNIQUEIDENTIFIER NULL,
  -- Object --
  [DeploymentScriptObjectID] INT NOT NULL,
  [DeploymentScriptLayerID] SMALLINT NOT NULL,
  [DeploymentScriptStreamID] SMALLINT NOT NULL,
  [DeploymentScriptStreamVariantID] SMALLINT NOT NULL,
  -- Stream --
  [LayerID] SMALLINT NULL,
  [StreamID] SMALLINT NULL,
  [StreamVariantID] SMALLINT NULL,
  -- Tags --
  [ReplacementTags] NVARCHAR(MAX),
  [ActionedBy] NVARCHAR(128) NOT NULL
) ON [PRIMARY]
GO
GO
CREATE TABLE [CodeHouse].[DeploymentGroup] (
  [DeploymentGroupID] INT IDENTITY (1,1) NOT NULL,
  CONSTRAINT [PK_DeploymentGroup] PRIMARY KEY CLUSTERED ([DeploymentGroupID] ASC) WITH (FILLFACTOR = 100),
  [SystemFromDate] DATETIME2 GENERATED ALWAYS AS ROW START,
  [SystemToDate] DATETIME2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (SystemFromDate, SystemToDate),
  [Ordinal] SMALLINT NOT NULL,
  [DeploymentGroupName] NVARCHAR(128) NOT NULL,
  -- If using existing deployment --
  [DeploymentSet] UNIQUEIDENTIFIER NULL,
  -- Object --
  -- Object --
  [DeploymentScriptObjectID] INT NOT NULL,
  [DeploymentScriptLayerID] SMALLINT NOT NULL,
  [DeploymentScriptStreamID] SMALLINT NOT NULL,
  [DeploymentScriptStreamVariantID] SMALLINT NOT NULL,
  -- Stream --
  [LayerID] SMALLINT NULL,
  [StreamID] SMALLINT NULL,
  [StreamVariantID] SMALLINT NULL,
  -- Tags --
  [ReplacementTags] NVARCHAR(MAX),
  [ActionedBy] NVARCHAR(128) NOT NULL
    CONSTRAINT [DF1_DeploymentGroup] DEFAULT (SYSTEM_USER),
  CONSTRAINT [UK_DeploymentGroup] UNIQUE NONCLUSTERED([DeploymentGroupName] ASC, [DeploymentScriptObjectID] ASC, [DeploymentScriptLayerID] ASC, [DeploymentScriptStreamID] ASC, [DeploymentScriptStreamVariantID] ASC, [LayerID] ASC, [StreamID] ASC, [StreamVariantID] ASC, [Ordinal] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [UK2_DeploymentGroup] UNIQUE NONCLUSTERED([DeploymentGroupName] ASC, [Ordinal] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [FK_DeploymentGroup_CodeObject] FOREIGN KEY ([DeploymentScriptObjectID]) REFERENCES [CodeHouse].[CodeObject] ([CodeObjectID]),
  CONSTRAINT [FK_DeploymentGroup_DeploymentScriptLayer] FOREIGN KEY ([DeploymentScriptLayerID]) REFERENCES [CodeHouse].[Layer] ([LayerID]),
  CONSTRAINT [FK_DeploymentGroup_DeploymentScriptStream] FOREIGN KEY ([DeploymentScriptStreamID]) REFERENCES [CodeHouse].[Stream] ([StreamID]),
  CONSTRAINT [FK_DeploymentGroup_DeploymentScriptStreamVariant] FOREIGN KEY ([DeploymentScriptStreamVariantID]) REFERENCES [CodeHouse].[StreamVariant] ([StreamVariantID]),
  CONSTRAINT [FK_DeploymentGroup_Layer] FOREIGN KEY ([LayerID]) REFERENCES [CodeHouse].[Layer] ([LayerID]),
  CONSTRAINT [FK_DeploymentGroup_Stream] FOREIGN KEY ([StreamID]) REFERENCES [CodeHouse].[Stream] ([StreamID]),
  CONSTRAINT [FK_DeploymentGroup_StreamVariant] FOREIGN KEY ([StreamVariantID]) REFERENCES [CodeHouse].[StreamVariant] ([StreamVariantID]),
) ON [PRIMARY]
  WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [CodeHouse].[DeploymentGroup_History]));
GO
/* End of File ********************************************************************************************************************/