--Using sp_spaceused to check free space in SQL Server

User<DbName>;
EXEC sp_spaceused N'<tableName>';

--Using DBCC SQLPERF to check free space for a SQL Server database

USE master 
GO 

DBCC SQLPERF(logspace) 

--Size of the database

use <DBname>;
EXEC sp_spaceused;

--Brief Details of a DB

EXEC sp_helpdb '<dbname>';
EXEC sp_databases;

--To check details of a table, indexes

sp_help <tablename>

--Page Details
DBCC IND ('<dbname>', '<tablename>', -1);

--to check the extents information
DBCC showfilestats

--Check who all are connected

sp_who
--or
sp_who2

