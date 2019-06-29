alter function dbo.fn_FKScripted (
--anil nair
--2019-06-29
--generate foreign key constraint scripting of given/all table(s)


	@schema sysname = null
	, @table sysname = null
	, @constraint sysname = null
)
returns @tab table (schemaName sysname, tableName sysname, constraintName sysname, dropConstraintScript varchar(max), createConstraintScript varchar(max), noCheckConstraintScript varchar(max), checkConstraintScript varchar(max))
as
begin
	insert into @tab (
		schemaName, tableName, constraintName, dropConstraintScript, createConstraintScript, noCheckConstraintScript, checkConstraintScript
	)
	select 
	SCHEMA_NAME(t1.schema_id) as SchemaName 
	, OBJECT_NAME(fkc.parent_object_id) as TableName
	, fk.[name] as ConstraintName
	, CONCAT('alter table ', quotename(SCHEMA_NAME(t1.schema_id)), '.',  quotename(OBJECT_NAME(fkc.parent_object_id)), ' drop constraint ', QUOTENAME(fk.[name]), ';') as DropConstraint
	, CONCAT('alter table ', quotename(SCHEMA_NAME(t1.schema_id)), '.',  quotename(OBJECT_NAME(fkc.parent_object_id)), ' with check add constraint ', QUOTENAME(fk.[name]), ' foreign key (', c1.ParentColumns, ') references ', QUOTENAME(schema_name(t2.schema_id)), '.', QUOTENAME(object_name(fkc.referenced_object_id)), '(', c2.ReferencedColumns, '); alter table ', quotename(SCHEMA_NAME(t1.schema_id)), '.',  quotename(OBJECT_NAME(fkc.parent_object_id)), ' CHECK CONSTRAINT ', QUOTENAME(fk.[name]), ';') as CreateConstraint
	, CONCAT('ALTER TABLE ', quotename(SCHEMA_NAME(t1.schema_id)), '.',  quotename(OBJECT_NAME(fkc.parent_object_id)), ' nocheck constraint ', QUOTENAME(fk.[name]), ';') as NoCheckConstraint
	, CONCAT('ALTER TABLE ', quotename(SCHEMA_NAME(t1.schema_id)), '.',  quotename(OBJECT_NAME(fkc.parent_object_id)), ' check constraint ', QUOTENAME(fk.[name]), ';') asCheckConstraint
	 from sys.foreign_keys fk 
	  inner join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
	  cross apply (
		select STUFF (
			(
				SELECT ',' + c1.name
				FROM sys.columns as c1
				where c1.object_id=fkc.parent_object_id and c1.column_id=fkc.parent_column_id
				FOR XML PATH('')
				), 1, 1, ''
			)
		) AS c1(ParentColumns)
		cross apply (
			select STUFF(
				(
					select ',' + c2.[name]
					from sys.columns as c2
					where c2.object_id=fkc.referenced_object_id and c2.column_id=fkc.referenced_column_id
					for XML path('')
				), 1, 1, ''
			)
		) as c2(ReferencedColumns)
	  inner join sys.tables t1 on t1.object_id=fkc.parent_object_id 
	  inner join sys.tables t2 on t2.object_id=fkc.referenced_object_id 
	where ((@schema is null) or @schema in (SCHEMA_NAME(t1.schema_id), schema_NAME(t2.schema_id)))
		and ((@table is null) or @table in (OBJECT_NAME(fkc.parent_object_id), OBJECT_NAME(fkc.referenced_object_id)))
		and ((@constraint is null) or @constraint = fk.[name])
	return;
end
