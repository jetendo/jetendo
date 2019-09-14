<cfcomponent>
<cfoutput>
<!--- 
/z/server-manager/admin/verify-table-increment/index
 --->
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	setting requesttimeout="5000";
	request.ignoreSlowScript=true;
	echo("disabled");abort;
	form.deleteZero=application.zcore.functions.zso(form, 'deleteZero', true, 0);
	db=request.zos.queryObject;
	db.sql="select * from #db.table("table_increment", request.zos.zcoreDatasource)# 
	WHERE site_id <> #db.param(-1)#";
	qTable=db.execute("qTable");
	updated=0;
	zeroDeleteFields=0;
	zeroFields=0;
	for(row in qTable){
		if(left(row.table_increment_table, len("feature")) EQ "feature"){
			echo("WARNING: #row.table_increment_table# is not being checked due to it being an incomplete feature outside of jetendo core.<br>");
			continue;
		}
		db.sql="select *, `#db.trustedSQL(row.table_increment_table&"_id")#` id
		from #db.table(row.table_increment_table, request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(row.site_id)# and 
		`#db.trustedSQL(row.table_increment_table&"_id")#`=#db.param(0)# and 
		`#db.trustedSQL(row.table_increment_table&"_deleted")#`=#db.param(0)#";
		qZero=db.execute("qZero");
		if(qZero.recordcount NEQ 0){
			if(form.deleteZero){
				echo("delete a record with zero in the primary key id field: #row.table_increment_table# in #row.site_id#<br>");
				db.sql="delete from #db.table(row.table_increment_table, request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(row.site_id)# and 
				`#db.trustedSQL(row.table_increment_table&"_id")#`=#db.param(0)# and 
				`#db.trustedSQL(row.table_increment_table&"_deleted")#`=#db.param(0)#";
				db.execute("qDelete");
				zeroDeleteFields++;
			}else{
				echo("found a table with a zero in the primary key id field: #row.table_increment_table# in #row.site_id#<br>");
				writedump(qZero);
				zeroFields++;
			}
		}
		db.sql="select max(`#db.trustedSQL(row.table_increment_table&"_id")#`) maxId 
		from #db.table(row.table_increment_table, request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(row.site_id)# and 
		`#db.trustedSQL(row.table_increment_table&"_deleted")#`=#db.param(0)#";
		qMax=db.execute("qMax");
		if(qTable.recordcount EQ 0){
			if(row.table_increment_table_id GT 1){
				echo("change table_increment_table_id(#row.table_increment_table_id#) to #1# for #row.table_increment_table# in #row.site_id#<br>");
				db.sql="update #db.table("table_increment", request.zos.zcoreDatasource)# 
				set table_increment_table_id=#db.param(1)# 
				where table_increment_table=#db.param(row.table_increment_table)# and 
				site_id = #db.param(row.site_id)# and 
				table_increment_deleted=#db.param(0)#";
				db.execute("qUpdate");
				updated++;
			}
		}else{
			if(qMax.maxId GT row.table_increment_table_id){
				echo("change table_increment_table_id(#row.table_increment_table_id#) to #qMax.maxId# for #row.table_increment_table# in #row.site_id#<br>");
				db.sql="update #db.table("table_increment", request.zos.zcoreDatasource)# 
				set table_increment_table_id=#db.param(qMax.maxId)# 
				where table_increment_table=#db.param(row.table_increment_table)# and 
				site_id = #db.param(row.site_id)#";
				db.execute("qUpdate");
				updated++;
			}
		} 
	} 
	echo("#qTable.recordcount# records verified, and #updated# were corrected.<br>");
	if(zeroFields GT 0){
		echo(zeroFields&" tables have a record with 0 in the primary key id field, <a href=""/z/server-manager/admin/verify-table-increment/index?deleteZero=1"">click here to delete them</a>.<br>");
	}
	if(zeroDeleteFields GT 0){
		echo(zeroDeleteFields&" records with 0 in the primary key id field were deleted.<br>");
	}
	</cfscript>	
</cffunction>
</cfoutput>
</cfcomponent>