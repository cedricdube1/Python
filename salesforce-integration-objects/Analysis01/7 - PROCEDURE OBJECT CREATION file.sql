--STEP 7 FILE
/*****************************************************************************************************************************************************
* Script     : 7 - PROCEDURE OBJECT CREATION file.sql                                                         *--
* Created By : Cedric Dube                                                                                                                          *--
* Created On : 2024-05-24                                                                                                                           *--
* Updated By : Cedric Dube                                                                                                                          *--
* Updated On : 2024-05-24                                                                                                                             *--
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


/* 7 Procedures *************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_PlayerPromoMarketing] 
AS
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--Created By: Cedric Dube                                                           
--Date: 28 June 2023                                                                
--Description of SP: Used to Update Offer Eligibility for SalesFrorce/Adobe                                                                                                                                                                                                       
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--BIS Change Control
--Ver     Date             Description														Changed by        
------------------------------------------------------------------------------------------------------------
--1.0	  28/06/2023	   Initial Development												Cedric Dube
--2.0	  07/05/2024	   Align columns as requested in below link 
--						   https://digioutsource.atlassian.net/wiki/spaces/ENP/pages/123021262867/EPC+Player+Account+Marketing+Attributes+Adobe		
--                                                                                          Cedric Dube
------------------------------------------------------------------------------------------------------------
BEGIN

	SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Procedure NVARCHAR(50)         = 'usp_PlayerPromoMarketing'
    DECLARE @BatchTime DATETIME             = GETDATE()


	IF (SELECT COUNT(1)
    FROM [dbPromotions].[dbo].[ProcessRuntimeLog] WITH(NOLOCK) 
    WHERE  CAST(CONVERT(VARCHAR(8), GETDATE(),112)AS INT) =  CAST(CONVERT(VARCHAR(8), DatetimeStamp,112)AS INT) 
    AND [Procedure] = 'usp_PlayerPromoMarketing' 
    AND Step = 'End' ) =  1
    RETURN
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'START', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    BEGIN TRY;	   

    -- Pull all Live offers for Tomorrow (subject to change)
    IF OBJECT_ID('tempdb..#ActiveOffers') IS NOT NULL DROP TABLE #ActiveOffers
    SELECT	b.PlayerKey,a.*, RANK() OVER(PARTITION BY a.GamingServerId, a.UserID ORDER BY AuditDate DESC) r
    INTO	#ActiveOffers
    FROM	CPTAOLSTN02.dbPromotions.dbo.tblPlayerOfferDetails a WITH (NOLOCK)
	JOIN	dbDWAlignment.dbo.dimPlayer b WITH (NOLOCK) ON a.UserID = b.Hist_PTSUserID and a.GamingServerID = b.Hist_PTSGamingserverID
	WHERE GETDATE()+1 BETWEEN ValidFrom AND ValidTo
	AND	OfferType IN ('Lapsed','Daily','Deal-a-Day')
    
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 1', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE CLUSTERED INDEX IX1 ON #ActiveOffers (PlayerKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 1 Index', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    --when player has more than one offer retrive latest offer
    DELETE FROM #ActiveOffers WHERE r >1  
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 2', @BatchTime, GETDATE(), @@ROWCOUNT 
    
	-- Pull all Live birthday offers for Tomorrow (subject to change)
    IF OBJECT_ID('tempdb..#PlayerRewards') IS NOT NULL DROP TABLE #PlayerRewards
    SELECT	DISTINCT b.playerKey, a.Amount, a.RewardType, a.PromoType, a.RewardStartDateTime, a.RewardEndDateTime, RANK() OVER(PARTITION BY b.playerKey ORDER BY a.RewardStartDateTime DESC) r
    INTO	#PlayerRewards
    FROM	CPTAOLSTN02.dbPromotions.dbo.tblPlayerOfferReward a With (NOLOCK) 
	JOIN	dbDWAlignment.dbo.dimPlayer b WITH (NOLOCK) ON a.UserID = b.Hist_PTSUserID and a.GamingServerID = b.Hist_PTSGamingserverID
    WHERE GETDATE()+1 BETWEEN a.RewardStartDateTime AND a.RewardEndDateTime
	AND a.PromoType = 'Birthday'

    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 3', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE NONCLUSTERED INDEX IX3 ON #PlayerRewards (Playerkey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 3 Index', @BatchTime, GETDATE(), @@ROWCOUNT 

	--when player has more than one offer retrive latest offer
	DELETE FROM #PlayerRewards WHERE r >1  

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 4', @BatchTime, GETDATE(), @@ROWCOUNT 

	--HACK to remove secondary birthday offer
	;WITH CTE AS (
	SELECT a.playerKey, a.Amount, a.RewardType, a.PromoType, a.RewardStartDateTime, a.RewardEndDateTime,RANK() OVER(PARTITION BY a.playerKey ORDER BY a.Amount DESC) r2
	FROM #PlayerRewards a)
	DELETE FROM cte WHERE r2 >1
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 5', @BatchTime, GETDATE(), @@ROWCOUNT 
	
	--use the same CDC playeer used to generate offers
	DELETE a --select * 
	FROM [dbDWAlignment].[dbo].[CDC_CustomerId_PromoSnapshot] a WITH (NOLOCK)
	WHERE DateKey < CONVERT(VARCHAR(8), GETDATE()-2, 112) 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 6', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Get CDC list
    IF OBJECT_ID('tempdb..#CDC_Players') IS NOT NULL   DROP TABLE #CDC_Players;
    SELECT DISTINCT a.CustomerId , b.playerKey 
    INTO #CDC_Players
    --FROM dbDWAlignment.dbo.CDC_CustomerId a WITH (NOLOCK)
	FROM [dbDWAlignment].[dbo].[CDC_CustomerId_PromoSnapshot] a WITH (NOLOCK)
    JOIN dbDWAlignment.dbo.dimplayer B WITH (NOLOCK) ON a.CustomerID = B.CustomerId AND a.Datekey = CONVERT(VARCHAR(8), GETDATE()-1, 112) --USE CDC list used to geberate promos
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 7', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE UNIQUE NONCLUSTERED INDEX IX1 ON #CDC_Players (playerKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 7 index', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Create a CasinoDetail lookup + Rulekey based of the PromoConfiguration table
    IF OBJECT_ID('tempdb..#CasinoDetail') IS NOT NULL DROP TABLE #CasinoDetail
    SELECT	dcd.Hist_PTSCasinoID CasinoID, casinoDetailKey, dcd.OperatorName, dcd.Licensee, dcd.LicensedCountry , rk.BehaviourRuleKey,  dcd.BOSP
    INTO	#CasinoDetail  
    FROM	dbDWAlignment.dbo.vw_dimCasinoDetail_Lic dcd WITH (NOLOCK) 
    LEFT JOIN dbPromotions..PromoConfiguration  RK ON Rk.Operator = dcd.OperatorName AND RK.Licensee = dcd.Licensee AND RK.LicensedCountry = dcd.LicensedCountry 
    AND		rk.OfferType IN ('Daily','Deal-a-day')  -- 1 row per casino combination. Ruleky is same for lapsed and daily
    WHERE	dcd.BOSP = 'FS' 
    AND		dcd.IsActive = 'Y' 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 8', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Update RuleKey for Baytree since its not on the promoConfig table
    UPDATE  dcd
    SET dcd.BehaviourRuleKey = RK.BehaviourRuleKey --	SELECT dcd.OperatorName, rk.Operator,dcd.Licensee, rk.Licensee, dcd.LicensedCountry,rk.LicensedCountry, rk.BehaviourRuleKey
    FROM #CasinoDetail dcd
    JOIN dbPromotions..PromoConfiguration  RK ON Rk.Operator = dcd.OperatorName  
	AND RK.LicensedCountry =  'ALD' AND dcd.LicensedCountry = '.Com'
    AND rk.OfferType IN ('Daily','Deal-a-day')  
   
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 9', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Delete inactive casinos after the Baytree update
    DELETE a 
    FROM #CasinoDetail A WHERE a.BehaviourRuleKey IS  NULL

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 10', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE CLUSTERED INDEX IX1 ON #CasinoDetail (casinoDetailKey)
    CREATE  INDEX IX2 ON #CasinoDetail (BehaviourRuleKey) 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 10 Index', @BatchTime, GETDATE(), @@ROWCOUNT          

	--Pull all cdc players to determine PlayerLifeCycle
    IF OBJECT_ID('tempdb..#Target') IS NOT NULL DROP TABLE #Target
    SELECT	DISTINCT DP.CustomerId,dcd.BehaviourRuleKey RuleKey
    INTO	#Target
    FROM	dbDWAlignment.dbo.dimPlayer DP WITH (NOLOCK)    
    JOIN	#CDC_Players A ON DP.playerKey = a.playerkey
	JOIN	#CasinoDetail dcd WITH (NOLOCK) ON dcd.casinoDetailKey = DP.PlayerCasinoDetailKey 
 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 11', @BatchTime, GETDATE(), @@ROWCOUNT   

	CREATE CLUSTERED INDEX IX1 ON #Target (CustomerID,RuleKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 11 Index', @BatchTime, GETDATE(), @@ROWCOUNT   

	IF OBJECT_ID('tempdb..#borg') IS NOT NULL DROP TABLE #borg
	SELECT t.CustomerId, t.rulekey, b.ActivityStatus, b.PercentageScoreCasino , B.CouponScoreCasino, B.FirstPurchasedDate,
	       ISNULL(B.BehaviourCat,'BaseExpectationLowTipping') BehaviourCat,
           ISNULL(B.GameGroupCat1,'Unknown') GameGroupCat1,
           ISNULL(B.GameGroupCat2,'Unknown') GameGroupCat2,
           ISNULL(B.GameGroupCat3,'Unknown') GameGroupCat3,
		   ISNULL(B.SoftLapsedDays,0) SoftLapsedDays,
           ISNULL(REPLACE(B.SoftLapsedReason,'N/A','Unknown'),'Unknown') SoftLapsedReason
           --ISNULL(((b.PercentageScoreCasino * b.CouponScoreCasino)/1000),0) SuggestedBonus
    INTO #borg
	FROM #Target t
	JOIN   dbDWAlignment.dbo.tblCustomerBorg b WITH (NOLOCK) ON b.CustomerID = t.CustomerId AND b.RuleKey = t.RuleKey

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 10', @BatchTime, GETDATE(), @@ROWCOUNT 

	UPDATE a
    SET a.SoftLapsedReason = 'Unknown'
    FROM #borg a 
    WHERE SoftLapsedReason = '' 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 11', @BatchTime, GETDATE(), @@ROWCOUNT 

	CREATE CLUSTERED INDEX IX1 ON #borg (CustomerID,RuleKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 11 Index', @BatchTime, GETDATE(), @@ROWCOUNT 

	--Pull intervention Types
	IF OBJECT_ID('tempdb..#PlayerLifeCycle') IS NOT NULL DROP TABLE #PlayerLifeCycle
    SELECT	DISTINCT t.CUSTOMERID, t.RuleKey, ISNULL(a.Softlapsed,0) Softlapsed, ISNULL(a.ProjectingDown,0) ProjectingDown,  CAST(NULL AS VARCHAR(255)) PlayerLifeCycle
    INTO	#PlayerLifeCycle
    FROM	#Target  t
    LEFT JOIN 	dbDWAlignment.dbo.tblCustomerScoringCasino A WITH(NOLOCK) ON T.CustomerID = A.CustomerID AND T.RuleKey = A.RuleKey

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 12', @BatchTime, GETDATE(), @@ROWCOUNT  

	CREATE CLUSTERED INDEX ix1 ON #PlayerLifeCycle(CustomerId, RuleKey)	

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 12 index', @BatchTime, GETDATE(), @@ROWCOUNT  

	--Update PlayerLifeCycle with intervention Types
	UPDATE a
	SET PlayerLifeCycle = CASE	WHEN a.ProjectingDown = 1 
							THEN 'ProjectingDown' 
							WHEN a.Softlapsed = 1 
							THEN 'Softlapsed'
							ELSE NULL
						END 

	FROM #PlayerLifeCycle a 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 13', @BatchTime, GETDATE(), @@ROWCOUNT  


	--Update PlayerLifeCycle with ActivityStatus if they dont have intervention Types
	UPDATE a
	SET PlayerLifeCycle = b.ActivityStatus
	--SELECT a.* , b.ActivityStatus
	FROM #PlayerLifeCycle a
	JOIN   #borg b WITH (NOLOCK) ON b.CustomerID = a.CustomerId AND b.RuleKey = a.RuleKey
	WHERE    a.PlayerLifeCycle IS NULL

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 14', @BatchTime, GETDATE(), @@ROWCOUNT 

	--Update ONA Players
	UPDATE a
	SET a.PlayerLifeCycle = 'ONA'
	--SELECT a.* , b.ActivityStatus, B.PercentageScoreCasino, B.CouponScoreCasino,B.FirstPurchasedDate
	FROM #PlayerLifeCycle a
	JOIN   #borg B WITH (NOLOCK) ON B.CustomerID = a.CustomerId AND B.RuleKey = a.RuleKey
	WHERE (b.PercentageScoreCasino IS NULL OR  B.CouponScoreCasino IS NULL )
	OR  B.FirstPurchasedDate IS NULL 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 15', @BatchTime, GETDATE(), @@ROWCOUNT 

	--------------------------------------------------------------------------
    -- ### ALIGN OFFERTYPES 
    --------------------------------------------------------------------------
    UPDATE #ActiveOffers  
	SET OfferType = 'Daily'
	WHERE OfferType IN ( 'Deal-a-Day')     
    
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 16', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    
    IF OBJECT_ID('tempdb..#PlayerPromoMarketing') IS NOT NULL DROP TABLE #PlayerPromoMarketing
    CREATE TABLE #PlayerPromoMarketing
	(
	[CustomerID] [INT] NOT NULL,
	[RuleKey] [INT] NOT NULL ,			--will keep but wont tranfer over to CDP
	[PlayerKey] [INT] NOT NULL,			--will keep but wont tranfer over to CDp
	[UserID] [INT] NOT NULL,
	[CasinoId] [INT] NOT NULL,
	[GamingServerId] [INT] NOT NULL,
	[PlayerLifecycle] [VARCHAR](255),	
	[SuggestedBonus] [FLOAT] NULL,	
	[BehaviourCat] [VARCHAR](255) NULL DEFAULT 'BaseExpectationLowTipping',
	[CustomerMajoritySegment] [VARCHAR](255) NULL,
	[CustomerPurchaseLifeTimeSegment] [VARCHAR](255) NOT NULL DEFAULT 'None',	
	[SoftLapsedDays] [INT] NULL,
	[SoftLapsedReason] [VARCHAR](255) NULL,
	[GameGroupCat1] [VARCHAR](255) NULL,
	[GameGroupCat2] [VARCHAR](255) NULL,
	[GameGroupCat3] [VARCHAR](255) NULL,
	[ABTestFlag] [CHAR](1) NULL,
	[lastModified] [DATETIME] NOT NULL,
    )    
    
	--------------------------------------------------------------------------
    -- ### Get player details for CDC Players
    --------------------------------------------------------------------------
	--DECLARE @BatchTime DATETIME             = GETDATE()	 
	INSERT INTO #PlayerPromoMarketing (CustomerId, RuleKey, playerKey, UserID, CasinoID, GamingServerId, ABTestFlag, lastModified)
    SELECT	DP.CustomerId, DCD.BehaviourRuleKey, DP.playerKey, dp.Hist_PTSUserID UserID, dcd.CasinoID, dp.Hist_PTSGamingserverID GamingServerId, 
			CASE WHEN (dp.CustomerId  % 2) = 0 THEN 'A' ELSE 'B' END AS ABTestFlag, 
			@BatchTime LastModified 
    FROM #CDC_Players cdc
    JOIN dbDWAlignment.dbo.dimPlayer DP WITH (NOLOCK) ON DP.playerKey = cdc.PlayerKey
    JOIN #CasinoDetail dcd WITH (NOLOCK) ON dcd.casinoDetailKey = DP.PlayerCasinoDetailKey 
	WHERE dp.Hist_PTSGamingserverID > 0	
	--AND DP.CustomerId > 0		
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 17', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE CLUSTERED INDEX IX1 ON #PlayerPromoMarketing (CustomerID, RuleKey)
	CREATE NONCLUSTERED INDEX IXPl ON #PlayerPromoMarketing (PlayerKey)
	CREATE NONCLUSTERED INDEX IX2 ON #PlayerPromoMarketing (GamingServerId, UserID)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 17 Index', @BatchTime, GETDATE(), @@ROWCOUNT 


	--Remove players not on the borg
	DELETE a 
	FROM #PlayerPromoMarketing a WITH (NOLOCK)
	LEFT JOIN [dbDWAlignment].[dbo].[tblCustomerBorg]  b WITH (NOLOCK) ON b.CustomerID = a.CustomerId AND b.RuleKey = a.RuleKey
	WHERE b.CustomerID is NULL
    
	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 18', @BatchTime, GETDATE(), @@ROWCOUNT 

	--UPDATE CDC Player lifecycle
    UPDATE A
    SET	 A.PlayerLifecycle = b.PlayerLifecycle
    FROM #PlayerPromoMarketing A WITH (NOLOCK)
	JOIN #PlayerLifeCycle b ON B.customerid = A.customerID  AND b.RuleKey = a.RuleKey

    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 19', @BatchTime, GETDATE(), @@ROWCOUNT     

	--Update segments
    UPDATE A
    SET    A.CustomerPurchaseLifeTimeSegment = b.CustomerPurchaseLifeTimeSegment,
	       A.CustomerMajoritySegment = b.CustomerMajoritySegment
    FROM   #PlayerPromoMarketing A WITH (NOLOCK)
    JOIN dbDWAlignment..dimSegments b WITH (NOLOCK) ON b.PlayerKey = a.PlayerKey   
    
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 20', @BatchTime, GETDATE(), @@ROWCOUNT 
    
	--update  borg metrics
    UPDATE A
    SET    A.BehaviourCat		= B.BehaviourCat,
           A.GameGroupCat1		= B.GameGroupCat1,
           A.GameGroupCat2		= B.GameGroupCat2,
           A.GameGroupCat3		= B.GameGroupCat3,
		   A.SoftLapsedDays		= B.SoftLapsedDays,
           A.SoftLapsedReason	= B.SoftLapsedReason,
           A.SuggestedBonus		= ISNULL(((b.PercentageScoreCasino * b.CouponScoreCasino)/1000),0)
    FROM   #PlayerPromoMarketing A WITH (NOLOCK) 
    JOIN   #borg b WITH (NOLOCK) ON B.customerid = A.customerID  AND b.RuleKey = a.RuleKey
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 21', @BatchTime, GETDATE(), @@ROWCOUNT 
    

	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    BEGIN TRANSACTION;	
	   
    -- MERGE : Source / Target --
    ;WITH CTE AS (
      SELECT CustomerID
			,RuleKey  
			,PlayerKey
			,UserID
			,CasinoID
			,GamingServerId
			,PlayerLifecycle
			,SuggestedBonus	
            ,BehaviourCat
            ,CustomerMajoritySegment
            ,CustomerPurchaseLifeTimeSegment	
            ,SoftLapsedDays
            ,SoftLapsedReason
            ,GameGroupCat1
            ,GameGroupCat2
            ,GameGroupCat3
			,ABTestFlag
			,lastModified
      FROM #PlayerPromoMarketing
    ) MERGE dbPromotions.dbo.PlayerPromoMarketing AS Tgt
      USING CTE AS Src
		ON  Tgt.UserID = Src.UserID
	   AND  Tgt.GamingServerId = Src.GamingServerID
      -- UPDATE : Matched / Differs 
      WHEN MATCHED AND EXISTS (
        SELECT 
                Tgt.CustomerID
			   ,Tgt.RuleKey  
			   ,Tgt.PlayerKey
			   ,Tgt.UserID
			   ,Tgt.CasinoID
			   ,Tgt.GamingServerId
			   ,Tgt.PlayerLifecycle
			   ,Tgt.SuggestedBonus	
               ,Tgt.BehaviourCat
               ,Tgt.CustomerMajoritySegment
               ,Tgt.CustomerPurchaseLifeTimeSegment	
               ,Tgt.SoftLapsedDays
               ,Tgt.SoftLapsedReason
               ,Tgt.GameGroupCat1
               ,Tgt.GameGroupCat2
               ,Tgt.GameGroupCat3
			   ,Tgt.ABTestFlag
        EXCEPT
        SELECT 
                Src.CustomerID
			   ,Src.RuleKey  
			   ,Src.PlayerKey
			   ,Src.UserID
			   ,Src.CasinoID
			   ,Src.GamingServerId
			   ,Src.PlayerLifecycle
			   ,Src.SuggestedBonus	
               ,Src.BehaviourCat
               ,Src.CustomerMajoritySegment
               ,Src.CustomerPurchaseLifeTimeSegment	
               ,Src.SoftLapsedDays
               ,Src.SoftLapsedReason
               ,Src.GameGroupCat1
               ,Src.GameGroupCat2
               ,Src.GameGroupCat3
			   ,Src.ABTestFlag
      )  THEN
	    --if player exist and other columns dont match update
        UPDATE SET
          Tgt.CustomerID						= Src.CustomerID,
		  Tgt.RuleKey							= Src.RuleKey,  
		  Tgt.PlayerKey							= Src.PlayerKey,
		  Tgt.UserID							= Src.UserID,
		  Tgt.CasinoID							= Src.CasinoID,
		  Tgt.GamingServerId					= Src.GamingServerId,
		  Tgt.PlayerLifecycle					= Src.PlayerLifecycle,
		  Tgt.SuggestedBonus					= Src.SuggestedBonus,	
          Tgt.BehaviourCat						= Src.BehaviourCat,
          Tgt.CustomerMajoritySegment			= Src.CustomerMajoritySegment,
          Tgt.CustomerPurchaseLifeTimeSegment	= Src.CustomerPurchaseLifeTimeSegment,	
          Tgt.SoftLapsedDays					= Src.SoftLapsedDays,
          Tgt.SoftLapsedReason					= Src.SoftLapsedReason,
          Tgt.GameGroupCat1						= Src.GameGroupCat1,
          Tgt.GameGroupCat2						= Src.GameGroupCat2,
          Tgt.GameGroupCat3						= Src.GameGroupCat3,
		  Tgt.ABTestFlag						= Src.ABTestFlag,
		  Tgt.LastModified						= Src.LastModified
      -- INSERT : NOT Matched --
      WHEN NOT MATCHED BY TARGET THEN
	    --if player does not exist insert
        INSERT (
          CustomerID,
		  RuleKey,  
		  PlayerKey,
		  UserID,
		  CasinoID,
		  GamingServerId,
		  PlayerLifecycle,
		  Eligible,
		  PrimaryOffer,
		  CouponValue,
		  BirthdayOffer,
		  SuggestedBonus,	
          BehaviourCat,
          CustomerMajoritySegment,
          CustomerPurchaseLifeTimeSegment,	
          SoftLapsedDays,
          SoftLapsedReason,
          GameGroupCat1,
          GameGroupCat2,
          GameGroupCat3,
		  ABTestFlag,
		  LastModified
      ) VALUES (
          CustomerID,
		  RuleKey,  
		  PlayerKey,
		  UserID,
		  CasinoID,
		  GamingServerId,
		  PlayerLifecycle,
		  'N',
		  0,
		  0,
		  0,
		  SuggestedBonus,	
          BehaviourCat,
          CustomerMajoritySegment,
          CustomerPurchaseLifeTimeSegment,	
          SoftLapsedDays,
          SoftLapsedReason,
          GameGroupCat1,
          GameGroupCat2,
          GameGroupCat3,
		  ABTestFlag,
		  LastModified
        );


    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 22', @BatchTime, GETDATE(), @@ROWCOUNT 

	--------------------------------------------------------------------------
    -- ### RESET ELIGIBILITY 
    --------------------------------------------------------------------------	
    UPDATE A
    SET a.Eligible = 'N',
    a.PrimaryOffer = 0,
    a.CouponValue = 0,
    a.ValidFrom = NULL,
    A.ValidTo = NULL,
	A.OfferType = NULL
    --SELECT *
    FROM dbPromotions.dbo.PlayerPromoMarketing A WITH (NOLOCK) 
    WHERE a.OfferType IN ('Daily', 'Lapsed') 
	AND  GETDATE()+1 NOT BETWEEN ValidFrom AND ValidTo
	AND a.Eligible = 'Y'
    
	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 23', @BatchTime, GETDATE(), @@ROWCOUNT 
    
	--Update with recent bithday offers
    ;WITH CTE AS (
      SELECT PlayerKey
	        ,'Y' Eligible
			,Match PrimaryOffer
			,Coupon CouponValue
			,OfferType
			,ValidFrom
			,ValidTo			
      FROM #ActiveOffers 
    ) MERGE dbPromotions.dbo.PlayerPromoMarketing AS Tgt
      USING CTE AS Src
		ON  Tgt.PlayerKey = Src.PlayerKey
      -- UPDATE : Matched / Differs 
      WHEN MATCHED AND EXISTS (
        SELECT 
                Tgt.Eligible
			   ,Tgt.PrimaryOffer
			   ,Tgt.CouponValue
			   ,Tgt.OfferType
			   ,Tgt.ValidFrom  
			   ,Tgt.ValidTo			   
        EXCEPT
        SELECT Src.Eligible
			  ,Src.PrimaryOffer
			  ,Src.CouponValue
			  ,Src.OfferType
			  ,Src.ValidFrom  
			  ,Src.ValidTo			  
      )  THEN
        UPDATE SET
          Tgt.Eligible   						= Src.Eligible,
		  Tgt.PrimaryOffer						= Src.PrimaryOffer,
		  Tgt.CouponValue						= Src.CouponValue,
		  Tgt.OfferType  						= Src.OfferType,
		  Tgt.ValidFrom							= Src.ValidFrom,  
		  Tgt.ValidTo							= Src.ValidTo,
		  Tgt.lastModified                      = @BatchTime;	
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 24', @BatchTime, GETDATE(), @@ROWCOUNT 

    --Remove birthday offers nolonger valid
    UPDATE A
    SET A.BirthdayOffer = 0, 
    a.StartDate = NULL ,
    A.EndDate = NULL  --SELECT TOP 10 *
    FROM dbPromotions.dbo.PlayerPromoMarketing A WITH (NOLOCK)
    WHERE GETDATE()+1 NOT BETWEEN a.StartDate AND a.EndDate

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 25', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    --Update with recent bithday offers
    ;WITH CTE AS (
      SELECT PlayerKey
			,Amount BirthdayOffer
			,RewardStartDateTime StartDate
			,RewardEndDateTime EndDate
      FROM #PlayerRewards 
    ) MERGE dbPromotions.dbo.PlayerPromoMarketing AS Tgt
      USING CTE AS Src
		ON  Tgt.PlayerKey = Src.PlayerKey
      -- UPDATE : Matched / Differs 
      WHEN MATCHED AND EXISTS (
        SELECT 
                Tgt.BirthdayOffer
			   ,Tgt.StartDate  
			   ,Tgt.EndDate
        EXCEPT
        SELECT 
                Src.BirthdayOffer
			   ,Src.StartDate  
			   ,Src.EndDate
      )  THEN
        UPDATE SET
          Tgt.BirthdayOffer						= Src.BirthdayOffer,
		  Tgt.StartDate							= Src.StartDate,  
		  Tgt.EndDate							= Src.EndDate,
		  Tgt.lastModified                      = @BatchTime;	
	
	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 26', @BatchTime, GETDATE(), @@ROWCOUNT 

	COMMIT TRANSACTION;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;		 

	END TRY
	BEGIN CATCH

		/*
		  -- XACT_STATE:
		   1 = Active transactions, CAN be committed or rolled back. Because of error, we rollback
		   0 = NO Active transactions, CANNOT be committed or rolled back.
		  -1 = Active transactions, CANNOT be committed but CAN be rolled back. Because of error, we rollback
		*/
		IF XACT_STATE() <> 0
		  ROLLBACK;
		  DECLARE @ProcessName NVARCHAR(150)	= 'PlayerPromoMarketing Segmentation',
		          @ErrProc NVARCHAR(128)		= ERROR_PROCEDURE(),
				  @ErrMsg  NVARCHAR(4000)		= ERROR_MESSAGE(),
				  @ErrNum  INT					= ERROR_NUMBER(),
				  @ErrLn   INT					= ERROR_LINE();

		INSERT INTO [dbPromotions].[dbo].[ProcessError]([ProcessName],[ErrorProcedure],[ErrorNumber],[ErrorLine],[ErrorMessage])
		SELECT @ProcessName,@ErrProc, @ErrNum, @ErrLn,@ErrMsg 

		THROW;
		INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Failure', @BatchTime, GETDATE(), @@ROWCOUNT 

	END CATCH;
    
	WAITFOR DELAY '00:00:01'
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'END', @BatchTime, GETDATE(), @@ROWCOUNT 



