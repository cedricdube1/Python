/***********************************************************************************************************************************
* Script      : 6.Common - Functions - Config.sql                                                                                  *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-10-02                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Config                                                                                                         *
***********************************************************************************************************************************/
USE [dbSurge]
GO

GO
CREATE FUNCTION [Config].[GetJobEnabledByID] (
  @JobID SMALLINT
) RETURNS BIT
BEGIN;
  DECLARE @IsEnabled BIT;
  SELECT @IsEnabled = [IsEnabled]
   FROM [Config].[Job] WITH (NOLOCK)
  WHERE [JobID] = @JobID;
  -- Default / Return --
  RETURN ISNULL(@IsEnabled, 0);
END;
GO
GO
CREATE FUNCTION [Config].[GetJobEnabledByName] (
  @JobName VARCHAR(150)
) RETURNS BIT
BEGIN;
  DECLARE @IsEnabled BIT;
  SELECT @IsEnabled = [IsEnabled]
   FROM [Config].[Job] WITH (NOLOCK)
  WHERE [JobName] = @JobName;
  -- Default / Return --
  RETURN ISNULL(@IsEnabled, 0);
END;
GO
GO
CREATE FUNCTION [Config].[GetJobIDByName] (
  @JobName VARCHAR(150)
) RETURNS SMALLINT
BEGIN;
  DECLARE @JobID SMALLINT;
  SELECT @JobID = [JobID]
   FROM [Config].[Job] WITH (NOLOCK)
  WHERE [JobName] = @JobName;
  -- Default / Return --
  RETURN ISNULL(@JobID, -1);
END;
GO
GO
CREATE FUNCTION [Config].[GetProcessIDByName] (
  @ProcessName VARCHAR(150)
) RETURNS SMALLINT
BEGIN;
  DECLARE @ProcessID SMALLINT;
  SELECT @ProcessID = [ProcessID]
   FROM [Config].[Process] WITH (NOLOCK)
  WHERE [ProcessName] = @ProcessName;
  -- Default / Return --
  RETURN ISNULL(@ProcessID, -1);
END;
GO

GO
CREATE FUNCTION [Config].[GetTaskIDByName] (
  @TaskName VARCHAR(150)
)
  RETURNS SMALLINT
BEGIN;
  DECLARE @TaskID SMALLINT;
  SELECT @TaskID = [TaskID]
   FROM [Config].[Task] WITH (NOLOCK)
  WHERE [TaskName] = @TaskName;
  -- Default / Return --
  RETURN ISNULL(@TaskID, -1);
END;
GO
GO
CREATE FUNCTION [Config].[GetProcessTaskByName] (
  @ProcessID SMALLINT,
  @Taskname VARCHAR(150)
) RETURNS INTEGER
BEGIN;
  DECLARE @ProcessTaskID INT;
  SELECT @ProcessTaskID = [PT].[ProcessTaskID]
   FROM [Config].[ProcessTask] PT WITH (NOLOCK)
  INNER JOIN [Config].[Task] T WITH (NOLOCK)
     ON [PT].[TaskID] = [T].[TaskID]
  WHERE [PT].[ProcessID] = @ProcessID
    AND [T].[Taskname] = @Taskname;
  -- Default / Return --
  RETURN ISNULL(@ProcessTaskID, -1);
END;
GO

GO
CREATE FUNCTION [Config].[GetProcessTaskByID] (
  @ProcessID SMALLINT,
  @TaskID SMALLINT
) RETURNS INTEGER
BEGIN;
  DECLARE @ProcessTaskID INT;
  SELECT @ProcessTaskID = [PT].[ProcessTaskID]
   FROM [Config].[ProcessTask] PT WITH (NOLOCK)
  WHERE [PT].[ProcessID] = @ProcessID
    AND [PT].[TaskID] = @TaskID;
  -- Default / Return --
  RETURN ISNULL(@ProcessTaskID, -1);
END;
GO

GO
CREATE FUNCTION [Config].[GetProcessTaskExtractSourceID] (
  @ProcessTaskID INT,
  @ExtractTypeCode CHAR(3),
  @ExtractObject NVARCHAR(128),
  @TrackedColumn NVARCHAR(128) = NULL
) RETURNS INTEGER
BEGIN;
  DECLARE @TaskExtractSourceID INT;
  SELECT TOP (1) @TaskExtractSourceID = TaskExtractSourceID
   FROM [Config].[ProcessTask] PT WITH (NOLOCK)
  INNER JOIN [Config].[ProcessTaskExtractSource] TS WITH (NOLOCK)
     ON  PT.[ProcessTaskID] = TS.[ProcessTaskID]
  INNER JOIN [Config].[ExtractSource] ES WITH (NOLOCK)
    ON  TS.[ExtractSourceID] = ES.[ExtractSourceID]
  INNER JOIN [Config].[ExtractType] ET WITH (NOLOCK)
    ON  ES.[ExtractTypeID] = ET.[ExtractTypeID]
  WHERE PT.[ProcessTaskID]  = @ProcessTaskID
    AND ET.[ExtractTypeCode] = @ExtractTypeCode
    AND ES.[ExtractObject] = @ExtractObject
	AND (ES.[TrackedColumn] = @TrackedColumn OR @TrackedColumn IS NULL);
  -- Default / Return --
  RETURN ISNULL(@TaskExtractSourceID, -1);
