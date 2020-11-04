
EXEC sp_MSforeachdb 'USE ? SELECT  DB_NAME(), u.name
FROM    master..syslogins l
        RIGHT JOIN sysusers u ON l.sid = u.sid
WHERE   l.sid IS NULL
        AND issqlrole <> 1
        AND isapprole <> 1
        AND ( u.name <> ''INFORMATION_SCHEMA''
              AND u.name <>   ''guest'' 
              AND u.name <>   ''dbo'' 
              AND u.name <>   ''sys''
              AND u.name <>   ''system_function_schema'' )'