END
GO

CREATE PROCEDURE [dbo].[usp_PlayerPromoMarketing_2ndDay] 
AS
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--Created By: Cedric Dube                                                           
--Date: 28 June 2023                                                                
--Description of SP: Used to Update Offer Eligibility for SalesFrorce/Adobe                                                                                                                                                                                                       
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--BIS Change Control
--Ver     Date             Description														Changed by        
------------------------------------------------------------------------------------------------------------
--1.0	  28/06/2023	   Initial Development												Cedric Dube
--2.0	  07/05/2024	   Align columns as requested in below link 
--						   https://digioutsource.atlassian.net/wiki/spaces/ENP/pages/123021262867/EPC+Player+Account+Marketing+Attributes+Adobe		
--                                                                                          Cedric Dube
------------------------------------------------------------------------------------------------------------
BEGIN
    
	SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Procedure NVARCHAR(50)         = 'usp_PlayerPromoMarketing_2ndDay'
    DECLARE @BatchTime DATETIME             = GETDATE()


	IF (SELECT COUNT(1)
    FROM [dbPromotions].[dbo].[ProcessRuntimeLog] WITH(NOLOCK) 
    WHERE  CAST(CONVERT(VARCHAR(8), GETDATE(),112)AS INT) =  CAST(CONVERT(VARCHAR(8), DatetimeStamp,112)AS INT) 
    AND [Procedure] = 'usp_PlayerPromoMarketing_2ndDay' 
    AND Step = 'End' ) =  1
    RETURN
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'START', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    BEGIN TRY;	   

    -- Pull all Live offers for Tomorrow (subject to change)
    IF OBJECT_ID('tempdb..#ActiveOffers') IS NOT NULL DROP TABLE #ActiveOffers
    SELECT	b.PlayerKey,a.*, RANK() OVER(PARTITION BY a.GamingServerId, a.UserID ORDER BY AuditDate DESC) r
    INTO	#ActiveOffers
    FROM	CPTAOLSTN02.dbPromotions.dbo.tblPlayerOfferDetails a WITH (NOLOCK) 
	JOIN	dbDWAlignment.dbo.dimPlayer b WITH (NOLOCK) ON a.UserID = b.Hist_PTSUserID AND a.GamingServerID = b.Hist_PTSGamingserverID
	WHERE   CONVERT(VARCHAR(8), GETDATE(), 112) = CONVERT(VARCHAR(8), ValidFrom, 112)
	AND	    OfferType IN ('2ndDay')
    
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 1', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE CLUSTERED INDEX IX1 ON #ActiveOffers (PlayerKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 1 Index', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    --when player has more than one offer retrive latest offer
    DELETE FROM #ActiveOffers WHERE r >1  
		   
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 2', @BatchTime, GETDATE(), @@ROWCOUNT 
    
	--use the same CDC playeer used to generate offers
	--DELETE a --select * 
	--FROM [dbDWAlignment].[dbo].[CDC_CustomerId_PromoSnapshot] a WITH (NOLOCK)
	--WHERE DateKey < CONVERT(VARCHAR(8), GETDATE()-2, 112) 

	--INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 3', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Get CDC list only do 2ndDAY players
    IF OBJECT_ID('tempdb..#CDC_Players') IS NOT NULL   DROP TABLE #CDC_Players;
    SELECT DISTINCT a.CustomerId , b.playerKey 
    INTO #CDC_Players
    --FROM dbDWAlignment.dbo.CDC_CustomerId a WITH (NOLOCK)
	--FROM [dbDWAlignment].[dbo].[CDC_CustomerId_PromoSnapshot] a WITH (NOLOCK)
 --   JOIN dbDWAlignment.dbo.dimplayer B WITH (NOLOCK) ON a.CustomerID = B.CustomerId AND a.Datekey = CONVERT(VARCHAR(8), GETDATE()-1, 112) --USE CDC list used to geberate promos
    FROM dbDWAlignment.dbo.dimplayer a WITH (NOLOCK)
	JOIN #ActiveOffers b ON a.playerKey = b.playerKey
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 3', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE UNIQUE NONCLUSTERED INDEX IX1 ON #CDC_Players (playerKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 3 index', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Create a CasinoDetail lookup + Rulekey based of the PromoConfiguration table
    IF OBJECT_ID('tempdb..#CasinoDetail') IS NOT NULL DROP TABLE #CasinoDetail
    SELECT	dcd.Hist_PTSCasinoID CasinoID, casinoDetailKey, dcd.OperatorName, dcd.Licensee, dcd.LicensedCountry , rk.BehaviourRuleKey,  dcd.BOSP
    INTO	#CasinoDetail  
    FROM	dbDWAlignment.dbo.vw_dimCasinoDetail_Lic dcd WITH (NOLOCK) 
    LEFT JOIN dbPromotions..PromoConfiguration  RK ON Rk.Operator = dcd.OperatorName AND RK.Licensee = dcd.Licensee AND RK.LicensedCountry = dcd.LicensedCountry 
    AND		rk.OfferType IN ('Daily','Deal-a-day')  -- 1 row per casino combination. Ruleky is same for lapsed and daily
    WHERE	dcd.BOSP = 'FS' 
    AND		dcd.IsActive = 'Y' 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 4', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Update RuleKey for Baytree since its not on the promoConfig table
    UPDATE  dcd
    SET dcd.BehaviourRuleKey = RK.BehaviourRuleKey --	SELECT dcd.OperatorName, rk.Operator,dcd.Licensee, rk.Licensee, dcd.LicensedCountry,rk.LicensedCountry, rk.BehaviourRuleKey
    FROM #CasinoDetail dcd
    JOIN dbPromotions..PromoConfiguration  RK ON Rk.Operator = dcd.OperatorName  
	AND RK.LicensedCountry =  'ALD' AND dcd.LicensedCountry = '.Com'
    AND rk.OfferType IN ('Daily','Deal-a-day')  
   
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 5', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    -- Delete inactive casinos after the Baytree update
    DELETE a 
    FROM #CasinoDetail A WHERE a.BehaviourRuleKey IS  NULL

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 6', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE CLUSTERED INDEX IX1 ON #CasinoDetail (casinoDetailKey)
    CREATE  INDEX IX2 ON #CasinoDetail (BehaviourRuleKey) 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 6 Index', @BatchTime, GETDATE(), @@ROWCOUNT          

	--Pull all cdc players to determine PlayerLifeCycle
    IF OBJECT_ID('tempdb..#Target') IS NOT NULL DROP TABLE #Target
    SELECT	DISTINCT DP.CustomerId,dcd.BehaviourRuleKey RuleKey
    INTO	#Target
    FROM	dbDWAlignment.dbo.dimPlayer DP WITH (NOLOCK)    
    JOIN	#ActiveOffers A ON DP.playerKey = a.playerkey
	JOIN	#CasinoDetail dcd WITH (NOLOCK) ON dcd.casinoDetailKey = DP.PlayerCasinoDetailKey 
 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 7', @BatchTime, GETDATE(), @@ROWCOUNT   

	CREATE INDEX IX1 ON #Target (CustomerID,RuleKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 7 Index', @BatchTime, GETDATE(), @@ROWCOUNT   

	IF OBJECT_ID('tempdb..#borg') IS NOT NULL DROP TABLE #borg
	SELECT t.CustomerId, t.rulekey, b.ActivityStatus, b.PercentageScoreCasino , B.CouponScoreCasino, B.FirstPurchasedDate,
	       ISNULL(B.BehaviourCat,'BaseExpectationLowTipping') BehaviourCat,
           ISNULL(B.GameGroupCat1,'Unknown') GameGroupCat1,
           ISNULL(B.GameGroupCat2,'Unknown') GameGroupCat2,
           ISNULL(B.GameGroupCat3,'Unknown') GameGroupCat3,
		   ISNULL(B.SoftLapsedDays,0) SoftLapsedDays,
           ISNULL(REPLACE(B.SoftLapsedReason,'N/A','Unknown'),'Unknown') SoftLapsedReason
           --ISNULL(((b.PercentageScoreCasino * b.CouponScoreCasino)/1000),0) SuggestedBonus
    INTO #borg
	FROM #Target t
	JOIN dbDWAlignment.dbo.tblCustomerBorg b WITH (NOLOCK) ON b.CustomerID = t.CustomerId AND b.RuleKey = t.RuleKey

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 8', @BatchTime, GETDATE(), @@ROWCOUNT 

	UPDATE a
    SET a.SoftLapsedReason = 'Unknown'
    FROM #borg a 
    WHERE SoftLapsedReason = '' 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 9', @BatchTime, GETDATE(), @@ROWCOUNT 

	CREATE CLUSTERED INDEX IX1 ON #borg (CustomerID,RuleKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 9 Index', @BatchTime, GETDATE(), @@ROWCOUNT

	--Pull intervention Types
	IF OBJECT_ID('tempdb..#PlayerLifeCycle') IS NOT NULL DROP TABLE #PlayerLifeCycle
    SELECT	DISTINCT t.CUSTOMERID, t.RuleKey, ISNULL(a.Softlapsed,0) Softlapsed, ISNULL(a.ProjectingDown,0) ProjectingDown,  CAST(NULL AS VARCHAR(255)) PlayerLifeCycle
    INTO	#PlayerLifeCycle
    FROM	#Target  t
    LEFT JOIN 	dbDWAlignment.dbo.tblCustomerScoringCasino A WITH(NOLOCK) ON T.CustomerID = A.CustomerID AND T.RuleKey = A.RuleKey

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 10', @BatchTime, GETDATE(), @@ROWCOUNT  

	CREATE CLUSTERED INDEX ix1 ON #PlayerLifeCycle(CustomerId, RuleKey)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 10 index', @BatchTime, GETDATE(), @@ROWCOUNT  

	--Update PlayerLifeCycle with intervention Types
	UPDATE a
	SET PlayerLifeCycle = CASE	WHEN a.ProjectingDown = 1 
							THEN 'ProjectingDown' 
							WHEN a.Softlapsed = 1 
							THEN 'Softlapsed'
							ELSE NULL
						END 

	FROM #PlayerLifeCycle a 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 11', @BatchTime, GETDATE(), @@ROWCOUNT  


	--Update PlayerLifeCycle with ActivityStatus if they dont have intervention Types
	UPDATE a
	SET PlayerLifeCycle = b.ActivityStatus
	--SELECT a.* , b.ActivityStatus
	FROM #PlayerLifeCycle a
	JOIN   #borg b WITH (NOLOCK) ON b.CustomerID = a.CustomerId AND b.RuleKey = a.RuleKey
	WHERE  a.PlayerLifeCycle IS NULL

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 12', @BatchTime, GETDATE(), @@ROWCOUNT 

	--Update ONA Players
	UPDATE a
	SET a.PlayerLifeCycle = 'ONA'
	--SELECT a.* , b.ActivityStatus, B.PercentageScoreCasino, B.CouponScoreCasino,B.FirstPurchasedDate
	FROM #PlayerLifeCycle a
	JOIN   #borg B WITH (NOLOCK) ON B.CustomerID = a.CustomerId AND B.RuleKey = a.RuleKey
	WHERE (b.PercentageScoreCasino IS NULL OR  B.CouponScoreCasino IS NULL )
	OR  B.FirstPurchasedDate IS NULL 

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 13', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    
    IF OBJECT_ID('tempdb..#PlayerPromoMarketing') IS NOT NULL DROP TABLE #PlayerPromoMarketing
    CREATE TABLE #PlayerPromoMarketing
	(
	[CustomerID] [INT] NOT NULL,
	[RuleKey] [INT] NOT NULL ,			--will keep but wont tranfer over to CDP
	[PlayerKey] [INT] NOT NULL,			--will keep but wont tranfer over to CDp
	[UserID] [INT] NOT NULL,
	[CasinoId] [INT] NOT NULL,
	[GamingServerId] [INT] NOT NULL,
	[PlayerLifecycle] [VARCHAR](255),	
	[SuggestedBonus] [FLOAT] NULL,	
	[BehaviourCat] [VARCHAR](255) NULL DEFAULT 'BaseExpectationLowTipping',
	[CustomerMajoritySegment] [VARCHAR](255) NULL,
	[CustomerPurchaseLifeTimeSegment] [VARCHAR](255) NOT NULL DEFAULT 'None',	
	[SoftLapsedDays] [INT] NULL,
	[SoftLapsedReason] [VARCHAR](255) NULL,
	[GameGroupCat1] [VARCHAR](255) NULL,
	[GameGroupCat2] [VARCHAR](255) NULL,
	[GameGroupCat3] [VARCHAR](255) NULL,
	[ABTestFlag] [CHAR](1) NULL,
	[lastModified] [DATETIME] NOT NULL,
    )    
    
	--------------------------------------------------------------------------
    -- ### Get player details for CDC Players
    --------------------------------------------------------------------------
	--DECLARE @BatchTime DATETIME             = GETDATE()	 
	INSERT INTO #PlayerPromoMarketing (CustomerId, RuleKey, playerKey, UserID, CasinoID, GamingServerId, ABTestFlag, lastModified)
    SELECT	DP.CustomerId, DCD.BehaviourRuleKey, DP.playerKey, dp.Hist_PTSUserID UserID, dcd.CasinoID, dp.Hist_PTSGamingserverID GamingServerId, 
			CASE WHEN (dp.CustomerId  % 2) = 0 THEN 'A' ELSE 'B' END AS ABTestFlag, 
			@BatchTime LastModified 
    FROM #CDC_Players cdc
    JOIN dbDWAlignment.dbo.dimPlayer DP WITH (NOLOCK) ON DP.playerKey = cdc.PlayerKey
    JOIN #CasinoDetail dcd WITH (NOLOCK) ON dcd.casinoDetailKey = DP.PlayerCasinoDetailKey 
	WHERE dp.Hist_PTSGamingserverID > 0	
	--AND DP.CustomerId > 0		
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 14', @BatchTime, GETDATE(), @@ROWCOUNT 
    
    CREATE CLUSTERED INDEX IX1 ON #PlayerPromoMarketing (CustomerID, RuleKey)
	CREATE NONCLUSTERED INDEX IXPl ON #PlayerPromoMarketing (PlayerKey)
	CREATE NONCLUSTERED INDEX IX2 ON #PlayerPromoMarketing (GamingServerId, UserID)

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 14 Index', @BatchTime, GETDATE(), @@ROWCOUNT 


	--Remove players not on the borg
	DELETE a 
	FROM #PlayerPromoMarketing a WITH (NOLOCK)
	LEFT JOIN [dbDWAlignment].[dbo].[tblCustomerBorg]  b WITH (NOLOCK) ON b.CustomerID = a.CustomerId AND b.RuleKey = a.RuleKey
	WHERE b.CustomerID is NULL
    
	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 15', @BatchTime, GETDATE(), @@ROWCOUNT 

	--UPDATE CDC Player lifecycle
    UPDATE A
    SET	 A.PlayerLifecycle = b.PlayerLifecycle
    FROM #PlayerPromoMarketing A WITH (NOLOCK)
	JOIN #PlayerLifeCycle b ON B.customerid = A.customerID  AND b.RuleKey = a.RuleKey

    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 16', @BatchTime, GETDATE(), @@ROWCOUNT     

	--Update segments
    UPDATE A
    SET    A.CustomerPurchaseLifeTimeSegment = b.CustomerPurchaseLifeTimeSegment,
	       A.CustomerMajoritySegment = b.CustomerMajoritySegment
    FROM   #PlayerPromoMarketing A WITH (NOLOCK)
    JOIN dbDWAlignment..dimSegments b WITH (NOLOCK) ON b.PlayerKey = a.PlayerKey   
    
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 17', @BatchTime, GETDATE(), @@ROWCOUNT 
    
	--update  borg metrics
    UPDATE A
    SET    A.BehaviourCat		= B.BehaviourCat,
           A.GameGroupCat1		= B.GameGroupCat1,
           A.GameGroupCat2		= B.GameGroupCat2,
           A.GameGroupCat3		= B.GameGroupCat3,
		   A.SoftLapsedDays		= B.SoftLapsedDays,
           A.SoftLapsedReason	= B.SoftLapsedReason,
           A.SuggestedBonus		= ISNULL(((b.PercentageScoreCasino * b.CouponScoreCasino)/1000),0)
    FROM   #PlayerPromoMarketing A WITH (NOLOCK) 
    JOIN   #borg b WITH (NOLOCK) ON B.customerid = A.customerID  AND b.RuleKey = a.RuleKey 
    
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 18', @BatchTime, GETDATE(), @@ROWCOUNT 
    

	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    BEGIN TRANSACTION;	
	   
    -- MERGE : Source / Target --
    ;WITH CTE AS (
      SELECT CustomerID
			,RuleKey  
			,PlayerKey
			,UserID
			,CasinoID
			,GamingServerId
			,PlayerLifecycle
			,SuggestedBonus	
            ,BehaviourCat
            ,CustomerMajoritySegment
            ,CustomerPurchaseLifeTimeSegment	
            ,SoftLapsedDays
            ,SoftLapsedReason
            ,GameGroupCat1
            ,GameGroupCat2
            ,GameGroupCat3
			,ABTestFlag
			,lastModified
      FROM #PlayerPromoMarketing
    ) MERGE dbPromotions.dbo.PlayerPromoMarketing AS Tgt
      USING CTE AS Src
		ON  Tgt.UserID = Src.UserID
	   AND  Tgt.GamingServerId = Src.GamingServerID
      -- UPDATE : Matched / Differs 
      WHEN MATCHED AND EXISTS (
        SELECT 
                Tgt.CustomerID
			   ,Tgt.RuleKey  
			   ,Tgt.PlayerKey
			   ,Tgt.UserID
			   ,Tgt.CasinoID
			   ,Tgt.GamingServerId
			   ,Tgt.PlayerLifecycle
			   ,Tgt.SuggestedBonus	
               ,Tgt.BehaviourCat
               ,Tgt.CustomerMajoritySegment
               ,Tgt.CustomerPurchaseLifeTimeSegment	
               ,Tgt.SoftLapsedDays
               ,Tgt.SoftLapsedReason
               ,Tgt.GameGroupCat1
               ,Tgt.GameGroupCat2
               ,Tgt.GameGroupCat3
			   ,Tgt.ABTestFlag
        EXCEPT
        SELECT 
                Src.CustomerID
			   ,Src.RuleKey  
			   ,Src.PlayerKey
			   ,Src.UserID
			   ,Src.CasinoID
			   ,Src.GamingServerId
			   ,Src.PlayerLifecycle
			   ,Src.SuggestedBonus	
               ,Src.BehaviourCat
               ,Src.CustomerMajoritySegment
               ,Src.CustomerPurchaseLifeTimeSegment	
               ,Src.SoftLapsedDays
               ,Src.SoftLapsedReason
               ,Src.GameGroupCat1
               ,Src.GameGroupCat2
               ,Src.GameGroupCat3
			   ,Src.ABTestFlag
      )  THEN
	    --if player exist and other columns dont match update
        UPDATE SET
          Tgt.CustomerID						= Src.CustomerID,
		  Tgt.RuleKey							= Src.RuleKey,  
		  Tgt.PlayerKey							= Src.PlayerKey,
		  Tgt.UserID							= Src.UserID,
		  Tgt.CasinoID							= Src.CasinoID,
		  Tgt.GamingServerId					= Src.GamingServerId,
		  Tgt.PlayerLifecycle					= Src.PlayerLifecycle,
		  Tgt.SuggestedBonus					= Src.SuggestedBonus,	
          Tgt.BehaviourCat						= Src.BehaviourCat,
          Tgt.CustomerMajoritySegment			= Src.CustomerMajoritySegment,
          Tgt.CustomerPurchaseLifeTimeSegment	= Src.CustomerPurchaseLifeTimeSegment,	
          Tgt.SoftLapsedDays					= Src.SoftLapsedDays,
          Tgt.SoftLapsedReason					= Src.SoftLapsedReason,
          Tgt.GameGroupCat1						= Src.GameGroupCat1,
          Tgt.GameGroupCat2						= Src.GameGroupCat2,
          Tgt.GameGroupCat3						= Src.GameGroupCat3,
		  Tgt.ABTestFlag						= Src.ABTestFlag,
		  Tgt.LastModified						= Src.LastModified
      -- INSERT : NOT Matched --
      WHEN NOT MATCHED BY TARGET THEN
	    --if player does not exist insert
        INSERT (
          CustomerID,
		  RuleKey,  
		  PlayerKey,
		  UserID,
		  CasinoID,
		  GamingServerId,
		  PlayerLifecycle,
		  Eligible,
		  PrimaryOffer,
		  CouponValue,
		  BirthdayOffer,
		  SuggestedBonus,	
          BehaviourCat,
          CustomerMajoritySegment,
          CustomerPurchaseLifeTimeSegment,	
          SoftLapsedDays,
          SoftLapsedReason,
          GameGroupCat1,
          GameGroupCat2,
          GameGroupCat3,
		  ABTestFlag,
		  LastModified
      ) VALUES (
          CustomerID,
		  RuleKey,  
		  PlayerKey,
		  UserID,
		  CasinoID,
		  GamingServerId,
		  PlayerLifecycle,
		  'N',
		  0,
		  0,
		  0,
		  SuggestedBonus,	
          BehaviourCat,
          CustomerMajoritySegment,
          CustomerPurchaseLifeTimeSegment,	
          SoftLapsedDays,
          SoftLapsedReason,
          GameGroupCat1,
          GameGroupCat2,
          GameGroupCat3,
		  ABTestFlag,
		  LastModified
        );


    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 19', @BatchTime, GETDATE(), @@ROWCOUNT

	--------------------------------------------------------------------------
    -- ### RESET ELIGIBILITY 
    --------------------------------------------------------------------------	
    UPDATE A
    SET a.Eligible = 'N',
    a.PrimaryOffer = 0,
    a.CouponValue = 0,
    a.ValidFrom = NULL,
    A.ValidTo = NULL,
	A.OfferType = NULL
    --SELECT *
    FROM dbPromotions.dbo.PlayerPromoMarketing A WITH (NOLOCK) 
    WHERE a.OfferType = '2ndDay'
	AND a.Eligible = 'Y'

	INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 20', @BatchTime, GETDATE(), @@ROWCOUNT

   --Update with recent offers
   UPDATE a
   SET a.Eligible = 'Y',
   a.PrimaryOffer = b.Match,
   a.CouponValue = b.Coupon,
   a.validfrom = b.ValidFrom,
   A.validTo = B.ValidTo,
   a.OfferType = b.OfferType,
   a.lastModified = @BatchTime
   --SELECT *
   FROM dbPromotions.dbo.PlayerPromoMarketing A
   --JOIN #ActiveOffers b ON b.GamingServerId = a.GamingServerId AND b.UserID = a.UserID
   JOIN #ActiveOffers b ON b.PlayerKey = a.PlayerKey

    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Step 21', @BatchTime, GETDATE(), @@ROWCOUNT
    
	COMMIT TRANSACTION;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;	
	
	END TRY
	BEGIN CATCH

		/*
		  -- XACT_STATE:
		   1 = Active transactions, CAN be committed or rolled back. Because of error, we rollback
		   0 = NO Active transactions, CANNOT be committed or rolled back.
		  -1 = Active transactions, CANNOT be committed but CAN be rolled back. Because of error, we rollback
		*/
		IF XACT_STATE() <> 0
		  ROLLBACK;
		  DECLARE @ProcessName NVARCHAR(150)	= 'PlayerPromoMarketing Segmentation',
		          @ErrProc NVARCHAR(128)		= ERROR_PROCEDURE(),
				  @ErrMsg  NVARCHAR(4000)		= ERROR_MESSAGE(),
				  @ErrNum  INT					= ERROR_NUMBER(),
				  @ErrLn   INT					= ERROR_LINE();

		INSERT INTO [dbPromotions].[dbo].[ProcessError]([ProcessName],[ErrorProcedure],[ErrorNumber],[ErrorLine],[ErrorMessage])
		SELECT @ProcessName,@ErrProc, @ErrNum, @ErrLn,@ErrMsg

		THROW;
		INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'Failure', @BatchTime, GETDATE(), @@ROWCOUNT 

	END CATCH;
    
	WAITFOR DELAY '00:00:01'
    INSERT INTO [dbPromotions].[dbo].[ProcessRuntimeLog] SELECT @Procedure, 'END', @BatchTime, GETDATE(), @@ROWCOUNT 

