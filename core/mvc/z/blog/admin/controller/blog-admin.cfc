<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" output="yes" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog"); 
	if(application.zcore.app.siteHasApp("blog") EQ false){
		application.zcore.functions.zRedirect('/');
	}
	request.disableShareThis=true;
	application.zcore.template.setTag("title","Blog Manager");
	</cfscript>
	
	
	#this.navTemplate()#
</cffunction>



<cffunction name="navTemplate" localmode="modern" access="public" output="yes" returntype="any">
	<!---
	<cfscript>
	//var link='';
	var homelink='';
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	//link=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id, 4, "html",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
	
	if(application.zcore.app.getAppData("blog").optionstruct.blog_config_root_url NEQ "{default}"){
		homelink=request.zos.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url;
	}else{
		// default home url
		homelink=request.zos.currentHostName&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id,3,"html",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
	}
	//homelink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id, 3, "html",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
 
	//application.zcore.siteOptionCom.displaySectionNav();
	</cfscript>
	<a href="#homelink#" target="_blank">Blog Home Page</a> | 
	<a href="/z/blog/admin/blog-admin/articleList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Articles</a> | 
	<a href="/z/blog/admin/blog-admin/articleAdd?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Article</a> | 
	<a href="/z/blog/admin/blog-admin/categoryList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Categories</a> | 
	<a href="/z/blog/admin/blog-admin/categoryAdd?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Category</a> | 
	<a href="/z/blog/admin/blog-admin/tagList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Tags</a> | 
	<a href="/z/blog/admin/blog-admin/tagAdd?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Tag</a>
	<hr />--->
</cffunction>

<cffunction name="sortCat" localmode="modern" output="yes" returntype="any" roles="member">
	<cfargument name="id" type="any" required="yes">
	<cfargument name="cur" type="numeric" required="no" default="0">
	<cfargument name="level" type="numeric" required="no" default="0">
	<cfscript>
	var local=structnew();
	var db=request.zos.queryObject; 
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	WHERE blog_category_parent_id = #db.param(arguments.id)# and 
	site_id=#db.param(request.zos.globals.id)#  and 
	blog_category_deleted = #db.param(0)#
	ORDER BY blog_category_name ASC 
	</cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
	<cfloop query="local.qC">
		<cfset arguments.cur=arguments.cur+1>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("blog_category", request.zos.zcoreDatasource)#  
		SET blog_category_sort=#db.param(arguments.cur)#, 
		blog_category_level=#db.param(arguments.level)#  
		WHERE blog_category_id = #db.param(local.qC.blog_category_id)#  and 
		blog_category_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>local.qU=db.execute("qU");
		arguments.cur=this.sortCat(local.qC.blog_category_id, arguments.cur, arguments.level+1);
		</cfscript>
	</cfloop>
	<cfreturn arguments.cur>
</cffunction>


<cffunction name="sort" localmode="modern" access="remote" roles="member">
	<cfscript>
	
	sortSetup();
	</cfscript>
	<div class="manualSortMessage" style="display:none; padding:5px; width:100%; float:left;">Manual sorting is disabled when you are using column sorting.  Please refresh the page to use manual sorting again.</div>
	<table id="sortRowTable" class="display" cellspacing="0" width="100%">
		<thead>
			<tr>
				<!--- <th style="display:none;">ID</th> --->
				<th>Name</th>
				<th>Position</th>
				<th>Office</th>
				<th>Age</th> 
				<th class="sortColumnHeader">Sort</th>
				<th>Admin</th>
			</tr>
		</thead>
 		<tbody> 
  
		</tbody>
	</table>

	<cfscript>
	application.zcore.functions.zRequireDataTables();
	</cfscript>
	<script type="text/javascript">
		var table=-1;
	zArrDeferredFunctions.push(function() {
		/*	$('##example').dataTable( {
	  "filter": false,
	  "destroy": true
	} );*/

		var dataTableConfig={};
		var sortColumnIndex=-1;
		var sortingOnSortColumn=true;
		function enableManualSort(){
			if(!sortingOnSortColumn){
				return;
			}
			if($(".sortColumnHeader").length){
				$(".sortRowTable_handle").show();
				$(".manualSortMessage").hide();
				//$(".sortColumnHeader").html("Sort");
			}
		}
		function disableManualSort(){
			if($(".sortColumnHeader").length){
				for(i=0;i<dataTableConfig.columns.length;i++){
					var title = $(table.column( sortColumnIndex-1 ).header()).html();
					console.log("|"+title+"|");
					table.column(sortColumnIndex-1).visible(false);
				}
				$(".sortRowTable_handle").hide();
				$(".manualSortMessage").fadeIn('fast');
				//$(".sortColumnHeader").html("Reload page to Sort");
			}

		}
		function checkColumnSortStatus(){ 
			var i=table.page.info();
			var t=table.order();
			if(i.recordsTotal == i.recordsDisplay){
				if(t.length == 1 && t[0][0] == sortColumnIndex && t[0][1] == "asc"){
					sortingOnSortColumn=true;
					ensableManualSort();
				}else{
					sortingOnSortColumn=false;
					disableManualSort();
				}

			}else{
				disableManualSort();
			}
		}
		var displayingAll=false;
		var dataTableConfig={
			"order": [
				[ 0, "asc" ]
			], 
			"columns":[
				//{ "data": "__sortValue" },
				{ "data": "column1" },
				{ "data": "column2" },
				{ "data": "column3" },
				{ "data": "column4" },
				{ "data": "Sort" },
				{ "data": "Admin" }
			],
			/*"columnDefs": [
				{
					"targets": [ 0 ],
					"visible": false,
					"searchable": false
				}
			],*/
			paging: true,
			stateSave:false,
			deferRender:true,
			length:5,
			//"ajax": '../ajax/data/arrays.txt',
			"processing": true,
			"serverSide": true,
			"ajax": "/z/blog/admin/blog-admin/getSortData" 
		};


		for(var i=0;i<dataTableConfig.columns;i++){
			if(dataTableConfig.columns[i].data == "Sort"){
				sortColumnIndex=i;
				break;
			}
		}
		table=$('##sortRowTable').DataTable( dataTableConfig );
		var firstOrder=true;
		$('##sortRowTable').on( 'page.dt', function () { 
			var i=table.page.info();
			console.log(i);
			checkColumnSortStatus();
		});
		$('##sortRowTable').on( 'order.dt', function (a, e) {  
			if(firstOrder){ 
				//zSetupAjaxTableSortAgain();
				firstOrder=false;
				return;
			} 
			/*
			.columns().nodes().flatten().to$().each(function(){
				if(
			});
			*/
			checkColumnSortStatus();
		});
		$("##sortRowTable").on('dblclick', function(e){
			console.log('doubleclick:'+e.target.tagName.toLowerCase()+":"+$(".zEditCellField", e.target).length);
			var t=e.target;
			var clickedTD=false;
			var $editDiv;
			while(true){
				if(t.tagName.toLowerCase() == 'td'){
					$editDiv=$(".zEditableCellValue", t);
					if($editDiv.length==0){
						return false;
					}
					clickedTD=true;
					break;
				}else if(t.tagName.toLowerCase() == 'table'){
					return false;
				}else{
					t=t.parentNode;
				}
			}
			if(clickedTD){
				if($(".zEditCellField", e.target).length==0){
					var v=$(e.target).html();
   					var i = document.createElement("input");
   					i.type="text";
   					console.log("original value:"+v);
   					i.setAttribute('data-originalvalue', v);
   					i.onfocus=function(){
   						console.log('field focused');
   					};
   					i.onblur=function(){
   						console.log('field blurred');

   						if(this.value == v){
   							console.log('No value change detected');
	   						$(e.target).html(v);
   						}else{
   							console.log('Saving change: TODO AJAX call');
   							return;
   							var link=$editDiv.attr("data-save-url");
   							var fieldName=$editDiv.attr("data-save-field-name");
   							if(link.indexOf("?") == -1){
   								link+="?";
   							}else{
   								link+="&";
   							}
   							var postObj={};
   							postObj[fieldName]=this.value;
							var obj={
								id:"ajaxSaveCell",
								method:"post",
								postObj:postObj,
								ignoreOldRequests:false,
								callback:function(r){
		   							//r=eval('('+r+')');
		   							r={success:true};
		   							if(r.success){
			   							$(e.target).html(i.getAttribute("data-originalvalue"));
			   						}else{
			   							alert('Value not saved. Please check your value and try again.');
			   						}

								},
								errorCallback:function(){ alert('Unknown error occurred'); },
								url:link
							}; 
							zAjax(obj);
	   					}
   					};
   					i.onkeydown=function ( e ) {
						if ( e.keyCode == 13 || e.keyCode ==9 ) {
							e.preventDefault();
							$(this).trigger("blur");
	   					}
	   				}
   					var d = document.createElement("div");
   					d.className="zEditCellContainer";
   					i.name="cellEdit";
   					i.id="cellEdit1";
   					i.className="zEditCellField";
   					i.value=v;
   					$(d).append(i);
   					var a = document.createElement("a");
   					a.innerHTML='Save';
   					a.href="##";
   					a.onclick=function(){return false;};
   					a.className="zEditCellSave";
   					$(d).append(a);
   					$(e.target).html(d);
   					$(i).trigger("focus");
   					i.select();
				}else{
					console.log('do nothing');
				}
			}
		});
	});
	</script>


</cffunction>


<cffunction name="saveColumnData" localmode="modern" access="remote" roles="member">
	<cfscript>
	/*
	action=edit
data[first_name]=Ashton
data[last_name]=Cox2
data[position]=Junior Technical Author
data[office]=San Francisco
data[extn]=1562
data[start_date]=2009-01-12
data[salary]=86000
id=row_3

need to return the edited row data as json.

getSortFormObject


			orderable:true,
			searchable:true,
			name:"column"&i
			editable:true
	*/
	rs={
		success:true,
		data:form
	}
	application.zcore.functions.zReturnJson(rs);
</cfscript>
</cffunction>

<cffunction name="sortSetup" localmode="modern" access="remote" roles="member">
	<cfscript>
	variables.queueSortStruct = StructNew();
	// required
	variables.queueSortStruct.tableName = "contenttest";
	variables.queueSortStruct.sortFieldName = "content_sort";
	variables.queueSortStruct.primaryKeyName = "content_id";
	// optional 
	variables.queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	variables.queueSortWhere="site_id = '#application.zcore.functions.zescape(request.zos.globals.id)#' and content_deleted=0 ";
	variables.queueSortStruct.where = variables.queueSortWhere&" and content_parent_id='0' ";
	variables.queueSortStruct.disableRedirect=true;

	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/nonsense?content_parent_id=#0#';
	
	request.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	request.queueSortCom.init(variables.queueSortStruct);
	if(structkeyexists(form, 'zQueueSortAjax')){
		application.zcore.functions.zMenuClearCache({content=true});
		request.queueSortCom.returnJson();
	}
	
	</cfscript>
</cffunction>

<cffunction name="getSortFormObject" localmode="modern" access="remote" roles="member">
	<cfscript> 
	sortSetup();
	

	sortStruct={};
	sortStruct.draw=application.zcore.functions.zso(form, 'draw', true); // unique ajax id
	sortStruct.start=application.zcore.functions.zso(form, 'start', true); // offset
	sortStruct.length=application.zcore.functions.zso(form, 'length', true); // perpage
	if(sortStruct.length LT 10 or sortStruct.length GT 100){
		sortStruct.length=10;
	}
	sortStruct.searchValue=application.zcore.functions.zso(form, 'search[value]', false, '');  
	sortStruct.arrOrder=[];

	sortStruct.arrColumn=[];

	/*
	Doesn't support regex search or individual column search.
	*/
	columnIndexStruct={};

	columnCount=4;
	for(i=1;i LTE columnCount;i++){
		ts={
			orderable:true,
			searchable:true,
			name:"column"&i
		};
		columnIndexStruct[i]=ts.name;
		arrayAppend(sortStruct.arrColumn, ts);
	}
	ts={
		orderable:false,
		searchable:false,
		name:"Sort"
	};
	columnCount++;
	columnIndexStruct[columnCount]=ts.name;
	arrayAppend(sortStruct.arrColumn, ts);
	ts={
		orderable:false,
		searchable:false,
		name:"Admin"
	};
	columnCount++;
	columnIndexStruct[columnCount]=ts.name;
	arrayAppend(sortStruct.arrColumn, ts);
	ts={
		orderable:true,
		searchable:false,
		name:"__sortValue"
	};
	columnCount++;
	columnIndexStruct[columnCount]=ts.name;
	arrayAppend(sortStruct.arrColumn, ts);
	for(i=0;i LTE 20;i++){
		if(structkeyexists(form, 'order[#i#][column]')){
			ts={
				column: application.zcore.functions.zso(form, 'order[#i#][column]', true),
				direction: application.zcore.functions.zso(form, 'order[#i#][dir]')
			};
			if(ts.direction NEQ "desc" and ts.direction NEQ "asc"){
				ts.direction="asc";
			}
			if(structkeyexists(columnIndexStruct, i)){
				//a
			}
			arrayAppend(sortStruct.arrOrder, ts);
		}else{
			break;
		}
	} 
	return sortStruct;
	</cfscript>
</cffunction>


<cffunction name="getSortData" localmode="modern" access="remote" roles="member">
	<cfscript>
	sortStruct=getSortFormObject();
	//writedump(sortStruct);

	rs.draw=sortStruct.draw;
	rs.recordsTotal=30;
	rs.recordsFiltered=rs.recordsTotal;
	rs.data=[];

	count=0;
	for(i=1;i LTE rs.recordsFiltered;i++){
		if(i-1 LT sortStruct.start){
			continue;
		}
		rowStruct={};
		sortHandleStruct=request.queueSortCom.getRowStruct(i);
		rowStruct.__sortValue=i;
		rowStruct.DT_RowId=sortHandleStruct.id;
		rowStruct.DT_RowData={
				"primaryKeyId": sortHandleStruct.primaryKeyId
		};
		for(i2=1;i2 LTE 4;i2++){
			rowStruct[sortStruct.arrColumn[i2].name]='<div class="zEditableCellValue" data-save-url="/z/blog/admin/blog-admin/saveColumnData?site_x_option_group_set_id=#i2#&amp;site_option_id=#i2#" data-save-field-name="site_x_option_group_value">'&i&"_"&i2&'</div>'; 
		}
		rowStruct["Sort"]=request.queueSortCom.getAjaxHandleButton(i);
		rowStruct["Admin"]='<a href="##">View</a>'; 
		arrayAppend(rs.data, rowStruct);
		count++;
		if(count EQ sortStruct.length){
			break;
		}
	}
	//rs.error=""; // don't use yet

	application.zcore.functions.zReturnJSON(rs);
	abort;
