<cfcomponent>
<cfoutput>  
<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0; 
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#
	WHERE inquiries_autoresponder_id= #db.param(application.zcore.functions.zso(form,'inquiries_autoresponder_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Autoresponder doesn''t exist or was already removed', false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#');
	} 

	if(qCheck.inquiries_autoresponder_main_image NEQ ""){
		application.zcore.functions.zDeleteFile(request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath, 1, 1)&qCheck.inquiries_autoresponder_main_image);
	} 

	db.sql="DELETE FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# WHERE 
	inquiries_autoresponder_id= #db.param(application.zcore.functions.zso(form, 'inquiries_autoresponder_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)#   ";
	q=db.execute("q");
	application.zcore.status.setStatus(Request.zsid, 'Autoresponder deleted');
	application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#');
	</cfscript> 
</cffunction>

<cffunction name="sendTest" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject; 
	form.email=application.zcore.functions.zso(form, 'email');
	form.format=application.zcore.functions.zso(form, 'format', true, 1);
 	form.inquiries_autoresponder_id=application.zcore.functions.zso(form, 'inquiries_autoresponder_id');

 	if(not application.zcore.functions.zEmailValidate(form.email)){
		application.zcore.status.setStatus(request.zsid, "You must enter a valid email.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/test?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#");
 	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# 
	WHERE  
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");
	if(qAutoresponder.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Autoresponder doesn't exist.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#");
	}

	fromEmail = qAutoresponder.inquiries_autoresponder_from;

	if ( fromEmail EQ '' ) {
		fromEmail = request.officeEmail;
	}

	ts={
		// required
		inquiries_type_id:qAutoresponder.inquiries_type_id,
		inquiries_type_id_siteidtype:qAutoresponder.inquiries_type_id_siteidtype,
		to:form.email,
		from: fromEmail,
		dataStruct:{
			firstName:"John",
			lastName:"Doe",
			interestedInModel: qAutoresponder.inquiries_autoresponder_interested_in_model,
			email:request.zos.developerEmailTo
		},
		preview:false,
		forceSend:true
		// optional
		//cc:""
	};
	rs=sendAutoresponder(ts);
	if(rs.success EQ false){ 
		application.zcore.status.setStatus(request.zsid, "Autoresponder test failed");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#"); 
	}
	application.zcore.status.setStatus(request.zsid, "Autoresponder test sent");
	application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#"); 
	</cfscript> 
</cffunction> 

<cffunction name="test" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject;  
	form.email=application.zcore.functions.zso(form, 'email');
	form.format=application.zcore.functions.zso(form, 'format', true, 1);
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_id') EQ ''){
		form.inquiries_autoresponder_id = -1;
	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#  
	WHERE  
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");
	application.zcore.functions.zQueryToStruct(qAutoresponder);
	application.zcore.functions.zStatusHandler(request.zsid,true); 

	fromEmail = qAutoresponder.inquiries_autoresponder_from;

	if ( fromEmail EQ '' ) {
		fromEmail = request.officeEmail;
	}

	</cfscript>
	<p><a href="/z/inquiries/admin/autoresponder/index">Autoresponders</a> / </p>
	<h2>Test Autoresponder</h2>
	<p>You can preview the autoresponder by sending it to your email address with this form.</p>
	<p>If the variables fail to insert during testing, there may be html tags in between the % and the keyword which must be manually fixed in the code.</p>
	<p>Subject: #form.inquiries_autoresponder_subject#</p>
	<p>From: #fromEmail#</p>

	<h2>Send Test Email</h2>
	<form action="/z/inquiries/admin/autoresponder/sendTest" method="get">
		<input type="hidden" name="inquiries_autoresponder_id" value="#htmleditformat(form.inquiries_autoresponder_id)#">
		<p>Your Email: <input type="text" name="email" style="width:500px; max-width:100%;" value="#htmleditformat(form.email)#"></p>
		<!--- <p>HTML Format? #application.zcore.functions.zInput_Boolean("format")#</p> --->
		<p><input type="submit" name="Submit1" value="Send" class="z-manager-search-button"> <input type="button" name="cancel" value="Cancel" onclick="window.location.href='/z/inquiries/admin/autoresponder/index';" class="z-manager-search-button"></p>
	</form>
 
	<h2>or Preview as HTML below</h2> 
	<cfscript>
	ts={
		// required
		inquiries_type_id:qAutoresponder.inquiries_type_id,
		inquiries_type_id_siteidtype:qAutoresponder.inquiries_type_id_siteidtype,
		to:request.officeEmail,
		from: fromEmail,
		dataStruct:{
			firstName:"John",
			lastName:"Doe",
			interestedInModel:qAutoresponder.inquiries_autoresponder_interested_in_model,
			email:request.officeEmail
		},
		preview:true
		// optional
		//cc:""
	};
	rs=sendAutoresponder(ts);
	if(rs.success){
		echo('<p>Subject: #rs.data.subject#</p><hr>');

		// convert to absolute links
		echo(rs.data.html);
	}else{
		echo('Failed to generate preview');
	}
	</cfscript>


</cffunction> 
 

<!--- 
ts={
	// required
	inquiries_type_id:"1",
	inquiries_type_id_siteidtype:"1",
	to:request.zos.developerEmailTo,
	from:request.officeEmail,
	dataStruct:{
		firstName:"John",
		email:"someone@somewhere.com",
		interestedInModel:"abc123"
	}
	// optional
	// cc:""
	//preview:false
	//forceSend:false // set to true to force inactive autoresponders to be able to be sent.  Their variables will be forced to the defaults.
};
autoResponderCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.autoresponder");
rs=autoResponderCom.sendAutoresponder(ts);
if(rs.success){

}else{

}
 --->
<cffunction name="sendAutoresponder" localmode="modern" access="public" roles="administrator">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	ss=arguments.ss;
	var db=request.zos.queryObject;  
	if(not structkeyexists(ss, 'to')){
		throw("arguments.ss.to is required");
	}
	if(not structkeyexists(ss, 'from')){
		ss.from = '';
	}
	if(not structkeyexists(ss, 'inquiries_type_id')){
		throw("arguments.ss.inquiries_type_id is required");
	}
	if(not structkeyexists(ss, 'inquiries_type_id_siteidtype')){
		throw("arguments.ss.inquiries_type_id_siteidtype is required");
	}
	if(not structkeyexists(ss, 'forceSend')){
		ss.forceSend=false;
	}
	if(not structkeyexists(ss, 'preview')){
		ss.preview=false;
	}
	if(not structkeyexists(ss, 'dataStruct')){
		ss.dataStruct={};
	} 
	defaultStruct={
		firstName:"Customer",
		lastName:"",
		interestedInModel:"Unspecified Model",
		email:ss.to,
		officeID:0
	};
	structappend(ss.dataStruct, defaultStruct, false);

	hasModelEmail=false;
	if(application.zcore.functions.zso(ss.dataStruct, 'interestedInModel') NEQ ""){
		db.sql="SELECT * FROM 
		#db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#,
		#db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE 
		inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
		inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
		inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
		inquiries_autoresponder_deleted = #db.param(0)# and 
		inquiries_autoresponder_interested_in_model = #db.param(ss.dataStruct.interestedInModel)# and 
		inquiries_type_deleted = #db.param(0)# and 
		inquiries_autoresponder.inquiries_type_id=#db.param(ss.inquiries_type_id)# and 
		inquiries_autoresponder.inquiries_type_id_siteidtype=#db.param(ss.inquiries_type_id_siteidtype)# "; 
		if(not ss.preview and not ss.forceSend){
			db.sql&=" and inquiries_autoresponder_active=#db.param(1)# ";
		}
		qAutoresponder=db.execute("qAutoresponder", "", 10000, "query", false); 
		if(qAutoresponder.recordcount NEQ 0){
			hasModelEmail=true;
		}
	}
	if(not hasModelEmail){
		db.sql="SELECT * FROM 
		#db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#,
		#db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE 
		inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
		inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
		inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
		inquiries_autoresponder_deleted = #db.param(0)# and 
		inquiries_autoresponder_interested_in_model = #db.param('')# and 
		inquiries_type_deleted = #db.param(0)# and 
		inquiries_autoresponder.inquiries_type_id=#db.param(ss.inquiries_type_id)# and 
		inquiries_autoresponder.inquiries_type_id_siteidtype=#db.param(ss.inquiries_type_id_siteidtype)# "; 
		if(not ss.preview and not ss.forceSend){
			db.sql&=" and inquiries_autoresponder_active=#db.param(1)# ";
		}
		qAutoresponder=db.execute("qAutoresponder", "", 10000, "query", false); 
	} 
	if(qAutoresponder.recordcount EQ 0){  
		return {success:false}; 
	}

	ts={};
	ts.subject=qAutoresponder.inquiries_autoresponder_subject;
	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderTemplate')){
		for(row in qAutoresponder){
			rs=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderTemplate(row);
		}
		if(structkeyexists(rs, 'dataStruct')){
			for(i in rs.dataStruct){
				if(application.zcore.functions.zso(ss.dataStruct, i) EQ ""){
					ss.dataStruct[i]=rs.dataStruct[i];
				}
			}
		}
		if(ss.preview or ss.forceSend){ 
			if(structkeyexists(rs, 'defaultStruct')){
				structappend(ss.dataStruct, rs.defaultStruct, true);
			}	
			ss.dataStruct.email=ss.to;
		}
	}else{
		rs={
			htmlStart:'#application.zcore.functions.zHTMLDoctype()#
				<head>
				<meta charset="utf-8" />
				<title></title>
				</head> 
				<body>',
			htmlEnd:'</body>
			</html>'
		};

	}
	mainHTML = "";
	if ( qAutoresponder.inquiries_autoresponder_main_image NEQ '' ) {
		// if ( qAutoresponder.inquiries_autoresponder_main_link NEQ '' ) {
		// 	mainHTML = '<p><a href="#qAutoresponder.inquiries_autoresponder_main_link#"><img src="#this.getDripImageURL( qAutoresponder.inquiries_autoresponder_main_image )#" style="float:left;"></a></p>';
		// } else {
			mainHTML = '<p><img src="#request.zos.globals.domain#/zupload/autoresponder/#qAutoresponder.inquiries_autoresponder_main_image#" style="float:left;"></p>';
		// }
	}
	ts.html=rs.htmlStart&qAutoresponder.inquiries_autoresponder_html&mainHTML&rs.htmlEnd;

	ts.html=application.zcore.email.forceAbsoluteURLs(ts.html);
	// replace variables
	for(field in ss.dataStruct){
		value=ss.dataStruct[field];
		ts.html=replaceNoCase(ts.html, "%"&field&"%", value, "all");
	}
	ts.html=rereplace(ts.html, '%[^%]+%', '', 'all');
	ts.html=replace(ts.html, '%%', '%', 'all');
 

	ts.to=ss.to;

	fromEmail = ss.from; 
	if(qAutoresponder.inquiries_autoresponder_from NEQ ""){
		fromEmail=qAutoresponder.inquiries_autoresponder_from;
	}


	if ( fromEmail EQ '' ) {
		fromEmail = request.officeEmail;
	}

	ts.from=fromEmail;
	if(application.zcore.functions.zso(ss, 'cc') NEQ ""){
		ts.cc=ss.cc;
	}
	if(qAutoresponder.inquiries_autoresponder_bcc NEQ ""){
		ts.bcc=qAutoresponder.inquiries_autoresponder_bcc;
	}
	if(ss.preview){
		return {success:true, data:ts};
	}
 
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rCom.setStatusErrors(request.zsid); 
		application.zcore.status.setStatus(request.zsid, "Autoresponder test failed");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#"); 
	}

	autoresponderDripsCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.autoresponder-drips' );

	if ( autoresponderDripsCom.autoresponderHasDrips( qAutoresponder.inquiries_autoresponder_id ) ) {
		subscriberStruct = {
			'email': ts.to,
			'inquiries_type_id': ss.inquiries_type_id,
			'autoresponder_id': qAutoresponder.inquiries_autoresponder_id,
			'first_name': ss.dataStruct.firstName,
			'last_name': ss.dataStruct.lastName,
			'interested_in_model': ss.dataStruct.interestedInModel,
			'officeID':ss.dataStruct.officeID
		};

		autoresponderDripsCom.subscribe( subscriberStruct );
	}

	return {success:true, data:ts};
	</cfscript> 