END
GO

CREATE PROCEDURE [dbo].[usp_PlayerPromoMarketing_Event] 
AS
-- =============================================
-- Author:		<Veven Naidoo>
-- Create date: <24-05-2024>
-- Description:	<This proc packages all information for the salesforce promo marketing stuff into JSON and adds to a generic event table>
-- =============================================
BEGIN

	SET NOCOUNT ON; 

DECLARE @MaxLastModified DATETIME = (SELECT MAX(LastModified) FROM dbPromotions.dbo.PlayerPromoMarketing WITH (NOLOCK))
DECLARE @ProcessStart DATETIME = GETDATE()
DECLARE @LastModified DATETIME = CAST(ISNULL((SELECT MAXModifiedDate FROM dbPromotions.dbo.tblPublishCDOIdentity WITH (NOLOCK) WHERE processNAme = 'PlayerPromoMarketing'), GETDATE()) AS DATE)
DECLARE @ProcedureName VARCHAR(50) = 'usp_PromoMarketing_Event'

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'START', @ProcessStart, GETDATE(), @@ROWCOUNT);

IF @MaxLastModified > @LastModified
BEGIN	

TRUNCATE TABLE [dbPromotions].[dbo].[PlayerPromoMarketingTargetlist]

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'Step 1', @ProcessStart, GETDATE(), @@ROWCOUNT);

