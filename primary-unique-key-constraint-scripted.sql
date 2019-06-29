alter function dbo.fn_IXScripted (
--anil nair
--2019-06-29
--generate index scripting of given/all table(s)
 
	@schema sysname = null
	,@table sysname = null
	,@constraint sysname = null
)
returns @tab table (schemaName sysname, tableName sysname, constraintName sysname, dropConstraint varchar(max), createConstraint varchar(max))
as
begin
insert into @tab (schemaName, tableName, constraintName, dropConstraint, createConstraint)
select [schema_name], tableName, IndexName
	, case when is_primary_key = 1 
	then concat('alter table ', quotename([schema_name]), '.', QUOTENAME(tableName), ' drop constraint ', quotename(indexName), ';') 
	else 
		case when is_disabled = 1 then CONCAT('--already disabled index ', IndexName, ' on ', QUOTENAME([schema_name]), '.', quotename(tablename), ';') else 
		CONCAT('alter index ', quotename([schema_name]), '.', QUOTENAME(indexname), ' on ', QUOTENAME(tableName), ' disable;') end
	end as DropConstraint
	, case when is_primary_key = 1
	then CONCAT(
	'alter table ', quotename([schema_name]), '.', quotename(tableName), ' add constraint ', quotename(IndexName), UQ_Text, PK_Text, [type_desc] collate Latin1_General_CI_AS_KS_WS, ' (', IncludedColumns, ') WITH (', IndexOptions, ') on ', quotename(FileGroupName), ';')
	else 
		CONCAT('alter table ',  QUOTENAME(indexname), ' on ', quotename([schema_name]), '.', QUOTENAME(tableName), ' enable;')
	end as CreateIndex
from (
select c1.includedColumns, schema_name(t.schema_id) as [schema_name], t.name as tableName, ix.name as IndexName,ix.is_primary_key, ix.IS_DISABLED, 
 case when ix.is_unique_constraint = 1 then ' UNIQUE ' else '' END as UQ_Text
    , case when ix.is_primary_key = 1 then ' PRIMARY KEY ' else '' END as PK_Text
 , ix.type_desc
 , CONCAT(case when ix.is_padded=1 then 'PAD_INDEX = ON, ' else 'PAD_INDEX = OFF, ' end
 , case when ix.allow_page_locks=1 then 'ALLOW_PAGE_LOCKS = ON, ' else 'ALLOW_PAGE_LOCKS = OFF, ' end
 , case when ix.allow_row_locks=1 then  'ALLOW_ROW_LOCKS = ON, ' else 'ALLOW_ROW_LOCKS = OFF, ' end
 , case when INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1 then 'STATISTICS_NORECOMPUTE = ON, ' else 'STATISTICS_NORECOMPUTE = OFF, ' end
 , case when ix.ignore_dup_key=1 then 'IGNORE_DUP_KEY = ON, ' else 'IGNORE_DUP_KEY = OFF, ' end
 , 'SORT_IN_TEMPDB = OFF, FILLFACTOR = ' , case when ix.fill_factor = 0 then 100 else ix.fill_factor end) AS IndexOptions
 , FILEGROUP_NAME(ix.data_space_id) FileGroupName
 from sys.tables t 
 inner join sys.indexes ix on t.object_id=ix.object_id
 cross apply (
	select STUFF(
		(select concat(N',', col.name)
			from sys.index_columns as ixc
			join sys.columns as col on ixc.object_id = col.object_id and ixc.column_id=col.column_id
			where ixc.object_id=ix.object_id and ixc.index_id = ix.index_id
			for XML path('')
		), 1, 1, '')
) as c1 (IncludedColumns)
 where ix.type >  0 
 --and  (ix.is_primary_key = 1 or ix.is_unique_constraint = 1) 
 and t.is_ms_shipped = 0 and t.name <> 'sysdiagrams'
 and ((@schema is null) or schema_name(t.schema_id) = @schema)
 and ((@table is null) or t.name = @table)
 and ((@constraint is null) or ix.name = @constraint)
 ) as a
 return;
 end

