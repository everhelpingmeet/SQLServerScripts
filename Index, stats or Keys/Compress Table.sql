--Compress all the indexes on a table
ALTER INDEX ALL ON
dbo.Applications
REBUILD
WITH ( SORT_IN_TEMPDB = ON, DATA_COMPRESSION = PAGE);;