--======================================================================
--STEP 1: Insert info into temp table that contains only the new records
--======================================================================
INSERT INTO [dbPromotions].[dbo].[PlayerPromoMarketingTargetlist]
(
[EventPayloadID]
,[EventPayloadRecordID]
,[EventPayloadGenerated]
,[Event_Type]
,[Source_System]
,[CustomerID]
,[UserID]
,[CasinoID]
,[GamingServerId]
,[PlayerLifecycle]
,[Eligible]
,[PrimaryOffer]
,[CouponValue]
,[ValidFrom]
,[ValidTo]
,[BirthdayOffer]
,[StartDate]
,[EndDate]
,[SuggestedBonus]
,[BehaviourCat]
,[CustomerMajoritySegment]
,[CustomerPurchaseLifeTimeSegment]
,[SoftLapsedDays]
,[SoftLapsedReason]
,[GameGroupCat1]
,[GameGroupCat2]
,[GameGroupCat3]
,[ABTestFlag]
,[LastModified]
)
SELECT 
	   NULL AS EventPayloadID,
	   ROW_NUMBER() OVER(ORDER BY GETDATE() DESC) AS EventPayloadRecordID,
	   CONVERT(VARCHAR(23),GETDATE(),121) AS EventPayloadGenerated,
	   'PlayerPromoMarketing' AS Event_Type,
	   'IGInsights' AS Source_System,
	   CAST(a.CustomerID AS VARCHAR(50)) AS CustomerID,
       CAST(a.UserID AS VARCHAR(50)) AS UserID,
       CAST(a.CasinoId AS VARCHAR(50)) CasinoID,
       CAST(a.GamingServerId AS VARCHAR(50)) AS GamingServerId,
       RTRIM(a.PlayerLifecycle) AS PlayerLifecycle,
       a.Eligible,
       CAST(a.PrimaryOffer AS VARCHAR(50)) AS PrimaryOffer,
       CAST(a.CouponValue AS VARCHAR(50)) AS CouponValue,
	   ISNULL(CONVERT(VARCHAR(23), a.ValidFrom,121),'') AS ValidFrom,
       ISNULL(CONVERT(VARCHAR(23), a.ValidTo,121),'') AS ValidTo,
       CAST(a.BirthdayOffer AS VARCHAR(50)) AS BirthdayOffer,
       ISNULL(CONVERT(VARCHAR(23), a.StartDate,121),'') AS StartDate,
       ISNULL(CONVERT(VARCHAR(23), a.EndDate,121),'') AS EndDate,
       CAST(a.SuggestedBonus AS VARCHAR(50)) AS SuggestedBonus,
       a.BehaviourCat,
       a.CustomerMajoritySegment,
       a.CustomerPurchaseLifeTimeSegment,
       CAST(a.SoftLapsedDays AS VARCHAR(50)) AS SoftLapsedDays,
       a.SoftLapsedReason,
       a.GameGroupCat1,
       a.GameGroupCat2,
       a.GameGroupCat3,
       a.ABTestFlag,
       CONVERT(VARCHAR(23),a.lastModified,121) AS LastModified
