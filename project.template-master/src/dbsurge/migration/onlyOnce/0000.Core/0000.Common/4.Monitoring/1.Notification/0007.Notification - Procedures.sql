/***********************************************************************************************************************************
* Script      : 7.Notification - Procedures.sql                                                                                    *
* Created By  : Cedric Dube/Cedric Dube                                                                                            *
* Created On  : 2021-03-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. [SendMail]                                                                                                     *
*             :  2. [SendSMS]                                                                                                      *
*             :  3. [Convert_SQLQuery_ToHtml]                                                                                      *
*             :  4. [SetRecipient]                                                                                                 *
*             :  5. [SetNotification]                                                                                              *
*             :  6. [Process_Alerting]                                                                                             *
***********************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE PROCEDURE [Notification].[SendMail] (
  @Recipients VARCHAR(MAX),
  @ProfileName NVARCHAR(128) = 'DEFAULT',
  @BodyFormat VARCHAR(20) = 'TEXT',
  @Body NVARCHAR(MAX),
  @Subject NVARCHAR(255) = 'DEFAULT',
  @FromAddress NVARCHAR(255)
) AS
  SET NOCOUNT ON;
BEGIN
BEGIN TRY;
  IF @ProfileName = 'DEFAULT' BEGIN;
    SET @ProfileName = (SELECT TOP (1) ProfileName FROM [Notification].[SendProfile] WHERE SendType = 'EMail' AND ProfileType = @ProfileName);
  END;
  IF @Subject = 'DEFAULT' BEGIN;
    SET @Subject = (SELECT TOP (1) DefaultSubject FROM [Notification].[SendProfile] WHERE SendType = 'EMail' AND ProfileName = @ProfileName);
  END;
  EXEC msdb.dbo.sp_send_dbmail @profile_name = @ProfileName,
                               @recipients = @Recipients,
                               @body = @Body,
                               @body_format = @BodyFormat,
                               @subject = @Subject,
							   @from_address = @FromAddress; 				 
END TRY
BEGIN CATCH
 THROW;                            
END CATCH;
END;
GO

GO
CREATE PROCEDURE [Notification].[SendSMS] (
  @Recipients VARCHAR(MAX),
  @ProfileName NVARCHAR(128) = 'DEFAULT',
  @Body VARCHAR(1000),
  @Subject NVARCHAR(255) = 'DEFAULT'
) AS
  SET NOCOUNT ON;
BEGIN
BEGIN TRY;
  IF @ProfileName = 'DEFAULT' BEGIN;
    SET @ProfileName = (SELECT TOP (1) ProfileName FROM [Notification].[SendProfile] WHERE SendType = 'SMS' AND ProfileType = @ProfileName);
  END;
  IF @Subject = 'DEFAULT' BEGIN;
    SET @Subject = (SELECT TOP (1) DefaultSubject FROM [Notification].[SendProfile] WHERE SendType = 'SMS' AND ProfileName = @ProfileName);
  END;
  EXEC [Notification].[SendMail] @ProfileName = @ProfileName,
                                 @Recipients = @Recipients,
                                 @Body = @Body,
                                 @BodyFormat = 'TEXT',
                                 @Subject = @Subject; 				 
END TRY
BEGIN CATCH
 THROW;                            
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Notification].[Convert_SQLQuery_ToHtml] (
  @query nvarchar(MAX), --A query to turn into HTML format. It should not include an ORDER BY clause.
  @orderBy nvarchar(MAX) = NULL, --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
  @html nvarchar(MAX) = NULL OUTPUT --The HTML output of the procedure.
) AS
  SET NOCOUNT ON;
BEGIN   
  BEGIN TRY;
    IF @orderBy IS NULL BEGIN
      SET @orderBy = ''  
    END;
    
    SET @orderBy = REPLACE(@orderBy, '''', '''''');
    
    DECLARE @realQuery nvarchar(MAX) = '
      DECLARE @headerRow nvarchar(MAX);
      DECLARE @cols nvarchar(MAX);    
    
      SELECT * INTO #dynSql FROM (' + @query + ') sub;
    
      SELECT @cols = COALESCE(@cols + '', '''''''', '', '''') + ''['' + name + ''] AS ''''td''''''
      FROM tempdb.sys.columns 
      WHERE object_id = object_id(''tempdb..#dynSql'')
      ORDER BY column_id;
    
      SET @cols = ''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @orderBy + ' FOR XML PATH(''''tr''''), ELEMENTS XSINIL) AS nvarchar(max))''    
    
      EXEC sys.sp_executesql @cols, N''@html nvarchar(MAX) OUTPUT'', @html=@html OUTPUT
    
      SELECT @headerRow = COALESCE(@headerRow + '''', '''') + ''<th>'' + name + ''</th>'' 
      FROM tempdb.sys.columns 
      WHERE object_id = object_id(''tempdb..#dynSql'')
      ORDER BY column_id;
    
      SET @headerRow = ''<tr>'' + @headerRow + ''</tr>'';
    
      SET @html = ''<table border="1">'' + @headerRow + @html + ''</table>'';    
      ';
    
    EXEC sys.sp_executesql @realQuery, N'@html nvarchar(MAX) OUTPUT', @html=@html OUTPUT;
END TRY
BEGIN CATCH
  THROW;
END CATCH
END;
GO
GO
CREATE PROCEDURE [Notification].[SetRecipient] (
  @RecipientName NVARCHAR(80),
  @MobileNumber CHAR(11),
  @EMailAddress NVARCHAR(150),
  @SendSMS BIT = 0,
  @SendEMail BIT = 0,
  @Delete BIT = 0,
  @DeleteByRecipientNameOnly BIT = 0
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  IF @Delete = 1 BEGIN;
    IF @DeleteByRecipientNameOnly = 1 BEGIN
      DELETE FROM [Notification].[Recipient] WHERE RecipientName = @RecipientName;
      SELECT 'DELETED: All for Recipient: ' + @RecipientName;
      RETURN;
    END; ELSE BEGIN;
      DELETE FROM [Notification].[Recipient] WHERE RecipientName = @RecipientName AND MobileNumber = @MobileNumber AND EMailAddress = @EMailAddress;
      SELECT 'DELETED: Recipient: ' + @RecipientName + ' ; MobileNumber: ' + @MobileNumber + ' ; EMailAddress: ' + @EMailAddress;
      RETURN;
	END;
  END;
  IF NOT EXISTS (SELECT 1 FROM [Notification].[Recipient] WHERE RecipientName = @RecipientName AND MobileNumber = @MobileNumber AND EMailAddress = @EMailAddress) BEGIN;
    INSERT INTO [Notification].[Recipient] ([RecipientName], [MobileNumber], [EMailAddress], [SendSMS], [SendEMail])
      VALUES (@RecipientName, @MobileNumber, @EMailAddress, @SendSMS, @SendEMail);
    SELECT 'INSERTED: Recipient: ' + @RecipientName + ' ; MobileNumber: ' + @MobileNumber + ' ; EMailAddress: ' + @EMailAddress;
    RETURN;
  END; ELSE BEGIN;
    UPDATE [Notification].[Recipient] WITH (ROWLOCK, READPAST)
       SET [SendSMS] = @SendSMS,
           [SendEMail] = @SendEMail
     WHERE [RecipientName] = @RecipientName
       AND [MobileNumber] = @MobileNumber
       AND [EMailAddress]= @EMailAddress;
    SELECT 'UPDATED: Recipient: ' + @RecipientName + ' ; MobileNumber: ' + @MobileNumber + ' ; EMailAddress: ' + @EMailAddress;
    RETURN;
  END;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Notification].[SetNotification] (
  @AlertDateTime DATETIME2(7),
  @AlertProcedure NVARCHAR(128),
  @AlertType VARCHAR(10),
  @AlertRecipients NVARCHAR(MAX),
  @AlertProfile NVARCHAR(128),
  @AlertFormat VARCHAR(20),
  @AlertSubject NVARCHAR(128),
  @AlertMessage NVARCHAR(MAX),
  @AlertID INT = -1 OUTPUT
) AS
  SET NOCOUNT ON;
BEGIN;
BEGIN TRY;
  INSERT INTO [Notification].[Alert]
  (
      AlertDateTime,
      AlertProcedure,
      AlertType,
      AlertRecipients,
      AlertProfile,
      AlertFormat,
      AlertSubject,
      AlertMessage
  )
  VALUES( @AlertDateTime,
          @AlertProcedure,
          @AlertType,
          @AlertRecipients,
          @AlertProfile,
          @AlertFormat,
          @AlertSubject,
          @AlertMessage );
  SET @AlertID = @@IDENTITY;
END TRY
BEGIN CATCH
  THROW;
END CATCH;
END;
GO
GO
CREATE PROCEDURE [Notification].[Process_Alerting] AS
  -------------------------------------------------------------------------------------------------
  -- Author:      Cedric Dube
  -- Create date: 2021-03-02
  -- Description: Send Alert notifications.
  -- Version:     1.0
  -------------------------------------------------------------------------------------------------
  SET NOCOUNT ON;
BEGIN
BEGIN TRY
  -------------------------------------------------------------------------------------------------
  -- PROC. SESSION SETUP
  -------------------------------------------------------------------------------------------------
  DECLARE @NowTime DATETIME2(7) = SYSUTCDATETIME();
  -------------------------------
  -- CONFIG VARS.
  -------------------------------
  DECLARE @ProcedureName NVARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @ProcessName VARCHAR(150) = 'Notification|Alerting',
          @ProcessLogID BIGINT,
          @ProcessLogCreatedMonth TINYINT;
  DECLARE @InfoMessage NVARCHAR(1000);
  DECLARE @ProcessID SMALLINT,
          @IsProcessEnabled BIT;
  EXEC [Config].[GetProcessStateByName] @ProcessName = @ProcessName, @ProcessID = @ProcessID OUTPUT, @IsEnabled = @IsProcessEnabled OUTPUT;
  -- IsEnabled = 0 --
  IF @IsProcessEnabled = 0
    RETURN; -- Nothing to do
  -------------------------------
  -- PROCESS VARS.
  -------------------------------
  DECLARE @Recipients VARCHAR(MAX),
          @ProfileName NVARCHAR(128),
          @BodyFormat VARCHAR(128),
          @Body NVARCHAR(MAX),
          @Subject NVARCHAR(255),
		  @FromAddress NVARCHAR(255);
  ------------------------
  -- CREATE LOG
  ------------------------
  EXEC [Logging].[LogProcessStart] @IsEnabled = @IsProcessEnabled, @ProcessID = @ProcessID,
                                   @ReuseOpenLog = 1,
                                   @ProcessLogID = @ProcessLogID OUTPUT,
                                   @ProcessLogCreatedMonth = @ProcessLogCreatedMonth OUTPUT;
  -- No Log --
  IF @ProcessLogID IS NULL BEGIN;
    SET @ProcessLogID = -1;
    SET @InfoMessage = 'No ProcessLogID was returned from [Logging].[LogProcessStart]. Procedure ' + @ProcedureName + ' terminated.';
    THROW 50000, @InfoMessage, 0;
   END;
  -------------------------------------------------------------------------------------------------
  -- PROCESS
  -------------------------------------------------------------------------------------------------
  ------------------------
  -- TEMP. TABLES -- 
  ------------------------
  IF OBJECT_ID('TempDB..#AlertsToSend') IS NOT NULL 
    DROP TABLE #AlertsToSend;
  CREATE TABLE #AlertsToSend (
    [AlertID] INT NOT NULL,
    [AlertDateTime] DATETIME2(7) NOT NULL,
    [AlertType] VARCHAR(10) NOT NULL,
    [AlertRecipients] NVARCHAR(MAX) NOT NULL,
    [AlertProfile] NVARCHAR(128) NOT NULL,
    [AlertFormat] VARCHAR(20) NOT NULL,
    [AlertSubject] NVARCHAR(128) NOT NULL,
    [AlertMessage] NVARCHAR(MAX) NOT NULL
  );
  DECLARE @AlertToSend TABLE (
    [AlertID] INT NOT NULL,
    [AlertDateTime] DATETIME2(7) NOT NULL,
    [AlertType] VARCHAR(10) NOT NULL,
    [AlertRecipients] NVARCHAR(MAX) NOT NULL,
    [AlertProfile] NVARCHAR(128) NOT NULL,
    [AlertFormat] VARCHAR(20) NOT NULL,
    [AlertSubject] NVARCHAR(128) NOT NULL,
    [AlertMessage] NVARCHAR(MAX) NOT NULL
  );
  ------------------------
  -- COLLECT ALERTS TO SEND
  ------------------------
  INSERT INTO #AlertsToSend (
    AlertID,
    AlertDateTime,
    AlertType,
    AlertRecipients,
    AlertProfile,
    AlertFormat,
    AlertSubject,
    AlertMessage
  ) SELECT AlertID,
           AlertDateTime,
           AlertType,
           AlertRecipients,
           AlertProfile,
           AlertFormat,
           AlertSubject,
           AlertMessage
      FROM [Notification].[Alert] A
     WHERE NOT EXISTS (SELECT 1 FROM [Notification].[AlertSent] NAS WITH (NOLOCK) WHERE AlertID = A.AlertID);
  WHILE EXISTS (SELECT 1 FROM #AlertsToSend) BEGIN;  -- BEGIN Send Iteration
    ------------------------
    -- CLEAR VARS.
    ------------------------
    SELECT @Recipients = NULL,
           @ProfileName = NULL,
           @BodyFormat = NULL,
           @Body = NULL,
           @Subject = NULL,
		   @FromAddress = NULL;
    ------------------------
    -- COLLECT ALERTS TO SEND
    ------------------------
    ;WITH DEL AS (
      SELECT TOP 1 *
	    FROM #AlertsToSend
       ORDER BY AlertID ASC
	)
    DELETE 
      FROM DEL
    OUTPUT Deleted.*
      INTO @AlertToSend;
    ------------------------
    -- SET VARS.
    ------------------------
    SELECT @Recipients = [AlertRecipients],
           @ProfileName = [AlertProfile],
           @BodyFormat = [AlertFormat],
           @Body = [AlertMessage],
           @Subject = [AlertSubject]
      FROM @AlertToSend;
	
	SELECT @FromAddress = [FromAddress]
      FROM [Notification].[SendProfile]
	  WHERE SendType = 'Email' AND ProfileType = 'DEFAULT' AND ProfileName = 'ISAlerts Profile'
    ------------------------
    -- SEND ALERT
    ------------------------
    EXEC [Notification].[SendMail] @Recipients = @Recipients,
                                   @ProfileName = @ProfileName,
                                   @BodyFormat = @BodyFormat,
                                   @Body = @Body,
                                   @Subject = @Subject,
								   @FromAddress = @FromAddress;
    ------------------------
    -- LOG SEND
    ------------------------
    INSERT INTO [Notification].[AlertSent] (
      AlertID,
      SentDate
    )
    SELECT AlertID,
           @NowTime
      FROM @AlertToSend ATS
     WHERE NOT EXISTS (SELECT 1 FROM [Notification].[AlertSent] NAS WHERE AlertID = ATS.AlertID);
    ------------------------
    -- COMPLETE ITERATION
    ------------------------
    DELETE FROM @AlertToSend;
    WAITFOR DELAY '00:00:02';
  END; -- End Send Iteration
  
  ------------------------
  -- COMPLETE LOG -- SUCCESS
  ------------------------
  -- Process
  EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @StatusCode = 1;
  
END TRY
BEGIN CATCH
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  -- CREATE ERROR LOG ENTRIES
  DECLARE @ErrorNumber INTEGER = ERROR_NUMBER(),
          @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
          @ErrorLine INTEGER = ERROR_LINE(),
          @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
  ------------------------
  -- COMPLETE LOG -- ERROR
  ------------------------
  -- PROCESS --
  EXEC [Logging].[LogProcessEnd] @ProcessLogID = @ProcessLogID,
                                 @ProcessLogCreatedMonth = @ProcessLogCreatedMonth,
                                 @StatusCode = 2;
  -- LOG ERROR --
  EXEC [Logging].[LogError] @ProcessID = @ProcessID,
                            @ProcessLogID = @ProcessLogID,
                            @ErrorNumber = @ErrorNumber,
                            @ErrorProcedure = @ErrorProcedure,
                            @ErrorLine = @ErrorLine,
                            @ErrorMessage = @ErrorMessage;
  THROW;
END CATCH;
END;
GO

/* End of File ********************************************************************************************************************/