--select * from dbo.fn_IXScripted (null, 'ServiceBase', null);
alter function dbo.fn_IXScripted (  
	@schema sysname = null
	,@table sysname = null
	,@constraint sysname = null
)
returns @tab table (schemaName sysname, tableName sysname, constraintName sysname, dropConstraint varchar(max), createConstraint varchar(max))
as
begin
insert into @tab (schemaName, tableName, constraintName, dropConstraint, createConstraint)
select [schema_name], tableName, IndexName
	, case when is_primary_key = 1 
	then concat('alter table ', quotename([schema_name]), '.', QUOTENAME(tableName), ' drop constraint ', quotename(indexName), ';') 
	else 
		case when is_disabled = 1 then CONCAT('--already disabled index ', IndexName, ' on ', QUOTENAME([schema_name]), '.', quotename(tablename), ';') else 
		CONCAT('alter index ', quotename([schema_name]), '.', QUOTENAME(indexname), ' on ', QUOTENAME(tableName), ' disable;') end
	end as DropConstraint
	, case when is_primary_key = 1
	then CONCAT(
	'alter table ', quotename([schema_name]), '.', quotename(tableName), ' add constraint ', quotename(IndexName), UQ_Text, PK_Text, [type_desc] collate Latin1_General_CI_AS_KS_WS, ' (', IncludedColumns, ') WITH (', IndexOptions, ') on ', quotename(FileGroupName), ';')
	else 
		CONCAT('alter table ',  QUOTENAME(indexname), ' on ', quotename([schema_name]), '.', QUOTENAME(tableName), ' enable;')
	end as CreateIndex
from (
select c1.includedColumns, schema_name(t.schema_id) as [schema_name], t.name as tableName, ix.name as IndexName,ix.is_primary_key, ix.IS_DISABLED, 
 case when ix.is_unique_constraint = 1 then ' UNIQUE ' else '' END as UQ_Text
    , case when ix.is_primary_key = 1 then ' PRIMARY KEY ' else '' END as PK_Text
 , ix.type_desc
 , CONCAT(case when ix.is_padded=1 then 'PAD_INDEX = ON, ' else 'PAD_INDEX = OFF, ' end
 , case when ix.allow_page_locks=1 then 'ALLOW_PAGE_LOCKS = ON, ' else 'ALLOW_PAGE_LOCKS = OFF, ' end
 , case when ix.allow_row_locks=1 then  'ALLOW_ROW_LOCKS = ON, ' else 'ALLOW_ROW_LOCKS = OFF, ' end
 , case when INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1 then 'STATISTICS_NORECOMPUTE = ON, ' else 'STATISTICS_NORECOMPUTE = OFF, ' end
 , case when ix.ignore_dup_key=1 then 'IGNORE_DUP_KEY = ON, ' else 'IGNORE_DUP_KEY = OFF, ' end
 , 'SORT_IN_TEMPDB = OFF, FILLFACTOR = ' , case when ix.fill_factor = 0 then 100 else ix.fill_factor end) AS IndexOptions
 , FILEGROUP_NAME(ix.data_space_id) FileGroupName
 from sys.tables t 
 inner join sys.indexes ix on t.object_id=ix.object_id
 cross apply (
	select STUFF(
		(select concat(N',', col.name)
			from sys.index_columns as ixc
			join sys.columns as col on ixc.object_id = col.object_id and ixc.column_id=col.column_id
			where ixc.object_id=ix.object_id and ixc.index_id = ix.index_id
			for XML path('')
		), 1, 1, '')
) as c1 (IncludedColumns)
 where ix.type >  0 
 --and  (ix.is_primary_key = 1 or ix.is_unique_constraint = 1) 
 and t.is_ms_shipped = 0 and t.name <> 'sysdiagrams'
 and ((@schema is null) or schema_name(t.schema_id) = @schema)
 and ((@table is null) or t.name = @table)
 and ((@constraint is null) or ix.name = @constraint)
 ) as a
 return;
 end