FROM dbPromotions.dbo.PlayerPromoMarketing a WITH (NOLOCK)
WHERE a.lastModified > @LastModified
--01:26 (1097943 Rows Affected)

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'Step 2', @ProcessStart, GETDATE(), @@ROWCOUNT);

--======================================================================
--STEP 2: Update the event payload id
--======================================================================
IF OBJECT_ID('tempdb..#tmpNextVal') IS NOT NULL DROP TABLE #tmpNextVal
SELECT NEXT VALUE FOR dbPromotions.dbo.PlayerPromoMarketing_Sequence AS NextVal
INTO #tmpNextVal

UPDATE a
SET a.EventPayloadID = (SELECT NextVal FROM #tmpNextVal)
--SELECT TOP 10 *
FROM [dbPromotions].[dbo].[PlayerPromoMarketingTargetlist] a
--02:28

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'Step 3', @ProcessStart, GETDATE(), @@ROWCOUNT);

BEGIN TRY
--======================================================================
--STEP 3: Build up the JSON string
--======================================================================
IF OBJECT_ID('tempdb..#EventPayload') IS NOT NULL DROP TABLE #EventPayload
SELECT
 a.EventPayloadID
,a.EventPayloadRecordID
,a.EventPayloadGenerated
,('"EventMetadata":{'+                    
              
              '"EventPayloadID":"'                     +CAST(EventPayloadID AS VARCHAR(20))                      +'",'+
              '"EventPayloadRecordID":"'               +CAST(EventPayloadRecordID AS VARCHAR(20))                +'",'+
			  '"EventPayloadGenerated":"'              +EventPayloadGenerated                +'",'+
			  '"Source_System":"'                      +Source_System                        +'",'+
			  '"Event_Type":"'                         +Event_Type                           +'"'+
            '}'
           ) AS EventMetadata