</cffunction> 

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject;
	var ts={}; 
	init(); 
	form.typeId=application.zcore.functions.zso(form, 'typeId', false, ""); 
	ts.inquiries_autoresponder_subject.required=true;
	ts.inquiries_autoresponder_html.required=true;
	error = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);

	arrType=listToArray(form.typeId, "|");
	if(arrayLen(arrType) EQ 2){
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE  
		inquiries_type_deleted=#db.param(0)# and 
		inquiries_type_id=#db.param(arrType[1])# and 
		site_id=#db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(arrType[2]))# ";
		qType=db.execute("qType"); 
		if(qType.recordcount EQ 0){
			error=true;
			application.zcore.status.setStatus(request.zsid, "Lead type is required.", form, true);
		}else{
			form.inquiries_type_id=arrType[1];
			form.inquiries_type_id_siteidtype=arrType[2];
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Lead type is required", form, true);
		error=true;
	}

	if(form.inquiries_autoresponder_from NEQ ""){
		if(not application.zcore.functions.zEmailValidate(form.inquiries_autoresponder_from)){
			application.zcore.status.setStatus(request.zsid, "From Email: #form.inquiries_autoresponder_from# is not a valid email.", form, true);
			error=true;
		}
	}
	arrBcc=listToArray(form.inquiries_autoresponder_bcc, ",");
	arrNewBcc=[];
	for(email in arrBcc){
		email=trim(email);
		if(email NEQ ""){
			if(not application.zcore.functions.zEmailValidate(email)){
				error=true;
				application.zcore.status.setStatus(request.zsid, "BCC Email: #email# is not a valid email.", form, true);
			}else{
				arrayAppend(arrNewBcc, email);
			}
		}
	}

	if(error){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/edit?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}
	}  
	form.inquiries_autoresponder_bcc=arrayToList(arrNewBcc, ",");


	application.zcore.functions.zCreateDirectory(request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath, 1, 1));
	StructDelete(variables,'inquiries_autoresponder_main_image');
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_main_image", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), '650x2000');
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_main_image", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), '650x2000', 'user', 'user_id', "inquiries_autoresponder_main_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'inquiries_autoresponder_main_image');
		StructDelete(variables,'inquiries_autoresponder_main_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.inquiries_autoresponder_main_image=arrList[1];
	}else{
		StructDelete(form,'inquiries_autoresponder_main_image');
	}
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_main_image_delete',true) EQ 1){
		form.inquiries_autoresponder_main_image='';	
	}

	form.inquiries_autoresponder_deleted=0;
	form.inquiries_autoresponder_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table='inquiries_autoresponder';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
 
	if(form.method EQ 'insert'){
		form.inquiries_autoresponder_id = application.zcore.functions.zInsert(ts);
		if(form.inquiries_autoresponder_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save autoresponder.  Note: there can only be 1 autoresponder per lead type.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Autoresponder saved.'); 
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save autoresponder.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/edit?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Autoresponder updated.');
		} 
	} 
	application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject; 
	var currentMethod=form.method; 
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_id') EQ ''){
		form.inquiries_autoresponder_id = -1;
	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# inquiries_autoresponder 
	WHERE  
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");
	application.zcore.functions.zQueryToStruct(qAutoresponder);
	application.zcore.functions.zStatusHandler(request.zsid,true);

	if(form.inquiries_autoresponder_active EQ ""){
		form.inquiries_autoresponder_active=1;
	}

	</cfscript>
	<h2><cfif currentMethod EQ "add">
		Add
		<cfscript>
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		</cfscript>
	<cfelse>
		Edit
	</cfif>
	Autoresponder</h2>
	 
	<cfscript>
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
			tabCom.init();
	tabCom.setTabs(["Basic"]);
	tabCom.setMenuName("admin-list"); 
	cancelURL="/z/inquiries/admin/autoresponder/index"; 
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();

	variableStruct={
		firstName:"John",
		interestedInModel:"Model",
		email:"test@test.com"
	};

	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderTemplate')){
		rs=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderTemplate({inquiries_type_name:''});
		if(structkeyexists(rs, 'defaultStruct')){
			structappend(variableStruct, rs.defaultStruct, true);
		}
	}
	
	</cfscript>

	<p>Be sure to use a simple one column plain text layout with no embedded assets to ensure users can read your content in any email client.  Colors/tables/videos/images may fail to load in an autoresponder.  Be sure to test the autoresponder after you make changes to it.</p>
	<p>The following variables can be included in the Body text. They will be replaced with the user's personal information when the autoresponder is sent.</p>
	<p>If the data for the variable is not available, a default value will be shown such as "Customer" for %firstName%</p>
	<ul>
		<cfscript>
		arrKey=structkeyarray(variableStruct);
		arraySort(arrKey, "text", "asc");
		for(field in arrKey){
			echo('<li>%#field#%</li>');
		}
		</cfscript>
	</ul>
	<p>If you need to insert a literal percent sign in the email, like 100%, you must type it twice so that it is not removed.  For example: 100%%.</p>
	<p>* Denotes required field</p>
	<form id="listForm1" action="/z/inquiries/admin/autoresponder/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#" method="post" enctype="multipart/form-data">
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%;" class="table-list">  
		<cfscript>
		if(application.zcore.functions.zso(form, 'typeId') EQ ""){
			form.typeId=form.inquiries_type_id&"|"&form.inquiries_type_id_siteidtype;
		} 
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted=#db.param(0)#";
		if(not application.zcore.app.siteHasApp("listing")){
			db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
		}
		if(not application.zcore.app.siteHasApp("rental")){
			db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
		}
		db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
		qType=db.execute("qType");
		arrLabel=[];
		arrValue=[];
		for(row in qType){
			arrayAppend(arrLabel, row.inquiries_type_name);
			arrayAppend(arrValue, row.inquiries_type_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id));
		}
		</cfscript>
		<tr>
			<th>Lead Type *</th>
			<td>
				<cfscript> 
				selectStruct = StructNew();
				selectStruct.name = "typeId";
				selectStruct.listValuesDelimiter=chr(9);
				selectStruct.listLabelsDelimiter=chr(9);
				selectStruct.listLabels=arrayToList(arrLabel, chr(9));
				selectStruct.listValues=arrayToList(arrValue, chr(9));   
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Subject *</th>
			<td><input type="text" name="inquiries_autoresponder_subject" id="inquiries_autoresponder_subject" value="#htmleditformat(form.inquiries_autoresponder_subject)#" /></td>
		</tr>
		<tr>
			<th>From Address</th>
			<td><input type="text" name="inquiries_autoresponder_from" id="inquiries_autoresponder_from" value="#htmleditformat(form.inquiries_autoresponder_from)#" /><br />(will default to &lt;#request.officeEmail#&gt; if left empty)</td>
		</tr>
		<tr>
			<th>BCC</th>
			<td><input type="text" name="inquiries_autoresponder_bcc" id="inquiries_autoresponder_bcc" value="#htmleditformat(form.inquiries_autoresponder_bcc)#" /><br />(comma separated list of people to BCC on all autoresponders and drip autoresponders)</td>
		</tr>
		<tr>
			<th>Interested In Model</th>
			<td><input type="text" name="inquiries_autoresponder_interested_in_model" id="inquiries_autoresponder_interested_in_model" value="#htmleditformat(form.inquiries_autoresponder_interested_in_model)#" /></td>
		</tr>
		<tr>
			<th>Main Image</th>
			<td> 
				#application.zcore.functions.zInputImage('inquiries_autoresponder_main_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), request.zos.globals.siteroot&request.zos.autoresponderImagePath)#<br><br>
				Maximum size is 650x2000. </td>
		</tr>
		<tr>
			<th>Body *</th>
			<td>
				<p><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.html-editor");
				htmlEditor.instanceName	= "inquiries_autoresponder_html";
				htmlEditor.value			= form.inquiries_autoresponder_html;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "100%";
				htmlEditor.height		= 300;
				htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
				htmlEditor.create();
				</cfscript></p>

			</td>
		</tr>
		
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>
			<tr>
				<th>Import Option</th>
				<td>
					<p>Allow non-administrators to import leads who can receive this autoresponder?</p>

					<p>#application.zcore.functions.zInput_Boolean("inquiries_autoresponder_allow_user_import")#</p>
				</td>
			</tr> 
		</cfif>

		<!--- <tr>
			<th>Text Version</th>
			<td><textarea type="text" cols="50" rows="5" name="inquiries_autoresponder_text" id="inquiries_autoresponder_text">#htmleditformat(form.inquiries_autoresponder_text)#</textarea></td>
		</tr> --->
		<tr>
			<th>Active</th>
			<td><!--- No <input type="hidden" name="inquiries_autoresponder_active" value="0">  --->
				#application.zcore.functions.zInput_Boolean("inquiries_autoresponder_active")# <!--- --->
			</td>
		</tr> 
	</table> 
	#tabCom.endFieldSet()#  
	#tabCom.endTabMenu()#    
	</form>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="administrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Autoresponders");	 
	</cfscript>
