/************************************************************************
* Script     : 2.Surge_MIT - DeploymentGroup.sql
* Created By : Cedric Dube
* Created On : 2021-09-02
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates a Surge deployment group from standard deployment components
:            : Only Schema, Functions and Tables and Views - they are common for Surge
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
  -- Only procedures and scripts. Tables/Functions will be common for Surge --
  INSERT INTO @OnlyObjectTypes (ObjectType) VALUES ('Schema'), ('Table'), ('Function') , ('View');
  DECLARE @CountryCode CHAR(2) = 'ZA',
          @StateCode VARCHAR(3) = 'WC',
          @ProviderCallerName NVARCHAR(128) = 'Surge';
  DECLARE @WaitTime VARCHAR(9); 
  DECLARE @DeploymentName NVARCHAR(128) = @ProviderCallerName;
  DECLARE @DeploymentNotes NVARCHAR(MAX) = CONCAT('CodeHouse deployment of components for implementation of ', @StateCode, ' for ', @CountryCode, ' for ', @DeploymentName);
  DECLARE @StreamVariant NVARCHAR(128) = @ProviderCallerName,
          @Schema NVARCHAR(128) = @ProviderCallerName,
          @FileGroup NVARCHAR(128) = 'PRIMARY';
  DECLARE @Ordinal SMALLINT = 0;
  DECLARE @ScriptLayer VARCHAR(50),
          @ScriptStream VARCHAR(50);
  DECLARE @ReplacementTagsString NVARCHAR(MAX);
  
  /* 1 > Schema */
  SET @Ordinal = @Ordinal + 1;  
  SET @ReplacementTagsString = CONCAT('{"ReplacementTags": [{"Tag": "{Schema}", "Value": "', @Schema, '"}, {"Tag": "{Authorization}", "Value": "dbo"}]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment_Schema', 'Any', 'Any', 'Any', 'Staging', 'Any', @StreamVariant, @ReplacementTagsString;

  /* 2  > Player */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Player';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 3  > PlayerAcquisitionOffer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerAcquisitionOffer';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 4  > RewardType */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'RewardType';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 5  > PlayerEligibility */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerEligibility'; 
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 6  > PlayerOffer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOffer';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 7  > PlayerOfferExperience */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferExperience';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;
 
  /* 8  > PlayerOfferFreeGame */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferFreeGame';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 9  > PlayerOfferStatusAccept */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferStatusAccept';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;
  
   /* 10  > PlayerOfferStatusReject */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferStatusReject';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;   

  /* 11  > Deposit */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Deposit';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 12 > PlayerOfferConversion */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferConversion';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 13  > PlayerOfferIncentive */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferIncentive';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 14  > Adjustment */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Adjustment';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 15  > Tournament */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'Tournament';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 16  > TournamentPlayer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TournamentPlayer';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

  /* 17  > TournamentWager */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TournamentWager';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

    /* 18  > PlayerOfferWager */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerOfferWager';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;
 
    /* 19  > TournamentInvitedPlayer */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TournamentInvitedPlayer';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

      /* 20 > PlayerBonusCredit */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'PlayerBonusCredit';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
                ]}');
  EXEC [CodeHouse].[SetDeploymentGroup] @Ordinal, @DeploymentName, NULL, 'GetDeployment', @ScriptLayer, @ScriptStream, @StreamVariant, @ScriptLayer, @ScriptStream, @StreamVariant, @ReplacementTagsString;

        /* 21 > TriggeringCondition */
  SET @Ordinal = @Ordinal + 1;
  SET @ScriptLayer = 'Staging';
  SET @ScriptStream = 'TriggeringCondition';
  SET @ReplacementTagsString = CONCAT('{"Tag": "{Schema}", "Value": "', @Schema, '"},
  									{"Tag": "{FileGroup}", "Value": "', @FileGroup, '"},
  									{"Tag": "{HeldSchema}", "Value": "', @ProviderCallerName, '"},
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

  