,('"Payload":{'+
              '"CustomerID":"'                         +CustomerID                           +'",'+
              '"UserID":"'                             +UserID                               +'",'+
              '"CasinoId":"'                           +CasinoId                             +'",'+
              '"GamingServerId":"'                     +GamingServerId                       +'",'+
              '"PlayerLifecycle":"'                    +PlayerLifecycle                      +'",'+
              '"Eligible":"'                           +Eligible                             +'",'+
              '"PrimaryOffer":"'                       +PrimaryOffer                         +'",'+
              '"CouponValue":"'                        +CouponValue                          +'",'+
              '"ValidFrom":"'						   +ValidFrom                            +'",'+ 
              '"ValidTo":"'                            +ValidTo                              +'",'+
              '"BirthdayOffer":"'                      +BirthdayOffer                        +'",'+
              '"StartDate":"'                          +StartDate                            +'",'+
              '"EndDate":"'                            +EndDate                              +'",'+
              '"SuggestedBonus":"'                     +SuggestedBonus                       +'",'+
              '"BehaviourCat":"'                       +BehaviourCat                         +'",'+
              '"CustomerMajoritySegment":"'            +CustomerMajoritySegment              +'",'+
              '"CustomerPurchaseLifeTimeSegment":"'    +CustomerPurchaseLifeTimeSegment      +'",'+
              '"SoftLapsedDays":"'                     +SoftLapsedDays                       +'",'+
              '"SoftLapsedReason":"'                   +SoftLapsedReason                     +'",'+
              '"GameGroupCat1":"'                      +GameGroupCat1                        +'",'+
              '"GameGroupCat2":"'                      +GameGroupCat2                        +'",'+
              '"GameGroupCat3":"'                      +GameGroupCat3                        +'",'+
              '"ABTestFlag":"'                         +ABTestFlag                           +'",'+
              '"LastModified":"'                       +lastModified                         +'"' +
            '}'
           ) AS JSONPayload
