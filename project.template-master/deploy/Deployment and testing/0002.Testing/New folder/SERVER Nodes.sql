IF SERVERPROPERTY ('IsHadrEnabled') = 1
BEGIN
	SELECT	 AGC.name
			,RCS.replica_server_name
			,ARS.role_desc
			,AGL.dns_name
	FROM	sys.availability_groups_cluster AS AGC
	  INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS ON RCS.group_id = AGC.group_id
	  INNER JOIN sys.dm_hadr_availability_replica_states AS ARS ON ARS.replica_id = RCS.replica_id
	  INNER JOIN sys.availability_group_listeners AS AGL ON AGL.group_id = ARS.group_id
	--WHERE ARS.role_desc = 'PRIMARY'
END

DECLARE @IsPrimary BIT =  CASE WHEN CAST((SELECT SERVERPROPERTY ( 'IsHadrEnabled' )) AS BIT) = 0 THEN 1 ELSE 0 END;
      WHILE @IsPrimary = 0
      BEGIN
        SET @IsPrimary = [master].[sys].[fn_hadr_is_primary_replica] ('dbSurge');
        IF @IsPrimary = 0 WAITFOR DELAY '00:01:00';
      END;
