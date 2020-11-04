--Identify Deadlock

select * from sys.sysprocesses where blocked <> 0;

--Blocking 

SELECT 
	t1.resource_type
,	t1.resource_database_id
,	t1.resource_associated_entity_id
,	t1.request_mode
,	t1.request_session_id
,	t2.blocking_session_id
FROM	
	sys.dm_tran_locks as t1
	INNER JOIN 
	sys.dm_os_waiting_tasks as t2 ON t1.lock_owner_address = t2.resource_address;

	
--Size of the tables

SELECT
	s.Name AS SchemaName
,	t.Name AS TableName
,	p.rows AS RowCounts
,	CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB
,	CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB
,	CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB
FROM 
	sys.tables t
	INNER JOIN 
	sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
	sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN 
	sys.allocation_units a ON p.partition_id = a.container_id
	INNER JOIN 
	sys.schemas s ON t.schema_id = s.schema_id
GROUP BY 
	t.Name 
,	s.Name 
,	p.Rows
ORDER BY 
	s.Name
, 	t.Name
GO

--To check free space in database

SELECT 
	[file_id] AS [File ID]
,   [type] AS [File Type]
,   substring([physical_name],1,1) AS [Drive]
,   [name] AS [Logical Name]
,   [physical_name] AS [Physical Name]
,   CAST([size] as DECIMAL(38,0))/128. AS [File Size MB]
,   CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128. AS [Space Used MB]
,   (CAST([size] AS DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.) AS [Free Space]
,   [max_size] AS [Max Size]
,   [is_percent_growth] AS [Percent Growth Enabled]
,   [growth] AS [Growth Rate]
,   SYSDATETIME() AS [Current Date]
FROM 
	sys.database_files;
	
--another SQL for checking free space

SELECT 
	DB_NAME(database_id) AS DatabaseName
,	CAST([Name] AS varchar(20)) AS NameofFile
,	CAST(physical_name AS varchar(100)) AS PhysicalFile
,	type_desc AS FileType
,	((size * 8)/1024) AS FileSize
,	MaxFileSize = CASE 
		WHEN max_size = -1 OR max_size = 268435456 THEN 'UNLIMITED'
		WHEN max_size = 0 THEN 'NO_GROWTH'
		WHEN max_size <> -1 OR max_size <> 0 THEN CAST(((max_size * 8) / 1024) AS varchar(15))
	ELSE 'Unknown'
	END
,	SpaceRemainingMB = CASE 
		WHEN max_size = -1 OR max_size = 268435456 THEN 'UNLIMITED'
		WHEN max_size <> -1 OR max_size = 268435456 THEN CAST((((max_size - size) * 8) / 1024) AS varchar(10))
	ELSE 'Unknown'
	END
,	Growth = CASE 
		WHEN growth = 0 THEN 'FIXED_SIZE'
		WHEN growth > 0 THEN ((growth * 8)/1024)
	ELSE 'Unknown'
	END
,	GrowthType = CASE 
		WHEN is_percent_growth = 1 THEN 'PERCENTAGE'
		WHEN is_percent_growth = 0 THEN 'MBs'
	ELSE 'Unknown'
	END
FROM 
	master.sys.master_files
WHERE 
	state = 0
AND type_desc IN ('LOG', 'ROWS')
ORDER BY 
	database_id, file_id

--To Check drive space

SELECT DISTINCT
	vs.volume_mount_point AS [Drive]
,  	vs.logical_volume_name AS [Drive Name]
,  	vs.total_bytes/1024/1024 AS [Drive Size MB]
,  	vs.available_bytes/1024/1024 AS [Drive Free Space MB]
FROM 
	sys.master_files AS f
	CROSS APPLY 
	sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
ORDER BY 
	vs.volume_mount_point;

--Partition tables

select 
	obj.name 
from 
	sys.objects obj
, 	sys.partitions prt
where 
	obj.object_id = prt.object_id;
	
--to check the SQL running for a plan_handle

SELECT 
	sql_handle 
FROM 
	sys.dm_exec_requests 
WHERE 
	session_id = 59  -- modify this value with your actual spid and pass sql_handle in below query

-- to see the text of sql_handle pass sql_handle to sys.dm_exec_sql_text

SELECT 
	* 
FROM 
	sys.dm_exec_sql_text(0x01000600B74C2A1300D2582A2100000000000000000000000000000000000000000000000000000000000000) -- modify this value with your actual sql_handle

--SQL Server services uptime

SELECT sqlserver_start_time FROM sys.dm_os_sys_info

--Check Backup Details

SELECT 
	database_name AS DBName
,	physical_device_name AS BackupLocation
,	CASE WHEN [TYPE]='D' THEN 'FULL'
		WHEN [TYPE]='I' THEN 'DIFFERENTIAL'
		WHEN [TYPE]='L' THEN 'LOG'
		WHEN [TYPE]='F' THEN 'FILE / FILEGROUP'
		WHEN [TYPE]='G'  THEN 'DIFFERENTIAL FILE'
		WHEN [TYPE]='P' THEN 'PARTIAL'
		WHEN [TYPE]='Q' THEN 'DIFFERENTIAL PARTIAL'
	END AS BackupType
,	backup_finish_date AS BackupFinishDate
FROM 
	msdb.dbo.backupset 
	JOIN 
	msdb.dbo.backupmediafamily ON(backupset.media_set_id=backupmediafamily.media_set_id)
--Where database_name Like '<dbname>'
ORDER BY backup_finish_date DESC

--Check is backup chain is broken, if NULL is returned, the chain is broken

SELECT 
	db_name(database_id) AS 'database'
, 	last_log_backup_lsn 
FROM 
	sys.database_recovery_status 
WHERE 
	database_id = db_id('<dbName>')
and database_id > 4

--Information of database

DBCC DBINFO('User') WITH TABLERESULTS

--to find any user created table in system databases manually

SELECT  
	*
FROM    
	msdb.sys.tables --change msdb to master, tempdb or model as required
WHERE   
	is_ms_shipped = 0 
AND name NOT LIKE '%DTA_%';


 
 -- FIND ACTIVE CLUSTER NODE NAME IN SQL SERVER CLUSTER
 SELECT CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS VARCHAR(50))
		AS PhysicalServerName
		
