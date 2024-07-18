/************************************************************************
* Script     : 0.ToolBox - CodeHouse - Drop All Objects.sql
* Created By : Cedric Dube
* Created On : 2021-08-05
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

------------------------------ PROCEDURES ------------------------------
DROP PROCEDURE IF EXISTS [CodeHouse].[SetObjectType];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetCodeType];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetLayer];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetStream];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetStreamVariant];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetTag];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetCodeObject];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetCodeObjectTag];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetCodeObjectComponent];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetCodeObject_Linter];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetDeployment];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetDeploymentTag];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetDeploymentComponent];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetDeploymentDocument];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[SetDeploymentGroup];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Script];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Schema];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_PartitionFunction];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_PartitionScheme];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_TableType];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DataType];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Table];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_TemporalTable];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Index];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_View];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Function];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Procedure];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_SBContract];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_SBMessageType];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_SBQueue];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_SBService];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_ReplaceTags];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_ReplaceComponents];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_Output];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_OutputPrint];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_FileHeader];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_FileSection];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_FileObject];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_FileFooter];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DeploymentHeader] ;
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DeploymentObjectHeader] ;
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DeploymentObjectFooter] ;
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DirectExecuteHeader] ;
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DirectExecuteFooter] ;
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DeploymentFooter] ;
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateDeployment];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateDeployment_Output];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level0];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level1];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_ExtendedProperties_Level2];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_DropComponent];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[GenerateCodeObject_ExistsComponent];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[ExecuteCall_Deployment];
GO
DROP PROCEDURE IF EXISTS [CodeHouse].[ExecuteCall_DeploymentGroup];
GO
------------------------------ FUNCTIONS ------------------------------
DROP FUNCTION IF EXISTS [CodeHouse].[GetCodeObjectTagList];
GO
DROP FUNCTION IF EXISTS [CodeHouse].[GetCodeObjectComponentList];
GO
DROP FUNCTION IF EXISTS [CodeHouse].[GetComponentCodeObject];
GO
------------------------------ VIEWS ------------------------------
DROP VIEW IF EXISTS [CodeHouse].[vObjectTypeUsage];
GO
DROP VIEW IF EXISTS [CodeHouse].[vCodeTypeUsage];
GO
DROP VIEW IF EXISTS [CodeHouse].[vLayerUsage];
GO
DROP VIEW IF EXISTS [CodeHouse].[vStreamUsage];
GO
DROP VIEW IF EXISTS [CodeHouse].[vStreamVariantUsage];
GO
DROP VIEW IF EXISTS [CodeHouse].[vCodeObjectTag];
GO
DROP VIEW IF EXISTS [CodeHouse].[vCodeObjectComponent];
GO
DROP VIEW IF EXISTS [CodeHouse].[vCodeObjectUsage];
GO
DROP VIEW IF EXISTS [CodeHouse].[vCodeObject];
GO
DROP VIEW IF EXISTS [CodeHouse].[vCodeObjectHistory];
GO
DROP VIEW IF EXISTS [CodeHouse].[vDeploymentDocument];
GO
DROP VIEW IF EXISTS [CodeHouse].[vDeploymentTag];
GO
DROP VIEW IF EXISTS [CodeHouse].[vDeploymentComponent];
GO
DROP VIEW IF EXISTS [CodeHouse].[vDeploymentGroup];
GO
DROP VIEW IF EXISTS [CodeHouse].[vDeployment];
GO
DROP VIEW IF EXISTS [CodeHouse].[vDeploymentHistory];
GO
DROP VIEW IF EXISTS [CodeHouse].[vTagUsage];
GO

------------------------------ TABLES ------------------------------
IF OBJECT_ID('[CodeHouse].[Deployment] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[Deployment] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[Tag] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[Tag] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[CodeObject] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[CodeObject] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[ObjectType] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[ObjectType] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[CodeType] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[CodeType] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[Layer] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[Layer] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[Stream] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[Stream] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[StreamVariant] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[StreamVariant] SET ( SYSTEM_VERSIONING = OFF)
GO
IF OBJECT_ID('[CodeHouse].[DeploymentGroup] ', 'U') IS NOT NULL
ALTER TABLE [CodeHouse].[DeploymentGroup] SET ( SYSTEM_VERSIONING = OFF)
GO

DROP TABLE IF EXISTS [CodeHouse].[DeploymentDocument];
GO
DROP TABLE IF EXISTS [CodeHouse].[DeploymentTag];
GO
DROP TABLE IF EXISTS [CodeHouse].[DeploymentComponent];
GO
DROP TABLE IF EXISTS [CodeHouse].[DeploymentError];
GO
DROP TABLE IF EXISTS [CodeHouse].[DeploymentGroup];
DROP TABLE IF EXISTS [CodeHouse].[DeploymentGroup_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[Deployment];
DROP TABLE IF EXISTS [CodeHouse].[Deployment_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[CodeObjectTag];
DROP TABLE IF EXISTS [CodeHouse].[CodeObjectComponent];
GO
DROP TABLE IF EXISTS [CodeHouse].[Tag];
DROP TABLE IF EXISTS [CodeHouse].[Tag_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[CodeObject];
DROP TABLE IF EXISTS [CodeHouse].[CodeObject_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[ObjectType];
DROP TABLE IF EXISTS [CodeHouse].[ObjectType_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[CodeType];
DROP TABLE IF EXISTS [CodeHouse].[CodeType_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[Layer];
DROP TABLE IF EXISTS [CodeHouse].[Layer_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[Stream];
DROP TABLE IF EXISTS [CodeHouse].[Stream_History];
GO
DROP TABLE IF EXISTS [CodeHouse].[StreamVariant];
DROP TABLE IF EXISTS [CodeHouse].[StreamVariant_History];
GO

------------------------------ TABLE TYPES ------------------------------
DROP TYPE IF EXISTS [CodeHouse].[ReplacementTag];
GO
DROP TYPE IF EXISTS [CodeHouse].[CodeObjectFullName];
GO
DROP TYPE IF EXISTS [CodeHouse].[GenerateCodeObjectList]
GO
DROP TYPE IF EXISTS [CodeHouse].[ReplacementComponent];
GO
DROP TYPE IF EXISTS [CodeHouse].[ObjectType];
GO

/* End of File ********************************************************************************************************************/