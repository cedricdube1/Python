/****************************************************************************************************************************
* Script      : 4.Notification - Functions.sql                                                                              *
* Created By  : Cedric Dube                                                                                                   *
* Created On  : 2021-03-02                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE FUNCTION [Notification].[GetRecipientList] (
  @SendType VARCHAR(10)
) RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Recipient AS TABLE (
    Recipient NVARCHAR(80)
  );
  IF @SendType = 'SMS' BEGIN;
    --DECLARE @SMSProvider CHAR(13) = (SELECT SendProvider FROM [Notification].[SendProfile] WITH (NOLOCK) WHERE ProfileType = 'DEFAULT' AND SendType = @SendType); 
    --INSERT INTO @Recipient 
    --SELECT DISTINCT
    --       LTRIM(RTRIM(MobileNumber)) + '@' + @SMSProvider
    --FROM [Notification].[Recipient] WITH (NOLOCK)
    --WHERE SendSMS = 1 AND LEN(MobileNumber) = 11;
	INSERT INTO @Recipient
    SELECT DISTINCT
           LTRIM(RTRIM(EMailAddress))
    FROM [Notification].[Recipient] WITH (NOLOCK)
    WHERE SendSMS = 1;
  END;
  IF @SendType = 'EMail' BEGIN;
    INSERT INTO @Recipient
    SELECT DISTINCT
           LTRIM(RTRIM(EMailAddress))
    FROM [Notification].[Recipient] WITH (NOLOCK)
    WHERE SendEMail = 1;
  END; 
  DECLARE @RecipientList NVARCHAR(MAX) = ( SELECT DISTINCT
                                                  STUFF(
                                                          ( SELECT DISTINCT
                                                                   '; ' + LTRIM(RTRIM(t1.Recipient))
                                                              FROM @Recipient t1
                                                                FOR XML PATH(''), TYPE
                                                           ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
                                                         ) ToRecipient
                                               FROM @Recipient);
  
  RETURN @RecipientList;
END;
GO

/* End of File ********************************************************************************************************************/