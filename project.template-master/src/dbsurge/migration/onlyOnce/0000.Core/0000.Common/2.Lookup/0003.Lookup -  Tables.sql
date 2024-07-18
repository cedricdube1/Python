/***********************************************************************************************************************************
* Script      : 3.Lookup - Tables.sql                                                                                              *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-09-06                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO

-- Country
GO
CREATE TABLE [Lookup].[Country] (
  [CountryCode] [CHAR](2) NOT NULL,
  [SystemFromDate] DATETIME2,
  [SystemToDate] DATETIME2,
  [Alpha2ISOCode] [CHAR](2) NOT NULL,
  [Alpha3ISOCode] [CHAR](3) NOT NULL,
  [NumericISOCode] [CHAR](3) NOT NULL,
  [ShortNameEnglish] [NVARCHAR](256) NOT NULL
  CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([CountryCode] ASC) WITH (FILLFACTOR = 100),
) ON [PRIMARY];
GO

-- Country State
GO
CREATE TABLE [Lookup].[CountryState] (
  [CountryCode] [CHAR](2) NOT NULL,
  CONSTRAINT [FK_CountryState_Country] FOREIGN KEY ([CountryCode]) REFERENCES [Lookup].[Country]([CountryCode]),
  [StateCode] VARCHAR(3) NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [StateName]  [NVARCHAR](256) NOT NULL,
  CONSTRAINT [PK_CountryState] PRIMARY KEY CLUSTERED ([CountryCode] ASC, [StateCode] ASC) WITH (FILLFACTOR = 100),
) ON [PRIMARY];
GO
-- TimeZone
GO
CREATE TABLE [Lookup].[TimeZone] (
  [TimeZone] [VARCHAR](10) NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [TimeZoneName] VARCHAR(50) NULL,
  [UTC_OffsetHours] SMALLINT NOT NULL,
  [UTC_OffsetHours_DaylightSavings] SMALLINT NOT NULL,
  CONSTRAINT [PK_TimeZone] PRIMARY KEY CLUSTERED ([TimeZone] ASC) WITH (FILLFACTOR = 100),
) ON [PRIMARY];
GO
-- DaylightSavings
GO
CREATE TABLE [Lookup].[DaylightSavings] (
  [TimeZone] [VARCHAR](10) NOT NULL,
  [DayLightSavingsStart] DATETIME2 NOT NULL,
  [DayLightSavingsEnd] DATETIME2 NOT NULL
  CONSTRAINT [FK_DaylightSavings_TimeZone] FOREIGN KEY ([TimeZone]) REFERENCES [Lookup].[TimeZone]([TimeZone]),
)  ON [PRIMARY];
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DaylightSavings] ON [Lookup].[DaylightSavings] (
  [TimeZone] ASC,
  [DayLightSavingsStart] ASC,
  [DayLightSavingsEnd] ASC
);
-- Country State TimeZone
GO
CREATE TABLE [Lookup].[CountryStateTimeZone] (
  [CountryCode] [CHAR](2) NOT NULL,
  [StateCode] VARCHAR(3) NOT NULL,
  CONSTRAINT [FK_CountryStateTimeZone_CountryState] FOREIGN KEY ([CountryCode], [StateCode]) REFERENCES [Lookup].[CountryState]([CountryCode], [StateCode]),
  CONSTRAINT [FK_CountryStateTimeZone_TimeZone] FOREIGN KEY ([TimeZone]) REFERENCES [Lookup].[TimeZone]([TimeZone]),
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [TimeZone] VARCHAR(10) NOT NULL
  CONSTRAINT [PK_CountryStateTimeZone] PRIMARY KEY CLUSTERED ([CountryCode] ASC, [StateCode] ASC) WITH (FILLFACTOR = 100),
)  ON [PRIMARY];
GO
-- Provider
GO
CREATE TABLE [Lookup].[Provider] (
  [ProviderID] INT IDENTITY(1,1) NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [ProviderName] VARCHAR(150) NOT NULL,
  [ProviderCallerName] VARCHAR(50) NOT NULL,
  [Descriptor] VARCHAR(250) NULL,
  CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED ([ProviderID] ASC) WITH (FILLFACTOR = 100),
  CONSTRAINT [UK_Provider] UNIQUE NONCLUSTERED ([ProviderCallerName] ASC) WITH (FILLFACTOR = 100),
)  ON [PRIMARY];
GO
-- ProviderSystem
CREATE TABLE [Lookup].[ProviderSystem] (
  [ProviderSystemID] INT IDENTITY(1,1) NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [ProviderID] INT NOT NULL,
  [ProviderExternalSystemID] VARCHAR(150) NOT NULL,
  CONSTRAINT [FK_ProviderSystem_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [Lookup].[Provider]([ProviderID]),
  CONSTRAINT [PK_ProviderSystem] PRIMARY KEY CLUSTERED ([ProviderSystemID]) WITH (FILLFACTOR = 100),
  CONSTRAINT [UK_ProviderSystem] UNIQUE NONCLUSTERED([ProviderID] ASC, [ProviderExternalSystemID] ASC) WITH (FILLFACTOR = 100),
)  ON [PRIMARY];
GO

-- SourceSystem
CREATE TABLE [Lookup].[SourceSystem] (
  [SourceSystemID] INT IDENTITY(1,1) NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [ProviderID] INT NOT NULL,
  [CountryCode] CHAR(2) NOT NULL,
  [StateCode] VARCHAR(3) NOT NULL,
  [ProviderSystemID] INT NOT NULL
  CONSTRAINT [FK_SourceSystem_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [Lookup].[Provider]([ProviderID]),
  CONSTRAINT [FK_SourceSystem_Country] FOREIGN KEY (CountryCode) REFERENCES [Lookup].[Country](CountryCode),
  CONSTRAINT [FK_SourceSystem_CountryState] FOREIGN KEY (CountryCode, StateCode) REFERENCES [Lookup].[CountryState](CountryCode, StateCode),
  CONSTRAINT [FK_SourceSystem_ProviderSystem] FOREIGN KEY (ProviderSystemID) REFERENCES [Lookup].[ProviderSystem](ProviderSystemID),
  CONSTRAINT [PK_SourceSystem] PRIMARY KEY CLUSTERED ([SourceSystemID]) WITH (FILLFACTOR = 100),
  CONSTRAINT [UK_SourceSystem] UNIQUE NONCLUSTERED([ProviderID] ASC, [CountryCode] ASC, [StateCode] ASC, [ProviderSystemID] ASC) WITH (FILLFACTOR = 100),
)  ON [PRIMARY];
GO

-- SourceSystemMaster
GO
CREATE TABLE [Lookup].[SourceSystemMaster] (
  [SourceSystemID] INT NOT NULL,
  [SystemFromDate] DATETIME2 NOT NULL,
  [SystemToDate] DATETIME2 NOT NULL,
  [MasterSourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_SourceSystemMaster_SourceSystem] FOREIGN KEY (SourceSystemID) REFERENCES [Lookup].[SourceSystem](SourceSystemID),
  CONSTRAINT [FK2_SourceSystemMaster_SourceSystem] FOREIGN KEY (SourceSystemID) REFERENCES [Lookup].[SourceSystem](SourceSystemID),
  CONSTRAINT [PK_SourceSystemMaster] PRIMARY KEY CLUSTERED ([SourceSystemID] ASC, [MasterSourceSystemID] ASC) WITH (FILLFACTOR = 100),
)  ON [PRIMARY];
GO

/* End of File ********************************************************************************************************************/