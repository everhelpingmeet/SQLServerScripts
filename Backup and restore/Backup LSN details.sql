
--Backup LSN details

select 
	database_name 
,	type
,	backup_start_date
,	backup_finish_date
,	first_lsn
,	last_lsn
,	checkpoint_lsn
,	database_backup_lsn
,	backup_set_id
from 
	msdb..backupset 
where 
--	type = 'D' 
	database_name = 'pq'
--and checkpoint_lsn = 24706000013526800000
--in ('L','D')
order by backup_start_date desc

