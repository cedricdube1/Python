/***********************************************************************************************************************************
* Script      : 1.Common - Schemas.sql                                                                                            *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Schema                                                                                                           *
***********************************************************************************************************************************/
USE [dbSurge]
GO

GO
CREATE SCHEMA [DataFlow]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [Logging]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [Config]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [Maintenance]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [DataCheck]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [Monitoring]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [Notification]
  AUTHORIZATION [dbo];
GO

GO
CREATE SCHEMA [Archive]
  AUTHORIZATION [dbo];
GO
GO
CREATE SCHEMA [Helper]
  AUTHORIZATION [dbo];
GO
GO
CREATE SCHEMA [Publish]
  AUTHORIZATION [dbo];
GO
GO
CREATE SCHEMA [Lookup]
  AUTHORIZATION [dbo];
GO

/* End of File ********************************************************************************************************************/