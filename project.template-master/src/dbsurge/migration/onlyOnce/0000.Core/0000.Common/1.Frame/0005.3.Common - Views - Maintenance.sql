/***********************************************************************************************************************************
* Script      : 5.Common - Views - Maintenance.sql                                                                                 *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2020-01-27                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script once.                                                                                                *
* Version     : 1.0                                                                                                                *
* Steps       :  1. Partitioning                                                                                                   *
***********************************************************************************************************************************/
USE [dbSurge]
GO


-- Summary --
GO
CREATE OR ALTER VIEW [Maintenance].[vPartitionSummary]
AS
  SELECT S.[Name] AS SchemaName,
         T.[Name] AS Tablename,
         I.[Name] AS PrimaryKeyName,
         PS.[Name] AS PartitionScheme,
         FG.[Name] AS PartitionFileGroup,
         CASE WHEN PF.[Name] LIKE '%Date' THEN 'Date'
              WHEN PF.[Name] LIKE '%Month' THEN 'Month'
              WHEN PF.[Name] LIKE '%Year' THEN 'Year'
              WHEN PF.[Name] LIKE '%MonthNumber' THEN 'MonthNumber'
              WHEN PF.[Name] LIKE '%SourceSystemID' THEN 'SourceSystemID'
         ELSE 'Unknown' END AS PartitionFunctionGroup,
         CASE WHEN PF.[Boundary_Value_On_Right] = 1 THEN 'Right'
         ELSE 'Left' END AS PartitionFunctionRangeDirection,
         PF.[Name] AS PartitionFunction,
         C.[Name] AS PartitionColumn,
         ST.[Name] AS PartitionColumnDataType,
         MIN(PRV.[Value]) AS LowestPartitionValue,
         MAX(PRV.[Value]) AS HighestPartitionValue,
         MIN(P.[Partition_Number]) AS LowestPartitionNumber,
         MAX(P.[Partition_Number]) AS HighestPartitionNumber
    FROM SYS.Tables T WITH (NOLOCK)
   INNER JOIN SYS.Schemas S WITH (NOLOCK)
      ON T.Schema_ID = S.Schema_ID
   INNER JOIN SYS.Indexes I WITH (NOLOCK)
      ON T.Object_ID = I.Object_ID
   INNER JOIN SYS.Index_Columns IC WITH (NOLOCK)
      ON I.Object_ID = IC.Object_ID
     AND I.Index_ID = IC.Index_ID
     AND IC.partition_ordinal = 1 -- Partioning Column only
   LEFT JOIN SYS.Columns C WITH (NOLOCK)
      ON IC.Object_ID = C.Object_ID
     AND IC.Column_ID = C.Column_ID
   LEFT JOIN SYS.Types ST WITH (NOLOCK)
      ON C.System_Type_ID = ST.System_Type_ID
   LEFT JOIN SYS.Partitions P WITH (NOLOCK)
      ON I.Object_ID = P.Object_ID
     AND I.Index_ID = P.Index_ID
   LEFT JOIN SYS.Partition_Schemes PS  WITH (NOLOCK)
     ON I.Data_Space_ID = PS.Data_Space_ID
   LEFT JOIN SYS.Partition_Functions PF WITH (NOLOCK)
     ON PS.Function_ID = PF.Function_ID
   LEFT JOIN SYS.Destination_Data_Spaces DDS WITH (NOLOCK)
     ON PS.Data_Space_ID = DDS.Partition_Scheme_ID 
    AND P.Partition_Number = DDS.Destination_ID
   LEFT JOIN SYS.FileGroups FG WITH (NOLOCK)
     ON DDS.Data_Space_ID = FG.Data_Space_ID
   LEFT JOIN SYS.Partition_Range_Values PRV WITH (NOLOCK)
     ON PF.Function_ID = PRV.Function_ID
   WHERE I.Is_Primary_Key = 1
   GROUP BY S.[Name], 
            T.[Name], 
            I.[Name],
            PS.[Name],
            PF.[Name],
            C.[Name],
            ST.[Name],
            FG.[Name],
            CASE WHEN PF.[Name] LIKE '%Date' THEN 'Date'
                 WHEN PF.[Name] LIKE '%Month' THEN 'Month'
                 WHEN PF.[Name] LIKE '%Year' THEN 'MonthNumber'
                 WHEN PF.[Name] LIKE '%MonthNumber' THEN 'Year'
                 WHEN PF.[Name] LIKE '%SourceSystemID' THEN 'SourceSystemID'
            ELSE 'Unknown' END,
            CASE WHEN PF.[Boundary_Value_On_Right] = 1 THEN 'Right'
            ELSE 'Left' END;
GO

/* End of File ********************************************************************************************************************/
