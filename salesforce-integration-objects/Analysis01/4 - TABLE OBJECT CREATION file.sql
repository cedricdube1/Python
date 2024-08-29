--STEP 4 FILE
/*****************************************************************************************************************************************************
* Script     : 4 - TABLE OBJECT CREATION file.sql                                                         *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                            *--
* Updated By : Cedric Dube                                                                                                                          *--
* Updated On : 2024-05-24                                                                                                                            *--
* Execute On : ALL Environments                                                                                                                      *--
* Execute As : Manual                                                                                                                                *--
* Execution  : Entire script once                                                                                                                    *--
* Object List ****************************************************************************************************************************************--
* 0 Drop All       : Yes                                                                                                                             *--
*				   : N/A																														     *--
*                  : N/A																														     *--
*                  : N/A                                                                                                                             *--
* Final Notes ****************************************************************************************************************************************--
* This script does not need to be populated at the start, As you discover all the objects you can list them down here.                          	 *--
*																																					 *--
*																														                             *--
*****************************************************************************************************************************************************/
USE dbPromotions;
GO

SET NOCOUNT ON;
GO

CREATE TABLE [dbo].[ProcessError](
	[ErrorLogID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ProcessName] [VARCHAR](500) NULL,
	[ErrorProcedure] [NVARCHAR](128) NULL,
	[ErrorNumber] [INT] NULL,
	[ErrorLine] [INT] NULL,
	[ErrorMessage] [NVARCHAR](4000) NULL,
	[CreatedDateTime] [DATETIME2](7) NOT NULL,
 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
(
	[ErrorLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ProcessError] ADD  CONSTRAINT [DF_ErrorLog_CreatedDateTime]  DEFAULT (SYSUTCDATETIME()) FOR [CreatedDateTime]
GO

CREATE TABLE [dbo].[PlayerPromoMarketing](
	[CustomerID] [INT] NOT NULL,
	[RuleKey] [INT] NOT NULL ,	    --will keep but wont tranfer over
	[PlayerKey] [INT] NOT NULL,		--will keep but wont tranfer over
	[UserID] [INT] NOT NULL,
	[CasinoId] [INT] NOT NULL,
	[GamingServerId] [INT] NOT NULL,
	[PlayerLifecycle] [VARCHAR](255) NULL,
	[Eligible] [CHAR](1) NULL,
	[OfferType] [VARCHAR](255) NULL,
	[PrimaryOffer] [INT] NULL,
	[CouponValue] [INT] NULL,
	[ValidFrom] [DATETIME] NULL,
	[ValidTo] [DATETIME] NULL,
	[BirthdayOffer] [INT] NULL,		
	[StartDate] [DATETIME] NULL,
	[EndDate] [DATETIME] NULL,	
	[SuggestedBonus] [FLOAT] NULL,	
	[BehaviourCat] [VARCHAR](255) NULL DEFAULT 'BaseExpectationLowTipping',
	[CustomerMajoritySegment] [VARCHAR](255) NULL,
	[CustomerPurchaseLifeTimeSegment] [VARCHAR](255) NOT NULL DEFAULT 'None',	
	[SoftLapsedDays] [INT] NULL,
	[SoftLapsedReason] [VARCHAR](255) NULL,
	[GameGroupCat1] [VARCHAR](255) NULL,
	[GameGroupCat2] [VARCHAR](255) NULL,
	[GameGroupCat3] [VARCHAR](255) NULL ,
	[ABTestFlag] [CHAR](1) NULL,
	[lastModified] [DATETIME] NOT NULL DEFAULT GETDATE(),
) ON [PRIMARY]

ALTER TABLE [dbo].[PlayerPromoMarketing] ADD  CONSTRAINT [PK1] PRIMARY KEY CLUSTERED ([GamingServerId] ASC, [UserID] ASC)

CREATE NONCLUSTERED INDEX [IX1] ON [dbo].[PlayerPromoMarketing] ([CustomerID] ASC,[RuleKey] ASC)

CREATE UNIQUE NONCLUSTERED INDEX [IX2] ON [dbo].[PlayerPromoMarketing] ([PlayerKey] ASC)

CREATE NONCLUSTERED INDEX [IX3] ON [dbo].[PlayerPromoMarketing] ([LastModified] ASC)
GO

CREATE TYPE [dbo].[ConfirmEvents] AS TABLE(
     [EventPayloadID] [int] NOT NULL,
     [EventPayloadRecordID] [int] NOT NULL,
     [EventPayloadGenerated] [datetime2] NOT NULL,
     [ProduceEventConfirmed] [datetime2] NOT NULL,
     [ProduceEventMessageID] [uniqueidentifier] NOT NULL,
     PRIMARY KEY CLUSTERED  ([EventPayloadID], [EventPayloadRecordID])
)
GO

CREATE TABLE [dbo].[PublishError](
     [PublishErrorID] [INT] NOT NULL IDENTITY(1, 1),
     [ErrorTimeStamp] [DATETIME2] NOT NULL CONSTRAINT [DF1_PublishError] DEFAULT (SYSUTCDATETIME()),
     [EventPayloadID] [INT] NOT NULL,
     [EventPayloadRecordID] [INT] NOT NULL,
     [ProduceEventMessageID] [UNIQUEIDENTIFIER] NOT NULL,
     [ErrorProcedure] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
     [ErrorMessage] [NVARCHAR] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
     [ErrorSeverity] [TINYINT] NULL,
     [ErrorNumber] [INT] NULL,
     [ErrorLine] [INT] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[PublishError] ADD CONSTRAINT [PK_PublishError] PRIMARY KEY CLUSTERED ([PublishErrorID]) WITH (FILLFACTOR=100) ON [PRIMARY]

ALTER TABLE [dbo].[PublishError] ADD CONSTRAINT [UK1_PublishError] UNIQUE NONCLUSTERED ([EventPayloadID], [EventPayloadRecordID], [ProduceEventMessageID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PlayerPromoMarketing_Event](
    [EventPayloadID] [int] NOT NULL,
    [EventPayloadRecordID] [int] NOT NULL,
    [EventPayloadGenerated] [datetime2] NOT NULL,
    [EventPayloadJSONString] [varchar] (2560) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [ProduceEventConfirmed] [datetime2] NULL,
    [ProduceEventMessageID] [uniqueidentifier] NULL
) ON [PartScheme_dbo_PlayerPromoMarketing_DT2] ([EventPayloadGenerated])
WITH(DATA_COMPRESSION = PAGE)

ALTER TABLE [dbo].[PlayerPromoMarketing_Event] ADD CONSTRAINT [PK_dbo_PlayerPromoMarketing_Event] PRIMARY KEY CLUSTERED ([EventPayloadID], [EventPayloadRecordID], [EventPayloadGenerated]) WITH (FILLFACTOR=100, DATA_COMPRESSION = PAGE) ON [PartScheme_dbo_PlayerPromoMarketing_DT2] ([EventPayloadGenerated])

--CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCSI1_dbo_PlayerPromoMarketing_Event] ON [dbo].[PlayerPromoMarketing_Event] ([ProduceEventConfirmed], [ProduceEventMessageID]) ON [PartScheme_dbo_PlayerPromoMarketing_DT2] ([EventPayloadGenerated])

ALTER TABLE [dbo].[PlayerPromoMarketing_Event] SET ( LOCK_ESCALATION = AUTO )
GO

--CREATE TABLE [dbo].[tbl_SalesforceTargetlist](
CREATE TABLE [dbo].[PlayerPromoMarketingTargetlist](
	[EventPayloadID] [INT] NULL,
	[EventPayloadRecordID] [INT] NULL,
	[EventPayloadGenerated] [VARCHAR](50) NULL,
	[Event_Type] [VARCHAR](50) NULL,
	[Source_System] [VARCHAR](50) NULL,
	[CustomerID] [VARCHAR](50) NULL,
	[UserID] [VARCHAR](50) NULL,
	[CasinoID] [VARCHAR](50) NULL,
	[GamingServerId] [VARCHAR](50) NULL,
	[PlayerLifecycle] [VARCHAR](50) NULL,
	[Eligible] [CHAR](1) NULL,
	[PrimaryOffer] [VARCHAR](50) NULL,
	[CouponValue] [VARCHAR](50) NULL,
	[ValidFrom] [VARCHAR](50) NULL,
	[ValidTo] [VARCHAR](50) NULL,
	[BirthdayOffer] [VARCHAR](50) NULL,
	[StartDate] [VARCHAR](50) NULL,
	[EndDate] [VARCHAR](50) NULL,
	[SuggestedBonus] [VARCHAR](50) NULL,
	[BehaviourCat] [VARCHAR](255) NULL,
	[CustomerMajoritySegment] [VARCHAR](255) NULL,
	[CustomerPurchaseLifeTimeSegment] [VARCHAR](255) NULL,
	[SoftLapsedDays] [VARCHAR](50) NULL,
	[SoftLapsedReason] [VARCHAR](255) NULL,
	[GameGroupCat1] [VARCHAR](255) NULL,
	[GameGroupCat2] [VARCHAR](255) NULL,
	[GameGroupCat3] [VARCHAR](255) NULL,
	[ABTestFlag] [CHAR](1) NULL,
	[LastModified] [VARCHAR](50) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tblPublishCDOIdentity](
	[ProcessName] [VARCHAR](100) NULL,
	[ProcessType] [VARCHAR](20) NULL,
	[Database] [VARCHAR](20) NULL,
	[TrackedColumn] [VARCHAR](20) NULL,
	[ExtractType] [VARCHAR](20) NULL,
	[ProcessStart] [DATETIME] NULL,
	[ProcessEnd] [DATETIME] NULL,
	[ProcessDuration] [INT] NULL,
	[MINModifiedDate] [DATETIME] NULL,
	[MAXModifiedDate] [DATETIME] NULL
) ON [PRIMARY]

CREATE CLUSTERED INDEX [IX1] ON [dbo].[tblPublishCDOIdentity]
(
	[ProcessName] ASC,
	[MINModifiedDate] ASC,
	[MAXModifiedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


DECLARE @ProcessName VARCHAR(100) = 'PlayerPromoMarketing'
DECLARE @ProcessType VARCHAR(20) = 'Publish Data'
DECLARE @Database VARCHAR(20)  = 'dbPromotions'
DECLARE @TrackedColumn VARCHAR(20) = 'LastModified'
DECLARE @ExtractType VARCHAR(20) = 'Changed Data Object'
DECLARE @Processstart DATETIME = CAST(GETDATE() AS DATETIME)
DECLARE @ProcessEnd DATETIME = CAST(GETDATE() AS DATETIME)
DECLARE @NewMinModified DATETIME = CAST(CAST(GETDATE() AS DATE)AS DATETIME)
DECLARE @NewMaxModified DATETIME = CAST(CAST(GETDATE() AS DATE)AS DATETIME)


INSERT INTO dbPromotions.dbo.tblPublishCDOIdentity (ProcessName, ProcessType, [Database], TrackedColumn, ExtractType, ProcessStart, ProcessEnd,ProcessDuration, MINModifiedDate, MAXModifiedDate)
SELECT @ProcessName, @ProcessType, @Database, @TrackedColumn, @ExtractType, @ProcessStart, @ProcessEnd,0,@NewMinModified,@NewMaxModified

/* End of File **************************************************************************************************************************************/

SELECT * FROM dbPromotions.dbo.tblPublishCDOIdentity 



