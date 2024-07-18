/***********************************************************************************************************************************
* Script      : 0.Lookup - Drop All Objects.sql                                                                                    *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-09-06                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script                                                                                                      *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- Lookup
DROP PROCEDURE IF EXISTS [Lookup].[SetProviderSystem];
GO
DROP PROCEDURE IF EXISTS [Lookup].[SetProvider];
GO
DROP PROCEDURE IF EXISTS [Lookup].[SetSourceSystem];
GO

-- Functions --
DROP FUNCTION IF EXISTS [Lookup].[GetSourceSystemID];
GO
DROP FUNCTION IF EXISTS [Lookup].[GetMasterSourceSystemID];
GO
DROP FUNCTION IF EXISTS [Lookup].[GetProviderSystemIDFromExternalID];
GO
DROP FUNCTION IF EXISTS [Lookup].[GetProviderIDFromName];
GO
DROP FUNCTION IF EXISTS [Lookup].[GetRegionalDateFromUTC];
GO
-- Views --
DROP VIEW IF EXISTS [Lookup].[vProvider];
GO
DROP VIEW IF EXISTS [Lookup].[vCountryStateTimeZone];
GO
DROP VIEW IF EXISTS [Lookup].[vSourceSystem];
GO

-- Tables --
DROP TABLE IF EXISTS [Lookup].[DaylightSavings];
GO
DROP TABLE IF EXISTS [Lookup].[CountryStateTimeZone];
GO
DROP TABLE IF EXISTS [Lookup].[TimeZone];
GO
DROP TABLE IF EXISTS [Lookup].[SourceSystemMaster];
GO
DROP TABLE IF EXISTS [Lookup].[ProviderSystem];
GO
DROP TABLE IF EXISTS [Lookup].[Provider];
GO
DROP TABLE IF EXISTS [Lookup].[CountryState];
GO
DROP TABLE IF EXISTS [Lookup].[Country];
GO
DROP TABLE IF EXISTS [Lookup].[SourceSystem];
GO
-- Schema --
/*
DROP SCHEMA [Lookup];
GO

*/

/* End of File ********************************************************************************************************************/