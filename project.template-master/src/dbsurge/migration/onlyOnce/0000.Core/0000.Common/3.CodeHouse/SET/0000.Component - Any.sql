/************************************************************************
* Script     : 0.Component - Any.sql
* Created By : Cedric Dube
* Created On : 2021-08-17
* Execute On : As required.
* Execute As : N/A
* Execution  : As required.
* Version    : 1.0
* Notes      : Creates CodeHouse template items
* Steps      :1 > ApplockStatement_GetLock
************************************************************************/
USE [dbSurge]
GO
SET NOCOUNT ON;
-------------------------------------
-- AppLockStatement_GetLock
-------------------------------------
DECLARE @Layer VARCHAR(50) = 'Any',
        @Stream VARCHAR(50) = 'Any',
        @StreamVariant VARCHAR(50) = 'Any',
        @CodeObjectName NVARCHAR(128) = 'AppLockStatement_GetLock',
        @VersionType CHAR(5) = 'Major',
        @ObjectType VARCHAR(50) = 'Component',
        @CodeType VARCHAR(50) = 'Process',
        @Author NVARCHAR(128) = 'Cedric Dube',
        @Remark VARCHAR(1000) = 'Initial Development',
        @CodeObjectRemark NVARCHAR(2000),
        @CodeObjectHeader NVARCHAR(2000),
        @CodeObjectExecutionOptions NVARCHAR(1000),
        @CodeObject NVARCHAR(MAX),
        @Action VARCHAR(6) = 'I',
        @CodeObjectID INT;

SET @CodeObjectRemark = 
'Standard CODE block for handling sp_GetAppLock in any layer Process for Procedures.';

SET @CodeObject = 
'  -- GET THE APP. LOCK --
      SET @AppLockAttempts = 0;
      SET @AppLockRetry = [Config].[GetVariable_AppLock](''Retry'', @TargetObject);
      SET @AppLockTimeout = [Config].[GetVariable_AppLock](''Timeout'', @TargetObject);
      WHILE @AppLockAttempts <= @AppLockRetry BEGIN;
        EXEC @AppLockResult = [sp_GetAppLock] @Resource = @TargetObject, @LockMode = ''Exclusive'', @LockTimeout = @AppLockTimeout;
        IF @AppLockResult >= 0 BREAK;
        IF (@AppLockAttempts = @AppLockRetry AND @AppLockResult < 0) BEGIN;
          SET @InfoMessage = ''Failed to acquire an Application Lock on object '' + @TargetObject;
          THROW 50000, @InfoMessage, 0;
        END;
        SET @AppLockAttempts = @AppLockAttempts + 1;
      END;    ';
EXEC [CodeHouse].[SetCodeObject] @Layer = @Layer,
                                 @Stream = @Stream,
                                 @StreamVariant = @StreamVariant,
                                 @CodeObjectName = @CodeObjectName,
                                 @VersionType = @VersionType,
                                 @ObjectType = @ObjectType,
                                 @CodeType = @CodeType,
                                 @Author = @Author,
                                 @Remark = @Remark,
                                 @CodeObjectRemark = @CodeObjectRemark,
                                 @CodeObjectHeader = @CodeObjectHeader,
                                 @CodeObjectExecutionOptions = @CodeObjectExecutionOptions,
                                 @CodeObject = @CodeObject,
                                 @Action = @Action,
                                 @CodeObjectID = @CodeObjectID OUTPUT;
SELECT * FROM [CodeHouse].[vCodeObject] WHERE [CodeObjectID] = @CodeObjectID;
GO

/* End of File ********************************************************************************************************************/