-- Find Active Sessions
SELECT
	r.session_id
,	r.blocking_session_id
, 	s.program_name
, 	s.host_name
, 	s.login_name
, 	s.login_time
, 	t.text
FROM	
	sys.dm_exec_requests AS r
	INNER JOIN 
	sys.dm_exec_sessions AS s on r.session_id = s.session_id
	CROSS APPLY 
	sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE	
	s.is_user_process = 1
AND	r.session_id <> @@SPID -- NOT MY SPID RUNNING THIS QUERY
--AND		s.login_name = 'NQCORP\ChappellO'

--to find all dmv's

SELECT	'sys.' + name AS DmvName
FROM	sys.system_objects 
WHERE	name LIKE 'dm%';
GO 

--DB file growth size

SELECT   'Database Name' = DB_NAME(database_id)
,'FileName' = NAME
,FILE_ID
,'size' = CONVERT(NVARCHAR(15), CONVERT(BIGINT, size) * 8) + N' KB'
,'maxsize' = (
CASE max_size
WHEN - 1
THEN N'Unlimited'
ELSE CONVERT(NVARCHAR(15), CONVERT(BIGINT, max_size) * 8) + N' KB'
END
)
,'growth' = (
CASE is_percent_growth
WHEN 1
THEN CONVERT(NVARCHAR(15), growth) + N'%'
ELSE CONVERT(NVARCHAR(15), CONVERT(BIGINT, growth) * 8) + N' KB'
END
)
,'type_desc' = type_desc
FROM sys.master_files
ORDER BY database_id

--find permission granter

select  princ.name
,       princ.type_desc
,       perm.permission_name
,       perm.state_desc
,       perm.class_desc
,		OBJECT_SCHEMA_NAME((perm.major_id)) AS 'SchemaName'
,       object_name(perm.major_id) AS 'ObjectName'
,		perm.grantor_principal_id
,		dp.name
,		perm.*
from    sys.database_principals princ
	LEFT JOIN sys.database_permissions perm on perm.grantee_principal_id = princ.principal_id
	LEFT JOIN sys.database_principals as dp on perm.grantor_principal_id = dp.principal_id

--to kill existing sessions
	
-- check for blocking
use master
select distinct(blocked) from sysprocesses where blocked <> 0

-- check if the blocking is blocked
select blocked from sysprocesses where spid =   

-- check the command
dbcc inputbuffer (106) -- change the spid to blocker

-- if the blocker executing a select statement the spid can be safely killed
kill 106  -- change the spid to blocker


--Generate commands for granting role at database level
--you will get the output printed, run those commands. Start with only 1.

Use master
GO

DECLARE @dbname VARCHAR(50)   
DECLARE @statement NVARCHAR(max)

DECLARE db_cursor CURSOR 
LOCAL FAST_FORWARD
FOR  
SELECT name
FROM MASTER.dbo.sysdatabases
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbname  
WHILE @@FETCH_STATUS = 0  
BEGIN  

--change below as per need
SELECT @statement = 'use '+@dbname +';'+ 'CREATE USER [<username>] 
FOR LOGIN [<username>]; EXEC sp_addrolemember N''db_datareader'',[<username>];'

print @statement

FETCH NEXT FROM db_cursor INTO @dbname  
END  
CLOSE db_cursor  
DEALLOCATE db_cursor

--To check Users added to AD group

EXEC xp_logininfo 'NMPC\WiPro SQL DBAs', 'members' 