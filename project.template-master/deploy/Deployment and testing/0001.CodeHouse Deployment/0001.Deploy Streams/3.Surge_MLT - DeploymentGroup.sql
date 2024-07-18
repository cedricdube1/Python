/************************************************************************
* Script     : 3.Surge_MLT - DeploymentGroup.sql
* Created By : Hector Prakke
* Created On : 2021-09-02
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates a Surge deployment group from standard deployment components
:            : Only Schema, Procedure and Scripts - Tables and Functions and Views are common for Surge
* Steps      : 1 > Schema
*            : 2 > Player
*            : 3 > PlayerAcquisitionOffer
*            : 4 > RewardType
*            : 5 > PlayerEligibility
*            : 6 > PlayerOffer
*            : 7 > PlayerOfferExperience
*            : 8 > PlayerOfferFreeGame
*            : 9 > PlayerOfferStatusAccept
*            :10 > PlayerOfferStatusReject
*            :11 > Deposit
*            :12 > PlayerOfferConversion
*            :13 > PlayerOfferIncentive
*            :14 > Adjustment
*            :15 > Tournament
*            :16 > TournamentPlayer
*            :17 > TournamentWager
*            :18 > PlayerOfferWager
*            :19 > TournamentInvitedPlayer
*            :20 > PlayerBonusCredit
*            :21 > TriggeringCondition
************************************************************************/

  USE [dbSurge]
  GO
  SET NOCOUNT ON;
  ------------------------------------------------------------------------
  -- SETTING AND DEPLOYMENT GROUP STORAGE
  ------------------------------------------------------------------------
  ------------------
  -- DEPLOYMENT SETTINGS
  ------------------
  -- SET TO 0 IF WANTING TO JUST CHECK WITHOUT CREATING DEPLOYMENT SCRIPTS --
  DECLARE @Generate BIT = 1,
  -- SET TO 0 IF WANTING TO ENSURE A NEW DEPLOYMENT IS GENERATED AS OPPOSED TO USING AN EXISTING DEPLOYMENT --
          @DeployExisting BIT = 0,
  -- DEPLOYMENT GENERATION OPTIONS --
          @ReturnDropScript BIT = 1,
          @ReturnObjectScript BIT = 1,
          @ReturnExtendedPropertiesScript BIT = 1,
          @OnlyLayer VARCHAR(50) = NULL,
          @OnlyStream VARCHAR(50) = NULL,
          @OnlyDeploymentGroupID INT = NULL,
          @OnlyObjectTypes [CodeHouse].[ObjectType];
  DECLARE @ServerAgentJobOwner NVARCHAR(128) = 'CAPETOWN~svc_PDMDataProc'; -- ~ = escape character for \
  -- Only procedures and scripts. Tables/Functions will be common for Surge --
  INSERT INTO @OnlyObjectTypes (ObjectType) VALUES ('Schema'), ('Procedure'), ('Script');
  DECLARE @CountryCode CHAR(2) = 'ZA',
          @StateCode VARCHAR(3) = 'WC',
          @ProviderCallerName NVARCHAR(128) = 'Surge';
  DECLARE @MasterProviderExternalSystemID NVARCHAR(128) = 'Default',
          @ProviderExternalSystemID NVARCHAR(128) = 'MLT';
  DECLARE @ExtractDatabase NVARCHAR(128) = 'dbReportingResource',
          @ExtractSchema NVARCHAR(128) = 'dbo',
          @ExtractTableName NVARCHAR(128),
          @CDOtrackedColumn NVARCHAR(128);
  DECLARE @WaitTime VARCHAR(9); 
  DECLARE @DeploymentName NVARCHAR(128) = @ProviderCallerName + @ProviderExternalSystemID;
  DECLARE @DeploymentNotes NVARCHAR(MAX) = CONCAT('CodeHouse deployment of components for implementation of ', @StateCode, ' for ', @CountryCode, ' for ', @DeploymentName);
  DECLARE @StreamVariant NVARCHAR(128) = @ProviderCallerName,
          @Schema NVARCHAR(128) = @ProviderCallerName + '_' + @ProviderExternalSystemID,
          @FileGroup NVARCHAR(128) = 'PRIMARY';
  DECLARE @Ordinal SMALLINT = 0;
  DECLARE @ScriptLayer VARCHAR(50),
          @ScriptStream VARCHAR(50),
          @HubStream VARCHAR(50);
  DECLARE @ReplacementTagsString NVARCHAR(MAX);
  DECLARE @JobCategory NVARCHAR(128) = 'IGP - IN - Operational';
  
  /* 1 > Schema */
  SET @Ordinal = @Ordinal + 1;  
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{Schema}", "Value": "', @Schema, '"}, {"Tag": "{Authorization}", "Value": "dbo"}]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment_Schema', 'Any', 'Any', 'Any', 'Staging', 'Any', @StreamVariant, @ReplacementTagsString;

  /* 2  > Player */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Player';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblRegistration';
  SET @CDOtrackedColumn = 'RegistrationID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 3  > PlayerAcquisitionOffer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerAcquisitionOffer';
  SET @HubStream = 'Player';
  SET @ExtractTableName = 'SURGE_tblAcquisitionCompletedOffers';
  SET @CDOtrackedColumn = 'ID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 4  > RewardType */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'RewardType';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'PEX_lupRewardType';
  SET @CDOtrackedColumn = 'RewardTypeID';
  SET @WaitTime = '12:00:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream, '"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 5  > PlayerEligibility */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerEligibility'; 
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblEligibility';
  SET @CDOtrackedColumn = 'EligibilityID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream, '"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 6  > PlayerOffer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOffer';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblOfferDetails';
  SET @CDOtrackedColumn = 'OfferDetailsId';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 7  > PlayerOfferExperience */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferExperience';
  SET @HubStream = 'PlayerOffer';
  SET @ExtractTableName = 'SURGE_tblExperienceResult';
  SET @CDOtrackedColumn = 'ExperienceResultID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 8  > PlayerOfferFreeGame */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferFreeGame';
  SET @HubStream = 'PlayerOffer';
  SET @ExtractTableName = 'SURGE_tblFreeGamev3';
  SET @CDOtrackedColumn = 'FreeID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 9  > PlayerOfferStatusAccept */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferStatusAccept';
  SET @HubStream = 'PlayerOffer';
  SET @ExtractTableName = 'SURGE_tblOptInv3';
  SET @CDOtrackedColumn = 'OptInv3ID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;  
  
   /* 10  > PlayerOfferStatusReject */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferStatusReject';
  SET @HubStream = 'PlayerOffer';
  SET @ExtractTableName = 'SURGE_tblOptInCancel';
  SET @CDOtrackedColumn = 'OptInCancelID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;   

  /* 11  > Deposit */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Deposit';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblDeposit';
  SET @CDOtrackedColumn = 'DepositID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 12 > PlayerOfferConversion */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferConversion';
  SET @HubStream = 'PlayerOffer';
  SET @ExtractTableName = 'SURGE_tblConversionv3';
  SET @CDOtrackedColumn = 'ConversionID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 13  > PlayerOfferIncentive */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferIncentive';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblPlayerIncentive';
  SET @CDOtrackedColumn = 'PlayerIncentiveID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 14  > Adjustment */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Adjustment';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'PEX_tblBalanceUpdate';
  SET @CDOtrackedColumn = 'BalanceUpdateID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 15  > Tournament */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Tournament';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblTournamentSetup';
  SET @CDOtrackedColumn = 'TournamentCreateID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;  

  /* 16  > TournamentPlayer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TournamentPlayer';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblTournamentReport_MLT';
  SET @CDOtrackedColumn = 'tblTournamentReportID';
  SET @WaitTime = '01:00:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString; 

  /* 17  > TournamentWager */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TournamentWager';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblTournamentWager';
  SET @CDOtrackedColumn = 'TournamentWagerID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;
 
  /* 18  > PlayerOfferWager */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferWager';
  SET @HubStream = 'PlayerOffer';
  SET @ExtractTableName = 'SURGE_tblTriggeringWager';
  SET @CDOtrackedColumn = 'TriggeringWagerID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 19  > TournamentInvitedPlayer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TournamentInvitedPlayer';
  SET @HubStream = 'TournamentPlayer';
  SET @ExtractTableName = 'SURGE_tblTournamentEligibleUser';
  SET @CDOtrackedColumn = 'TournamentEligibleUserID';
  SET @WaitTime = '01:00:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 20  > PlayerBonusCredit */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerBonusCredit';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblPlayerBonusCredit';
  SET @CDOtrackedColumn = 'PlayerBonusCreditID';
  SET @WaitTime = '00:15:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 21 > TriggeringCondition */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TriggeringCondition';
  SET @HubStream = @ScriptStream;
  SET @ExtractTableName = 'SURGE_tblTriggerConditionsMet';
  SET @CDOtrackedColumn = 'ID';
  SET @WaitTime = '00:30:00';
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{CountryCode}", "Value": "', @CountryCode, '"},
  	                                {"Tag": "{StateCode}", "Value": "', @StateCode, '"},
  									{"Tag": "{ProviderCallerName}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{ProcessnamePart}", "Value": "', @ProviderCallerName, '_', @ProviderExternalSystemID, '"},
  									{"Tag": "{MasterProviderExternalSystemID}", "Value": "', @MasterProviderExternalSystemID, '"},
  									{"Tag": "{ProviderExternalSystemID}", "Value": "', @ProviderExternalSystemID, '"},
  									{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
                                    {"Tag": "{HubStream}", "Value": "', @HubStream , '"},
  									{"Tag": "{ExtractDatabase}", "Value": "', @ExtractDatabase, '"},
  									{"Tag": "{ExtractSchema}", "Value": "', @ExtractSchema, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
  									{"Tag": "{CDOTrackedColumn}", "Value": "',@CDOtrackedColumn, '"},
  									{"Tag": "{ExtractTableName}", "Value": "', @ExtractTableName, '"},
                                    {"Tag": "{ProcessNamePrefix}", "Value": "', @ScriptStream , '"},
  									{"Tag": "{JobProcedure}", "Value": "', 'Process_', @ScriptStream,'"},
  									{"Tag": "{JobNameClass}", "Value": "', 'Process', '"},
									{"Tag": "{JobCategory}", "Value": "', @JobCategory, '"},
  									{"Tag": "{JobCategoryClass}", "Value": "', 'Process', '"},
  									{"Tag": "{JobOwner}", "Value": "', @ServerAgentJobOwner, '"},
  									{"Tag": "{WaitTime}", "Value": "', @WaitTime, '"}
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;
  
  ------------------------------------------------------------------------
  -- CODE GENERATION
  ------------------------------------------------------------------------
  IF @Generate = 1 BEGIN;
    EXEC [CodeHouse].[ExecuteCall_DeploymentGroup] @DeploymentName = @DeploymentName,
                                                   @DeploymentNotes = @DeploymentNotes,
                                                   @DeployExist = @DeployExisting,
                                                   @OnlyLayer = @OnlyLayer,
                                                   @OnlyStream = @OnlyStream,
                                                   @OnlyDeploymentGroupID = @OnlyDeploymentGroupID,
                                                   @ReturnDropScript = @ReturnDropScript,
                                                   @ReturnObjectScript = @ReturnObjectScript,
                                                   @ReturnExtendedPropertiesScript = @ReturnExtendedPropertiesScript,
                                                   @OnlyObjectTypes = @OnlyObjectTypes;
  END;
  ------------------------------------------------------------------------
  -- CHECKS
  ------------------------------------------------------------------------
  SELECT * FROM [CodeHouse].[vDeploymentGroup] WHERE [DeploymentGroupName] = @DeploymentName ORDER BY [Ordinal] ASC;
