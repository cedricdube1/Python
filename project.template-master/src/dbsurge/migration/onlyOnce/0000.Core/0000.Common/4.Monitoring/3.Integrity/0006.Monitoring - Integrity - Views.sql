/****************************************************************************************************************************
* Script      : 5.Monitoring - Views.sql                                                                                    *
* Created By  : Lyle Ward/Ntokozo Mashaba                                                                                   *
* Created On  : 2021-03-02                                                                                                  *
* Execute On  : As required.                                                                                                *
* Execute As  : N/A                                                                                                         *
* Execution   : Entire script once.                                                                                         *
* Version     : 1.0                                                                                                         *
****************************************************************************************************************************/
USE [dbSurge]
GO
GO
CREATE VIEW [Monitoring].[vIntegrityObject]
AS
 SELECT IOJ.[DatabaseName],
		IOJ.[SchemaName],
		IOJ.[ObjectName],
		IOC.[ColumnName],
		IOC.[IsParameter]
  FROM [Monitoring].[IntegrityObject] IOJ WITH (NOLOCK)
 INNER JOIN [Monitoring].[IntegrityObjectColumn] IOC WITH (NOLOCK)
    ON IOJ.[IntegrityObjectID] = IOC.[IntegrityObjectID];
GO

GO
CREATE VIEW [Monitoring].[vIntegrityCompareObject]
AS
 SELECT ICO.[IntegrityCompareObjectID],
        ICO.[IsEnabled],
		IO_A.[IntegrityObjectID] AS [IntegrityObjectID_A],
		IO_B.[IntegrityObjectID] AS [IntegrityObjectID_B],
		IOC_A.[IntegrityObjectColumnID] AS [IntegrityObjectColumnID_A],
		IOC_B.[IntegrityObjectColumnID] AS [IntegrityObjectColumnID_B],
        IO_A.[DatabaseName] AS [DatabaseName_A],
		IO_B.[DatabaseName] AS [DatabaseName_B],
		IO_A.[SchemaName] AS [SchemaName_A],
		IO_B.[SchemaName] AS [SchemaName_B],
		IO_A.[ObjectName] AS [ObjectName_A],
		IO_B.[ObjectName] AS [ObjectName_B],
		IOC_A.[ColumnName] AS [ColumnName_A],
		IOC_B.[ColumnName] AS [ColumnName_B],
		IOC_A.[IsParameter] AS [IsParameter_A],
		IOC_B.[IsParameter] AS [IsParameter_B]
  FROM [Monitoring].[IntegrityCompareObject] ICO WITH (NOLOCK)
 INNER JOIN [Monitoring].[IntegrityObject] IO_A WITH (NOLOCK)
    ON ICO.[IntegrityObjectID_A] = IO_A.[IntegrityObjectID]
 INNER JOIN [Monitoring].[IntegrityObject] IO_B WITH (NOLOCK)
    ON ICO.[IntegrityObjectID_B] = IO_B.[IntegrityObjectID]
 INNER JOIN [Monitoring].[IntegrityObjectColumn] IOC_A WITH (NOLOCK)
    ON ICO.[IntegrityObjectColumnID_A] = IOC_A.[IntegrityObjectColumnID]
 INNER JOIN [Monitoring].[IntegrityObjectColumn] IOC_B WITH (NOLOCK)
    ON ICO.[IntegrityObjectColumnID_B] = IOC_B.[IntegrityObjectColumnID];
GO

GO
CREATE VIEW [Monitoring].[vIntegrityAlert]
AS
 SELECT I.[InsertDate],
        I.[IntegrityParameters],
        I.[AlertID],
		I.[ValueAExceptB],
		I.[ValueBExceptA],
		I.[CheckQuery],
		IOJ_A.[IntegrityObjectID] AS [IntegrityObjectID_A],
		IOJ_B.[IntegrityObjectID] AS [IntegrityObjectID_B],
		IOJ_A.[DatabaseName] AS [DatabaseName_A],
		IOJ_A.[SchemaName] AS [SchemaName_A],
		IOJ_A.[ObjectName] AS [ObjectName_A],
		IOJ_B.[DatabaseName] AS [DatabaseName_B],
		IOJ_B.[SchemaName] AS [SchemaName_B],
		IOJ_B.[ObjectName] AS [ObjectName_B]
  FROM [Monitoring].[Integrity] I WITH (NOLOCK)
 INNER JOIN [Monitoring].[IntegrityObject] IOJ_A WITH (NOLOCK)
    ON I.[IntegrityObjectID_A] = IOJ_A.[IntegrityObjectID]
 INNER JOIN [Monitoring].[IntegrityObject] IOJ_B WITH (NOLOCK)
    ON I.[IntegrityObjectID_B] = IOJ_B.[IntegrityObjectID];
GO
/* End of File ********************************************************************************************************************/