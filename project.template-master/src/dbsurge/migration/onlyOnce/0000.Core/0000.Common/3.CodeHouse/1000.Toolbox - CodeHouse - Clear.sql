/************************************************************************
* Script     : 1000.ToolBox - CodeHouse - Clear.sql
* Created By : Cedric Dube
* Created On : 2021-09-23
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
* Steps      : 1. Clear out all CodeHouse CodeObjects and Deployments
************************************************************************/
USE [dbSurge]
GO
-- DEPLOYMENT --
/*
TRUNCATE TABLE CodeHouse.DeploymentGroup;
TRUNCATE TABLE CodeHouse.DeploymentTag;
TRUNCATE TABLE CodeHouse.DeploymentComponent;
TRUNCATE TABLE CodeHouse.DeploymentDocument;
TRUNCATE TABLE CodeHouse.DeploymentError;
DELETE FROM CodeHouse.Deployment;
*/
--CODE OBJECT --
/*
TRUNCATE TABLE CodeHouse.CodeObjectTag;
TRUNCATE TABLE CodeHouse.CodeObjectComponent;
DELETE FROM CodeHouse.CodeObject;
*/

/* End of File ********************************************************************************************************************/