</cffunction>	

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	init();  
	
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	application.zcore.functions.zStatusHandler(request.zsid); 
 	searchOn=false; 
	db.sql="SELECT * 
	from #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# , 
	#db.table("inquiries_type", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
	inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)# and 
	inquiries_type_deleted = #db.param(0)# 
	ORDER BY inquiries_type_name ASC ";
	qAutoresponder=db.execute("qAutoresponder"); 
	</cfscript>
	<h2 style="display:inline-block;">Autoresponders</h2> &nbsp;&nbsp; 
	<a href="/z/inquiries/admin/autoresponder/add" class="z-manager-search-button">Add</a>
	<br><br>
	<p>Note: If you wish to further customize how autoresponders work, please contact your web developer.</p> 
 
	<cfif qAutoresponder.recordcount EQ 0>
		<p>No autoresponders found.</p>
	<cfelse> 
		<table class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Lead Type</th>  
				<th>Subject</th>  
				<th>Updated Date</th>  
				<th>Active</th>  
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfloop query="qAutoresponder">
				<tr <cfif qAutoresponder.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qAutoresponder.inquiries_autoresponder_id#</td> 
					<td>#qAutoresponder.inquiries_type_name#</td> 
					<td>#qAutoresponder.inquiries_autoresponder_subject#</td> 
					<td>#dateformat(qAutoresponder.inquiries_autoresponder_updated_datetime, "m/d/yy")#</td>
					<td><cfif qAutoresponder.inquiries_autoresponder_active EQ 1>Yes<cfelse>No</cfif></td>
					<td class="z-manager-admin"> 

						<div class="z-manager-button-container"> 
							<a href="##" class="z-manager-edit" id="z-manager-edit#qAutoresponder.inquiries_autoresponder_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
							<div class="z-manager-edit-menu">
								<a href="/z/inquiries/admin/autoresponder/edit?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#">Edit</a> 
								<a href="/z/inquiries/admin/autoresponder/test?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#">Test Autoresponder</a>
								<a href="/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#">Manage Drip Emails</a>    
							</div>
						</div>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/autoresponder/delete?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#" onclick="return window.confirm('Are you sure you want to remove this autoresponder?');" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a> 
						</div>
					</td>

				</tr>
				</cfloop>
			</tbody>
		</table> 
	</cfif>
</cffunction>

</cfoutput>
</cfcomponent>