/*
	Parameter name	Type	Description
draw	integerJS	Draw counter. This is used by DataTables to ensure that the Ajax returns from server-side processing requests are drawn in sequence by DataTables (Ajax requests are asynchronous and thus can return out of sequence). This is used as part of the draw return parameter (see below).
start	integerJS	Paging first record indicator. This is the start point in the current data set (0 index based - i.e. 0 is the first record).
length	integerJS	Number of records that the table can display in the current draw. It is expected that the number of records returned will be equal to this number, unless the server has fewer records to return. Note that this can be -1 to indicate that all records should be returned (although that negates any benefits of server-side processing!)
search[value]	stringJS	Global search value. To be applied to all columns which have searchable as true.
search[regex]	booleanJS	true if the global filter should be treated as a regular expression for advanced searching, false otherwise. Note that normally server-side processing scripts will not perform regular expression searching for performance reasons on large data sets, but it is technically possible and at the discretion of your script.
order[i][column]	integerJS	Column to which ordering should be applied. This is an index reference to the columns array of information that is also submitted to the server.
order[i][dir]	stringJS	Ordering direction for this column. It will be asc or desc to indicate ascending ordering or descending ordering, respectively.
columns[i][data]	stringJS	Column's data source, as defined by columns.dataDT.
columns[i][name]	stringJS	Column's name, as defined by columns.nameDT.
columns[i][searchable]	booleanJS	Flag to indicate if this column is searchable (true) or not (false). This is controlled by columns.searchableDT.
columns[i][orderable]	booleanJS	Flag to indicate if this column is orderable (true) or not (false). This is controlled by columns.orderableDT.
columns[i][search][value]	stringJS	Search value to apply to this specific column.
columns[i][search][regex]	booleanJS	Flag to indicate if the search term for this column should be treated as regular expression (true) or not (false). As with global search, normally server-side processing scripts will not perform regular expression searching for performance reasons on large data sets, but it is technically possible and at the discretion of your script.
*/
</cfscript>
	<cfsavecontent variable="out">
	{
  "data": [
	[
	  "Tiger Nixon",
	  "System Architect",
	  "Edinburgh",
	  "5421",
	  "2011/04/25",
	  "$320,800"
	],
	[
	  "Garrett Winters",
	  "Accountant",
	  "Tokyo",
	  "8422",
	  "2011/07/25",
	  "$170,750"
	],
	[
	  "Ashton Cox",
	  "Junior Technical Author",
	  "San Francisco",
	  "1562",
	  "2009/01/12",
	  "$86,000"
	],
	[
	  "Cedric Kelly",
	  "Senior Javascript Developer",
	  "Edinburgh",
	  "6224",
	  "2012/03/29",
	  "$433,060"
	],
	[
	  "Airi Satou",
	  "Accountant",
	  "Tokyo",
	  "5407",
	  "2008/11/28",
	  "$162,700"
	],
	[
	  "Brielle Williamson",
	  "Integration Specialist",
	  "New York",
	  "4804",
	  "2012/12/02",
	  "$372,000"
	],
	[
	  "Herrod Chandler",
	  "Sales Assistant",
	  "San Francisco",
	  "9608",
	  "2012/08/06",
	  "$137,500"
	],
	[
	  "Rhona Davidson",
	  "Integration Specialist",
	  "Tokyo",
	  "6200",
	  "2010/10/14",
	  "$327,900"
	],
	[
	  "Colleen Hurst",
	  "Javascript Developer",
	  "San Francisco",
	  "2360",
	  "2009/09/15",
	  "$205,500"
	],
	[
	  "Sonya Frost",
	  "Software Engineer",
	  "Edinburgh",
	  "1667",
	  "2008/12/13",
	  "$103,600"
	],
	[
	  "Jena Gaines",
	  "Office Manager",
	  "London",
	  "3814",
	  "2008/12/19",
	  "$90,560"
	],
	[
	  "Quinn Flynn",
	  "Support Lead",
	  "Edinburgh",
	  "9497",
	  "2013/03/03",
	  "$342,000"
	],
	[
	  "Charde Marshall",
	  "Regional Director",
	  "San Francisco",
	  "6741",
	  "2008/10/16",
	  "$470,600"
	],
	[
	  "Haley Kennedy",
	  "Senior Marketing Designer",
	  "London",
	  "3597",
	  "2012/12/18",
	  "$313,500"
	],
	[
	  "Tatyana Fitzpatrick",
	  "Regional Director",
	  "London",
	  "1965",
	  "2010/03/17",
	  "$385,750"
	],
	[
	  "Michael Silva",
	  "Marketing Designer",
	  "London",
	  "1581",
	  "2012/11/27",
	  "$198,500"
	],
	[
	  "Paul Byrd",
	  "Chief Financial Officer (CFO)",
	  "New York",
	  "3059",
	  "2010/06/09",
	  "$725,000"
	],
	[
	  "Gloria Little",
	  "Systems Administrator",
	  "New York",
	  "1721",
	  "2009/04/10",
	  "$237,500"
	],
	[
	  "Bradley Greer",
	  "Software Engineer",
	  "London",
	  "2558",
	  "2012/10/13",
	  "$132,000"
	],
	[
	  "Dai Rios",
	  "Personnel Lead",
	  "Edinburgh",
	  "2290",
	  "2012/09/26",
	  "$217,500"
	],
	[
	  "Jenette Caldwell",
	  "Development Lead",
	  "New York",
	  "1937",
	  "2011/09/03",
	  "$345,000"
	],
	[
	  "Yuri Berry",
	  "Chief Marketing Officer (CMO)",
	  "New York",
	  "6154",
	  "2009/06/25",
	  "$675,000"
	],
	[
	  "Caesar Vance",
	  "Pre-Sales Support",
	  "New York",
	  "8330",
	  "2011/12/12",
	  "$106,450"
	],
	[
	  "Doris Wilder",
	  "Sales Assistant",
	  "Sidney",
	  "3023",
	  "2010/09/20",
	  "$85,600"
	],
	[
	  "Angelica Ramos",
	  "Chief Executive Officer (CEO)",
	  "London",
	  "5797",
	  "2009/10/09",
	  "$1,200,000"
	],
	[
	  "Gavin Joyce",
	  "Developer",
	  "Edinburgh",
	  "8822",
	  "2010/12/22",
	  "$92,575"
	],
	[
	  "Jennifer Chang",
	  "Regional Director",
	  "Singapore",
	  "9239",
	  "2010/11/14",
	  "$357,650"
	],
	[
	  "Brenden Wagner",
	  "Software Engineer",
	  "San Francisco",
	  "1314",
	  "2011/06/07",
	  "$206,850"
	],
	[
	  "Fiona Green",
	  "Chief Operating Officer (COO)",
	  "San Francisco",
	  "2947",
	  "2010/03/11",
	  "$850,000"
	],
	[
	  "Shou Itou",
	  "Regional Marketing",
	  "Tokyo",
	  "8899",
	  "2011/08/14",
	  "$163,000"
	],
	[
	  "Michelle House",
	  "Integration Specialist",
	  "Sidney",
	  "2769",
	  "2011/06/02",
	  "$95,400"
	],
	[
	  "Suki Burks",
	  "Developer",
	  "London",
	  "6832",
	  "2009/10/22",
	  "$114,500"
	],
	[
	  "Prescott Bartlett",
	  "Technical Author",
	  "London",
	  "3606",
	  "2011/05/07",
	  "$145,000"
	],
	[
	  "Gavin Cortez",
	  "Team Leader",
	  "San Francisco",
	  "2860",
	  "2008/10/26",
	  "$235,500"
	],
	[
	  "Martena Mccray",
	  "Post-Sales support",
	  "Edinburgh",
	  "8240",
	  "2011/03/09",
	  "$324,050"
	],
	[
	  "Unity Butler",
	  "Marketing Designer",
	  "San Francisco",
	  "5384",
	  "2009/12/09",
	  "$85,675"
	],
	[
	  "Howard Hatfield",
	  "Office Manager",
	  "San Francisco",
	  "7031",
	  "2008/12/16",
	  "$164,500"
	],
	[
	  "Hope Fuentes",
	  "Secretary",
	  "San Francisco",
	  "6318",
	  "2010/02/12",
	  "$109,850"
	],
	[
	  "Vivian Harrell",
	  "Financial Controller",
	  "San Francisco",
	  "9422",
	  "2009/02/14",
	  "$452,500"
	],
	[
	  "Timothy Mooney",
	  "Office Manager",
	  "London",
	  "7580",
	  "2008/12/11",
	  "$136,200"
	],
	[
	  "Jackson Bradshaw",
	  "Director",
	  "New York",
	  "1042",
	  "2008/09/26",
	  "$645,750"
	],
	[
	  "Olivia Liang",
	  "Support Engineer",
	  "Singapore",
	  "2120",
	  "2011/02/03",
	  "$234,500"
	],
	[
	  "Bruno Nash",
	  "Software Engineer",
	  "London",
	  "6222",
	  "2011/05/03",
	  "$163,500"
	],
	[
	  "Sakura Yamamoto",
	  "Support Engineer",
	  "Tokyo",
	  "9383",
	  "2009/08/19",
	  "$139,575"
	],
	[
	  "Thor Walton",
	  "Developer",
	  "New York",
	  "8327",
	  "2013/08/11",
	  "$98,540"
	],
	[
	  "Finn Camacho",
	  "Support Engineer",
	  "San Francisco",
	  "2927",
	  "2009/07/07",
	  "$87,500"
	],
	[
	  "Serge Baldwin",
	  "Data Coordinator",
	  "Singapore",
	  "8352",
	  "2012/04/09",
	  "$138,575"
	],
	[
	  "Zenaida Frank",
	  "Software Engineer",
	  "New York",
	  "7439",
	  "2010/01/04",
	  "$125,250"
	],
	[
	  "Zorita Serrano",
	  "Software Engineer",
	  "San Francisco",
	  "4389",
	  "2012/06/01",
	  "$115,000"
	],
	[
	  "Jennifer Acosta",
	  "Junior Javascript Developer",
	  "Edinburgh",
	  "3431",
	  "2013/02/01",
	  "$75,650"
	],
	[
	  "Cara Stevens",
	  "Sales Assistant",
	  "New York",
	  "3990",
	  "2011/12/06",
	  "$145,600"
	],
	[
	  "Hermione Butler",
	  "Regional Director",
	  "London",
	  "1016",
	  "2011/03/21",
	  "$356,250"
	],
	[
	  "Lael Greer",
	  "Systems Administrator",
	  "London",
	  "6733",
	  "2009/02/27",
	  "$103,500"
	],
	[
	  "Jonas Alexander",
	  "Developer",
	  "San Francisco",
	  "8196",
	  "2010/07/14",
	  "$86,500"
	],
	[
	  "Shad Decker",
	  "Regional Director",
	  "Edinburgh",
	  "6373",
	  "2008/11/13",
	  "$183,000"
	],
	[
	  "Michael Bruce",
	  "Javascript Developer",
	  "Singapore",
	  "5384",
	  "2011/06/27",
	  "$183,000"
	],
	[
	  "Donna Snider",
	  "Customer Support",
	  "New York",
	  "4226",
	  "2011/01/25",
	  "$112,000"
	]
  ]
}
</cfsavecontent>
	<cfscript>
	echo(out);abort;
</cfscript>
</cffunction>

<cffunction name="categoryInsert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.categoryUpdate();
	</cfscript>
</cffunction>