INTO #EventPayload
FROM [dbPromotions].[dbo].[PlayerPromoMarketingTargetlist] a WITH (NOLOCK)

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'Step 4', @ProcessStart, GETDATE(), @@ROWCOUNT);

CREATE CLUSTERED INDEX IX1 ON #EventPayload (EventPayloadID, EventPayloadRecordID)

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'Step 5', @ProcessStart, GETDATE(), @@ROWCOUNT);

--======================================================================
--STEP 5: Concat values together and insert into genric event table
--======================================================================


SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;	

INSERT INTO [dbo].[PlayerPromoMarketing_Event]
(
EventPayloadID,
EventPayloadRecordID,
EventPayloadGenerated,
EventPayloadJSONString,
ProduceEventConfirmed,
ProduceEventMessageID
)
SELECT a.EventPayloadID,
       a.EventPayloadRecordID,
       a.EventPayloadGenerated,
CONCAT('{"Event":{', a.EventMetadata, ',', REPLACE(LTRIM(RTRIM(JSONPayload)),'       "','"') ,'}}') AS EventPayloadJSONString , 
NULL AS ProduceEventConfirmed,
NULL AS ProduceEventMessageID
FROM #EventPayload a
DECLARE @ROWCOUNT INT = @@ROWCOUNT
--01:21

COMMIT TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;	

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'Step 6', @ProcessStart, GETDATE(), @ROWCOUNT);

END TRY
BEGIN CATCH

	/*
		-- XACT_STATE:
		1 = Active transactions, CAN be committed or rolled back. Because of error, we rollback
		0 = NO Active transactions, CANNOT be committed or rolled back.
		-1 = Active transactions, CANNOT be committed but CAN be rolled back. Because of error, we rollback
	*/
	IF XACT_STATE() <> 0
		ROLLBACK;
		DECLARE @ProcName NVARCHAR(150)	= 'PlayerPromoMarketing Segmentation',
		        @ErrProc NVARCHAR(128)		= ERROR_PROCEDURE(),
				@ErrMsg  NVARCHAR(4000)		= ERROR_MESSAGE(),
				@ErrNum  INT					= ERROR_NUMBER(),
				@ErrLn   INT					= ERROR_LINE();

	INSERT INTO [dbPromotions].[dbo].[ProcessError]([ProcessName],[ErrorProcedure],[ErrorNumber],[ErrorLine],[ErrorMessage])
	SELECT @ProcName,@ErrProc, @ErrNum, @ErrLn,@ErrMsg 

	THROW;
	INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] SELECT @ProcedureName, 'Failure', @ProcessStart, GETDATE(), @@ROWCOUNT 

END CATCH;


--======================================================================
--STEP 6: Add a record to the CDO identity table to show what we processed
--======================================================================
--DECLARE @ProcessStart DATETIME = GETDATE()
DECLARE @ProcessName VARCHAR(100)
DECLARE @ProcessType VARCHAR(20)
DECLARE @Database VARCHAR(20)
DECLARE @TrackedColumn VARCHAR(20)
DECLARE @ExtractType VARCHAR(20)
DECLARE @ProcessEnd DATETIME
DECLARE @NewMinModified DATETIME
DECLARE @NewMaxModified DATETIME
DECLARE @ProcessDuration INT

SET @ProcessName = 'PlayerPromoMarketing'
SET @ProcessType = 'Publish Data'
SET @Database = 'dbPromotions'
SET @TrackedColumn = 'LastModified'
SET @ExtractType = 'Changed Data Object'
SET @ProcessEnd = GETDATE()
SET @NewMinModified = @LastModified
SET @NewMaxModified = @MaxLastModified
SET @ProcessDuration = DATEDIFF(MINUTE,@ProcessStart,@ProcessEnd)


INSERT INTO dbPromotions.dbo.tblPublishCDOIdentity (ProcessName, ProcessType, [Database], TrackedColumn, ExtractType, ProcessStart, ProcessEnd,ProcessDuration, MINModifiedDate, MAXModifiedDate)
SELECT @ProcessName, @ProcessType, @Database, @TrackedColumn, @ExtractType, @ProcessStart, @ProcessEnd,@ProcessDuration,@NewMinModified,@NewMaxModified

