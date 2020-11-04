
--this query shows SQL's plan in cache memory

SELECT	
	qplan.Query_Plan
,	Stext.text
,	qstats.*
,	plns.*
FROM	
	SYS.DM_EXEC_CACHED_PLANS AS plns
	INNER JOIN 
	SYS.DM_EXEC_QUERY_STATS AS qstats ON plns.Plan_Handle = qstats.plan_handle
	CROSS APPLY 
	SYS.DM_EXEC_QUERY_PLAN(qstats.Plan_Handle) AS qplan
	CROSS APPLY 
	SYS.DM_EXEC_SQL_TEXT(QSTATS.Plan_Handle) AS stext
WHERE	
	Qplan.Query_Plan IS NOT NULL


-- removing a specific SQL plan from cache memory, be careful. 
--SQL Server engine will take time to create plan for the specific query again.
--This is sometimes needed, when engine uses old Statistics for the query.

SELECT 
	plan_handle
, 	st.text  
FROM 
	sys.dm_exec_cached_plans   
	CROSS APPLY 
	sys.dm_exec_sql_text(plan_handle) AS st  
WHERE 
	text LIKE N'%tablename%';
	
DBCC FREEPROCCACHE (<plan_handle, from above query>)

