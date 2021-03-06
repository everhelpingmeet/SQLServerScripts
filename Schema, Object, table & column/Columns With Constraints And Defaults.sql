--Find Columns With Constraints And Defaults
SELECT	
	ST.[name] AS TableName,
	SC.[name] AS ColumnName,
	SD.definition AS DefaultValue,
	SD.[name] AS ConstraintName
FROM	
	sys.tables ST
	INNER JOIN 
	sys.columns SC ON ST.[object_id] = SC.object_id
	INNER JOIN 
	sys.default_constraints SD ON ST.[object_id] = SD.[parent_object_id] AND SC.column_Id = SD.parent_column_id 
ORDER BY 
	ST.[name]
, 	SC.column_Id;