/************************************************************************
* Script     : 6.ToolBox - CodeHouse - Views.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO


CREATE OR ALTER VIEW [CodeHouse].[vTagUsage]
  WITH SCHEMABINDING
AS
  SELECT [TagID] FROM [CodeHouse].[DeploymentTag]
  UNION ALL
  SELECT [TagID] FROM [CodeHouse].[CodeObjectTag];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vCodeObjectUsage]
  WITH SCHEMABINDING
AS
  SELECT [CodeObjectID] FROM [CodeHouse].[Deployment]
  UNION ALL
  SELECT [CodeObjectID] FROM [CodeHouse].[DeploymentComponent]
  UNION ALL
  SELECT [DeploymentScriptObjectID] FROM [CodeHouse].[DeploymentGroup]
  UNION ALL
  SELECT [CodeObjectID] FROM [CodeHouse].[CodeObjectComponent]
  UNION ALL
  SELECT [ComponentCodeObjectID] FROM [CodeHouse].[CodeObjectComponent];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vObjectTypeUsage]
  WITH SCHEMABINDING
AS
  SELECT ObjectTypeID
    FROM [CodeHouse].[CodeObject];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vCodeTypeUsage]
  WITH SCHEMABINDING
AS
  SELECT CodeTypeID
    FROM [CodeHouse].[CodeObject];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vLayerUsage]
  WITH SCHEMABINDING
AS
  SELECT LayerID
    FROM [CodeHouse].[CodeObject];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vStreamUsage]
  WITH SCHEMABINDING
AS
  SELECT StreamID
    FROM [CodeHouse].[CodeObject];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vStreamVariantUsage]
  WITH SCHEMABINDING
AS
  SELECT StreamVariantID
    FROM [CodeHouse].[CodeObject];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vCodeObject]
  WITH SCHEMABINDING
AS
  SELECT [CO].[CodeObjectID],
         [CO].[SystemFromDate],
         [CO].[SystemToDate],
         [CO].[LayerID],
         [CO].[StreamID],
         [CO].[StreamVariantID],
         [CO].[ObjectTypeID],
         [CO].[CodeTypeID],
         [LR].[Layer],
         [LR].[DatabaseName],
         [ST].[Stream],
         [SV].[StreamVariant],
         [CO].[CodeVersion],
         [OT].[ObjectType],
         [CT].[CodeType],
         [CO].[CodeObjectName],
         [CO].[Author],
         [CO].[Remark],
         [CO].[CodeObjectRemark],
         [CO].[CodeObjectHeader],
         [CO].[CodeObjectExecutionOptions],
         [CO].[CodeObject]
    FROM [CodeHouse].[CodeObject] AS [CO]
   INNER JOIN [CodeHouse].[Layer] AS [LR]
      ON [CO].[LayerID] = [LR].[LayerID]
   INNER JOIN [CodeHouse].[Stream] AS [ST]
      ON [CO].[StreamID] = [ST].[StreamID]
   INNER JOIN [CodeHouse].[StreamVariant] AS [SV]
      ON [CO].[StreamVariantID] = [SV].[StreamVariantID]
   INNER JOIN [CodeHouse].[ObjectType] AS [OT]
      ON [CO].[ObjectTypeID] = [OT].[ObjectTypeID]
   INNER JOIN [CodeHouse].[CodeType] AS [CT]
      ON [CO].[CodeTypeID] = [CT].[CodeTypeID];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vCodeObjectTag]
  WITH SCHEMABINDING
AS
  SELECT [CO].[CodeObjectID],
         [TG].[TagID],
         [CO].[Layer],
         [CO].[Stream],
         [CO].[StreamVariant],
         [CO].[CodeObjectName],
         [TG].[Tag]
    FROM [CodeHouse].[CodeObjectTag] AS [COT]
  INNER JOIN [CodeHouse].[vCodeObject] [CO]
      ON [COT].[CodeObjectID] = [CO].[CodeObjectID]
   INNER JOIN [CodeHouse].[Tag] AS [TG]
      ON [COT].[TagID] = [TG].[TagID];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vCodeObjectComponent]
  WITH SCHEMABINDING
AS
  SELECT [CO].[CodeObjectID],
         [CO].[Layer],
         [CO].[Stream],
         [CO].[StreamVariant],
         [CO].[CodeObjectName],
         [COMO].[CodeObjectID] AS [Component_CodeObjectID],
         [COMO].[Layer] AS [Component_Layer],
         [COMO].[Stream] AS [Component_Stream],
         [COMO].[StreamVariant] AS [Component_StreamVariant],
         [COMO].[CodeObjectName] AS [Component_CodeObjectName]
    FROM [CodeHouse].[CodeObjectComponent] AS [COM]
  INNER JOIN [CodeHouse].[vCodeObject] [CO]
      ON [COM].[CodeObjectID] = [CO].[CodeObjectID]
  INNER JOIN [CodeHouse].[vCodeObject] [COMO]
      ON [COM].[ComponentCodeObjectID] = [COMO].[CodeObjectID]
GO
GO
CREATE OR ALTER VIEW [CodeHouse].[vDeployment]
  WITH SCHEMABINDING
AS
  SELECT [DP].[DeploymentID],
         [DP].[ActionedBy] AS [DeploymentBy],
         [DP].[SystemFromDate],
         [DP].[SystemToDate],
         [DP].[DeploymentServer],
         [DP].[DeploymentSet],
         CASE WHEN [DP].[DeploymentStatus] = 'U' THEN 'Unactioned'
              WHEN [DP].[DeploymentStatus] = 'F' THEN 'Failed'
              WHEN [DP].[DeploymentStatus] = 'S' THEN 'Succeeded' END AS [DeploymentStatus],
         [DP].[LayerID],
         [DP].[StreamID],
         [DP].[StreamVariantID],
         [DP].[ObjectTypeID],
         [DP].[CodeTypeID],
         [DP].[CodeObjectID],
         [DP].[CodeVersion],
         [LR].[Layer],
         [ST].[Stream],
         [SV].[StreamVariant],
         [OT].[ObjectType],
         [CT].[CodeType],
         [CO].[CodeObjectName],
         [CO].[Author],
         [CO].[Remark],
         [LR].[DatabaseName],
         [DP].[ObjectSchema] AS [SchemaName],
         [DP].[ObjectName],
         [DP].[DeploymentOrdinal],
         [DP].[DropScript],
         [DP].[ObjectScript],
         [DP].[ExtendedPropertiesScript]
    FROM [CodeHouse].[Deployment] AS [DP]
   INNER JOIN [CodeHouse].[Layer] AS [LR]
      ON [DP].[LayerID] = [LR].[LayerID]
   INNER JOIN [CodeHouse].[Stream] AS [ST]
      ON [DP].[StreamID] = [ST].[StreamID]
   INNER JOIN [CodeHouse].[StreamVariant] AS [SV]
      ON [DP].[StreamVariantID] = [SV].[StreamVariantID]
   INNER JOIN [CodeHouse].[ObjectType] AS [OT]
      ON [DP].[ObjectTypeID] = [OT].[ObjectTypeID]
   INNER JOIN [CodeHouse].[CodeType] AS [CT]
      ON [DP].[CodeTypeID] = [CT].[CodeTypeID]
   INNER JOIN [CodeHouse].[CodeObject] AS [CO]
      ON [DP].[CodeObjectID] = [CO].[CodeObjectID];
GO
GO
CREATE OR ALTER VIEW [CodeHouse].[vDeploymentTag]
  WITH SCHEMABINDING
AS
  SELECT [DP].[DeploymentBy],
         [DP].[DeploymentServer],
         [DP].[DeploymentSet],
         [DP].[DeploymentStatus],
         [DP].[Layer],
         [DP].[Stream],
         [DP].[StreamVariant],
         [DPT].[TagID],
         [TG].[Tag],
         [DPT].[TagValue]
    FROM [CodeHouse].[DeploymentTag] AS [DPT]
   CROSS APPLY (SELECT DISTINCT [DP].[DeploymentBy],
                                [DP].[DeploymentServer],
                                [DP].[DeploymentSet],
                                [DP].[DeploymentStatus],
                                [DP].[Layer],
                                [DP].[Stream],
                                [DP].[StreamVariant]
                           FROM [CodeHouse].[vDeployment] DP
                          WHERE [DP].[DeploymentSet] = [DPT].[DeploymentSet]) DP
   INNER JOIN [CodeHouse].[Tag] AS [TG]
      ON [DPT].[TagID] = [TG].[TagID];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vDeploymentComponent]
  WITH SCHEMABINDING
AS
  SELECT [DP].[DeploymentBy],
         [DP].[DeploymentServer],
         [DP].[DeploymentSet],
         [DP].[DeploymentStatus],
         [DP].[Layer],
         [DP].[Stream],
         [DP].[StreamVariant],
         [CO].[CodeObjectID] AS [ComponentCodeObjectID],
         [CO].[CodeObjectName] AS [ComponentCodeObjectName]
    FROM [CodeHouse].[DeploymentComponent] AS [DPC]
   CROSS APPLY (SELECT DISTINCT [DP].[DeploymentBy],
                                [DP].[DeploymentServer],
                                [DP].[DeploymentSet],
                                [DP].[DeploymentStatus],
                                [DP].[Layer],
                                [DP].[Stream],
                                [DP].[StreamVariant]
                           FROM [CodeHouse].[vDeployment] DP
                          WHERE [DP].[DeploymentSet] = [DPC].[DeploymentSet]) DP
   INNER JOIN [CodeHouse].[CodeObject] AS [CO]
      ON [DPC].[CodeObjectID] = [CO].[CodeObjectID];
GO
GO
CREATE OR ALTER VIEW [CodeHouse].[vDeploymentDocument]
  WITH SCHEMABINDING
AS
  SELECT [DP].[DeploymentBy],
         [DP].[DeploymentServer],
         [DP].[DeploymentSet],
         [DP].[DeploymentStatus],
         [DP].[Layer],
         [DP].[Stream],
         [DP].[StreamVariant],
         [DPD].[DeploymentName],
         [DPD].[Notes]
    FROM [CodeHouse].[DeploymentDocument] AS [DPD]
   CROSS APPLY (SELECT DISTINCT [DP].[DeploymentBy],
                                [DP].[DeploymentServer],
                                [DP].[DeploymentSet],
                                [DP].[DeploymentStatus],
                                [DP].[Layer],
                                [DP].[Stream],
                                [DP].[StreamVariant]
                           FROM [CodeHouse].[vDeployment] DP
                          WHERE [DP].[DeploymentSet] = [DPD].[DeploymentSet]) DP;
GO
GO
CREATE OR ALTER VIEW [CodeHouse].[vDeploymentGroup]
  WITH SCHEMABINDING
AS
  SELECT [DPG].[DeploymentGroupID],
         [DPG].[ActionedBy] AS [DeploymentGroupBy],
         [DPG].[SystemFromDate],
         [DPG].[SystemToDate],
         [DPG].[Ordinal],
         [DPG].[DeploymentGroupName],
         [DP].[DeploymentBy],
         [DP].[DeploymentServer],
         [DP].[DeploymentStatus],
         [DPG].[DeploymentSet],
         [CO].[CodeObjectName] AS [DeploymentScriptObject],
         [LR].[Layer] AS [DeploymentScriptLayer],
         [ST].[Stream] AS [DeploymentScriptStream],
         [SV].[StreamVariant] AS [DeploymentScriptStreamVariant],
         [LRR].[Layer],
         [ST].[Stream],
         [SVV].[StreamVariant],
         [DPG].[ReplacementTags]
    FROM [CodeHouse].[DeploymentGroup] AS [DPG]
   INNER JOIN [CodeHouse].[Layer] AS [LR]
      ON [DPG].[DeploymentScriptLayerID] = [LR].[LayerID]
   INNER JOIN [CodeHouse].[Stream] AS [ST]
      ON [DPG].[DeploymentScriptStreamID] = [ST].[StreamID]
   INNER JOIN [CodeHouse].[StreamVariant] AS [SV]
      ON [DPG].[DeploymentScriptStreamVariantID] = [SV].[StreamVariantID]
   INNER JOIN [CodeHouse].[CodeObject] AS [CO]
      ON [DPG].[DeploymentScriptObjectID] = [CO].[CodeObjectID]
   OUTER APPLY (SELECT DISTINCT [DP].[DeploymentBy],
                                [DP].[DeploymentServer],
                                [DP].[DeploymentSet],
                                [DP].[DeploymentStatus],
                                [DP].[Layer],
                                [DP].[Stream],
                                [DP].[StreamVariant]
                           FROM [CodeHouse].[vDeployment] [DP]
                          WHERE [DP].[DeploymentSet] = [DPG].[DeploymentSet]) [DP]
   LEFT  JOIN [CodeHouse].[Layer] AS [LRR]
      ON [DPG].[LayerID] = [LRR].[LayerID]
   LEFT  JOIN [CodeHouse].[Stream] AS [STT]
      ON [DPG].[StreamID] = [STT].[StreamID]
   LEFT  JOIN [CodeHouse].[StreamVariant] AS [SVV]
      ON [DPG].[StreamVariantID] = [SVV].[StreamVariantID];
GO
GO
CREATE OR ALTER VIEW [CodeHouse].[vCodeObjectHistory]
  WITH SCHEMABINDING
AS
  SELECT [CO].[CodeObjectID],
         [CO].[SystemFromDate],
         [CO].[SystemToDate],
         [CO].[LayerID],
         [CO].[StreamID],
         [CO].[StreamVariantID],
         [CO].[ObjectTypeID],
         [CO].[CodeTypeID],
         [LR].[Layer],
         [LR].[DatabaseName],
         [ST].[Stream],
         [SV].[StreamVariant],
         [CO].[CodeVersion],
         [OT].[ObjectType],
         [CT].[CodeType],
         [CO].[CodeObjectName],
         [CO].[Author],
         [CO].[Remark],
         [CO].[CodeObjectRemark],
         [CO].[CodeObjectHeader],
         [CO].[CodeObjectExecutionOptions],
         [CO].[CodeObject]
    FROM [CodeHouse].[CodeObject] FOR SYSTEM_TIME ALL AS [CO]
   INNER JOIN [CodeHouse].[Layer] AS [LR]
      ON [CO].[LayerID] = [LR].[LayerID]
   INNER JOIN [CodeHouse].[Stream] AS [ST]
      ON [CO].[StreamID] = [ST].[StreamID]
   INNER JOIN [CodeHouse].[StreamVariant] AS [SV]
      ON [CO].[StreamVariantID] = [SV].[StreamVariantID]
   INNER JOIN [CodeHouse].[ObjectType] AS [OT]
      ON [CO].[ObjectTypeID] = [OT].[ObjectTypeID]
   INNER JOIN [CodeHouse].[CodeType] AS [CT]
      ON [CO].[CodeTypeID] = [CT].[CodeTypeID];
GO

GO
CREATE OR ALTER VIEW [CodeHouse].[vDeploymentHistory]
  WITH SCHEMABINDING
AS
  SELECT [DP].[DeploymentID],
         [DP].[ActionedBy] AS [DeploymentBy],
         [DP].[SystemFromDate],
         [DP].[SystemToDate],
         [DP].[DeploymentServer],
         [DP].[DeploymentSet],
         CASE WHEN [DP].[DeploymentStatus] = 'U' THEN 'Unactioned'
              WHEN [DP].[DeploymentStatus] = 'F' THEN 'Failed'
              WHEN [DP].[DeploymentStatus] = 'S' THEN 'Succeeded' END AS [DeploymentStatus],
         [DP].[LayerID],
         [DP].[StreamID],
         [DP].[StreamVariantID],
         [DP].[ObjectTypeID],
         [DP].[CodeTypeID],
         [DP].[CodeObjectID],
         [DP].[CodeVersion],
         [LR].[Layer],
         [ST].[Stream],
         [SV].[StreamVariant],
         [OT].[ObjectType],
         [CT].[CodeType],
         [CO].[CodeObjectName],
         [CO].[Author],
         [CO].[Remark],
         [LR].[DatabaseName],
         [DP].[ObjectSchema] AS [SchemaName],
         [DP].[ObjectName],
         [DP].[DeploymentOrdinal],
         [DP].[DropScript],
         [DP].[ObjectScript],
         [DP].[ExtendedPropertiesScript]
    FROM [CodeHouse].[Deployment] FOR SYSTEM_TIME ALL AS [DP]
   INNER JOIN [CodeHouse].[Layer] AS [LR]
      ON [DP].[LayerID] = [LR].[LayerID]
   INNER JOIN [CodeHouse].[Stream] AS [ST]
      ON [DP].[StreamID] = [ST].[StreamID]
   INNER JOIN [CodeHouse].[StreamVariant] AS [SV]
      ON [DP].[StreamVariantID] = [SV].[StreamVariantID]
   INNER JOIN [CodeHouse].[ObjectType] AS [OT]
      ON [DP].[ObjectTypeID] = [OT].[ObjectTypeID]
   INNER JOIN [CodeHouse].[CodeType] AS [CT]
      ON [DP].[CodeTypeID] = [CT].[CodeTypeID]
   INNER JOIN [CodeHouse].[CodeObject] AS [CO]
      ON [DP].[CodeObjectID] = [CO].[CodeObjectID];
GO

/* End of File ********************************************************************************************************************/