<cffunction name="categoryUpdate" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var tempURL=0;
	var qT9=0;
	var ts=0;
	var db=request.zos.queryObject;
	var uniqueChanged=0;
	var res=0;
	var qCheck=0;
	var result=0;
	var blogform=0;
	var inputStruct=0;
	var qId=0;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Categories", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	form.blog_datetime = dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	blogform = StructNew();
	blogform.blog_category_name.required = true;
	blogform.blog_category_description.html = true;
	blogform.blog_category_description.allowNull = true;
	result = application.zcore.functions.zValidateStruct(form, blogform, request.zsid, true);
	if(application.zcore.functions.zso(form,'blog_category_unique_name') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'blog_category_unique_name'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		result=true;
	}
	if(result){
	if(form.method EQ "updateGroup"){
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/categoryEdit?zsid=#Request.zsid#&blog_category_id=#form.blog_category_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}else{
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/categoryAdd?zsid=#Request.zsid#&blog_category_id=#form.blog_category_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	}
	
	uniqueChanged=false;
	oldURL="";
	//if(application.zcore.user.checkSiteAccess()){
		if((structkeyexists(form,'blog_category_id') EQ false or form.blog_category_id EQ '') and application.zcore.functions.zso(form, 'blog_category_unique_name') NEQ ""){
			uniqueChanged=true;
		}
		if(structkeyexists(form, 'blog_category_id') and form.blog_category_id NEQ ''){
			db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
			WHERE blog_category_id=#db.param(form.blog_category_id)# and 
			blog_category_deleted = #db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)#";
			qCheck=db.execute("qCheck"); 
			if(qcheck.recordcount EQ 0){
				application.zcore.status.setStatus(request.zsid,"This blog category no longer exists.");
				application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
			}
			oldURL=qCheck.blog_category_unique_name;
			if(qcheck.blog_category_unique_name NEQ form.blog_category_unique_name){
				uniqueChanged=true;	
			}
		}
	//}
	
	if(application.zcore.app.siteHasApp("listing")){
			if(structkeyexists(form, 'blog_category_id') and form.blog_category_id NEQ ''){
				db.sql="SELECT blog_category_saved_search_id, blog_category_search_mls 
				from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
				WHERE blog_category_id = #db.param(form.blog_category_id)# and 
				blog_category_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)#";
				qId=db.execute("qId"); 
				form.blog_category_saved_search_id=qid.blog_category_saved_search_id;
			}else{
				form.blog_category_saved_search_id="";
			}
			if(form.blog_category_search_mls EQ 1) {
				form.blog_category_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.blog_category_saved_search_id, '', form);
			} else {
				form.blog_category_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.blog_category_saved_search_id);
			}
	}
	if(trim(application.zcore.functions.zso(form, 'blog_category_metakey')) EQ ""){
		form.blog_category_metakey=replace(replace(form.blog_category_name,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'blog_category_metadesc')) EQ ""){
		form.blog_category_metadesc=left(replace(replace(rereplacenocase(form.blog_category_description,"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	form.site_id=request.zos.globals.id;

	if(application.zcore.functions.zso(form, 'convertLinks') EQ 1){
		form.blog_category_description=application.zcore.functions.zProcessAndStoreLinksInHTML(form.blog_category_name, form.blog_category_description);
	}

	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "blog_category";
	inputStruct.datasource=request.zos.zcoreDatasource;
	
	if(structkeyexists(form, 'blog_category_id') and form.blog_category_id NEQ ''){
		db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
		WHERE blog_category_id = #db.param(form.blog_category_id)# and 
		blog_category_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck"); 
		if(application.zcore.functions.zso(form, 'blog_category_metakey') EQ qCheck.blog_category_metakey and qCheck.blog_category_metakey NEQ ""){
			if(replace(replace(qCheck.blog_category_name,"|"," ","ALL"),","," ","ALL") EQ qCheck.blog_category_metakey){
				form.blog_category_metakey=replace(replace(form.blog_category_name,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'blog_category_metadesc') EQ qCheck.blog_category_metadesc and qCheck.blog_category_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(qcheck.blog_category_description,"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.blog_category_metakey){
				form.blog_category_metadesc=left(replace(replace(rereplacenocase(form.blog_category_description,"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}
		inputStruct.forceWhereFields = "blog_category_id"; // list: forces function to use one or more fields for the WHERE statement.
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			// failed, on duplicate key or sql error
			application.zcore.status.setStatus(request.zsid, 'There was an error updating this category.', form,true);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/categoryEdit?blog_category_id=#form.blog_category_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'This category was updated successfully.', form,false);
		}
	}else{
		form.blog_category_id = application.zcore.functions.zInsert(inputStruct); 
		if(form.blog_category_id EQ false){
			//Throw Error
			application.zcore.status.setStatus(request.zsid, 'There was an error inserting this category.', form,true);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/categoryEdit?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'This category was added successfully.', form,false);
		}
	}
	
	 db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	WHERE blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qT9=db.execute("qT9");
	application.zcore.functions.zQueryToStruct(qT9, form);
	ts=StructNew();
	ts.table="blog_category_version";
	ts.datasource=request.zos.zcoreDatasource;
	form.site_id=request.zos.globals.id;
	ts.struct=form;
	application.zcore.functions.zInsert(ts);

	if(uniqueChanged){
		application.zcore.app.getAppCFC("blog").updateRewriteRuleBlogCategory(form.blog_category_id, oldURL); 
	}
	this.sortCat(0);
	application.zcore.siteOptionCom.activateOptionAppId(application.zcore.functions.zso(form, 'blog_category_site_option_app_id'));
	application.zcore.app.getAppCFC("blog").searchReindexBlogCategories(form.blog_category_id, false);
	
	application.zcore.functions.zMenuClearCache({blogCategory=true});
	if(form.method EQ "categoryInsert" and structkeyexists(request.zsession, 'blogcategory_return') and request.zsession['blogcategory_return'] NEQ ""){
		tempURL = request.zsession['blogcategory_return'];
		StructDelete(request.zsession, 'blogcategory_return', true);
		application.zcore.functions.zRedirect(replace(tempURL, "zsid=", "ztv=", "all"), true);
	}else if(structkeyexists(request.zsession, 'blogcategory_return'&form.blog_category_id) and request.zsession['blogcategory_return'&form.blog_category_id] NEQ "" and not uniqueChanged){	
		tempURL = request.zsession['blogcategory_return'&form.blog_category_id];
		StructDelete(request.zsession, 'blogcategory_return'&form.blog_category_id, true);
		application.zcore.functions.zRedirect(replace(tempURL, "zsid=", "ztv=", "all"), true);
	}else{	
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/categoryList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	</cfscript>
</cffunction>

<cffunction name="categoryDelete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qList=0;
	var db=request.zos.queryObject;
	var qDelete=0;
	var res=0;
	this.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Categories", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	db.sql="select *
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
	WHERE blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qList=db.execute("qList");
	if(qList.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"This category no longer exists.");
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/categoryList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");	
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		if(application.zcore.app.siteHasApp("listing")){
			request.zos.listing.functions.zMLSSearchOptionsUpdate('delete',qlist.blog_category_saved_search_id);
		}
		application.zcore.siteOptionCom.deleteOptionAppId(qList.blog_category_site_option_app_id);
		application.zcore.app.getAppCFC("blog").searchIndexDeleteBlogCategory(form.blog_category_id);
		db.sql="delete
			from #db.table("blog_category", request.zos.zcoreDatasource)# 
			
		WHERE blog_category_id = #db.param(form.blog_category_id)# and 
		blog_category_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qDelete=db.execute("qDelete");
		this.sortCat(0);
		application.zcore.functions.zDeleteUniqueRewriteRule(qList.blog_category_unique_name);
		application.zcore.functions.zMenuClearCache({blogCategory=true});
			application.zcore.status.setStatus(request.zsid, 'This category was deleted successfully.', form,false);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/categoryList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		</cfscript>
	<cfelse>
		<cfscript>
		db.sql="select *
		from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
		
		WHERE blog_category_id = #db.param(form.blog_category_id)# and 
		blog_category_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qList=db.execute("qList");
		</cfscript>
		<h2>Are you sure you want to delete category, #qList.blog_category_name#?<br />
		<br />
		<a href="/z/blog/admin/blog-admin/categoryDelete?confirm=true&amp;blog_category_id=#form.blog_category_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/blog/admin/blog-admin/categoryList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">No</a></h2>
	</cfif>
</cffunction>


<cffunction name="commentDelete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qList=0;
	var db=request.zos.queryObject;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	</cfscript>
	<cfsavecontent variable="db.sql">
	select *
	from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment
	WHERE blog_id = #db.param(form.blog_id)# and 
	blog_comment_deleted = #db.param(0)# and 
	blog_comment_id = #db.param(form.blog_comment_id)# and 
	site_id=#db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qList=db.execute("qList");
	if(qList.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"This comment no longer exists.");
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");	
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="DELETE FROM #db.table("blog_comment", request.zos.zcoreDatasource)#  
		WHERE blog_id=#db.param(form.blog_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_comment_deleted = #db.param(0)# and 
		blog_comment_id =#db.param(form.blog_comment_id)#";
		db.execute("q"); 


		updateBlogCommentCount(form.blog_id);
		application.zcore.status.setStatus(request.zsid,"Comment deleted.");
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		</cfscript>
	<cfelse>
		<h2>Are you sure you want to delete this blog comment?<br /><br />

		Subject: #qList.blog_comment_title#<br /><br />

		Comments: #qlist.blog_comment_text#?<br />
		<br />
		<a href="/z/blog/admin/blog-admin/commentDelete?confirm=true&amp;blog_id=#form.blog_id#&amp;blog_comment_id=#form.blog_comment_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">No</a></h2>
		
	</cfif>
</cffunction>

<cffunction name="updateBlogCommentCount" localmode="modern" access="public">
	<cfargument name="blog_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	
	db.sql="SELECT count(blog_comment_id) count from #db.table("blog_comment", request.zos.zcoreDatasource)#  
	WHERE blog_comment_approved=#db.param(1)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	blog_comment_deleted = #db.param(0)# and
	blog_id =#db.param(form.blog_id)#";
	qCount=db.execute("qCount");
	 db.sql="UPDATE #db.table("blog", request.zos.zcoreDatasource)#  
	 SET blog_comment_count=#db.param(qCount.count)#, 
	 blog_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and
	blog_id =#db.param(form.blog_id)#";
	db.execute("qUpdate");
	</cfscript>
</cffunction>
	

<cffunction name="commentApprove" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	 db.sql="UPDATE #db.table("blog_comment", request.zos.zcoreDatasource)#  
	 SET blog_comment_approved=#db.param(1)#, 
	 blog_comment_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	blog_comment_deleted = #db.param(0)# and
	blog_comment_id =#db.param(form.blog_comment_id)#";
	db.execute("q");

	updateBlogCommentCount(form.blog_id);

	application.zcore.status.setStatus(request.zsid,"Comment approved");	
	application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	</cfscript>
</cffunction>

<cffunction name="commentUpdate" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var inputStruct=0;
	var blogform=0;
	var result=0;
	var db=request.zos.queryObject;
	var qc=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	
	form.blog_comment_id=application.zcore.functions.zso(form, 'blog_comment_id');
	if(structkeyexists(form, 'deletef') and form.deletef EQ 1){
		db.sql="DELETE FROM #db.table("blog_comment", request.zos.zcoreDatasource)#  
		WHERE blog_id=#db.param(form.blog_id)# and 
		blog_comment_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_comment_id =#db.param(form.blog_comment_id)#";
		db.execute("q"); 
		application.zcore.status.setStatus(request.zsid,"Comment deleted.");
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	db.sql="select * from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment 
	WHERE blog_comment_id =#db.param(form.blog_comment_id)# and 
	blog_comment_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qC=db.execute("qC"); 
	if(qC.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid request");
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	form.blog_comment_approved = 1;
	if(form.blog_comment_title eq ''){
		db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog 
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		query=db.execute("query"); 
		form.blog_comment_title = 'Re: '&query.blog_title;
	}
	if(form.blog_comment_author eq ''){
		//throw error
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentReview?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	if(form.blog_comment_title eq ''){
		//throw error
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentReview?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	if(len(form.blog_comment_text) lt 1){
		//throw error
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentReview?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	blogform = StructNew();
	blogform.blog_comment_author_email.email = true;
	result = application.zcore.functions.zValidateStruct(form, blogform, request.zsid, true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentReview?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	form.site_id=request.zos.globals.id;
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "blog_comment";
	inputStruct.datasource=request.zos.zcoreDatasource;
	inputStruct.forceWhereFields = "blog_comment_id";
	if(application.zcore.functions.zUpdate(inputStruct) EQ false){
		// failed, on duplicate key or sql error
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}else{
		updateBlogCommentCount(form.blog_id);
		// success
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	</cfscript>
</cffunction>

<cffunction name="articleInsert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.articleUpdate();
	</cfscript>
</cffunction>

<cffunction name="articleUpdate" localmode="modern" access="remote" roles="member">
	<cfscript>
	var inputStruct=0;
	var eCom=0;
	var qCheck=0;
	var ts=0;
	var tempURL=0;
	var uniqueChanged=0;
	var site_id=0;
	var db=request.zos.queryObject;
	var arrTag=0;
	var i=0;
	var qId=0;
	var arrCat=0;
	var error=0;
	var qT9=0;
	var blogform=0;
	variables.init();
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);

	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	blogform = StructNew();
	blogform.blog_story.html = true;


	if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_disable_author', true, 0) EQ 0){
		blogform.uid.required=true;
		blogform.uid.friendlyname="Author";
	}
	blogform.blog_title.required=true;
	blogform.ccid.required=true;
	blogform.ccid.friendlyname="Category";
	form.blog_datetime=application.zcore.functions.zGetDateSelect("blog_datetime","yyyy-mm-dd")&' '&application.zcore.functions.zGetTimeSelect("blog_datetime","HH:mm:ss");
	error = application.zcore.functions.zValidateStruct(form, blogform, request.zsid,true);
	if(structkeyexists(form, 'blog_status') EQ false){
		error=true;
	}else{
		if(form.blog_status EQ 0){
			form.blog_datetime=request.zos.mysqlnow;	
			form.blog_status=1;
		}
	}
	if(isdate(form.blog_datetime) EQ false){		
		application.zcore.status.setStatus(request.zsid, 'Invalid Date/Time Format.  Please try again or alert the administrator.',form,true);
		error=true;
	}
	if(application.zcore.functions.zso(form,'blog_unique_name') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'blog_unique_name'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		error=true;
	}

	if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_disable_author', true, 0) EQ 0){
		form.user_id=application.zcore.functions.zso(form, 'uid');
		arrUser=listToArray(form.user_id, "|");
		if(arraylen(arrUser) EQ 1){
			arrayAppend(arrUser, 0);
		}else if(arrayLen(arrUser) EQ 2){
			form.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(arrUser[2]);
			form.user_id=arrUser[1];
		}
	}else{
		form.user_id_siteIDType="1";
		form.user_id="0";
	}

	if(error){
		application.zcore.status.setStatus(request.zsid, false,form,true);
		if(form.method EQ 'articleInsert'){
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleAdd?zsid=#Request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}else{
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleEdit?zsid=#Request.zsid#&blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}
	}
	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'articleInsert' and application.zcore.functions.zso(form, 'blog_unique_name') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'articleUpdate'){
		db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog 
		WHERE blog_id=#db.param(form.blog_id)# and 
		blog_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)#";
		qCheck=db.execute("qCheck"); 
		if(qcheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"This blog article no longer exists.");
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}
		oldURL=qCheck.blog_unique_name;
		if(qcheck.blog_unique_name NEQ form.blog_unique_name){
			uniqueChanged=true;	
		}
	}
	if(application.zcore.app.siteHasApp("listing")){
			if(form.method NEQ 'articleInsert') {
				 db.sql="SELECT mls_saved_search_id, blog_search_mls 
				 from #db.table("blog", request.zos.zcoreDatasource)# blog 
				WHERE blog_id = #db.param(form.blog_id)# and 
				blog_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)#";
				qId=db.execute("qId");
				form.mls_saved_search_id=qid.mls_saved_search_id;
			}else{
				form.mls_saved_search_id="";
			}
			if(application.zcore.functions.zso(form, 'blog_search_mls', false, 0) EQ 1) {
				form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.mls_saved_search_id, "", form);
			} else {
				form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.mls_saved_search_id);
			}
	}
	if(trim(application.zcore.functions.zso(form, 'blog_metakey')) EQ ""){
		form.blog_metakey=replace(replace(form.blog_title,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'blog_metadesc')) EQ ""){
		form.blog_metadesc=left(replace(replace(rereplacenocase(trim(form.blog_story&" "&form.blog_summary),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	if(form.method EQ "articleUpdate"){
		db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog 
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)#";
		qCheck=db.execute("qCheck"); 
		if(application.zcore.functions.zso(form, 'blog_metakey') EQ qCheck.blog_metakey and qCheck.blog_metakey NEQ ""){
			if(replace(replace(qCheck.blog_title,"|"," ","ALL"),","," ","ALL") EQ qCheck.blog_metakey){
				form.blog_metakey=replace(replace(form.blog_title,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'blog_metadesc') EQ qCheck.blog_metadesc and qCheck.blog_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(trim(qcheck.blog_story&" "&qCheck.blog_summary),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.blog_metakey){
				form.blog_metadesc=left(replace(replace(rereplacenocase(trim(form.blog_story&" "&form.blog_summary),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}

		StructDelete(variables,'blog_og_image');
		arrList=ArrayNew(1);
		application.zcore.functions.zCreateDirectory(application.zcore.functions.zVar('privatehomedir')&"zupload/blog/");
		if(form.method EQ 'insert'){
			arrList = application.zcore.functions.zUploadResizedImagesToDb("blog_og_image", application.zcore.functions.zVar('privatehomedir')&"zupload/blog/", '2048x1070');
		}else{
			arrList = application.zcore.functions.zUploadResizedImagesToDb("blog_og_image", application.zcore.functions.zVar('privatehomedir')&"zupload/blog/", '2048x1070', 'blog', 'blog_id', "blog_og_image_delete",request.zos.zcoreDatasource);
		}
		if(isarray(arrList) EQ false){
			application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
			StructDelete(form,'blog_og_image');
			StructDelete(variables,'blog_og_image');
		}else if(ArrayLen(arrList) NEQ 0){
			form.blog_og_image=arrList[1];
		}else{
			StructDelete(form,'blog_og_image');
		}
		if(application.zcore.functions.zso(form,'blog_og_image_delete',true) EQ 1){
			form.blog_og_image='';	
		}
	}
	if(left(form.blog_summary,100) NEQ left(form.blog_story,100)){
		form.blog_search=application.zcore.functions.zCleanSearchText(form.blog_title&' '&form.blog_summary&' '&form.blog_story);
	}else{
		form.blog_search=application.zcore.functions.zCleanSearchText(form.blog_title&' '&form.blog_summary&' '&form.blog_story);
	}
	if(application.zcore.functions.zso(form, 'convertLinks') EQ 1){
		form.blog_story=application.zcore.functions.zProcessAndStoreLinksInHTML(form.blog_title, form.blog_story);
	}

	form.blog_category_id_list=form.ccid;

	form.site_id=request.zos.globals.id;
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "blog";
	inputStruct.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'articleInsert'){
		form.blog_guid=createUUID();
		
		form.blog_id = application.zcore.functions.zInsert(inputStruct);
		if(form.blog_id EQ false){
			//Throw Error
			application.zcore.status.setStatus(request.zsid, 'There was an error adding this story.', form,true);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/articleAdd?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'This story has been added successfully.');
		}
	}else{
		// insert
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			// failed, on duplicate key or sql error
			application.zcore.status.setStatus(request.zsid, 'An error has occured while updating this story.', form,true);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/articleEdit?blog_id=#form.blog_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'This story was updated successfully.');
		}
	}
	if(form.ccid NEQ ''){
		arrCat=listtoarray(form.ccid,',');
		for(i=1;i LTE arraylen(ArrCat);i++){
			if(i EQ 1){
				db.sql="UPDATE #db.table("blog", request.zos.zcoreDatasource)#  
				SET blog_category_id = #db.param(arrCat[i])#,
				blog_updated_datetime = #db.param(request.zos.mysqlnow)#
				WHERE blog_id = #db.param(form.blog_id)# and 
				blog_deleted = #db.param(0)# and 
				site_id=#db.param(request.zos.globals.id)# ";
				a=db.execute("q"); 
			}
			db.sql="INSERT IGNORE INTO #db.table("blog_x_category", request.zos.zcoreDatasource)#  
			SET blog_id = #db.param(form.blog_id)#, 
			blog_x_category_updated_datetime = #db.param(request.zos.mysqlnow)#, 
			blog_x_category_deleted=#db.param(0)#, 
			blog_category_id = #db.param(arrCat[i])#, 
			site_id=#db.param(request.zos.globals.id)# ";
			db.execute("q"); 
		}	
		db.sql="DELETE FROM #db.table("blog_x_category", request.zos.zcoreDatasource)#  
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_x_category_deleted = #db.param(0)# and 
		blog_category_id NOT IN (";
		for(i=1;i LTE arraylen(ArrCat);i++){
			if(i NEQ 1){
				db.sql&=", ";
			}
			db.sql&="#db.param(arrCat[i])# ";
		}
		db.sql&=") and  
		site_id=#db.param(request.zos.globals.id)# ";
		db.execute("q");
	}
	 db.sql="DELETE from #db.table("blog_x_tag", request.zos.zcoreDatasource)#  
	WHERE blog_id = #db.param(form.blog_id)# and 
	blog_x_tag_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	db.execute("q"); 
	form.site_id=request.zos.globals.id;
	if(trim(form.blog_tags) NEQ ""){
		arrTagId=[];
		arrTag=listtoarray(form.blog_tags, chr(9));
		for(i=1;i LTE arraylen(arrTag);i++){
			form.blog_tag_name=trim(arrTag[i]);
			ts=StructNew();
			ts.struct=form;
			ts.table="blog_tag";
			ts.datasource=request.zos.zcoreDatasource;
			form.blog_tag_id=application.zcore.functions.zInsert(ts);
			if(form.blog_tag_id EQ false){
				db.sql="SELECT blog_tag_id FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
				WHERE blog_tag_name = #db.param(form.blog_tag_name)# and 
				blog_tag_deleted = #db.param(0)# and
				site_id=#db.param(request.zos.globals.id)#";
				qId=db.execute("qId"); 
				form.blog_tag_id=qid.blog_tag_id;
			}
			db.sql="INSERT INTO #db.table("blog_x_tag", request.zos.zcoreDatasource)#  
			SET blog_id = #db.param(form.blog_id)#, 
			blog_x_tag_updated_datetime = #db.param(request.zos.mysqlnow)#, 
			blog_x_tag_deleted=#db.param(0)#,
			blog_tag_id=#db.param(form.blog_tag_id)#, 
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("q"); 
			arrayAppend(arrTagId, form.blog_tag_id);
		}
		db.sql="DELETE FROM #db.table("blog_x_tag", request.zos.zcoreDatasource)#  
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_x_tag_deleted = #db.param(0)# and 
		blog_tag_id NOT IN (";
		for(i=1;i LTE arraylen(arrTagId);i++){
			if(i NEQ 1){
				db.sql&=", ";
			}
			db.sql&="#db.param(arrTagId[i])# ";
		}
		db.sql&=") and  
		site_id=#db.param(request.zos.globals.id)# ";
		q=db.execute("q"); 
	}
	
	
	db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog 
	WHERE blog_id = #db.param(form.blog_id)# and 
	blog_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)#";
	qT9=db.execute("qT9"); 
	application.zcore.functions.zQueryToStruct(qT9, form);
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.struct=form;
	ts.table="blog_version";
	ts.datasource=request.zos.zcoreDatasource;
	application.zcore.functions.zInsert(ts);
	if(uniqueChanged){
		application.zcore.app.getAppCFC("blog").updateRewriteRuleBlogArticle(form.blog_id, oldURL); 
	}

	application.zcore.siteOptionCom.activateOptionAppId(application.zcore.functions.zso(form, 'blog_site_option_app_id'));
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'blog_image_library_id'));
	application.zcore.app.getAppCFC("blog").searchReindexBlogArticles(form.blog_id, false);
	
	application.zcore.functions.zMenuClearCache({blogArticle=true});
	
	 
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/getReturnLayoutRowHTML?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}else{
		if(form.method EQ "articleInsert" and structkeyexists(request.zsession, 'blog_return') and request.zsession['blog_return'] NEQ ""){
			tempURL = request.zsession['blog_return'];
			StructDelete(request.zsession, 'blog_return', true);
			application.zcore.functions.zRedirect(replace(tempURL, "zsid=", "ztv=", "all"), true);
		}else if(structkeyexists(request.zsession, 'blog_return'&form.blog_id) and request.zsession['blog_return'&form.blog_id] NEQ "" and not uniqueChanged){	
			tempURL = request.zsession['blog_return'&form.blog_id];
			StructDelete(request.zsession, 'blog_return'&form.blog_id, true);
			application.zcore.functions.zRedirect(replace(tempURL, "zsid=", "ztv=", "all"), true);
		}else{	
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}
	}
	</cfscript>
</cffunction>


<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init(); 
	var db=request.zos.queryObject; 
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);
	form.blog_id=application.zcore.functions.zso(form, "blog_id", true, 0); 
 
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, SUM(c1.blog_comment_approved) approvedComments, count(distinct c1.blog_comment_id) totalComments
	 #db.trustedSQL(rs2.select)#  
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_category.blog_category_id = blog.blog_category_id  and 
	blog.site_id = blog_category.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# c1 ON 
	c1.blog_id = blog.blog_id and 
	blog.site_id = c1.site_id and 
	c1.blog_comment_deleted = #db.param(0)# 
	#db.trustedSQL(rs2.leftJoin)#
	WHERE blog.site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and 
	site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	blog.blog_id=#db.param(form.blog_id)# "; 
	db.sql&=" group by blog.blog_id ";
	qBlog=db.execute("qBlog"); 
 
	savecontent variable="rowOut"{
		for(row in qblog){
			getLayoutRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>

<cffunction name="getLayoutRowHTML" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;  
	</cfscript>
	<cfscript>
	arrImages=[];
	if(row.blog_image_library_id NEQ 0){
		ts=structnew();
		ts.image_library_id=row.blog_image_library_id;
		ts.output=false;
		ts.struct=row;
		ts.size="100x70";
		ts.crop=1;
		ts.count = 1;
		arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts);
	}
	contentphoto99=""; 
	if(arraylen(arrImages) NEQ 0){
		contentphoto99=(arrImages[1].link);
	}

	arrCategory=application.zcore.app.getAppCFC("blog").getCategoriesByIdList(row.blog_category_id_list);
	</cfscript>
	<td class="z-hide-at-767">#row.blog_id#</td>
	<td class="z-hide-at-767" style="vertical-align:top; width:100px; ">
		<cfif contentphoto99 NEQ "">
			<img alt="Image" src="#request.zos.currentHostName&contentphoto99#" style="max-width:100%;" /></a>
		<cfelse> 
		</cfif></td>
	<td>#row.blog_title#</td> 
	<td class="z-hide-at-767"><cfscript>
		first=true;
		for(category in arrCategory){
			if(not first){
				echo(', ');
			}
			first=false;
			echo(category.name);
		}
		</cfscript></td>
	<td style="width:145px;">#dateformat(row.blog_datetime, 'm/d/yyyy')# @ #timeformat(row.blog_datetime, 'h:mm tt')#</td>
	<td class="z-manager-admin z-manager-blog-admin">
		<cfscript>
		if(row.blog_unique_name NEQ ''){
			viewlink=row.blog_unique_name;
		}else{
			viewlink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,row.blog_id,"html",row.blog_title,row.blog_datetime);
		}
		/*if(row.blog_status EQ 2 or (row.blog_status EQ 1 and datecompare(parsedatetime(dateformat(row.blog_datetime,'yyyy-mm-dd')),now()) EQ 1)){
			viewlink&"?preview=1";
		}*/
		previewEnabled=false;
		if(row.blog_status EQ 2 or (row.blog_status EQ 1 and datecompare(parsedatetime(dateformat(row.blog_datetime,'yyyy-mm-dd')),now()) EQ 1)){
			previewEnabled=true;
			viewlink&="?preview=1";

		}
		</cfscript>
		<cfif previewEnabled>
			<div class="z-manager-button-container">
				<a title="Inactive"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
			</div>
		<cfelse> 
			<div class="z-manager-button-container">
				<a title="Active"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
			</div>
		</cfif>
		<div class="z-manager-button-container">
			<a href="#viewlink#"  class="z-manager-view" target="_blank" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a>
		</div>

		<cfscript>
		hasMultipleLinks=false;
		if(application.zcore.app.siteHasApp("listing")){
			hasMultipleLinks=true;
		}else if(not application.zcore.user.checkServerAccess() and row.blog_unique_name NEQ ""){
			hasMultipleLinks=true;
		}
		</cfscript>

		<div class="z-manager-button-container">
			<cfif hasMultipleLinks>
				<a href="##" class="z-manager-edit" id="z-manager-edit#row.blog_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
				<div class="z-manager-edit-menu">
				
					<a href="/z/blog/admin/blog-admin/articleEdit?blog_id=#row.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit Page</a>
					<cfif row.blog_search_mls EQ 1>
						<a href="#request.zos.currentHostName##application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), "zsearch_bid=#row.blog_id#")#" target="_blank">Search Results Only</a>
					</cfif>

					<cfif not application.zcore.user.checkServerAccess() and row.blog_unique_name NEQ "">
						Delete disabled
					</cfif>
				</div>
			<cfelse>
				<a href="/z/blog/admin/blog-admin/articleEdit?blog_id=#row.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;" class="z-manager-edit" id="z-manager-edit#row.blog_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
			</cfif>
		</div>
		<cfscript>
		if(!application.zcore.functions.zIsExternalCommentsEnabled()){
			newCount=0;
			if(row.totalComments-row.approvedComments NEQ 0){
				newCount=row.totalComments-row.approvedComments;
			}
			echo('<div class="z-manager-button-container"><a href="/z/blog/admin/blog-admin/commentList?blog_id=#row.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#" title="Comments (#row.totalComments-newCount# Approved, #newCount# New)"><i class="fa fa-comment" aria-hidden="true" style="');
			if(newCount NEQ 0){
				echo('color:##900; ');
			}else{
				echo('color:##090; ');
			}
			echo('"></i></a></div>');
		}
		</cfscript> 
 
		<cfif application.zcore.user.checkServerAccess() or row.blog_unique_name EQ "">
			<div class="z-manager-button-container">
				<a href="##" onclick="zDeleteTableRecordRow(this, '/z/blog/admin/blog-admin/blogDelete?blog_id=#row.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;returnJson=1&amp;confirm=1'); return false;" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
			</div>
		</cfif>


	</td>
</cffunction>

<cffunction name="blogDelete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var qlist=0;
	var db=request.zos.queryObject;
	var qdelete=0;
	var res=0;
	this.init();
	form.returnJson=application.zcore.functions.zso(form, 'returnJSON', true, 0);
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	db.sql="select *
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	
	WHERE blog_id = #db.param(form.blog_id)# and
	site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	blog_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)#";
	qList=db.execute("qList");
	if(qList.recordcount EQ 0){
		if(form.returnJson){
			application.zcore.functions.zReturnJson({success:false, errorMessage:"This article no longer exists."});
		}else{
			application.zcore.status.setStatus(request.zsid,"This article no longer exists.");
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");	
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.app.siteHasApp("listing")){
		request.zos.listing.functions.zMLSSearchOptionsUpdate('delete',qlist.mls_saved_search_id);
		}


		if(qList.blog_og_image NEQ ""){
			application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&"zupload/blog/"&qList.blog_og_image);
		}

		application.zcore.siteOptionCom.deleteOptionAppId(qList.blog_site_option_app_id);
		application.zcore.app.getAppCFC("blog").searchIndexDeleteBlogArticle(form.blog_id);
		db.sql="delete
		from #db.table("blog", request.zos.zcoreDatasource)# 
		WHERE blog_id = #db.param(form.blog_id)# and
		blog_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qDelete=db.execute("qDelete");
			
		db.sql="DELETE FROM #db.table("blog_x_category", request.zos.zcoreDatasource)#  
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_x_category_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)# ";
		db.execute("q");
		db.sql="DELETE from #db.table("blog_x_tag", request.zos.zcoreDatasource)#  
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_x_tag_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)# ";
		db.execute("q");
			
		application.zcore.imageLibraryCom.deleteImageLibraryId(qList.blog_image_library_id);
		application.zcore.functions.zDeleteUniqueRewriteRule(qList.blog_unique_name);
		application.zcore.functions.zMenuClearCache({blogArticle=true});

		if(form.returnJson){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(request.zsid, 'Your story has been deleted.');
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}
		</cfscript>
	<cfelse>
		<h2>Are you sure you want to delete #qList.blog_title#?<br />
		<br />
		<a href="/z/blog/admin/blog-admin/blogDelete?confirm=yes&amp;blog_id=#form.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/blog/admin/blog-admin/articleList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">No</a></h2>
	</cfif>
</cffunction>



<cffunction name="articleList" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qlist=0;
	var qCount=0;
	var qList=0;
	var start=0;
	var searchStruct=0;
	var db=request.zos.queryObject;
		var searchNav=0;
	this.init();
	application.zcore.functions.zSetPageHelpId("3.1");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	if(structkeyexists(form, 'searchText')){
		request.zsession.blogSearchText=form.searchText;
	}else if(structkeyexists(form, 'searchText')){
		form.searchText=request.zsession.blogSearchText;
	}
	
	form.searchText				= trim(application.zcore.functions.zso(form, 'searchText'));
	form.searchBlogCategoryId	= application.zcore.functions.zso(form, 'searchBlogCategoryId');
	searchTextOriginal=replace(replace(replace(form.searchText, '+', ' ', 'all'), '@', '_', 'all'), '"', '', "all");
	if(not isnumeric(searchTextOriginal)){
		form.searchText=application.zcore.functions.zCleanSearchText(form.searchText, true);
		if(form.searchText NEQ "" and isNumeric(form.searchText) EQ false and len(form.searchText) LTE 2){
			application.zcore.status.setStatus(request.zsid,"The search searchText must be 3 or more characters.",form);
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}
	}
	searchTextReg=rereplace(form.searchText,"[^A-Za-z0-9[[:white:]]]*",".","ALL");
	searchTextOReg=rereplace(searchTextOriginal,"[^A-Za-z0-9 ]*",".","ALL");
	
	if(application.zcore.functions.zso(form, 'ListID') EQ ''){ 
		  form.ListId = application.zcore.status.getNewId(); 
	 } 
	 if(structkeyexists(form, 'zIndex')){ 
		  application.zcore.status.setField(form.ListID,'zIndex', form.zIndex); 
	 }
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = ""; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.url = "/z/blog/admin/blog-admin/articleList";  
	searchStruct.buttons = 5; 
	// set from query string or default value 
	searchStruct.perpage = 30;	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = application.zcore.status.getField(form.ListId, "zIndex",1); 
	start = searchStruct.perpage * searchStruct.index - 30;
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, SUM(c1.blog_comment_approved) approvedComments, count(distinct c1.blog_comment_id) totalComments";
	if(form.searchtext NEQ ''){
		if(application.zcore.enableFullTextIndex){
			db.sql&=" , MATCH(blog.blog_search) AGAINST (#db.param(form.searchText)#) as score,
			MATCH(blog.blog_search) AGAINST (#db.param(searchTextOriginal)#) as score2 ";
		}
	}
	db.sql&=" #db.trustedSQL(rs2.select)#  
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_category.blog_category_id = blog.blog_category_id  and 
	blog.site_id = blog_category.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# c1 ON 
	c1.blog_id = blog.blog_id and 
	blog.site_id = c1.site_id and 
	c1.blog_comment_deleted = #db.param(0)# 
	#db.trustedSQL(rs2.leftJoin)#
	WHERE blog.site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and 
	site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
	if(form.searchBlogCategoryId NEQ ''){
		db.sql &= " and blog.blog_category_id = #db.param(form.searchBlogCategoryId)# ";
	}
	if(searchTextOriginal NEQ ''){
		db.sql&=" and 
		
		(blog.blog_id = #db.param(searchTextOriginal)# or 
			(
				( ";
				if(application.zcore.enableFullTextIndex){
					db.sql&="
					MATCH(blog.blog_search) AGAINST (#db.param(form.searchText)#) or 
					MATCH(blog.blog_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchText, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) 
					";
				}else{
					db.sql&=" blog.blog_search like #db.param('%#replace(form.searchText,' ','%','ALL')#%')# ";
				}
				db.sql&=" ) or ( ";
				
				if(application.zcore.enableFullTextIndex){
					db.sql&="
					MATCH(blog.blog_search) AGAINST (#db.param(searchTextOriginal)#) or 
					MATCH(blog.blog_search) AGAINST (#db.param('+#replace(trim(replace(replace(searchTextOriginal, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE)
					";
				}else{
					db.sql&=" blog.blog_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')# ";
				}
				db.sql&="
				)
			) 
		) ";
	}
	db.sql&=" group by blog.blog_id 
	ORDER BY 
		blog_datetime desc 
		LIMIT #db.param(start)#, #db.param(searchStruct.perpage)#";
	qList=db.execute("qList");
	</cfscript>
	<cfsavecontent variable="db.sql">
	select count(blog_id) as count 
	from #db.table("blog", request.zos.zcoreDatasource)# blog 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	blog_deleted = #db.param(0)#
	<cfif form.searchBlogCategoryId NEQ ''>
		and blog_category_id = #db.param(form.searchBlogCategoryId)#
	</cfif>
	<cfif searchTextOriginal NEQ ''>
		and 
		
		(blog.blog_id = #db.param(searchTextOriginal)# or 
			(
				(
				<cfif application.zcore.enableFullTextIndex>
					MATCH(blog.blog_search) AGAINST (#db.param(form.searchText)#) or 
					MATCH(blog.blog_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchText, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) 
				<cfelse>
					blog.blog_search like #db.param('%#replace(form.searchText,' ','%','ALL')#%')#
				</cfif>
				) or (
				
				<cfif application.zcore.enableFullTextIndex>
					MATCH(blog.blog_search) AGAINST (#db.param(searchTextOriginal)#) or 
					MATCH(blog.blog_search) AGAINST (#db.param('+#replace(trim(replace(replace(searchTextOriginal, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE)
				<cfelse>
					blog.blog_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
				</cfif>
				)
			) 
		)
	</cfif>
	</cfsavecontent>
	<cfscript>
		qCount=db.execute("qCount");
		searchStruct.count = qCount.count;
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
		db.sql = "SELECT blog_category_id, blog_category_name
		FROM #db.table("blog_category", request.zos.zcoreDatasource)# blog  
		WHERE site_id = #db.param(request.zos.globals.id)#
		AND blog_category_deleted = #db.param(0)#";
		qCategory = db.execute("qCategory");

	echo('<div class="z-manager-list-view">');
	echo('<div class="z-float z-mb-10">'); 
	echo('<h2 style="display:inline-block;">');
	if(searchTextOriginal NEQ ""){
		echo('Blog Articles | Search Results');
	}else{
		echo('Blog Articles');
	}
	echo('</h2>'); 
	echo(' &nbsp;&nbsp; <a href="/z/blog/admin/blog-admin/articleAdd?returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#" class="z-button">Add</a>
	</div>');
	</cfscript> 
	<form name="myForm22" action="/z/blog/admin/blog-admin/articleList?site_x_option_group_set_id=#form.site_x_option_group_set_id#" method="GET" style="margin:0px;">
		<input type="hidden" name="method" value="list" />
		<div class="z-float z-mb-10">
			<input type="text" name="searchtext" id="searchtext" placeholder="ID or Keyword" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" style="min-width:200px;width:75%; max-width:400px;" size="20" maxchars="10" /> 
			<select id="searchBlogCategoryId" name="searchBlogCategoryId">
				<option value=""></option>
				<cfloop query="qCategory">
					<cfif form.searchBlogCategoryId EQ qCategory.blog_category_id>
						<option selected value="#qCategory.blog_category_id#">#qCategory.blog_category_name#</option>
					<cfelse>
						<option value="#qCategory.blog_category_id#">#qCategory.blog_category_name#</option>
					</cfif>
				</cfloop>
			</select>

			<input type="submit" name="searchForm" value="Search" class="z-manager-search-button" /> 
			<cfif application.zcore.functions.zso(form, 'searchtext') NEQ ''> | 
				<input type="button" name="searchForm2" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/blog/admin/blog-admin/articleList?searchtext=';" />
			</cfif>
			<input type="hidden" name="zIndex" value="1" />
		</div>
	</form> 
	<cfif qlist.recordcount NEQ 0>
	#searchNAV#
	<table style="border-spacing:0px; border:0; width:100%;" class="table-list">
		<tr>
			<th class="z-hide-at-767" style="width:25px; " >ID</th>
			<th class="z-hide-at-767"  style="width:100px;">Photo</th>
			<th >Title</th> 
			<th class="z-hide-at-767">Category</th>
			<th style="width:145px;">Date &amp; Time</th>
			<th style="width:200px;">Admin</th>
		</tr>
		
	<cfscript>
	currentRow=0;
	for(row in qList){
		currentRow++;
		echo('<tr');
		if(currentRow MOD 2){
			echo(' class="row2"');
		}else{
			echo(' class="row1"');
		}
		echo('>');
		row.currentRow=currentRow;
		echo(getLayoutRowHTML(row));

		echo('</tr>');
	}
	</cfscript> 
	</table>
	#searchNAV#
	</cfif>
	</div>
	
</cffunction>








<cffunction name="tagInsert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.tagUpdate();
	</cfscript>
</cffunction>

<cffunction name="tagUpdate" localmode="modern" access="remote" roles="member">
	<cfscript>
	var tempURL=0;
	var qT9=0;
	var ts=0;
	var res=0;
	var db=request.zos.queryObject;
	var uniqueChanged=0;
	var inputStruct=0;
	var qCheck=0;
	var db=request.zos.queryObject;
	var blogform=0;
	var error=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Tags", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	uniqueChanged=false;
	oldURL="";
	//if(application.zcore.user.checkSiteAccess()){
		if(form.method EQ 'tagInsert' and application.zcore.functions.zso(form, 'blog_tag_unique_name') NEQ ""){
			uniqueChanged=true;
		}
		if(form.method EQ 'tagUpdate'){
			 db.sql="select * from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
			WHERE blog_tag_id=#db.param(form.blog_tag_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			blog_tag_deleted = #db.param(0)#";
			qCheck=db.execute("qCheck");
			if(qcheck.recordcount EQ 0){
				application.zcore.status.setStatus(request.zsid,"This tag no longer exists.");
				application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/tagList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
			}
			oldURL=qCheck.blog_tag_unique_name;
			if(qcheck.blog_tag_unique_name NEQ form.blog_tag_unique_name){
				uniqueChanged=true;	
			}
		}
	//}

	
	blogform = StructNew();
	blogform.blog_tag_name.required=true;
	error = application.zcore.functions.zValidateStruct(form, blogform, request.zsid, true);


	if(application.zcore.functions.zso(form,'blog_tag_unique_name') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'blog_tag_unique_name'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		error=true;
	}
	if(error){	
		application.zcore.status.setStatus(request.zsid,"Please correct the following validation errors.",form,true);
		if(form.method EQ 'tagInsert'){
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/tagAdd?zsid=#Request.zsid#&ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}else{
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/tagEdit?zsid=#Request.zsid#&ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&blog_tag_id=#form.blog_tag_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}
	}

	if(application.zcore.app.siteHasApp("listing")){
	if(form.method NEQ 'tagInsert') {
		db.sql="SELECT blog_tag_saved_search_id, blog_tag_search_mls 
		FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
		WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		blog_tag_deleted = #db.param(0)#";
		qId=db.execute("qId"); 
		form.blog_tag_saved_search_id=qid.blog_tag_saved_search_id;
	}else{
		form.blog_tag_saved_search_id="";
	}
	if(form.blog_tag_search_mls EQ 1) {
		form.blog_tag_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.blog_tag_saved_search_id, '', form);
	} else {
		form.blog_tag_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.blog_tag_saved_search_id);
	}
	}
	if(trim(application.zcore.functions.zso(form, 'blog_tag_metakey')) EQ ""){
		form.blog_tag_metakey=replace(replace(form.blog_tag_name,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'blog_tag_metadesc')) EQ ""){
		form.blog_tag_metadesc=left(replace(replace(rereplacenocase(form.blog_tag_description,"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	if(form.method EQ "tagUpdate"){
		db.sql="select * from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
		WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_tag_deleted = #db.param(0)#"; 
		qCheck=db.execute("qCheck");
		if(application.zcore.functions.zso(form, 'blog_tag_metakey') EQ qCheck.blog_tag_metakey and qCheck.blog_tag_metakey NEQ ""){
			if(replace(replace(qCheck.blog_tag_name,"|"," ","ALL"),","," ","ALL") EQ qCheck.blog_tag_metakey){
				form.blog_tag_metakey=replace(replace(form.blog_tag_name,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'blog_tag_metadesc') EQ qCheck.blog_tag_metadesc and qCheck.blog_tag_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(qcheck.blog_tag_description,"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.blog_tag_metakey){
				form.blog_tag_metadesc=left(replace(replace(rereplacenocase(form.blog_tag_description,"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}
	}


	if(application.zcore.functions.zso(form, 'convertLinks') EQ 1){
		form.blog_tag_description=application.zcore.functions.zProcessAndStoreLinksInHTML(form.blog_tag_name, form.blog_tag_description);
	}
	
		form.blog_tag_search=application.zcore.functions.zCleanSearchText(form.blog_tag_name&' '&form.blog_tag_description);
		
		form.site_id=request.zos.globals.id;
		//Update
		inputStruct = StructNew();
	inputStruct.struct=form;
		inputStruct.table = "blog_tag";
		inputStruct.datasource=request.zos.zcoreDatasource;

	if(form.method EQ 'tagInsert'){
		form.blog_tag_id = application.zcore.functions.zInsert(inputStruct);
		if(form.blog_tag_id EQ false){
			//Throw Error
			application.zcore.status.setStatus(request.zsid, 'The tag name, "#form.blog_tag_name#", already exists. Please type a unique tag name.', form,true);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/tagAdd?ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'This tag has been added successfully.');
		}
	}else{
		// insert
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			// failed, on duplicate key or sql error
			application.zcore.status.setStatus(request.zsid, 'The tag name, "#form.blog_tag_name#", already exists. Please type a unique tag name.', form,true);
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/tagEdit?blog_tag_id=#form.blog_tag_id#&ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'This tag was updated successfully.');
		}
	}
	
	 db.sql="select * from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
	WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	blog_tag_deleted = #db.param(0)#";
	qT9=db.execute("qT9");
	application.zcore.functions.zQueryToStruct(qT9, form);
	ts=StructNew();
	ts.table="blog_tag_version";
ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	form.site_id=request.zos.globals.id;
	application.zcore.functions.zInsert(ts);
	if(uniqueChanged){
		application.zcore.app.getAppCFC("blog").updateRewriteRuleBlogTag(form.blog_tag_id, oldURL); 
	}
	application.zcore.siteOptionCom.activateOptionAppId(application.zcore.functions.zso(form, 'blog_tag_site_option_app_id'));
	application.zcore.app.getAppCFC("blog").searchReindexBlogTags(form.blog_tag_id, false);
	
	if(form.method EQ "tagInsert" and structkeyexists(request.zsession, 'blogtag_return') and request.zsession['blogtag_return'] NEQ ""){
			tempURL = request.zsession['blogtag_return'];
			StructDelete(request.zsession, 'blogtag_return', true);
			application.zcore.functions.zRedirect(replace(tempURL, "zsid=", "ztv=", "all"), true);
	}else if(structkeyexists(form, 'blog_tag_id') and structkeyexists(request.zsession, 'blogtag_return'&form.blog_tag_id) and request.zsession['blogtag_return'&form.blog_tag_id] NEQ "" and uniqueChanged EQ false){	
		tempURL = request.zsession['blogtag_return'&form.blog_tag_id];
		StructDelete(request.zsession, 'blogtag_return'&form.blog_tag_id, true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/tagList?ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
	}
	</cfscript>
</cffunction>



<cffunction name="tagList" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qT=0;
	var qCount=0;
	var db=request.zos.queryObject;
	var selectStruct=0;
	var searchStruct=0;
	var searchNAV=0;
	this.init();
	application.zcore.functions.zSetPageHelpId("3.6");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Tags"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	
	if(application.zcore.functions.zso(form, 'ListTagID') EQ ''){ 
		form.ListTagId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex')){ 
		application.zcore.status.setField(form.ListTagID,'zIndex', form.zIndex); 
	}else{
		form.zindex = application.zcore.status.getField(form.ListTagId, "zIndex",1); 
	}
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Tags "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.index=form.zIndex;
	searchStruct.url = '/z/blog/admin/blog-admin/tagList';  
	searchStruct.buttons = 7; 
	// set from query string or default value 
	searchStruct.perpage = 30;	


	echo('<div class="z-float z-mb-10">'); 
	echo('<h2 style="display:inline-block;">Blog Tags</h2>'); 
	echo(' &nbsp;&nbsp; <a href="/z/blog/admin/blog-admin/tagAdd?returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#" class="z-button">Add</a>
	</div>');
	</cfscript>

	<cfsavecontent variable="db.sql">
	SELECT count(blog_tag.blog_tag_id) count 
	FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
	WHERE  site_id=#db.param(request.zos.globals.id)# and 
	blog_tag_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qCount=db.execute("qCount");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT *, if(blog_x_tag.blog_tag_id IS NULL,#db.param(0)#,count(blog_x_tag.blog_tag_id)) count 
	FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
	LEFT JOIN #db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag on 
	blog_x_tag.blog_tag_id = blog_tag.blog_tag_id and 
	blog_tag.site_id = blog_x_tag.site_id and
	blog_x_tag_deleted = #db.param(0)#
	WHERE  blog_tag.site_id=#db.param(request.zos.globals.id)# and 
	blog_tag_deleted = #db.param(0)#
	GROUP BY blog_tag.blog_tag_id ORDER BY blog_tag_name ASC 
	LIMIT #db.param((form.zIndex-1)*searchStruct.perpage)#,#db.param(searchStruct.perpage)#
	</cfsavecontent><cfscript>qT=db.execute("qT");
		searchStruct.count = qCount.count;
		if(qCount.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
		}
	</cfscript>
	#searchNAV#
	<table style="border-spacing:0px; border:0; width:100%;" class="table-list">
		<tr>
			<th style="width:25px; " >ID</th>
			<th >Tag</th>
			<th >Associated Articles</th>
			<th >Admin</th>
		</tr>
	<cfloop query="qT">
		<tr <cfif qT.currentrow MOD 2>class="row2"<cfelse>class="row1"</cfif>>
			<td>#qT.blog_id#</td>
			<td>#qT.blog_tag_name#</td>
			<td>#qT.count#</td>
			<td><cfif qT.count NEQ 0><a href="<cfif qT.blog_tag_unique_name NEQ ''>#qT.blog_tag_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_tag_id, qT.blog_tag_id,"html", qT.blog_tag_name)#</cfif>" target="_blank">View</a> | </cfif>
			<a href="/z/blog/admin/blog-admin/tagEdit?ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&amp;blog_tag_id=#qT.blog_tag_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Edit</a> | 
				<cfif not application.zcore.user.checkServerAccess() and qT.blog_tag_unique_name NEQ "">
					Delete disabled
				<cfelse> 
					<a href="/z/blog/admin/blog-admin/tagDelete?ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&amp;blog_tag_id=#qT.blog_tag_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Delete</a>
				</cfif>
			</td>
		</tr>
	</cfloop>
	#searchNAV#
	</table>
</cffunction>


<cffunction name="tagDelete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qList=0;
	var qDelete=0;
	var db=request.zos.queryObject;
	this.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Tags", true); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	</cfscript>
	<cfsavecontent variable="db.sql">
	select *
	from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag
	WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
	blog_tag_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qList=db.execute("qList");
	if(qList.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"This article no longer exists.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");	
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.app.siteHasApp("listing")){
			request.zos.listing.functions.zMLSSearchOptionsUpdate('delete',qlist.blog_tag_saved_search_id);
		}
		application.zcore.siteOptionCom.deleteOptionAppId(qList.blog_tag_site_option_app_id);
		application.zcore.functions.zDeleteUniqueRewriteRule(qList.blog_tag_unique_name);
		application.zcore.app.getAppCFC("blog").searchIndexDeleteBlogTag(form.blog_tag_id);
		db.sql="delete from #db.table("blog_tag", request.zos.zcoreDatasource)# 
		WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_tag_deleted = #db.param(0)#";
		qDelete=db.execute("qDelete");
		db.sql="delete from #db.table("blog_x_tag", request.zos.zcoreDatasource)# 
		WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
		blog_x_tag_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qDelete=db.execute("qDelete");
		application.zcore.status.setStatus(request.zsid, 'Your tag has been deleted.');
		application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/tagList?ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		</cfscript>
	<cfelse>
		<cfscript>
		db.sql="select *
		from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag
		WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_tag_deleted = #db.param(0)#";
		qList=db.execute("qList");
		</cfscript>
		<h2>Are you sure you want to delete #qList.blog_tag_name#?<br />
		<br />
		<a href="/z/blog/admin/blog-admin/tagDelete?confirm=yes&amp;ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&amp;blog_tag_id=#form.blog_tag_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/blog/admin/blog-admin/tagList?ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">No</a></h2>
	</cfif>
</cffunction>

<cffunction name="tagAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.tagEdit();
	</cfscript>
</cffunction>

<cffunction name="tagEdit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var htmlEditor=0;
	var ts=0;
	var tabCom=0;
	var cancelURL=0;
	var newAction=0;
	var qEdit=0;
	var db=request.zos.queryObject;
	application.zcore.functions.zSetPageHelpId("3.7");
	backupMethod=form.method;
	this.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Tags"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	form.blog_tag_id=application.zcore.functions.zso(form, 'blog_tag_id',false,-1);
	request.zsession["blogtag_return"&form.blog_tag_id]=application.zcore.functions.zso(form, "returnURL");
	</cfscript>
		<cfsavecontent variable="db.sql">
		select *
		from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag
		WHERE blog_tag_id = #db.param(form.blog_tag_id)# and 
		blog_tag_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>qEdit=db.execute("qEdit");</cfscript>
		<cfif backupMethod EQ 'tagEdit'>
			<h2>Edit Tag: "#qEdit.blog_tag_name#"</h2>
		<cfelse>
			<h2>Add Tag</h2>
		</cfif>
		<cfscript>
		application.zcore.functions.zQueryToStruct(qEdit, form);
		application.zcore.functions.zStatusHandler(request.zsid,true, false, form);
		</cfscript>
		* denotes required field.
		<cfscript>
		ts=StructNew();
		ts.name="zMLSSearchForm";
		ts.ajax=false;
		if(backupMethod EQ 'tagAdd'){
			newAction="tagInsert";
		}else{
			newAction="tagUpdate";
		}
		ts.class="zFormCheckDirty";
		ts.enctype="multipart/form-data";
		ts.action="/z/blog/admin/blog-admin/#newAction#?blog_tag_id=#form.blog_tag_id#&ListTagId=#application.zcore.functions.zso(form, 'listTagId')#&site_x_option_group_set_id=#form.site_x_option_group_set_id#";
		ts.method="post";
		ts.successMessage=false;
		if(application.zcore.app.siteHasApp("listing")){
			ts.onLoadCallback="loadMLSResults";
			ts.onChangeCallback="getMLSCount";
		}
		application.zcore.functions.zForm(ts);
		
tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
tabCom.setMenuName("member-blog-tag-edit");
cancelURL=application.zcore.functions.zso(request.zsession, 'blogtag_return'&form.blog_tag_id);
if(cancelURL EQ ""){
	cancelURL="/z/blog/admin/blog-admin/tagList?site_x_option_group_set_id=#form.site_x_option_group_set_id#";
}
tabCom.setCancelURL(cancelURL);
tabCom.enableSaveButtons();
</cfscript>
#tabCom.beginTabMenu()#
   #tabCom.beginFieldSet("Basic")# 
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th style="width:120px;">#application.zcore.functions.zOutputHelpToolTip("Tag Name","member.blog.editTag blog_tag_name")# </th>
				<td>
					<input type="text" name="blog_tag_name" value="#form.blog_tag_name#" style="width:95%;"> *
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Description","member.blog.editTag blog_tag_description")#</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "blog_tag_description";
					htmlEditor.value			= form.blog_tag_description;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript>
				</td>
			</tr>
		<tr>
			<th style="width:1%; white-space:nowrap;">Cache External Images:</th>
			<td>
			<cfscript>
			form.convertLinks=application.zcore.functions.zso(form, 'convertLinks', true, 0); 
			ts = StructNew();
			ts.name = "convertLinks";
			ts.radio=true;
			ts.separator=" ";
			ts.listValuesDelimiter="|";
			ts.listLabelsDelimiter="|";
			ts.listLabels="Yes|No";
			ts.listValues="1|0";
			application.zcore.functions.zInput_Checkbox(ts);
			</cfscript> | Selecting "Yes", will cache the external images in the html editor to this domain.
			</td>
		</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.blog.editTag blog_tag_metakey")#</th>
				<td>
					<textarea name="blog_tag_metakey" style="width:100%; height:60px; ">#form.blog_tag_metakey#</textarea>
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.blog.editTag blog_tag_metadesc")#</th>
				<td>
					<textarea name="blog_tag_metadesc" style="width:100%; height:60px; ">#form.blog_tag_metadesc#</textarea>
				</td>
			</tr>
			</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")# 
	<table style="border-spacing:0px; width:100%; border:'0';" class="table-list">
		<tr>
		<th style="width:120px; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Custom Fields","member.blog.editTag blog_tag_site_option_app_id")#</th>
		<td colspan="2">
		<cfscript>
		ts=structnew();
		ts.name="blog_tag_site_option_app_id";
		ts.app_id=application.zcore.app.getAppCFC("blog").app_id;
		ts.value=form.blog_tag_site_option_app_id;
		application.zcore.siteOptionCom.getOptionForm(ts);
		</cfscript>
		</td>
		</tr>
		<tr> 
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Unique URL","member.blog.editTag blog_tag_unique_name")#</th>
		<td style="vertical-align:top; ">
				<cfif form.method EQ "tagAdd">
					#application.zcore.functions.zInputUniqueUrl("blog_tag_unique_name", true)#
				<cfelse>
					#application.zcore.functions.zInputUniqueUrl("blog_tag_unique_name")#
				</cfif>
			</td>
		</tr>
		</table>
		#application.zcore.hook.trigger("blog.tagEditCustomFields", {query=qEdit})#

		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
		<cfscript>application.zcore.functions.zEndForm();</cfscript>
</cffunction>



<cffunction name="articleAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.articleEdit();
	</cfscript>
</cffunction>

<cffunction name="articleEdit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var currentMethod=form.method;
	this.init();
	application.zcore.functions.zSetPageHelpId("3.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]); 
	form.blog_id=application.zcore.functions.zso(form, 'blog_id',false,"");
	request.zsession["blog_return"&form.blog_id]=application.zcore.functions.zso(form, "returnURL");
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="select *
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	WHERE blog_id = #db.param(form.blog_id)# and 
	blog_deleted = #db.param(0)# and
	site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qEdit=db.execute("qEdit");
	</cfscript>
	<cfif currentMethod EQ "articleEdit">
		<h2>Edit Article</h2>
	<cfelse>
		<h2>Add Article</h2>
		<cfscript>
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		</cfscript>
	</cfif>
	<cfscript> 
	application.zcore.functions.zQueryToStruct(qEdit, form, 'site_x_option_group_set_id'); 
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form); 
	if(isdate(form.blog_datetime) eq false){
		form.blog_datetime=now();
	}
	</cfscript>
	* denotes required field.
	<cfscript>
	ts=StructNew();
	ts.name="zMLSSearchForm";
	if(currentMethod EQ "articleAdd"){
		newAction="articleInsert";
	}else{
		newAction="articleUpdate";
	}
	ts.ajax=false;
	ts.enctype="multipart/form-data";
	ts.action="/z/blog/admin/blog-admin/#newAction#?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#&modalpopforced=#form.modalpopforced#";
	ts.method="post";
	ts.class="zFormCheckDirty";
	ts.successMessage=false;
	if(application.zcore.app.siteHasApp("listing")){
		ts.onLoadCallback="loadMLSResults";
		ts.onChangeCallback="getMLSCount";
	}
	application.zcore.functions.zForm(ts);
		
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
	tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
	tabCom.setMenuName("member-blog-edit");
	cancelURL=application.zcore.functions.zso(request.zsession, 'blog_return'&form.blog_id);
	if(cancelURL EQ ""){
		cancelURL="/z/blog/admin/blog-admin/articleList";
	}
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	if(form.modalpopforced EQ 1){
		echo('
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			$(".tabCancelButton").on("click", function(e){
				e.preventDefault();
				window.parent.zCloseModal();
				return false;
			});
		});
		</script>
		');
	}
	</cfscript>
	#tabCom.beginTabMenu()#
   #tabCom.beginFieldSet("Basic")# 
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="width:120px;">#application.zcore.functions.zOutputHelpToolTip("Title","member.blog.edit blog_title")# * </th>
				<td>
					<input type="text" name="blog_title" value="#htmleditformat(form.blog_title)#" style="width:95%;">
				</td>
			</tr>
			<cfif application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_disable_author', true, 0) EQ 0>
				<tr>
					<th style="width:120px;">#application.zcore.functions.zOutputHelpToolTip("Author","member.blog.edit uid")# *</th>
					<td>
			<cfscript>
			if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_show_parent_site_authors', true, 1) EQ 0){
				qUser=application.zcore.user.getUsersWithGroupAccess("member", true);
			}else{
				qUser=application.zcore.user.getUsersWithGroupAccess("member", false);
			}
			// blog_config_show_parent_site_authors
			if(application.zcore.functions.zso(form, 'user_id',true) NEQ 0){
			if(form.user_id_siteIdType EQ 0){
				form.user_id_siteIdType=1;
			}
				form.uid=form.user_id&"|"&application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIdType);
			}else if(application.zcore.functions.zso(form, 'uid') EQ ''){
			   	form.uid=request.zsession.user.id&'|'&request.zsession.user.site_id;
			} 
			selectStruct = StructNew();
			selectStruct.name = "uid";
			selectStruct.selectedValues=form.uid;
			selectStruct.query = qUser;
			//selectStruct.style="monoMenu";
			selectStruct.queryParseLabelVars =true;
			selectStruct.queryParseValueVars =true;
			selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
			selectStruct.queryValueField = "##user_id##|##site_id##";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
					</td>
				</tr>
			</cfif>
	 
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Summary Text","member.blog.edit blog_summary")#</th>
				<td>
					<textarea name="blog_summary" style="width:100%; height:120px; ">#form.blog_summary#</textarea>
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Body Text","member.blog.edit blog_story")# *</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "blog_story";
					htmlEditor.value			= form.blog_story;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript> 
				</td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">Cache External Images:</th>
				<td>
				<cfscript>
				form.convertLinks=application.zcore.functions.zso(form, 'convertLinks', true, 0); 
				ts = StructNew();
				ts.name = "convertLinks";
				ts.radio=true;
				ts.separator=" ";
				ts.listValuesDelimiter="|";
				ts.listLabelsDelimiter="|";
				ts.listLabels="Yes|No";
				ts.listValues="1|0";
				application.zcore.functions.zInput_Checkbox(ts);
				</cfscript> | Selecting "Yes", will cache the external images in the html editor to this domain.
				</td>
			</tr>
			<tr>
				<th style="width:120px; vertical-align:top;">Category *</th>
				<td style="vertical-align:top; ">
				<cfsavecontent variable="db.sql">
				select *,concat(repeat(#db.param("_")#,blog_category_level*#db.param(3)#),blog_category_name) catname
				from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
				
				WHERE  site_id=#db.param(request.zos.globals.id)# and 
				blog_category_deleted = #db.param(0)#
				ORDER BY blog_category_sort 
			</cfsavecontent><cfscript>qCat=db.execute("qCat");
		if(qcat.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"You must add at least one category before adding articles.");
			application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/categoryAdd?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
		}else if(qcat.recordcount EQ 1 and form.method EQ "articleAdd"){
			form.select_category_id=qcat.blog_category_id;
			application.zcore.template.appendTag("scripts", '<script type="text/javascript">zArrDeferredFunctions.push(function(){  setCatBlock(true); });</script> ');
		}
		selectStruct = StructNew();
		selectStruct.name = "select_category_id";
		selectStruct.selectedValues="";
	selectStruct.onchange="setCatBlock(true);";
		selectStruct.query = qCat;
		//selectStruct.style="monoMenu";
		selectStruct.queryLabelField = "catname";
		selectStruct.queryValueField = "blog_category_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> 
		 
			 <cfif application.zcore.functions.zso(form, 'ccid') NEQ "">
				<cfscript>
				sql="'"&replace(application.zcore.functions.zescape(form.ccid),",","','","ALL")&"'";
				</cfscript>
				<cfsavecontent variable="db.sql">
				SELECT blog_category_name, blog_category_id, #db.param(1)# catassociated 
				from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
				WHERE blog_category_id IN (#db.trustedSQL(sql)#) and 
				site_id = #db.param(request.zos.globals.id)# and 
				blog_category_deleted = #db.param(0)#
				ORDER BY blog_category_name ASC
				</cfsavecontent><cfscript>qCat=db.execute("qCat");</cfscript>
				<cfelse>
				<cfsavecontent variable="db.sql">
				SELECT blog_category.blog_category_name,blog_category.blog_category_id, 
				if(blog_x_category.blog_category_id IS NULL,#db.param(0)#,#db.param(1)#) catassociated 
				from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
				left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
				blog_x_category.blog_category_id = blog_category.blog_category_id and 
				blog_x_category.blog_id = #db.param(form.blog_id)# and 
				blog_x_category.site_id = blog_category.site_id and
				blog_x_category_deleted = #db.param(0)#
				WHERE blog_category.site_id = #db.param(request.zos.globals.id)# and 
				blog_category_deleted = #db.param(0)#
				ORDER BY blog_category.blog_category_name ASC
				</cfsavecontent><cfscript>qCat=db.execute("qCat");</cfscript>
				</cfif>
				<div id="categoryBlock"></div>
				<script type="text/javascript">
				/* <![CDATA[ */
				var arrBlock=new Array();
				var arrBlockId=new Array();
				<cfloop query="qCat"><cfif qCat.catassociated EQ 1>arrBlockId.push(#qCat.blog_category_id#);arrBlock.push("#jsstringformat(qCat.blog_category_name)#");</cfif></cfloop>
				function removeCat(id){
					var ab=new Array();
					var ab2=new Array();
					for(i=0;i<arrBlock.length;i++){
						if(id!=i){ ab.push(arrBlock[i]); ab2.push(arrBlockId[i]); }
					}
					arrBlock=ab;
					arrBlockId=ab2;
					setCatBlock(false);
				}
				function setCatBlock(checkField){
					if(checkField){
						var cid=parseInt(document.zMLSSearchForm.select_category_id.options[document.zMLSSearchForm.select_category_id.selectedIndex].value);
						var cname=document.zMLSSearchForm.select_category_id.options[document.zMLSSearchForm.select_category_id.selectedIndex].text;
						if(isNaN(cid)){
							alert('Please select a category before clicking the add button.');
							return;
						}
						for(var i=0;i<arrBlockId.length;i++){
							if(arrBlockId[i] == cid){
								alert('This category is already associated with this article.');
								return;
							}
						}
						arrBlockId.push(cid);
						arrBlock.push(cname);
					}
					var cb=document.getElementById("categoryBlock");
					arrBlock2=new Array();
					arrBlock2.push('<table style="border-spacing:0px; ">');
					for(var i=0;i<arrBlock.length;i++){ 
						arrBlock2.push('<tr><td>'+arrBlock[i]+'</td><td><a href="##" onclick="removeCat('+(arrBlock2.length-1)+');return false;" title="Click to remove association to this category." class="z-manager-search-button" style="color:##FFF;">X</a></td></tr>');
					}
					arrBlock2.push('</table>');
					arrBlock2.push('<input type="hidden" name="ccid" value="'+arrBlockId.join(",")+'" />');
					cb.innerHTML=arrBlock2.join('');
					if(arrBlock2.length==0){
						cb.style.display="inline";
					}else{
						cb.style.display="block";
					}
				}
				setCatBlock(false);
				/* ]]> */
				</script>
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Tags","member.blog.edit select_tag_id")#</th>
				<td>
					<div class="z-float z-mb-10">
						<cfscript>
						db.sql=" SELECT *, if(blog_x_tag.blog_tag_id IS NULL,#db.param(0)#,count(blog_tag.blog_tag_id)) count 
						FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
						LEFT JOIN #db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag on 
						blog_x_tag.blog_tag_id = blog_tag.blog_tag_id and 
						blog_x_tag.site_id = blog_tag.site_id and 
						blog_x_tag_deleted = #db.param(0)#
						WHERE  blog_tag.site_id=#db.param(request.zos.globals.id)# and 
						blog_tag_deleted = #db.param(0)# 
						GROUP BY blog_tag.blog_tag_id ORDER BY blog_tag_name ASC ";
						qTag=db.execute("qTag");
						if(qtag.recordcount NEQ 0){
							writeoutput('Existing Tags: ');
							selectStruct = StructNew();
							selectStruct.name = "select_tag_id";
							selectStruct.query = qTag;
							selectStruct.onchange="setTagBlock2(true);";
							//selectStruct.style="monoMenu";
							selectStruct.queryLabelField = "blog_tag_name";
							selectStruct.queryValueField = "blog_tag_id";
							application.zcore.functions.zInputSelectBox(selectStruct); 
							echo('</div>
							<div class="z-float z-mb-10">');
							writeoutput('Type Tag: ');
						}else{
							writeoutput('Type Tag: ');
						}
						</cfscript>
						<input type="text" name="tagbox" id="tagbox" style="min-width:1%; width:250px; max-width:100%;" value="" /> 
						<input type="button" name="submitTag" onclick="setTagBlock(true);" value="Add" /> 
					</div>
					<div class="z-float z-mb-10">
						<div id="tagBlock"></div>
					</div>
				 
				<cfsavecontent variable="db.sql">
				SELECT * FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag, 
				#db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag 
				
				WHERE blog_tag.blog_tag_id = blog_x_tag.blog_tag_id and 
				blog_x_tag.blog_id = #db.param(form.blog_id)# and 
				blog_tag.site_id = #db.param(request.zos.globals.id)# and 
				blog_x_tag_deleted = #db.param(0)# and 
				blog_tag_deleted = #db.param(0)#
				and blog_tag.site_id = blog_x_tag.site_id 
				ORDER BY blog_tag.blog_tag_name ASC
				</cfsavecontent><cfscript>qTag=db.execute("qTag");</cfscript>
				<script type="text/javascript">
				/* <![CDATA[ */
				var arrTagBlock=[];
				<cfif application.zcore.functions.zso(form, 'blog_tags') NEQ "">
					<cfscript>
					arrT=listtoarray(form.blog_tags,chr(9));
					for(i=1;i LTE arraylen(arrT);i++){
						writeoutput('arrTagBlock.push("#jsstringformat(arrT[i])#");');
					}
					</cfscript>
				<cfelse>
					<cfloop query="qTag">arrTagBlock.push("#jsstringformat(qTag.blog_tag_name)#");</cfloop>
				</cfif>
				function removeTag(id){
					var ab=[];
					var ab2=[];
					for(i=0;i<arrTagBlock.length;i++){
						if(id!=i){ ab.push(arrTagBlock[i]); }
					}
					arrTagBlock=ab;
					setTagBlock(false);
				}
				function setTagBlock2(checkField){
					var cid=parseInt(document.zMLSSearchForm.select_tag_id.options[document.zMLSSearchForm.select_tag_id.selectedIndex].value);
					if(isNaN(cid)){
						alert('Please select a tag before clicking the add button.');
						return;
					}
					var d=document.zMLSSearchForm.select_tag_id.options[document.zMLSSearchForm.select_tag_id.selectedIndex].text;
					document.zMLSSearchForm.tagbox.value=d;
					setTagBlock(checkField);
				}
				function setTagBlock(checkField){
					if(checkField){
						var cname=document.zMLSSearchForm.tagbox.value.replace(/^\s+|\s+$/g, '');
						if(cname.length == 0){
							alert('Please type a phrase before clicking the add button.');
							return;
						}
						document.zMLSSearchForm.tagbox.value="";
						for(var i=0;i<arrTagBlock.length;i++){
							if(arrTagBlock[i] == cname){
								alert('Tag is already associated with this article.');
								return;
							}
						}
						arrTagBlock.push(cname);
					}
					var cb=document.getElementById("tagBlock");
					arrTagBlock2=[];
					arrTagBlock2.push('<table style="border-spacing:0px; ">');
					for(var i=0;i<arrTagBlock.length;i++){
						var s='';
						arrTagBlock2.push('<tr><td>'+arrTagBlock[i]+'</td><td><a href="##" onclick="removeTag('+(arrTagBlock2.length-1)+');return false;" title="Click to remove association to this tag." class="z-manager-search-button" style="color:##FFF;">X</a></td></tr>');
					}
					arrTagBlock2.push('</table>');
					arrTagBlock2.push('<input type="hidden" name="blog_tags" value="'+arrTagBlock.join("\t")+'" />');
					cb.innerHTML=arrTagBlock2.join('');
					if(arrTagBlock2.length==0){
						cb.style.display="inline";
					}else{
						cb.style.display="block";
					}
				}
				setTagBlock(false);
				/* ]]> */
				</script>
				</td>
			</tr>
			<cfscript>
			db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			office_deleted = #db.param(0)#
			ORDER BY office_name";
			qOffice=db.execute("qOffice");
			</cfscript>
			<cfif qOffice.recordcount>
				<tr>
					<th style="width:120px;">#application.zcore.functions.zOutputHelpToolTip("Office","member.blog.edit office_id")#</th>
					<td><cfscript>
						selectStruct = StructNew();
						selectStruct.name = "office_id";
						selectStruct.query = qOffice;
						selectStruct.queryParseLabelVars=true;
						selectStruct.queryLabelField = "##office_name## (##office_address##)";
						selectStruct.queryValueField = "office_id";
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript></td>
				</tr>
			</cfif>
			<cfscript>
			if(isnull(form.blog_datetime) or form.blog_datetime EQ '0000-00-00 00:00:00' or isdate(form.blog_datetime) EQ false){
				form.blog_datetime=dateadd("d",-7,now());
			} 
			</cfscript> 
			<tr><th style="width:120px;vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Date","member.blog.edit blog_status")#</th>
			<td><input type="radio" name="blog_status" id="blog_status1" value="2" <cfif form.blog_status EQ 2>checked="checked"</cfif> onclick="document.getElementById('dateBox').style.display='none';" style="background:none; border:none;"> Draft 

			<input type="radio" name="blog_status" id="blog_status2" value="0" <cfif currentMethod EQ "articleAdd" or form.blog_status EQ "" or form.blog_status EQ "0">checked="checked"</cfif> onclick="document.getElementById('dateBox').style.display='none';" style="background:none; border:none;"> Now 

			<input type="radio" name="blog_status" id="blog_status3" value="1" onclick="document.getElementById('dateBox').style.display='block';" <cfif form.blog_status EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Manual Date<br /><br />
 
			If a blog article's date is set to the future, it will be invisible to the public. 
			<br /><br />
			<div id="dateBox">
				<cfscript>
				writeoutput("Specify Date:"&application.zcore.functions.zDateSelect("blog_datetime","blog_datetime",2000,year(now())+1,""));
				writeoutput(" and Time:"&application.zcore.functions.zTimeSelect("blog_datetime","blog_datetime",1,5));
				</cfscript>
 
		
			</div>
 
	
			<script type="text/javascript">
			/* <![CDATA[ */
			function checkDateBlock(){
				var r1=document.getElementById("blog_status1");
				var r2=document.getElementById("blog_status2");
				var r3=document.getElementById("blog_status3");
				if(r1.checked || r2.checked){
					var d1=document.getElementById("dateBox");	
					d1.style.display="none";
				}
			}
			checkDateBlock();
			/* ]]> */
			</script>
			</td></tr>
	<tr>
		<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.blog.edit blog_image_library_id")#</th>
		<td>
			<cfscript>
			ts=structnew();
			ts.name="blog_image_library_id";
			ts.value=form.blog_image_library_id;
			application.zcore.imageLibraryCom.getLibraryForm(ts);
			</cfscript>
		</td>
	</tr>

	<tr>
		<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photo Layout","member.content.edit blog_image_library_layout")#</th>
		<td>
			<cfscript>
			if(form.blog_image_library_layout EQ ""){
				form.blog_image_library_layout=9;
			}
			ts=structnew();
			ts.name="blog_image_library_layout";
			ts.value=form.blog_image_library_layout;
			application.zcore.imageLibraryCom.getLayoutTypeForm(ts);
			</cfscript>
		</td>
	</tr>
	
	<cfscript>
	
	form.blog_show_all_sections=application.zcore.functions.zso(form, 'blog_show_all_sections', true, 0);
	</cfscript>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Show On All Sections?","member.blog.edit blog_show_all_sections")#</th>
				<td>#application.zcore.functions.zInput_Boolean("blog_show_all_sections")# | If this site uses custom sections, setting this to yes, will allow the blog article to appear on them.</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Sticky?","member.blog.edit blog_sticky")#</th>
				<td>#application.zcore.functions.zInput_Boolean("blog_sticky")# | Force to top of all pages.</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.blog.edit blog_metakey")#</th>
				<td>
					<textarea name="blog_metakey" style="width:100%; height:60px; ">#form.blog_metakey#</textarea>
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.blog.edit blog_metadesc")#</th>
				<td>
					<textarea name="blog_metadesc" style="width:100%; height:60px; ">#form.blog_metadesc#</textarea>
				</td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")# 
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr><th style="width:120px;vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Display time?","member.blog.edit blog_hide_time")#</th>
			<td>
			 <input type="radio" name="blog_hide_time" value="0" <cfif form.blog_hide_time EQ 0 or form.blog_hide_time EQ "">checked="checked"</cfif>  style="background:none; border:none;"> Yes <input type="radio" name="blog_hide_time" value="1" style="background:none; border:none;" <cfif form.blog_hide_time EQ 1>checked="checked"</cfif>> No
			</td></tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Open Graph Image","member.blog.edit blog_og_image")#</th>
				<td>#application.zcore.functions.zInputImage('blog_og_image', application.zcore.functions.zVar('privatehomedir')&"zupload/blog/", "/zupload/blog/", 250)# </td>
			</tr>
			
 
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableManageSlideshow', true, 0) EQ 1>
		
			<cfsavecontent variable="db.sql">
			SELECT * FROM #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			slideshow_deleted = #db.param(0)#
			ORDER BY slideshow_name ASC
			</cfsavecontent><cfscript>qslide=db.execute("qslide");</cfscript>
			<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Slideshow","member.blog.edit blog_slideshow_id")#</th>
			  <td style="vertical-align:top; ">
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "blog_slideshow_id";
			selectStruct.selectedValues=form.blog_slideshow_id;
			selectStruct.query = qslide;
			selectStruct.selectLabel="-- Select --";
			selectStruct.queryLabelField = "slideshow_name";
			selectStruct.queryValueField = "slideshow_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> | <a href="/z/admin/slideshow/add" target="_blank">Create a slideshow</a>
			</td>
			</tr>
		</cfif>
		<cfscript>
		db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# 
		WHERE site_option_appidlist like #db.param('%,10,%')# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_deleted=#db.param(0)#";
		qOptionCheck=db.execute("qOptionCheck");

		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_option_group_appidlist like #db.param('%,10,%')# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_deleted=#db.param(0)#";
		qGroupCheck=db.execute("qGroupCheck");
		</cfscript>
		<cfif qOptionCheck.recordcount or qGroupCheck.recordcount>
			<tr>
			<th style="width:120px; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Custom Fields","member.blog.edit blog_site_option_app_id")#</th>
			<td colspan="2">
			<cfscript>
			ts=structnew();
			ts.name="blog_site_option_app_id";
			ts.app_id=application.zcore.app.getAppCFC("blog").app_id;
			ts.value=form.blog_site_option_app_id;
			application.zcore.siteOptionCom.getOptionForm(ts);
			</cfscript>
			</td>
			</tr>
		</cfif>
	
		<tr> 
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Unique URL","member.blog.edit blog_unique_name")#</th>
		<td style="vertical-align:top; ">
			<cfif form.method EQ "articleAdd">
				#application.zcore.functions.zInputUniqueUrl("blog_unique_name", true)#
			<cfelse>
				#application.zcore.functions.zInputUniqueUrl("blog_unique_name")#
			</cfif>
	
		</td>
		</tr> 
		
		</table>
		#application.zcore.hook.trigger("blog.articleEditCustomFields", {query=qEdit})#
		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
		<cfscript>application.zcore.functions.zEndForm();</cfscript>
</cffunction>

<cffunction name="commentList" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var qc=0;
	var qCount=0;
	var viewlink=0;
	var db=request.zos.queryObject;
	var qcomments=0;
	var qr=0;
	form.blog_id=application.zcore.functions.zso(form, 'blog_id');
	this.init();
	application.zcore.functions.zSetPageHelpId("3.3");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	application.zcore.functions.zstatushandler(request.zsid, true, false, form);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * from #db.table("blog", request.zos.zcoreDatasource)# blog 
	WHERE blog_id = #db.param(form.blog_id)#  and 
	site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qR=db.execute("qR");
	if(qR.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid request.");
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	</cfscript>
	<script type="text/javascript">
/* <![CDATA[ */ 
function textCounter(field,cntfield,maxlimit) {
	if (field.value.length > maxlimit){
		field.value = field.value.substring(0, maxlimit);
	}else{
		cntfield.value = maxlimit - field.value.length;
	} 
}
/* ]]> */
</script>
	<cfsavecontent variable="db.sql">
	select *
	from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment
	WHERE blog_id = #db.param(form.blog_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	blog_comment_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qComments=db.execute("qComments");</cfscript>
	<cfsavecontent variable="db.sql">
	select count(*) as count from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment 
	WHERE blog_id = #db.param(form.blog_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	blog_comment_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qCount=db.execute("qCount");
  if(qR.blog_unique_name NEQ ''){
	 viewlink= application.zcore.functions.zvar('domain')&qR.blog_unique_name;
  }else{
	  viewlink=application.zcore.functions.zvar('domain')&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id, form.blog_id,"html",qR.blog_title,qR.blog_datetime);
  }
  </cfscript>
	<h2>Comments For Article: <a href="#viewlink#" target="_blank">#qr.blog_title#</a></h2>
	<cfif qr.blog_summary NEQ ""><p>Summary: #qr.blog_summary#</p></cfif>
	
	<cfif application.zcore.functions.zIsExternalCommentsEnabled()>
		<cfscript>
		
		if(qR.blog_unique_name EQ ""){
			local.currentBlogURL=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qR.blog_id,"html",qR.blog_title,qR.blog_datetime);
		}else{
			local.currentBlogURL=qR.blog_unique_name;
		}
		 // display external comments
		 writeoutput(application.zcore.functions.zDisplayExternalComments(application.zcore.app.getAppData("blog").optionstruct.app_x_site_id&"-"&qR.blog_id, qR.blog_title, request.zos.globals.domain&local.currentBlogURL));
		 </cfscript>
	<cfelseif application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct,'blog_config_disable_comments',false,0) EQ 0>
		

	<cfif qComments.recordcount EQ 0>
	<p>There are no comments for this article.</p>
	<cfelse>
	<p><a href="##postcomment">Post your own comment</a></p>
	<table style="border-spacing:0px; width:100%;" class="table-list">
		<tr>
			<th >Name</th>
			<th >Message</th>
			<th style="width:125px;">Date Posted</th>
			<th style="width:70px;" >Status</th>
			<th style="width:160px; " >Admin</th>
		</tr>
	<cfloop query="qComments">
		<tr  <cfif qComments.currentrow MOD 2>class="row2"<cfelse>class="row1"</cfif>>
			<td style="vertical-align:top; "><a href="mailto:#qComments.blog_comment_author_email#">#qComments.blog_comment_author#</a></td>
			<td style="vertical-align:top; ">#qComments.blog_comment_title#<br />
#application.zcore.functions.zparagraphformat(qComments.blog_comment_text)#</td>
			<td style="width:125px; vertical-align:top;">#dateformat(qComments.blog_comment_datetime,"m/d/yyyy")&" "&timeformat(qComments.blog_comment_datetime,"h:mm tt")#</td>
			<td style="width:70px; vertical-align:top;"><cfif qComments.blog_comment_approved EQ '0'>New<cfelse>Approved</cfif></td>
			<!--- <td>#left(qComments.blog_category_description, 100)#<cfif len(qComments.blog_category_description) gt 100>...</cfif></td> --->
			<td style=" vertical-align:top; width:160px; "><cfif qComments.blog_comment_approved EQ '0'><a href="/z/blog/admin/blog-admin/commentApprove?blog_comment_id=#qComments.blog_comment_id#&amp;blog_id=#qComments.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Approve</a> | </cfif> <a href="/z/blog/admin/blog-admin/commentReview?blog_comment_id=#qComments.blog_comment_id#&amp;blog_id=#qComments.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Edit</a> | 
			<a href="/z/blog/admin/blog-admin/commentDelete?blog_comment_id=#qComments.blog_comment_id#&amp;blog_id=#qComments.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Delete</a></td>
		</tr>
	</cfloop>
	</table>
	
	<br /></cfif>



  <a id="postcomment"></a>
  <h2>Add your own comments</h2>
	<cfsavecontent variable="db.sql">
	select * from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment 
	WHERE blog_id = #db.param('-1')# and 
	site_id = #db.param('-1')# and 
	blog_comment_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qC=db.execute("qC");
local.blogIdBackup=form.blog_id;
	application.zcore.functions.zquerytostruct(qc, form);
	application.zcore.functions.zstatushandler(request.zsid,true,true, form);
	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript>
	<form class="zFormCheckDirty" action="/z/blog/blog/addComment?blog_id=#local.blogIdBackup#&amp;managerReturn=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#" onsubmit="zSet9('zset9_#form.set9#');" method="post" name="myForm">
			<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
		<table style="width:100%; border-spacing:0px;" class="table-list">
		  <tr>
		  <tr>
			<th style="width:90px;">#application.zcore.functions.zOutputHelpToolTip("Your Name","member.blog.comments blog_comment_author")#</th>
			<td><input type="text" name="blog_comment_author" value="<cfif form.blog_comment_author NEQ "">#form.blog_comment_author#<cfelse>#request.zsession.user.first_name# #request.zsession.user.last_name#</cfif>" size="50"></td>
		  </tr>
		  <tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Your Email","member.blog.comments blog_comment_author_email")#</th>
			<td><input type="text" name="blog_comment_author_email" value="<cfif form.blog_comment_author_email NEQ "">#form.blog_comment_author_email#<cfelse>#request.zsession.user.email#</cfif>" size="50" /></td>
		  </tr>
		  <tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Subject","member.blog.comments blog_comment_title")#</th>
			<td><input type="text" name="blog_comment_title" value="#form.blog_comment_title#" size="50" /></td>
		  </tr>
		  <tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Comments","member.blog.comments blog_comment_text")#</th>
			<td>
			<textarea name="blog_comment_text" wrap="physical" cols="53" rows="5" onKeyDown="textCounter(document.myForm.blog_comment_text,document.myForm.remLen2,250)" onkeyup="textCounter(document.myForm.blog_comment_text,document.myForm.remLen2,250)">#form.blog_comment_text#</textarea><br />
			<input readonly type="text" name="remLen2" size="3" maxlength="3" value="250" /> characters left 
			<script type="text/javascript">
			/* <![CDATA[ */textCounter(document.myForm.blog_comment_text,document.myForm.remLen2,250);/* ]]> */
			</script>
			</td>
		  </tr>
			<th>&nbsp;<input type="hidden" name="blog_id" value="#form.blog_id#" /></th>
			<td><div id="waitdiv1" style="display:none;padding:5px; margin-right:5px; float:left;">Please Wait</div> 
			<button type="submit" name="submitForm" value="add" onclick="this.style.display='none';document.getElementById('waitdiv1').style.display='block';">Add Comment</button> <button type="button" name="deletecomment" value="Cancel" onclick="window.location.href='/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#';">Cancel</button></td>
		  </tr>
		</table>
	</form>
	<div style="height:1000px;clear:both;float:left; width:100%;"></div>
	</cfif>
</cffunction>

<cffunction name="categoryList" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var db=request.zos.queryObject;
	var qlist=0;
	this.init();
	application.zcore.functions.zSetPageHelpId("3.4");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Categories"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	db.sql="select *,concat(repeat(#db.param("_")#,blog_category_level*#db.param(3)#),blog_category_name) catname, 
	if(blog_x_category.blog_category_id IS NULL, #db.param(0)#, count(blog_x_category.blog_category_id)) count
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_category_id=blog_category.blog_category_id and 
	blog_x_category.site_id = blog_category.site_id and
	blog_x_category_deleted = #db.param(0)#
	
	WHERE blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category_deleted = #db.param(0)# 
	group by blog_category.blog_category_id
	ORDER BY blog_category_sort";
	qList=db.execute("qList");


	echo('<div class="z-float z-mb-10">'); 
	echo('<h2 style="display:inline-block;">Blog Categories</h2>'); 
	echo(' &nbsp;&nbsp; <a href="/z/blog/admin/blog-admin/categoryAdd?returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#" class="z-button">Add</a>
	</div>');
	</cfscript> 
	<table style="border-spacing:0px; width:450px;" class="table-list">
		<tr>
		<th style="width:25px;">ID</th>
			<th >Name</th>
			<th >Associated Articles</th>
			<th style="width:130px; " >Admin</th>
		</tr>
	<cfloop query="qList">
		<tr  <cfif qList.currentrow MOD 2>class="row2"<cfelse>class="row1"</cfif>>
			<td>#qList.blog_category_id#</td>
			<td>#qList.catname#</td>
			<td>#qList.count#</td>
			<!--- <td>#left(qList.blog_category_description, 100)#<cfif len(qList.blog_category_description) gt 100>...</cfif></td> --->
			<td style="width:130px; ">
			<a href="<cfif qList.blog_category_unique_name NEQ ''>#qList.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, qList.blog_category_id,"html", qList.blog_category_name)#</cfif>" target="_blank">View</a> | 
			<a href="/z/blog/admin/blog-admin/categoryEdit?blog_category_id=#qList.blog_category_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Edit</a> | 
				<cfif not application.zcore.user.checkServerAccess() and qList.blog_category_unique_name NEQ "">
					Delete disabled
				<cfelse>
					<a href="/z/blog/admin/blog-admin/categoryDelete?blog_category_id=#qList.blog_category_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Delete</a>
				</cfif>
			</td>
		</tr>
	</cfloop>
	</table>
</cffunction>

<cffunction name="categoryAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.categoryEdit();
	</cfscript>
</cffunction>

<cffunction name="categoryEdit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var ts=0;
	var currentMethod=form.method;
	var selectStruct=0;
	var db=request.zos.queryObject;
	var qcat=0;
	var htmleditor=0;
	var cancelURL=0;
	var tabcom=0;
	var qedit=0;
	application.zcore.functions.zSetPageHelpId("3.5");
	form.blog_category_id=application.zcore.functions.zso(form, 'blog_category_id');
	this.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Categories"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	</cfscript>
	<cfsavecontent variable="db.sql">
		select *
		from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
		
	WHERE blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qEdit=db.execute("qEdit"); 
	request.zsession["blogcategory_return"&form.blog_category_id]=application.zcore.functions.zso(form, "returnURL");
	application.zcore.functions.zquerytostruct(qedit, form);
	application.zcore.functions.zstatushandler(request.zsid,true, false, form);
	</cfscript>
	<cfif currentMethod EQ "categoryEdit">
		<cfscript>
		if(qEdit.recordcount EQ 0){
			application.zcore.functions.zredirect('/');	
		}
		</cfscript>
		<h2>Edit Category: "#qEdit.blog_category_name#"</h2>
	<cfelse>
		<h2>Add Category</h2>
	</cfif>
	<cfscript>
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	ts.class="zFormCheckDirty";
	ts.enctype="multipart/form-data";
	ts.action="/z/blog/admin/blog-admin/categoryUpdate?blog_category_id=#form.blog_category_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#";
	ts.method="post";
	ts.successMessage=false;
	if(application.zcore.app.siteHasApp("listing")){
		ts.onLoadCallback="loadMLSResults";
		ts.onChangeCallback="getMLSCount";
	}
	application.zcore.functions.zForm(ts);
	
tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
tabCom.setMenuName("member-blog-category-edit");
cancelURL=application.zcore.functions.zso(request.zsession, 'blogcategory_return'&form.blog_category_id);
if(cancelURL EQ ""){
	cancelURL="/z/blog/admin/blog-admin/categoryList?site_x_option_group_set_id=#form.site_x_option_group_set_id#";
}
tabCom.setCancelURL(cancelURL);
tabCom.enableSaveButtons();
</cfscript>
<p>* denotes required field</p>
#tabCom.beginTabMenu()#
   #tabCom.beginFieldSet("Basic")# 
	<table style="border-spacing:0px; width:100%; border:'0';" class="table-list">
		<tr>
			<th style="width:120px;">#application.zcore.functions.zOutputHelpToolTip("Name","member.blog.formcat blog_category_name")#</th>
			<td>
				<input type="text" name="blog_category_name" value="#form.blog_category_name#" style="width:90%;" /> *
			</td>
		</tr>
		<tr>
			<th style="width:120px; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Description","member.blog.edit blog_category_description")#</th>
			<td>
			
				<cfscript>
					
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "blog_category_description";
				htmlEditor.value			= form.blog_category_description;
				htmlEditor.width			= "100%";
				htmlEditor.height		= 400;
				htmlEditor.create();
				</cfscript>
			</td>
		</tr>
		<tr>
			<th style="width:1%; white-space:nowrap;">Cache External Images:</th>
			<td>
			<cfscript>
			form.convertLinks=application.zcore.functions.zso(form, 'convertLinks', true, 0); 
			ts = StructNew();
			ts.name = "convertLinks";
			ts.radio=true;
			ts.separator=" ";
			ts.listValuesDelimiter="|";
			ts.listLabelsDelimiter="|";
			ts.listLabels="Yes|No";
			ts.listValues="1|0";
			application.zcore.functions.zInput_Checkbox(ts);
			</cfscript> | Selecting "Yes", will cache the external images in the html editor to this domain.
			</td>
		</tr>
		<tr>
			<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.blog.formcat blog_category_metakey")#</th>
			<td>
				<textarea name="blog_category_metakey" style="width:100%; height:60px; ">#form.blog_category_metakey#</textarea>
			</td>
		</tr>
		<tr>
			<th style="vertical-align:top; width:120px; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.blog.formcat blog_category_metadesc")#</th>
			<td>
				<textarea name="blog_category_metadesc" style="width:100%; height:60px; ">#form.blog_category_metadesc#</textarea>
			</td>
		</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")# 
	<table style="border-spacing:0px; width:100%; border:'0';" class="table-list">
		<tr>
			<th style="width:120px;">#application.zcore.functions.zOutputHelpToolTip("Parent Category","member.blog.formcat blog_category_parent_id")#</th>
			<td>
		<cfsavecontent variable="db.sql">
			select *,concat(repeat(#db.param("_")#,blog_category_level*#db.param(3)#),blog_category_name) catname
			from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
			
			WHERE blog_category_id <> #db.param(form.blog_category_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			blog_category_deleted = #db.param(0)# 
			ORDER BY blog_category_sort 
		</cfsavecontent><cfscript>qCat=db.execute("qCat");
			selectStruct = StructNew();
			selectStruct.name = "blog_category_parent_id";
			selectStruct.selectedValues=form.blog_category_parent_id;
			selectStruct.query = qCat;
			//selectStruct.style="monoMenu";
			selectStruct.queryLabelField = "catname";
			selectStruct.queryValueField = "blog_category_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
			</td>
		</tr> 
 
	
	<tr>
	<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Custom Fields","member.blog.formcat blog_category_site_option_app_id")#</th>
	<td colspan="2">
	<cfscript>
	ts=structnew();
	ts.name="blog_category_site_option_app_id";
	ts.app_id=application.zcore.app.getAppCFC("blog").app_id;
	ts.value=form.blog_category_site_option_app_id;
	application.zcore.siteOptionCom.getOptionForm(ts);
	</cfscript>
	</td>
	</tr>
	<tr> 
	<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Unique URL","member.blog.formcat blog_category_unique_name")#</th>
	<td style="vertical-align:top; ">

		<cfif form.method EQ "categoryAdd">
			#application.zcore.functions.zInputUniqueUrl("blog_category_unique_name", true)#
		<cfelse>
			#application.zcore.functions.zInputUniqueUrl("blog_category_unique_name")#
		</cfif>
	</td>
	</tr> 
	</table>

	#application.zcore.hook.trigger("blog.categoryEditCustomFields", {query=qEdit})#

		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
		<cfscript>application.zcore.functions.zEndForm();</cfscript>
</cffunction>

<cffunction name="commentReview" localmode="modern" access="remote" roles="member">
	<cfscript>
	var local=structnew();
	var searchStruct=0;
	var qComments=0;
	var db=request.zos.queryObject;
	var start=0;
	this.init();
	application.zcore.functions.zSetPageHelpId("3.1");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Blog Articles"); 
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	form.blog_comment_id=application.zcore.functions.zso(form, 'blog_comment_id');
	</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */ 
	function textCounter(field,cntfield,maxlimit) {
		if (field.value.length > maxlimit)){
			field.value = field.value.substring(0, maxlimit);
		}else{
			cntfield.value = maxlimit - field.value.length;
		} 
	}
	/* ]]> */
	</script>
	<cfscript>
	if(application.zcore.functions.zso(form, 'ListID') EQ ''){ 
		  form.ListId = application.zcore.status.getNewId(); 
	 } 
	 if(structkeyexists(form, 'zIndex')){ 
		  application.zcore.status.setField(form.ListID,'zIndex', form.zIndex); 
	 }
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Comments "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.url = "/z/blog/admin/blog-admin/commentReview?blog_id=#form.blog_id#";
	searchStruct.buttons = 5; 
	// set from query string or default value 
	searchStruct.perpage = 10;	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = application.zcore.status.getField(form.ListId, "zIndex",1); 
	start = searchStruct.perpage * searchStruct.index - 10;
	</cfscript>
	
	<cfsavecontent variable="db.sql">
		select *
		from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_comment_id=#db.param(form.blog_comment_id)#  and 
		blog_comment_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qComments=db.execute("qComments");
	if(qComments.recordcount eq 0){
		application.zcore.functions.zRedirect("/z/blog/admin/blog-admin/articleList?site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	application.zcore.functions.zQueryToStruct(qComments, form);
	application.zcore.functions.zStatusHandler(request.zsid, true, false, form);
	</cfscript>
	<form class="zFormCheckDirty" action="/z/blog/admin/blog-admin/commentUpdate?site_x_option_group_set_id=#form.site_x_option_group_set_id#" method="post" name="myForm">
		<table style="width:100%; border-spacing:0px;" class="table-list">
		  <tr>
		  <tr>
			<th style="width:90px;">#application.zcore.functions.zOutputHelpToolTip("Your Name","member.blog.reviewComment blog_comment_author")#</th>
			<td><input type="text" name="blog_comment_author" value="#form.blog_comment_author#" size="50"></td>
		  </tr>
		  <tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Your Email","member.blog.reviewComment blog_comment_author_email")#</th>
			<td><input type="text" name="blog_comment_author_email" value="#form.blog_comment_author_email#" size="50"></td>
		  </tr>
		  <tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Title","member.blog.reviewComment blog_comment_title")#</th>
			<td><input type="text" name="blog_comment_title" value="#form.blog_comment_title#" size="50"></td>
		  </tr>
		  <tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Comments","member.blog.reviewComment blog_comment_text")#</th>
			<td>
			<textarea name="blog_comment_text" wrap="physical" cols="53" rows="5" onKeyDown="textCounter(document.myForm.blog_comment_text,document.myForm.remLen2,250)" onkeyup="textCounter(document.myForm.blog_comment_text,document.myForm.remLen2,250)">#form.blog_comment_text#</textarea><br />
			<input readonly type="text" name="remLen2" size="3" maxlength="3" value="250"> characters left 
			<script type="text/javascript">
			textCounter(document.myForm.blog_comment_text,document.myForm.remLen2,250);
			</script>
			</td>
		  </tr>
			<th>&nbsp;<input type="hidden" name="blog_id" value="#form.blog_id#" /><input type="hidden" name="blog_comment_id" value="#form.blog_comment_id#" /></th>
			<td>
			<div id="waitdiv1" style="display:none;padding:5px; margin-right:5px; float:left;">Please Wait</div>
			<button type="submit" name="submitForm" value="update" onclick="this.style.display='none';document.getElementById('waitdiv1').style.display='block';" >Update</button> <button type="button" name="deletecomment" value="Cancel" onclick="window.location.href='/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#';">Cancel</button></td>
		  </tr>
		</table>
	</form>
</cffunction>
</cfoutput>
</cfcomponent>