END

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] VALUES (@ProcedureName, 'END', @ProcessStart, GETDATE(), @@ROWCOUNT);

END
GO

CREATE PROCEDURE [dbo].[PublishErrorsBatch] (
  -- Events Tab. --
  @PublishEvents  dbo.ConfirmEvents READONLY
  -- Error Pars. --
 ,@ErrorProcedure NVARCHAR(128)
 ,@ErrorMessage   NVARCHAR(4000)
 ,@ErrorSeverity  TINYINT
 ,@ErrorNumber    INT
 ,@ErrorLine      INT
  -- Output Count --
 ,@RowCount       INT = 0 OUTPUT
) /*WITH RECOMPILE*/ AS
---------------------------------------------------------------------------------------------------
-- Description : Inserts a batch of entries / rows into the Publish Error table.
-- Events Tab. : PublishEvents  : table of type dbo.ConfirmEvent
-- Error Pars. : ErrorProcedure : value returned by ERROR_PROCEDURE() function
--             : ErrorMessage   : value returned by ERROR_MESSAGE() function
--             : ErrorSeverity  : value returned by ERROR_SEVERITY() function
--             : ErrorNumber    : value returned by ERROR_NUMBER() function
--             : ErrorLine      : value returned by ERROR_LINE() function
---------------------------------------------------------------------------------------------------
BEGIN;
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN TRY;
  BEGIN TRANSACTION;
    INSERT INTO dbo.PublishError (
      -- Event Cols. --
      EventPayloadID,
      EventPayloadRecordID,
      ProduceEventMessageID,
      -- Error Cols. --
      ErrorProcedure,
      ErrorMessage,
      ErrorSeverity,
      ErrorNumber,
      ErrorLine
    ) SELECT -- Event Cols. --
             EventPayloadID
            ,EventPayloadRecordID
            ,ProduceEventMessageID
             -- Error Vars. --
            ,@ErrorProcedure
            ,@ErrorMessage
            ,@ErrorSeverity
            ,@ErrorNumber
            ,@ErrorLine
      FROM @PublishEvents;
  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
  IF (XACT_STATE() <> 0) ROLLBACK TRANSACTION;
  THROW;
END CATCH;
END;
GO

CREATE PROCEDURE [dbo].[PlayerPromoMarketing_FetchUnpublishedEvents] (
  @PublishBatchSize INT = 2000
) /*WITH RECOMPILE*/ AS
---------------------------------------------------------------------------------------------------
-- Description : Fetch Unpublished Events method called by a Generic Producer.
-- Parameters : PublishBatchSize : The size of the batch to publish in a single call.
---------------------------------------------------------------------------------------------------
BEGIN;
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN TRY;
  /* Constants */
  DECLARE @SysUTCDT2 DATETIME2 = SYSUTCDATETIME(); -- {SUDT}
  DECLARE @Procedure NVARCHAR(50)         = 'PlayerPromoMarketing_FetchUnpublishedEvents'
  DECLARE @BatchTime DATETIME             = GETDATE()

  INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] SELECT @Procedure, 'Start', @BatchTime, GETDATE(), @@ROWCOUNT 

  /* Variables */
  DECLARE @EventPayloadID INT;
  DECLARE @EventPayloadGenerated DATETIME2;

  /* Processing */
  -- Pop. Vars. > Update / Return --
  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    -- EventPayloadID : Minimum --
    SELECT @EventPayloadID = MIN(EventPayloadID)
    FROM dbo.PlayerPromoMarketing_Event
    WHERE ProduceEventConfirmed IS NULL
     AND  ProduceEventMessageID IS NULL;
    -- EventPayloadGenerated : Related Minimum --
    SELECT @EventPayloadGenerated = MIN(EventPayloadGenerated)
    FROM dbo.PlayerPromoMarketing_Event
    WHERE EventPayloadID = @EventPayloadID
     AND  ProduceEventConfirmed IS NULL
     AND  ProduceEventMessageID IS NULL;
    -- Update / Return : Transaction --
    BEGIN TRANSACTION;
      UPDATE TopGenEvt
      -- Produce Event Confirmed : Update --
      SET ProduceEventConfirmed = @SysUTCDT2
      -- Generic Event : Return --
      OUTPUT Inserted.EventPayloadID
            ,Inserted.EventPayloadRecordID
            ,CONVERT(VARCHAR(27), Inserted.EventPayloadGenerated, 121) AS EventPayloadGenerated
            ,Inserted.EventPayloadJSONString
            ,CONVERT(VARCHAR(27), Inserted.ProduceEventConfirmed, 121) AS ProduceEventConfirmed
      FROM (-- Publish Batch Size : Select Top --
            SELECT TOP (@PublishBatchSize)
                   -- Standard Columns --
                   EventPayloadID
                  ,EventPayloadRecordID
                  ,EventPayloadGenerated
                  ,EventPayloadJSONString
                   -- Producer Columns --
                  ,ProduceEventConfirmed
            FROM dbo.PlayerPromoMarketing_Event
            WHERE EventPayloadID = @EventPayloadID
             AND  EventPayloadGenerated = @EventPayloadGenerated
             AND  ProduceEventConfirmed IS NULL
             AND  ProduceEventMessageID IS NULL
            ORDER BY EventPayloadID
                    ,EventPayloadRecordID
           ) TopGenEvt
      WHERE EventPayloadID = TopGenEvt.EventPayloadID
       AND  EventPayloadRecordID = TopGenEvt.EventPayloadRecordID
       AND  EventPayloadGenerated = TopGenEvt.EventPayloadGenerated;
    COMMIT TRANSACTION;
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END TRY
BEGIN CATCH
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  THROW;
END CATCH;

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] SELECT @Procedure, 'End', @BatchTime, GETDATE(), @@ROWCOUNT

END;
GO

CREATE PROCEDURE [dbo].[PlayerPromoMarketing_ConfirmEventsPublished] (
  @ConfirmEvents dbo.ConfirmEvents READONLY
) /*WITH RECOMPILE*/ AS
---------------------------------------------------------------------------------------------------
-- Description : Confirm Events Published method called by a Generic Producer.
-- Parameters : ConfirmEvents : A table type for Confirmed Events.
---------------------------------------------------------------------------------------------------
BEGIN;
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
BEGIN TRY;
  /* Constants */
  DECLARE @SourceSchema SYSNAME		= N'dbo'
         ,@SourceTable  SYSNAME		= N'PlayerPromoMarketing_Event';
  DECLARE @Procedure NVARCHAR(50)	= 'PlayerPromoMarketing_ConfirmEventsPublished'
  DECLARE @BatchTime DATETIME		= GETDATE()

  INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] SELECT @Procedure, 'Start', @BatchTime, GETDATE(), @@ROWCOUNT 

  /* Variables */
  DECLARE @ThrowMsg NVARCHAR(2048) =
    N'The table '+@SourceSchema+N'.'+@SourceTable+N' does not exist. Redirecting to the table dbo.PublishError.';

  /* Validation */
  IF (NOT EXISTS (SELECT 1
                  FROM INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_SCHEMA = @SourceSchema
                   AND  TABLE_NAME   = @SourceTable )) THROW 50000, @ThrowMsg, 1;

  /* Processing */
  -- Confirm Events : Transaction --
  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    BEGIN TRANSACTION;
      UPDATE GenEvt
      SET ProduceEventMessageID = ConEvt.ProduceEventMessageID
      FROM dbo.PlayerPromoMarketing_Event AS GenEvt
      INNER JOIN @ConfirmEvents AS ConEvt
        ON  ConEvt.EventPayloadID = GenEvt.EventPayloadID
       AND  ConEvt.EventPayloadRecordID = GenEvt.EventPayloadRecordID
       AND  ConEvt.EventPayloadGenerated = GenEvt.EventPayloadGenerated
       --AND  GenEvt.ProduceEventConfirmed = GenEvt.ProduceEventConfirmed
	   AND  ConEvt.ProduceEventConfirmed = GenEvt.ProduceEventConfirmed
      WHERE GenEvt.ProduceEventMessageID IS NULL;
    COMMIT TRANSACTION;
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END TRY
BEGIN CATCH
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  IF (XACT_STATE() <> 0) ROLLBACK TRANSACTION;
  DECLARE @ErrorProcedure NVARCHAR(128)  = ERROR_PROCEDURE()
         ,@ErrorMessage   NVARCHAR(4000) = ERROR_MESSAGE()
         ,@ErrorSeverity  TINYINT        = ERROR_SEVERITY()
         ,@ErrorNumber    INT            = ERROR_NUMBER()
         ,@ErrorLine      INT            = ERROR_LINE();
  -- Publish Events Error : Batch --
  EXEC dbo.PublishErrorsBatch             -- Events Tab. --
                                          @PublishEvents  = @ConfirmEvents
                                          -- Error Vars. --
                                         ,@ErrorProcedure = @ErrorProcedure
                                         ,@ErrorMessage   = @ErrorMessage
                                         ,@ErrorSeverity  = @ErrorSeverity
                                         ,@ErrorNumber    = @ErrorNumber
                                         ,@ErrorLine      = @ErrorLine;
  THROW;
END CATCH;

INSERT INTO [dbDWAlignmentStage].[audit].[ProcessRuntimeLog] SELECT @Procedure, 'End', @BatchTime, GETDATE(), @@ROWCOUNT

END;
GO



/* End of File **************************************************************************************************************************************/