END;
GO
GO
CREATE FUNCTION [Config].[GetVariableIDByname] (
  @ConfigGroupName VARCHAR(150),
  @ConfigName VARCHAR(150)
) RETURNS INT
BEGIN;
  DECLARE @ConfigID INT = NULL;
  -- TASK --
  SELECT @ConfigID = [ConfigID]
    FROM [Config].[vGroupVariable] WITH (NOLOCK)
   WHERE [ConfigGroupName] = @ConfigGroupName
     AND [ConfigName] = @ConfigName;
  -- Return --
  RETURN ISNULL(@ConfigID, -1);
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_AppLock] (
  @ConfigName VARCHAR(150),
  @ObjectName NVARCHAR(128)
) RETURNS INT
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'AppLock'
         ,@ConfigValue VARCHAR(150) = NULL;
  DECLARE @ConfigID INT = [Config].[GetVariableIDByname](@ConfigGroupName, @ConfigName);
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[AppLockVariable] AV WITH (NOLOCK)
  WHERE [ConfigID] = @ConfigID AND [ObjectName] = @ObjectName;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [ConfigDefaultValue]
    FROM [Config].[Variable] WITH (NOLOCK)
    WHERE [ConfigID] = @ConfigID;
  -- Return --
  RETURN @ConfigValue;
END;
GO
GO
CREATE FUNCTION [Config].[GetVariable_Process] (
  @ProcessID SMALLINT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Process'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessID] = @ProcessID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO
GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Extract] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Extract'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_RaiseEvent] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'RaiseEvent'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Stage] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Stage'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Load] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Load'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Held] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Held'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Logging] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Logging'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO
GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Maintenance] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Maintenance'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_ProcessTask_Monitoring] (
  @ProcessTaskID INT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Monitoring'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vProcessTaskVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [ProcessTaskID] = @ProcessTaskID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetVariable_Job] (
  @JobID SMALLINT,
  @ConfigName VARCHAR(150)
) RETURNS VARCHAR(150)
BEGIN;
  DECLARE @ConfigGroupName VARCHAR(150) = 'Job'
         ,@ConfigValue VARCHAR(150) = NULL;
  -- TASK --
  SELECT @ConfigValue = [ConfigValue]
  FROM [Config].[vJobVariable] WITH (NOLOCK)
  WHERE [ConfigGroupName] = @ConfigGroupName AND [ConfigName] = @ConfigName AND [JobID] = @JobID;
  -- DEFAULT --
  IF @ConfigValue IS NULL
    SELECT @ConfigValue = [C].[ConfigDefaultValue]
     FROM [Config].[VariableGroup] CG WITH (NOLOCK)
    INNER JOIN [Config].[Variable] C WITH (NOLOCK)
      ON [CG].[ConfigGroupID] = [C].[ConfigGroupID]
    WHERE [CG].[ConfigGroupName] = @ConfigGroupName AND [C].[ConfigName] = @ConfigName;
  -- Return --
  RETURN @ConfigValue;
END;
GO

GO
CREATE FUNCTION [Config].[GetEarliestNextExecution_JobLoop] (
  @JobID SMALLINT = NULL,
  @InitialDateTime DATETIME = NULL
) RETURNS @JobState TABLE (
   JobID INT NOT NULL,
   WaitForDelayValue VARCHAR(8) NOT NULL,
   EarliestNextExecution DATETIME NOT NULL
  )
AS 
BEGIN;
  SET @InitialDateTime = ISNULL(@InitialDateTime, SYSDATETIME()); -- Intentionally uses system time
  INSERT INTO @JobState (
    JobID,
    WaitForDelayValue,
    EarliestNextExecution
  ) SELECT [JobID],
           [WaitForDelayValue],
           -- ADD SECONDS --
           DATEADD(SECOND, DATEPART(SECOND, CAST([WaitForDelayValue] AS TIME(0))),
	         -- ADD MINUTES --
	         DATEADD(MINUTE, DATEPART(MINUTE, CAST([WaitForDelayValue] AS TIME(0))),
               -- ADD HOURS --
	           DATEADD(HOUR, DATEPART(HOUR, CAST([WaitForDelayValue] AS TIME(0))), @InitialDateTime))) AS [EarliestNextExecution]
       FROM (SELECT [J].[JobID],
                    [J].[JobName],
                    [Config].[GetVariable_Job] ([J].[JobID], 'WaitForDelay') AS [WaitForDelayValue]
               FROM [Config].[Job] [J] WITH (NOLOCK)
              WHERE ([J].[JobID] = @JobID OR @JobID IS NULL)
                AND [J].[IsEnabled] = 1
                AND [J].[IsLoopJob] = 1
                AND [J].[IsRunnable] = 1
                AND [J].[IsControllerJob] = 0) QRY;
  -- Return --
  RETURN;
END;
GO


/* End of File ********************************************************************************************************************/