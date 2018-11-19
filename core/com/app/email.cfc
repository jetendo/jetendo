<cfcomponent>
<cfoutput>
 
	
<!--- 
text=eCom.convertHTMLToText(text);
--->
<cffunction name="convertHTMLToText" localmode="modern" output="yes" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="enableSlowMethod" type="boolean" required="no" default="#false#">
	<cfscript>
	if(not arguments.enableSlowMethod){
		str=arguments.text;
	    str = reReplaceNoCase(str, "<style[^>]*?>(.*?)</style>","","all");
	    str = reReplaceNoCase(str, "<script[^>]*?>(.*?)</script>","","all");

	    str = reReplaceNoCase(str, "<[^>]*>","","all");
	    str=replace(replace(replace(replace(replace(replace(str, '&ndash;', '-', 'all'), '&nbsp;', ' ', 'all'), '&rsquo;', "'", 'all'), '&lsquo;', "'", 'all'), '&rdquo;', '"', 'all'), '&ldquo;', '"', 'all');
	    return str;
    }else{
		var badTagList="style|link|head|script|embed|base|input|textarea|button|object|iframe|form";
		arguments.text=lcase(arguments.text);
		// convert all whitespace to space
		arguments.text=rereplacenocase(arguments.text,"\s", " ", 'ALL');
		// remove consequtive spaces
		arguments.text=rereplacenocase(arguments.text,"\s*(\S*)", " \1", 'ALL');
		// convert break tags to newlines
		arguments.text=rereplacenocase(arguments.text,"<br.*?>", chr(10), 'ALL');
		// remove tags that have useless contents nested in them
		arguments.text=rereplacenocase(arguments.text,"<(#badTagList#)[^>]*?>.*?</\1>", " ", 'ALL');
		// remove all html tags
		arguments.text=rereplacenocase(arguments.text,"<.*?>", " ", 'ALL');
		// trim and return
		arguments.text=trim(arguments.text);
		return arguments.text;
	}
	</cfscript>
</cffunction>


<!--- html=application.zcore.email.cleanHTML(html); ---> 
<cffunction name="cleanHTML" localmode="modern" output="no" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfscript>
	var badTagList="style|script|embed|base|input|textarea|button|object|iframe|form"; 
	/*
	// this code will unescape urlencodedformat() which causes some links to break.  We can't use this feature anywhere.  we may need to implement a different solution someday.
	try{
		arguments.text = canonicalize( arguments.text, true, true );
	}catch(Any e){

	}*/
	arguments.text=rereplacenocase(arguments.text,"<(#badTagList#).*?</\1>", " ", 'ALL');
	arguments.text=rereplacenocase(arguments.text,"(</|<)(#badTagList#)[^>]*>", " ", 'ALL'); 
	// disable "javascript:" everywhere
	arguments.text=rereplacenocase(arguments.text,"j(\s*)a(\s*)v(\s*)a(\s*)s(\s*)c(\s*)r(\s*)i(\s*)p(\s*)t(\s*):",'javascript - ','all'); 
	// remove onanything tag attributes that could have javascript i.e. onclick="badCode();"
	arguments.text=rereplacenocase(arguments.text,"on([a-zA-Z\s])*=",'\0&##61;','ALL');   
	return arguments.text;
	</cfscript>
</cffunction>

<!--- html=application.zcore.email.makeHTMLSafe(html); --->
<cffunction name="makeHTMLSafe" localmode="modern" access="public">
	<cfargument name="theHTML" type="string" required="yes">
	<cfscript>
	var html = arguments.theHTML; 
	/*
	// this code will unescape urlencodedformat() which causes some links to break.  We can't use this feature anywhere.  we may need to implement a different solution someday.
	try{
		arguments.text = canonicalize( arguments.text, true, true );
	}catch(Any e){

	}*/
	var badTagList="script|embed|base|input|textarea|button|object|iframe|form|"&application.zcore.disabledHTMLTagList; 
	html=rereplacenocase(html,"<(#badTagList#).*?</\1>", " ", 'ALL'); 
	// remove improper tags
	html=rereplacenocase(html,"(</|<)(#badTagList#)[^>]*>", " ", 'ALL'); 
	// remove "javascript:" from all tags with href links but allow it to exist as a literal in case someone was trying to type it in a safe way.
	html=rereplacenocase(html,"j(\s*)a(\s*)v(\s*)a(\s*)s(\s*)c(\s*)r(\s*)i(\s*)p(\s*)t(\s*):",'javascript - ','all'); 
	// disable onanything tag attributes that could have javascript i.e. onclick="badCode();"
	html=rereplacenocase(html,"on([a-zA-Z\s])*=",'\0&##61;','ALL');  

	return html;
	</cfscript>
</cffunction>

<!--- text=eCom.convertToHtml(text); --->
<cffunction name="convertToHtml" localmode="modern" output="no" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfscript>
	var arrWord=0;
	var n=1;
	var ns="";
	var i=1;
	var np=0;
	var body=arguments.text;
	var body2=rereplacenocase(body,'([\s''"\[\]<>])',' \1 ','all');
	body2=rereplacenocase(body2,'([^http|https]):','\1: ','all');
	/*body2=replacenocase(body2,':',': ','all');
	body2=replacenocase(body2,'http: ','http:','all');
	body2=replacenocase(body2,'https: ','https:','all');*/
	arrWord=listtoarray(body2,' ');
	n=1;
	ns="";
	for(i=1;i LTE arraylen(arrWord);i++){
		if(len(trim(arrWord[i])) LTE 4) continue;
		if(application.zcore.functions.zEmailValidate(arrWord[i])){
			np=find(arrWord[i],body,n);
			if(np EQ 0) continue;
			ns='<a href="mailto:'&arrWord[i]&'" target="_blank">'&arrWord[i]&'</a>';
			n=np+len(ns);
			body=removeChars(body,np,len(arrWord[i]));
			body=insert(ns,body,np-1);
		}else{
			last4=right(arrWord[i],4);
			if(left(arrWord[i],7) EQ 'http://' and find('.',arrWord[i]) NEQ 0){
				np=find(arrWord[i],body,n);
				if(np EQ 0) continue;
				ns='<a href="'&arrWord[i]&'" target="_blank">'&arrWord[i]&'</a>';
				n=np+len(ns);
				body=removeChars(body,np,len(arrWord[i]));
				body=insert(ns,body,np-1);
			}else if(left(arrWord[i],8) EQ 'https://' and find('.',arrWord[i]) NEQ 0){
				np=find(arrWord[i],body,n);
				if(np EQ 0) continue;
				ns='<a href="'&arrWord[i]&'" target="_blank">'&arrWord[i]&'</a>';
				n=np+len(ns);
				body=removeChars(body,np,len(arrWord[i]));
				body=insert(ns,body,np-1);
			}else if(left(arrWord[i],4) EQ 'www.' and find('.',arrWord[i],5) NEQ 0){
				np=find(arrWord[i],body,n);
				if(np EQ 0) continue;
				ns='<a href="http://'&arrWord[i]&'" target="_blank">'&arrWord[i]&'</a>';
				n=np+len(ns);
				body=removeChars(body,np,len(arrWord[i]));
				body=insert(ns,body,np-1);
			}else if(left(last4,1) EQ '.' and findnocase(','&right(last4,3)&',', ',com,net,org,biz,gov,edu,')){
				np=find(arrWord[i],body,n);
				if(np EQ 0) continue;
				ns='<a href="http://'&arrWord[i]&'" target="_blank">'&arrWord[i]&'</a>';
				n=np+len(ns);
				body=removeChars(body,np,len(arrWord[i]));
				body=insert(ns,body,np-1);
			}
		}
	}
	return '#application.zcore.functions.zHTMLDoctype()#<body>'&application.zcore.functions.zparagraphformat(body)&'</body></html>';
	</cfscript>
</cffunction>



<!--- 
text=eCom.escapeEmailName(text);
 --->
<cffunction name="escapeEmailName" localmode="modern" output="no" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfscript>
	arguments.text=replace(arguments.text,'\','\\','ALL');
	arguments.text=replace(arguments.text,'"','\"','ALL');
	return arguments.text;
	</cfscript>
</cffunction>



<!--- 
text=eCom.forceAbsoluteURLs(text);
 --->
<cffunction name="forceAbsoluteURLs" localmode="modern" output="yes" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfscript>
	var ns=0;
	var newhtml=arguments.text;
	var links=0;
	var links2=0;
	var n=0;
	var u=0;
	var ru=0;
	var i=0;
	var dt=0;
	var ht=0;
	var up=0;
	var np=0;
	var upf=0;
	var arrImage=0;
	links=replace(newhtml,chr(9),' ','ALL');
	links=replace(links,chr(10),'','ALL');
	//links2=links;
	//links2=rereplacenocase(links2,"[^:]*?\s*(:\s*url\s*?\(\s*)([^\)]*)(\s*\))\s*(;|}|""|')[^:]*",chr(9)&'\2'&chr(10)&'\1\2\3'&chr(9),'ALL');		
	links=rereplacenocase(links,".*?<.*?(href\s*=\s*?(""|')*)([^\2^>^\s\^'^\""]*)((\2)*)?[^>]*>[^<^>]*",chr(9)&'\3'&chr(10)&'\1\3\4'&chr(9),'ALL');//&links2;
	// remove everything but the links
	links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1"&chr(9), 'ALL');
	links=replace(links,chr(10),chr(9),'ALL');
	arrImage=listtoarray(trim(links),chr(9),true);
	n=1;
	// map or download all the files to the filesystem and replace the text with the content ids
	if(arraylen(arrImage) GT 1){
		for(i=1;i LTE arraylen(arrImage);i+=2){
			u=arrImage[i];
			ru=arrImage[i+1];
			// ignore existing content ids
			if(trim(u) EQ '' or left(trim(u),4) EQ 'cid:' or left(trim(u),7) EQ 'mailto:') continue;
			// convert u to absolute url
			up=application.zcore.functions.zForceAbsoluteURL(request.zos.currentHostName,u);
			np=find(ru,newhtml,n);
			if(np EQ 0) continue;
			if(up EQ ''){
				ns=replace(ru,u,'','ONE');
			}else{
				ns=replace(ru,u,up,'ONE');
			}
			n=np+len(ns);
			newhtml=removeChars(newhtml,np,len(ru));
			newhtml=insert(ns,newhtml,np-1);
		}
	}
	// return the final object		
	return newhtml;
	</cfscript>
</cffunction>


<cffunction name="embedImages" localmode="modern" output="yes" returntype="any">
	<cfargument name="html" type="string" required="yes">
	<cfargument name="preview" type="boolean" required="no" default="#false#">
	<!--- <cfargument name="nodownload" type="boolean" required="no" default="#false#"> --->
	<cfscript>
	var rs=StructNew();
	var newhtml=0;
	var links=0;
	var links2=0;
	var n2='';
	var pos='';
	var ext='';
	var p='';
	var ns='';
	var n=0;
	var u=0;
	var ru=0;
	var i=0;
	var dt=0;
	var ht=0;
	var up=0;
	var np=0;
	var upf=0;
	var up1=0;
	var arrImage=0;
	var u2=0;
	var n5=0;
	var n3=0;
	var matched=false;
	var arrU=arraynew(1);
	var curDomain=request.zos.currentHostName;
	rs.html=arguments.html;
	rs.newhtml=arguments.html;
	rs.arrCID=arraynew(1); 
	if(arguments.preview){
		return rs;
	}
	// array of files to be used like this: 
	// <cfloop from="1" to="#arraylen(rs.arrCID)#" index="i"><cfmail><cfmailparam file="#rs.arrCID[i]#"></cfmail></cfloop>
	// process the text to extract all variations of src="image.jpg" and :url(image.jpg); 
	links=replace(rs.newhtml,chr(9),' ','ALL');
	links=replace(links,chr(10),'','ALL');
	links2=links;
	links2=rereplacenocase(links2,"[^:]*?\s*(:\s*url\s*?\(\s*)([^\)]*)(\s*\))\s*(;|}|""|')[^:]*",chr(9)&'\2'&chr(10)&'\1\2\3'&chr(9),'ALL');		
	links=rereplacenocase(links,".*?<.*?(src\s*=\s*?(""|')*)([^\2^>^\s\^'^\""]*)((\2)*)?[^>]*>[^<^>]*",chr(9)&'\3'&chr(10)&'\1\3\4'&chr(9),'ALL')&links2;
	// remove everything but the links
	links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1"&chr(9), 'ALL');
	links=replace(links,chr(10),chr(9),'ALL');
	arrImage=listtoarray(trim(links),chr(9),true);
	if(arraylen(arrImage) EQ 1){
		arrImage=arraynew(1);
	}
	n=1;
	n2=1;
	
	if(isDefined('request.zdebugemail')){
		request.sendEmailDataARRIMAGE=arrImage;
	}
	if(not directoryexists(request.zos.globals.serverprivatehomedir&'cid_tmp/')){
		application.zcore.functions.zcreatedirectory(request.zos.globals.serverprivatehomedir&'cid_tmp/');
	}
	// map or download all the files to the filesystem and replace the text with the content ids
	for(i=1;i LTE arraylen(arrImage);i+=2){
		u=arrImage[i];
		ru=arrImage[i+1];
		// ignore existing content ids
		if(trim(u) EQ '' or left(trim(u),4) EQ 'cid:') continue;
		// convert u to absolute url
		up=u;
		up1=application.zcore.functions.zForceAbsoluteURL(curDomain,urldecode(up));
		// check if the file is on our server
		dt=left(up1,len(curDomain));
		ht=request.zos.globals.privatehomedir&removeChars(up1,1,len(curDomain)+1);
		matched=0;
		for(n3=1;n3 LTE arraylen(arrU);n3++){
			if(trim(u) EQ trim(arrU[n3])){
				matched=n3;
			}
		}
		if(matched EQ 0){
			if(find("?",up1) EQ 0 and dt EQ curDomain and isImageFile(ht)){
				// fast grab from filesystem - no download needed
				up=up1;
				upf=ht;
			}else{
				// get rewrite, dynamic or remote urls using http
				u2=up1;
				pos=find("?",u2);
				if(pos NEQ 0){
					u2=left(u2,pos-1);
				}
				ext=application.zcore.functions.zGetFileExt(getFileFromPath(u2));
				p=request.zos.globals.serverprivatehomedir&'cid_tmp/'&timeformat(now(),'mmss')&gettickcount();
				if(ext NEQ ''){
					ext='.'&ext;
				}
				n5=1;
				while(true){
					if(fileexists(p&n5&ext) EQ false) break;
					n5++;
				}
				upf=p&n5&ext; // unique to the millisecond

				// ignore files that don't have an extension
				if(find(','&ext&',', ',.jpg,.jpe,.gif,.png,') EQ 0){
					//up='';
					continue;
				/* // don't need preview validation anymore
				}else if(arguments.preview){
					application.zcore.functions.zHTTPtoFile(up,false);
					if(left(cfhttp.statuscode,3) EQ '200'){
						up='{preview mode:#u# returned status code 200 OK}';
					}else{
						up='{preview mode:#u# failed with status code #cfhttp.statuscode#}';
					}*/
				}else if(application.zcore.functions.zHTTPtoFile(up1,upf) EQ false){
					// invalid link
					upf='';
				}
			}
		}
		// update newhtml
		np=find(ru,rs.newhtml,n);
		if(np EQ 0) continue;
		if(left(up,1) EQ '{'){
			//ns=replace(ru,u,'','ONE');
			if(matched EQ 0){
				arrayappend(rs.arrCID,up);	
				matched=arraylen(rs.arrCID);
			}
			arrayappend(arrU,upf);
			ns=replace(ru,u,'cid:zcorecid'&matched,'ONE');
			
		}else if(up EQ ''){
			ns=replace(ru,u,'','ONE');
		}else{
			arrayappend(arrU,u);
			if(matched EQ 0){
				arrayappend(rs.arrCID,up);	
				matched=arraylen(rs.arrCID);
			}
			ns=replace(ru,u,'cid:zcorecid'&matched,'ONE');
		}
		n=np+len(ns);
		rs.newhtml=removeChars(rs.newhtml,np,len(ru));
		rs.newhtml=insert(ns,rs.newhtml,np-1);
		// update html
		np=find(ru,rs.html,n2);
		if(np EQ 0) continue;
		if(left(up,1) EQ '{'){
			//ns=replace(ru,u,'','ONE');
			ns=replace(ru,u,up1,'ONE');
		}else if(up EQ ''){
			ns=replace(ru,u,'','ONE');
		}else{
			ns=replace(ru,u,up1,'ONE');
		}
		n2=np+len(ns);
		rs.html=removeChars(rs.html,np,len(ru));
		rs.html=insert(ns,rs.html,np-1);
	}
	//writeoutput(htmleditformat(rs.newhtml));
	//application.zcore.functions.zabort();
	// return the final object		
	return rs;
	</cfscript>
</cffunction>


<!--- 
ts=StructNew();
// required
ts.subject="";
ts.html="";
// or 
ts.text="";
ts.to="";
// optional
ts.priority=3; // 1-5; 1 is fastest
ts.cc="";
ts.bcc="";
ts.autotext=true; // automatically create the plain text from the html code
ts.embedImages=false; // set to true to automatically embed images
ts.attachments=arraynew(1); // array of file paths
ts.arrCID=arraynew(1); // used for sending an html email that already has the images embedded, much faster when sending the same email in bulk
ts.overrideMailServer=true;
ts.popserver="";
ts.username="";
ts.password="";
ts.spoolenable=true; // set to false to send email instantly
ts.preview=false; // set to true to return preview/debugging object instead of running <cfmail> and database queries.
ts.draft=false; // disables cfmail, but allows save and preview to work as normal.
ts.save=true; // if true, you must call eCom.setAccount() before using the function.  if false, the email is not saved in the database and no user_id or site_id is information.
ts.skipProcessing=false; // only set to true when you are 100% sure the data is valid.  Data will not be saved in sent folder.  This is used for bulk email campaigns.
// fields used when saving
ts.user_id=request.zsession.user.id;
ts.site_id=request.zos.globals.id;
ts.zemail_parent_id=0;
rCom=emailCom.send(ts);
if(rCom.isOK() EQ false){
	rCom.setStatusErrors(request.zsid);
	application.zcore.functions.zstatushandler(request.zsid);
	application.zcore.functions.zabort();
}
//zdump(rCom.getData());
 --->
<cffunction name="send" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var mimetype='';
	var rs2='';
	var i='';
	var ns='';
	var inputStruct='';
	var zemail_data_id='';
	var count='';
	var ts=StructNew();
	var rs=StructNew();
	var emailType="html";
	var cfmailType="html";
	var db=request.zos.queryObject;
	var tmpText="";
	var zemail_id=false;
	var np=0;
	var newFileName="";
	var p2=0;
	var p=0;
	var ext="";
	var renaming=true;
	var res="";
	var newhtml="";
	var ms=structNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	rs.addressList=structnew();
	rs.addressList.from=false;
	rs.addressList.to=false;
	rs.addressList.cc=false;
	rs.addressList.bcc=false;
	ts.zemail_parent_id=0; // not grouped by default
	ts.priority=3; // low priority by default
	ts.overrideMailServer=false;
	ts.autotext=true; // by default, automatically create the plain text from the html code
	ts.attachments=arraynew(1);
	if(structkeyexists(arguments.ss, 'save') and arguments.ss.save){
		ts.zemail_folder_id = this.getFolder("sent");
	} 
	ts.failto="";
	ts.preview=false;
	ts.embedImages=false;
	ts.to="";
	ts.arrCID=arraynew(1);
	ts.bcc="";
	ts.cc="";
	ts.text="";
	ts.replyto="";
	ts.html="";
	ts.subject="";
	ts.draft=false; // disables cfmail, but allows save and preview to work as normal.
	ts.skipProcessing=false; // only set to true when you are 100% sure the data is valid.  Data will not be saved in sent folder.  This is used for bulk email campaigns.
	ts.spoolenable=true; // by default allow coldfusion to spool emails for prioritized delivery
	ts.save=false; // by default don't save the email
	if(isDefined('request.zsession.user.id')){
		ts.user_id=request.zsession.user.id;
	}
	ts.site_id=request.zos.globals.id;
	// inherit email account login from the component
	ts.from=request.zos.emailData.from;
	ts.popserver=request.zos.emailData.popserver;
	ts.username=request.zos.emailData.username;
	ts.password=request.zos.emailData.password;
	StructAppend(arguments.ss,ts,false);
	if(arguments.ss.save and request.zos.emailData.zemail_account_id EQ false){
		rCom.setError("You must call this.setAccount() before calling this.send().",1);
		return rCom;
	}
	/*ms["pdf"]="application/pdf";
	ms["dwt"]="application/dwg";
	ms["plt"]="application/plt";
	ms["jpg"]="image/jpeg";
	ms["tif"]="image/tiff";*/
	</cfscript>
	<cfif arguments.ss.skipProcessing>
		<cfif arguments.ss.preview EQ false>
			disabled<cfabort><!--- server="#arguments.ss.popserver#" username="#arguments.ss.username#" password="#arguments.ss.password#" --->
<!--- <cfmail  TO = "#arguments.ss.to#" CC="#arguments.ss.cc#" BCC="#arguments.ss.bcc#" FROM="#arguments.ss.from#" replyto="#arguments.ss.replyto#" SUBJECT= "#arguments.ss.subject#" type="#cfmailType#" priority="#arguments.ss.priority#" mailerid="Web Mailer" charset="utf-8" failto="#arguments.ss.failto#" spoolenable="#arguments.ss.spoolenable#">
<cfif emailType EQ 'text+html'>
<cfmailpart wraptext="74" charset="utf-8" type="text/plain">#arguments.ss.text#</cfmailpart>
</cfif><cfif emailType EQ 'text+html' or emailType EQ 'html'>
 <cfmailparam name="Content-Type" value="multipart/related">
#arguments.ss.html#<!---<cfmailpart  charset="utf-8" type="text/html"></cfmailpart>--->
<cfloop index="count" from="1" to="#arraylen(arguments.ss.arrCID)#">
<cfscript>
mimetype=filegetmimetype(arguments.ss.arrCID[count]);
</cfscript>
<cfmailparam file="#arguments.ss.arrCID[count]#" disposition="inline" contentID="zcorecid#count#" type="#mimetype#">
</cfloop></cfif><cfif emailType EQ 'html'>#arguments.ss.html#<cfelseif emailType EQ 'text'>
<cfmailpart charset="utf-8" type="text/plain">#arguments.ss.text#</cfmailpart></cfif>
<cfloop index="count" from="1" to="#arraylen(arguments.ss.attachments)#">
<cfscript>
mimetype=filegetmimetype(arguments.ss.attachments[count]);
</cfscript>
<cfmailparam file="#arguments.ss.attachments[count]#" disposition="attachment"><!---  type="#mimetype#"> --->
</cfloop>
</cfmail> --->
			<cfloop index="count" from="1" to="#arraylen(arguments.ss.arrCID)#">
				<cfscript>
				if(arguments.ss.arrCID[count] contains "/cid_tmp/"){
					application.zcore.functions.zdeletefile(arguments.ss.arrCID[count]);
				}
				</cfscript>
			</cfloop>
		</cfif>
		<cfreturn>
	</cfif>
	<cfscript>
	// remove bad code before sending
	arguments.ss.html=trim(arguments.ss.html);//trim(this.cleanHTML(arguments.ss.html));
	arguments.ss.to=trim(arguments.ss.to);
	arguments.ss.failto=trim(arguments.ss.failto);
	arguments.ss.text=trim(arguments.ss.text);
	arguments.ss.subject=trim(arguments.ss.subject);
	arguments.ss.popserver=trim(arguments.ss.popserver);
	arguments.ss.username=trim(arguments.ss.username);
	arguments.ss.password=trim(arguments.ss.password);
	// validate for the following		
	/*if(arguments.ss.overrideMailServer and (arguments.ss.popserver EQ '' or arguments.ss.username EQ '' or arguments.ss.password EQ '')){
		rCom.setError("If arguments.ss.overrideMailServer is true, then arguments.ss.popserver, arguments.ss.username and arguments.ss.password are required.",2);
		return rCom;
	   // application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: send() - If arguments.ss.overrideMailServer is true, then arguments.ss.popserver, arguments.ss.username and arguments.ss.password are required.");
	}*/
	if(arguments.ss.draft EQ false){
		if(arguments.ss.subject EQ ''){
			rCom.setError("E-Mail Subject is required.",3);
		}
		if(trim(arguments.ss.from) EQ ''){
			rCom.setError("From E-Mail Address is required.",4);
		}
		if(trim(arguments.ss.to) EQ ''){
			rCom.setError("To E-Mail Address is required.",5);
		}
	}
	if(arguments.ss.spoolenable EQ 'no' or arguments.ss.spoolenable EQ false){
		arguments.ss.spoolenable="no";
	}else{
		arguments.ss.spoolenable="yes";
	}
	if(arguments.ss.autotext and arguments.ss.text EQ '' and arguments.ss.html NEQ ''){
		arguments.ss.text=this.convertHTMLToText(arguments.ss.html);
	}
	if(arguments.ss.html NEQ ''){
		if(findnocase('<html',arguments.ss.html) EQ 0){
			rCom.setError("arguments.ss.html must be a well-formed html document or there will be serious bouncing problems when forwarding badly formatted emails such as this.",6);
			//application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: send() - ");
		}
		if(arguments.ss.text NEQ ''){
			emailType="text+html";
		}else{
			emailType="html";
		}
	}else if(arguments.ss.text NEQ ''){
		emailType="text";
		cfmailType="text";
	}else{
		rCom.setError("The email message body can not be empty.",7);
		return rCom;
	}
	rs.addressList.from=application.zcore.functions.zEmailValidateList(arguments.ss.from);
	if(rs.addressList.from.success EQ false){
		rCom.setError("""from:"" is not a list of valid email addresses. Please check spelling, separate email addresses with commas or semicolons and try again.",8);
	} 
	arguments.ss.from=arraytolist(rs.addressList.from.processed);
	if(arguments.ss.failto EQ ''){
		arguments.ss.failto=arguments.ss.from; // don't need to validate the from twice
	}else{
		rs.addressList.failto=application.zcore.functions.zEmailValidateList(arguments.ss.failto);
		if(rs.addressList.failto.success EQ false){
			rCom.setError("arguments.ss.failto, #arguments.ss.failto#, must be a valid email address.",9);
		}
		arguments.ss.failto=arraytolist(rs.addressList.failto.processed);
	}
	// failto can't have name label, need to strip it
	if(arguments.ss.failto CONTAINS "<"){
		arrFailTo=listToArray(arguments.ss.failto, '<');
		arguments.ss.failto=left(arrFailTo[2], len(arrFailTo[2])-1);
	}

	rs.addressList.to=application.zcore.functions.zEmailValidateList(arguments.ss.to);
	if(rs.addressList.to.success EQ false){
		rCom.setError('"to:" is not a list of valid email addresses. Please check spelling, separate email addresses with commas or semicolons and try again.',10);
	}
	arguments.ss.to=arraytolist(rs.addressList.to.processed);
	if(arguments.ss.cc NEQ ''){
		rs.addressList.cc=application.zcore.functions.zEmailValidateList(arguments.ss.cc);
		if(rs.addressList.cc.success EQ false){
			rCom.setError('"cc:" is not a list of valid email addresses. Please check spelling, separate email addresses with commas or semicolons and try again.',11);
		}
		arguments.ss.cc=arraytolist(rs.addressList.cc.processed);
	}
	if(arguments.ss.bcc NEQ ''){
		rs.addressList.bcc=application.zcore.functions.zEmailValidateList(arguments.ss.bcc);
		if(rs.addressList.bcc.success EQ false){
			rCom.setError('"bcc:" is not a list of valid email addresses. Please check spelling, separate email addresses with commas or semicolons and try again.',12);
		}
		arguments.ss.bcc=arraytolist(rs.addressList.bcc.processed);
	}


	if(arguments.ss.preview EQ false){
		structdelete(rs, 'addressList');
	}
	if(arguments.ss.html NEQ ''){
		arguments.ss.html=this.forceAbsoluteURLs(arguments.ss.html);
		
		newhtml=arguments.ss.html;
		if(arguments.ss.embedImages){
			rs2=this.embedImages(newhtml,arguments.ss.preview);
			newhtml=rs2.newhtml;
			arguments.ss.html=rs2.html;
			for(i=1;i LTE arraylen(rs2.arrCID);i++){
				arrayappend(arguments.ss.arrCID,rs2.arrCID[i]);
			}
		}			
		newhtml=rereplacenocase(newhtml,'<(area|a)\s(.*)?\starget\s*=\s*(.*)?>','<\1 \2 target="_blank" z=\3>','ALL');
	}
	if(isDefined('request.zdebugemail')){
		rs.sendEmailData=arguments.ss;
		rs.sendemaildata.newhtml=newhtml;
	}
	if(arguments.ss.preview){
		// add all cfmail fields to a debugging/preview object
		rs.preview=StructNew();
		rs.preview.insert=StructNew();
		rs.preview.emailType=emailType;
		ns=StructNew();
		ns.popserver=arguments.ss.popserver;
		ns.username=arguments.ss.username;
		ns.password=arguments.ss.password;
		ns.to=arguments.ss.to;
		ns.cc=arguments.ss.cc;
		ns.from=arguments.ss.from;
		ns.subject=arguments.ss.subject;
		ns.type=cfmailType;
		ns.priority=arguments.ss.priority;
		ns.mailerid="Web Mailer";
		ns.charset="utf-8";
		ns.failto=arguments.ss.failto;
		ns.spoolenable=arguments.ss.spoolenable;
		ns.html=newhtml;
		ns.text=wrap(arguments.ss.text,72);
		ns.arrCID=arguments.ss.arrCID;
		ns.attachments=arguments.ss.attachments;
		rs.preview.cfmail=ns;
		rs.preview.text=arguments.ss.text;
		rs.preview.html=arguments.ss.html;
	}else if(rCom.isOK() and arguments.ss.draft EQ false){
		// server="#arguments.ss.popserver#" username="#arguments.ss.username#" password="#arguments.ss.password#"

		if(arraylen(arguments.ss.arrCID)){
			mail  TO="#arguments.ss.to#" CC="#arguments.ss.cc#" BCC="#arguments.ss.bcc#" FROM="#arguments.ss.from#" replyto="#arguments.ss.replyto#" SUBJECT= "#arguments.ss.subject#" type="html" priority="#arguments.ss.priority#" mailerid="Web Mailer" charset="utf-8" failto="#arguments.ss.failto#" spoolenable="#arguments.ss.spoolenable#"{
				for(count=1;count LTE arraylen(arguments.ss.arrCID);count++){
					mimetype=filegetmimetype(arguments.ss.arrCID[count]);
					mailparam file="#arguments.ss.arrCID[count]#" disposition="inline" contentID="zcorecid#count#" type="#mimetype#";
				}
				mailpart type="text/html"{
					echo(newhtml);
				}
				for(count=1;count LTE arraylen(arguments.ss.attachments);count++){
					mimetype=filegetmimetype(arguments.ss.attachments[count]);
					mailparam file="#arguments.ss.attachments[count]#" disposition="attachment";
				}
			}
		}else{
			mail TO="#arguments.ss.to#" CC="#arguments.ss.cc#" BCC="#arguments.ss.bcc#" FROM="#arguments.ss.from#" replyto="#arguments.ss.replyto#" SUBJECT= "#arguments.ss.subject#" type="#cfmailType#" priority="#arguments.ss.priority#" mailerid="Web Mailer" charset="utf-8" failto="#arguments.ss.failto#" spoolenable="#arguments.ss.spoolenable#"{
				if(emailType EQ 'text+html'){
					mailpart wraptext="74" charset="utf-8" type="text/plain"{
						echo(arguments.ss.text);
					}
				}
				if(emailType EQ 'text+html' or emailType EQ 'html'){
					mailpart  charset="utf-8" type="text/html"{
						echo(newhtml);
					}
				}
				if(emailType EQ 'html'){
					echo(newhtml);
				}else if(emailType EQ 'text'){
					mailpart charset="utf-8" type="text/plain"{
						echo(arguments.ss.text);
					}
				}
				for(count=1;count LTE arraylen(arguments.ss.attachments);count++){
					mimetype=filegetmimetype(arguments.ss.attachments[count]);
					mailparam file="#arguments.ss.attachments[count]#" disposition="attachment";
				}
			}
		}
	}
	if(arguments.ss.save and rCom.isOK()){
		ts = structnew();	
		ts.zemail_datetime = request.zos.mysqlnow;
		// set the account
		ts.zemail_account_id=this.zemail_account_id;
		ts.zemail_uid = "zcore_"&createuuid(); // can't be recreated
		ts.zemail_subject = arguments.ss.subject;
		
		if(arguments.ss.replyto NEQ ""){
			ts.zemail_replyto = arguments.ss.replyto; // not used yet
		}
		ts.zemail_from = arguments.ss.from;
		ts.zemail_to = arguments.ss.to;
		ts.zemail_cc = arguments.ss.cc;
		ts.zemail_bcc = arguments.ss.bcc;
		
		// set parent email for conversation grouping
		ts.zemail_parent_id=arguments.ss.zemail_parent_id;
		
		ts.zemail_attachment_count=arraylen(arguments.ss.attachments)+arraylen(arguments.ss.arrCID);
		
		// need to have zemail_folder_id instead of hardcoded folder fields.
		if(arguments.ss.draft){
			ts.zemail_folder_id = this.getFolder("draft");
		}else{
			ts.zemail_folder_id = this.getFolder("sent");
		}
		
		ts.site_id=arguments.ss.site_id;
		ts.user_id=arguments.ss.user_id;
		ts.user_id_siteIdType=arguments.ss.user_id_siteIdType;
		
		inputStruct = StructNew();
		inputStruct.table = 'zemail';
		inputStruct.datasource = request.zos.zcoreDatasource;
		inputStruct.struct = ts;
		if(arguments.ss.preview){
			rs.preview.insert.zemail=inputStruct;
			zemail_id=0;// force this to be impossible value for previewing purposes
		}else{
			zemail_id = application.zcore.functions.zInsert(inputStruct);
			if(zemail_id EQ false){
				rCom.setError('Failed to save email in sent folder.',13);
				rCom.setData(rs);
				return rCom;
			}
		}
		// upload attachments to final directory with secure hash path
		np=application.zcore.functions.zGetHashPath(request.zos.emailData.absPath,zemail_id);
		newFileName=lcase(hash(ts.zemail_uid))&'-'&zemail_id&'-';
		ts=StructNew();	
		ts.site_id=arguments.ss.site_id;
		ts.user_id=arguments.ss.user_id;
		ts.user_id_siteIdType=arguments.ss.user_id_siteIdType;
		ts.zemail_rename_number=0;
		if(arraylen(arguments.ss.attachments) NEQ 0){
			for(i=1;i LTE arraylen(arguments.ss.attachments);i++){
				fileName=getFileFromPath(arguments.ss.attachments[i]);
				p=newFileName&i;
				ext=application.zcore.functions.zGetFileExt(fileName);
				p2=p&'-0';
				if(ext NEQ ''){
					p2=p2&"."&ext;
				}
				if(arguments.ss.preview EQ false){
					// make sure file is unique when renamed by looping
					renaming=true;
					while(renaming){
						res=application.zcore.functions.zRenameFile(arguments.ss.attachments[i],np&p2);
						if(res EQ true or ts.zemail_rename_number GT 1000){
							renaming=false;
							break;
						}else{
							ts.zemail_rename_number++;
							p2=p&'-'&ts.zemail_rename_number;
							if(ext NEQ ''){
								p2=p2&"."&ext;
							}
						}
					}
				}
				// remove the path information from the attachment
				arguments.ss.attachments[i]=fileName;
			}
			ts.zemail_data_attachments = arraytolist(arguments.ss.attachments,chr(9));
			// fail when database will truncate data
			if(len(ts.zemail_data_attachments) GT 1000){
				rCom.setError("There are way too many attachments for this email.  Use shorter file names or fewer attachments.",14);
				rCom.setData(rs);
				return rCom;
			}
		}
	
		// clean the text for search indexing
		ts.zemail_data_search=arguments.ss.from&' '&arguments.ss.to&' '&arguments.ss.cc&' '&arguments.ss.bcc&' '&arguments.ss.subject&' ';
		if(trim(arguments.ss.text) EQ ''){
			ts.zemail_data_search&=arguments.ss.html;
		}else{
			ts.zemail_data_search&=arguments.ss.text;
		}
		ts.zemail_data_search=application.zcore.functions.zCleanSearchText(ts.zemail_data_search);
		
		if(arguments.ss.preview EQ false){
			// store html and text - not original
			application.zcore.functions.zWriteFile(np&newFileName&ts.zemail_rename_number&'-html.ini',trim(arguments.ss.html));
			application.zcore.functions.zWriteFile(np&newFileName&ts.zemail_rename_number&'-text.ini',trim(arguments.ss.text));
		}
		// store zemail_data row
		ts.zemail_id=zemail_id;
		inputStruct = StructNew();
		inputStruct.table = 'zemail_data';
		inputStruct.datasource = request.zos.zcoreDatasource;
		inputStruct.struct = ts;
		if(arguments.ss.preview){
			rs.preview.insert.zemail_data=inputStruct;
		}else{
			zemail_data_id = application.zcore.functions.zInsert(inputStruct);
			if(zemail_data_id EQ false){
				rCom.setError("Failed to save email attachments.",15);
				rCom.setData(rs);
				return rCom;
			}else{
				db.sql="UPDATE #db.table("zemail", request.zos.zcoreDatasource)# zemail 
				SET zemail_processed=#db.param('1')#, 
				zemail_rename_number = #db.param(ts.zemail_rename_number)#,
				zemail_updated_datetime=#db.param(request.zos.mysqlnow)# 
				WHERE zemail_id = #db.param(zemail_id)# and 
				zemail_deleted = #db.param(0)# and 
				user_id = #db.param(arguments.ss.user_id)# and 
				site_id = #db.param(arguments.ss.site_id)# ";
				db.execute("q"); 
			}
		}
	
	}
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>

<!--- global templates and types are always site_id = 0 --->

<!--- qType=emailCom.getEmailTemplateTypeByName(zemail_template_type_name); --->
<cffunction name="getEmailTemplateTypeByName" localmode="modern" returntype="any" output="no">
	<cfargument name="zemail_template_type_name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#" hint="global templates and types are always site_id = 0">
	<!--- get the default one first --->
	<cfscript>
	
	var qD=0;
	var db=request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail_template_type", request.zos.zcoreDatasource)# zemail_template_type WHERE 
	zemail_template_type.site_id =#db.param(arguments.site_id)# and 
	zemail_template_type_deleted = #db.param(0)# and 
	zemail_template_type.zemail_template_type_name = #db.param(arguments.zemail_template_type_name)# 
	</cfsavecontent><cfscript>qD=db.execute("qD");
	if(qD.recordcount EQ 0){
		application.zcore.template.fail("zemail_template_type_name, #zemail_template_type_name#, doesn't exist for this site.");
	}
	</cfscript>
	<cfreturn qD>
</cffunction>


<!--- qEmailTemplate=emailCom.getEmailTemplateByTypeName(zemail_template_type_name); --->
<cffunction name="getEmailTemplateByTypeName" localmode="modern" returntype="any" output="no">
	<cfargument name="zemail_template_type_name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#" hint="global templates are always site_id = 0">
	<!--- get the default one first --->
	<cfscript>
	
	var db=request.zos.queryObject;
	var qD=0;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail_template", request.zos.zcoreDatasource)# zemail_template, 
	#db.table("zemail_template_type", request.zos.zcoreDatasource)# zemail_template_type WHERE 
	zemail_template_deleted = #db.param(0)# and 
	zemail_template_type_deleted = #db.param(0)# and 
	zemail_template_type.site_id = zemail_template.site_id and 
	zemail_template.zemail_template_type_id = zemail_template_type.zemail_template_type_id and 
	zemail_template.site_id IN (#db.param(arguments.site_id)#,#db.param(0)#) and 
	zemail_template_type.zemail_template_type_name = #db.param(arguments.zemail_template_type_name)# 
	ORDER BY zemail_template.site_id DESC, zemail_template_default DESC LIMIT #db.param(0)#,#db.param(1)#
	</cfsavecontent><cfscript>qD=db.execute("qD");
	if(qD.recordcount EQ 0){
		application.zcore.template.fail("zemail_template_type_name, #zemail_template_type_name#, doesn't exist for this site.");
	}
	</cfscript>
	<cfreturn qD>
</cffunction>

<!--- qEmailTemplate=emailCom.getEmailTemplateByTypeId(zemail_template_type_id); --->
<cffunction name="getEmailTemplateByTypeId" localmode="modern" returntype="any" output="no">
	<cfargument name="zemail_template_type_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	
	var db=request.zos.queryObject;
	var qD=0;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail_template", request.zos.zcoreDatasource)# zemail_template, 
	#db.table("zemail_template_type", request.zos.zcoreDatasource)# zemail_template_type WHERE 
	zemail_template_type_deleted = #db.param(0)# and 
	zemail_template_deleted = #db.param(0)# and 
	zemail_template_type.site_id = zemail_template.site_id and 
	zemail_template.zemail_template_type_id = zemail_template_type.zemail_template_type_id and 
	zemail_template.site_id IN (#db.param(arguments.site_id)#,#db.param('0')#) and 
	zemail_template_type.zemail_template_type_id = #db.param(arguments.zemail_template_type_id)# 
	ORDER BY zemail_template.site_id DESC, zemail_template_default DESC 
	LIMIT #db.param(0)#,#db.param(1)#
	</cfsavecontent><cfscript>qD=db.execute("qD");
	if(qD.recordcount EQ 0){
		application.zcore.template.fail("zemail_template_type_id, #zemail_template_type_id#, doesn't exist for this site.");
	}
	</cfscript>
	<cfreturn qD>
</cffunction>

<!--- qEmailTemplate=emailCom.getEmailTemplateById(zemail_template_id); --->
<cffunction name="getEmailTemplateById" localmode="modern" returntype="any" output="no">
	<cfargument name="zemail_template_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	
	var qD=0;
	var db=request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail_template", request.zos.zcoreDatasource)# zemail_template, 
	#db.table("zemail_template_type", request.zos.zcoreDatasource)# zemail_template_type WHERE 
	zemail_template_deleted = #db.param(0)# and 
	zemail_template_type.site_id = zemail_template.site_id and 
	zemail_template.zemail_template_type_id = zemail_template_type.zemail_template_type_id and 
	zemail_template.site_id IN (#db.param(arguments.site_id)#,#db.param('0')#) and 
	zemail_template_id = #db.param(arguments.zemail_template_id)# 
	</cfsavecontent><cfscript>qD=db.execute("qD");
	if(qD.recordcount EQ 0){
		application.zcore.template.fail("zemail_template_type_id, #zemail_template_type_id#, doesn't exist for this site.");
	}
	</cfscript>
	<cfreturn qD>
</cffunction>



<!--- 
ts=structnew();
// required for update
ts.zemail_template_id=false;
// html, text or script is required
ts.zemail_template_html=''; // html version of email
ts.zemail_template_text=''; // plain text version of email
ts.zemail_template_script=''; // relative path to coldfusion script
ts.zemail_template_subject=''; // required
ts.zemail_template_created_datetime=request.zos.mysqlnow;
ts.zemail_template_type_id=0; // required
// optional
ts.zemail_template_active=1;
ts.zemail_template_default=0; 
ts.zemail_campaign_id=0;
ts.site_id=0;
ts.validate=false;
ts.update=false;
rCom=emailCom.saveEmailTemplate(ts);
 --->
<cffunction name="saveEmailTemplate" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var fromemail=0;
	var arid=0;
	var sid=0;
	var qE=0;
	var zemail='';
	var htmlContent='';
	var textContent='';
	var zemail_template_created_datetime='';
	var t2='';
	var result='';
	var ts=StructNew();
	var ts2=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var rs=structnew();
	ts.zemail_template_id=0;
	// html, text or script is required
	ts.zemail_template_html=''; // html version of email
	ts.zemail_template_text=''; // plain text version of email
	ts.zemail_template_script=''; // relative path to coldfusion script
	ts.zemail_template_subject=''; // required
	ts.zemail_template_created_datetime=request.zos.mysqlnow;
	ts.zemail_template_type_id=0; // required
	// optional
	ts.zemail_template_active=1;
	ts.zemail_template_default=0; 
	ts.zemail_campaign_id=0;
	ts.update=false;
	ts.site_id=request.zos.globals.id;
	ts.validate=false; // set to true to test for completed template.
	StructAppend(arguments.ss,ts,false);
	arguments.ss.zemail_template_complete=0; // can only be set to 1 if the validation is successful.
	</cfscript>
	<cfif arguments.ss.validate>
		<cfscript>
		if(trim(arguments.ss.zemail_template_script&arguments.ss.zemail_template_html&arguments.ss.zemail_template_text) eq ''){
			rCom.setError("HTML, text or a script path is required.",1);
			return rCom;
		}
		if(arguments.ss.zemail_template_html neq ''){
			application.zcore.template.prependErrorContent("XMLParse() failed. All HTML must be valid XML.");
			xmlparse(arguments.ss.zemail_template_html,true);
			application.zcore.template.replaceErrorContent("");
		}
		if(trim(arguments.ss.zemail_template_subject) eq ''){
			rCom.setError("Subject is required.",2);
			return rCom;
		}
		if(arguments.ss.update and arguments.ss.zemail_template_id eq 0){
			rCom.setError("Email template id is required when updating.",3);
		}
		if(arguments.ss.zemail_template_type_id eq 0){
			rCom.setError("Email template type is required.",4);
		}
		arguments.ss.zemail_template_complete=1;
		</cfscript>
		<cfif arguments.ss.zemail_template_script neq ''>
			<cfscript>
			// test coldfusion script is working? require both htmlContent neq '' and textContent neq ''
			zemail=StructNew();
			zemail.name='';
			zemail.username='';
			zemail.password='';
			zemail.domain='';
			zemail.fromEmail=arguments.ss.from;
			zemail.confirmURL="";
			zemail.unsubscribeURL="";
			zemail.preferencesURL="";
			zemail.viewEmailURL="";
			zemail.trackString="";
			zemail.openImageUrl="";
			htmlContent='';
			textContent='';
			
			application.zcore.template.prependErrorContent("Failed to parse email template script, #arguments.ss.zemail_template_script#");
			</cfscript>
				<cfinclude template="#arguments.ss.zemail_template_script#">
			<cfscript>
			if(htmlContent eq ''){
				rCom.fail("arguments.ss.zemail_template_script, #arguments.ss.zemail_template_script#, must generate both htmlContent and textContent variables.");
			}
			if(textContent eq ''){
				rCom.fail("arguments.ss.zemail_template_script, #arguments.ss.zemail_template_script#, must generate both htmlContent and textContent variables.");
			}
			application.zcore.template.prependErrorContent("XMLParse() failed. All HTML must be valid XML.");
			xmlparse('<xml>'&htmlContent&'</xml>',true);
			application.zcore.template.replaceErrorContent("");
			</cfscript>
		</cfif>
	</cfif>
	<cfscript>
	arguments.ss.zemail_template_created_datetime=request.zos.mysqlnow;
	// zInsert / zUpdate
	t2=structnew();
	t2.datasource="#request.zos.zcoreDatasource#";
	t2.table="zemail_template";
	t2.struct=arguments.ss;
	if(arguments.ss.update){
		result=application.zcore.functions.zUpdate(t2);
		if(result eq false){
			rCom.setError("Failed to update email template.",5);
			return rCom;
		}
	}else{
		arguments.ss.zemail_template_id=application.zcore.functions.zInsert(t2);
		if(arguments.ss.zemail_template_id eq false){
			rCom.setError("Failed to add email template.",6);
			return rCom;
		}
	}		
	rs.zemail_template_id=arguments.ss.zemail_template_id;
	rCom.setData(rs);
	return rCom;
	</cfscript>

</cffunction>


<!--- 
ts=StructNew();
// required
ts.user_id=user_id;// or ts.to="emailAddress";
// optional
ts.force=false; // set to true always pull user FROM #db.table("user", request.zos.zcoreDatasource)# user table
ts.forceHTML=false;
ts.zemail_template_type_id=; or ts.zemail_template_id=; or ts.zemail_template_type_name=;
ts.site_id=request.zos.globals.id;
ts.from="emailAddress";
ts.failto=false;
ts.preview=false;
ts.hideViewEmailUrl=false;
ts.showOptInReminder=true;
ts.forceOptInDatetime=false; // ignore opt-in status for older users
// you can override the mail server that is used.
ts.popserver=application.zcore.functions.zvar('emailPopserver',arguments.ss.site_id);
ts.username=application.zcore.functions.zvar('emailusername',arguments.ss.site_id);
ts.password=application.zcore.functions.zvar('emailpassword',arguments.ss.site_id);
//ts.zemail_campaign_id=-1; // set to a valid number to enable tracking
ts.trackUrls=false;
ts.zemail_campaign_id=false; // send in email campaign id
rCom=emailCom.sendEmailTemplate(ts);
if(rCom.isOK() EQ false){
	if(isDefined('rCom.sendReturnCom')){
		rCom.sendReturnCom.setStatusErrors(request.zsid);
	}
	rCom.setStatusErrors(request.zsid);
	application.zcore.functions.zstatushandler(request.zsid);
	application.zcore.functions.zabort();
}
//application.zcore.functions.zdump(rCom.getData());
 --->
<cffunction name="sendEmailTemplate" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var fromemail=0;
	var arid=0;
	var user_id='';
	var db=request.zos.queryObject;
	var previousDate='';
	var previousDateFormatted='';
	var showOptinMessage='';
	var zemail='';
	var htmlContent='';
	var textContent='';
	var allowLongUrls='';
	var sid=0;
	
	var qE=0;
	var ts=StructNew();
	var ts2=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var rCom2=0;
	var rs=StructNew();
	var i=0;
	var useConfirmedOptInIp=false;
	var qEmailTemplate=0;
	var newParamList="";
	user_id=0;
	ts.force=false; // set to true to skip opt-in validation.
	ts.forceHTML=false;
	ts.failToGlobalTemplate=false;
	ts.site_id=request.zos.globals.id;
	ts.arrParameters=arraynew(1);
	ts.zemail_template_id=false;
	ts.zemail_template_type_id=false;
	ts.zemail_template_type_name=false;	
	ts.showOptInReminder=true;	
	ts.failto="";
	ts.forceOptInDatetime=false;
	ts.popserver=application.zcore.functions.zvar('emailPopserver',arguments.ss.site_id);
	ts.username=application.zcore.functions.zvar('emailusername',arguments.ss.site_id);
	ts.password=application.zcore.functions.zvar('emailpassword',arguments.ss.site_id);
	//ts.zemail_campaign_id=false;
	ts.hideViewEmailUrl=false;
	ts.preview=false;
	ts.html=true;
	ts.subject="";
	ts.user_key="";
	ts.replyto="";
	ts.bcc="";
	ts.contact_id=false;
	ts.user_id=false;
	ts.user_id_siteIDType=false;
	ts.contact_key="";
	ts.to=false;
	ts.from=false;
	StructAppend(arguments.ss,ts,false);
	if(arguments.ss.user_id EQ false and arguments.ss.contact_id EQ false and arguments.ss.to EQ false){
		rCom.setError("You must specify a user id to send an email template.",1);
		return rCom;
		//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: arguments.ss.user_id or arguments.ss.to is required");
	}
	if(arraylen(arguments.ss.arrParameters) NEQ 0){
		newParamList="."&arraytolist(arguments.ss.arrParameters,".");	
	}
	if(arguments.ss.from EQ false){
		arguments.ss.from=application.zcore.functions.zvar('emailCampaignFrom',arguments.ss.site_id); // set to default
		if(trim(arguments.ss.from) EQ ''){
			rCom.setError("You must specify a From E-Mail Address to send an email template.",2);
			return rCom;
			//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: arguments.ss.fromEmail is required or site_email_campaign_from must be set in #db.table("site", request.zos.zcoreDatasource)# site.");				
		}
	}
	try{
		if(arguments.ss.zemail_template_id NEQ false){
			qEmailTemplate=this.getEmailTemplateById(arguments.ss.zemail_template_id, arguments.ss.site_id);
		}else if(arguments.ss.zemail_template_type_id NEQ false){
			qEmailTemplate=this.getEmailTemplateByTypeId(arguments.ss.zemail_template_type_id, arguments.ss.site_id);
		}else if(arguments.ss.zemail_template_type_name NEQ false){
			qEmailTemplate=this.getEmailTemplateByTypeName(arguments.ss.zemail_template_type_name, arguments.ss.site_id);
		}else{
			rCom.setError("You must specify an E-Mail Template Type to send an email template.",3);
			return rCom;
			//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: arguments.ss.zemail_template_type_id or arguments.ss.zemail_template_type_name is required.");
		}
	}catch(Any excpt){
		if(arguments.ss.failToGlobalTemplate){
			if(arguments.ss.zemail_template_id NEQ false){
				qEmailTemplate=this.getEmailTemplateById(arguments.ss.zemail_template_id, 0);
			}else if(arguments.ss.zemail_template_type_id NEQ false){
				qEmailTemplate=this.getEmailTemplateByTypeId(arguments.ss.zemail_template_type_id, 0);
			}else if(arguments.ss.zemail_template_type_name NEQ false){
				qEmailTemplate=this.getEmailTemplateByTypeName(arguments.ss.zemail_template_type_name, 0);
			}
		}
	}
	if(isQuery(qEmailTemplate) EQ false or qEmailTemplate.recordcount EQ 0){
		rCom.setError("The selected E-Mail Template doesn't exist.",4);
		return rCom;
		//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: Email template doesn't exist.");
	}
	if(qEmailTemplate.zemail_template_type_name EQ 'confirm opt-in'){
		arguments.ss.zemail_campaign_id=0;
	}
	previousDate=dateadd("d",-2,now());
	previousDateFormatted=dateformat(previousDate,'yyyy-mm-dd')&' '&timeformat(previousDate,'HH:mm:ss');
	</cfscript>
	
	<cfif arguments.ss.to NEQ false>
		<cfscript>
		showOptinMessage=false;
		zemail=StructNew();
		zemail.name='Customer';
		zemail.username=request.zos.developerEmailTo;
		//zemail.password='PASSWORD';
		zemail.fromEmail=arguments.ss.from;
		zemail.domain=application.zcore.functions.zvar('domain',arguments.ss.site_id);
		if(request.zos.istestserver EQ false){
			zemail.domain=replace(zemail.domain,'http://www.','http://','all');
		}
		zemail.shortdomain=replace(zemail.domain,'http://','','all');
		zemail.trackString="";
		zemail.openImageUrl="/z/a/images/s.gif";
			zemail.confirmURL="##DELAYzemail.confirmURL##";
		zemail.replaceDelayconfirmURL="#zemail.domain#/z/-ein0.0";
		zemail.preferencesURL="#zemail.domain#/z/-epr0.0";
		if(structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0){
			zemail.unsubscribeURL="#zemail.domain#/z/-eou0.#arguments.ss.zemail_campaign_id#";
			zemail.trackString="#zemail.domain#/z/-eck0.0.#arguments.ss.zemail_campaign_id#.";
			zemail.viewEmailURL="#zemail.domain#/z/-evm0.#arguments.ss.zemail_campaign_id#.k.#qEmailTemplate.zemail_template_type_id##newParamList#";
			zemail.openImageUrl="#zemail.domain#/z/-eck0.0.#arguments.ss.zemail_campaign_id#.1.0.0";
		}else{
			zemail.unsubscribeURL="#zemail.domain#/z/user/out/index";
		}
		</cfscript>
	<cfelseif arguments.ss.contact_id NEQ false>
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("contact", request.zos.zcoreDatasource)#  
		WHERE contact_id = #db.param(arguments.ss.contact_id)# and 
		contact_opt_out = #db.param(0)# and 
		contact_deleted = #db.param(0)# and 
		(site_id = #db.param(arguments.ss.site_id)# 
		<cfif arguments.ss.contact_key NEQ ""> or contact_key = #db.param(arguments.ss.contact_key)# </cfif>
		) 
		<cfif arguments.ss.force EQ false>
			<cfif qEmailTemplate.zemail_template_type_name EQ 'confirm opt-in'>
				and contact_sent_datetime <= #db.param(previousDateFormatted)# and 
				contact_confirm_count < #db.param(3)# 
			</cfif>
		</cfif>
		</cfsavecontent><cfscript>qE=db.execute("qE");
		arguments.ss.zemail_campaign_id=0;
		if(qE.recordcount EQ 0){
			rCom.setError("User doesn't exist or hasn't opt-in yet.",5);
			return rCom;
		}
		showOptinMessage=false;
		</cfscript>
		<cfloop query="qE">
			<cfscript>
			// setup autoresponder variables
			zemail=StructNew();
			zemail.username=qE.contact_email;
			//zemail.password=qE.contact_password;
			if(qE.contact_first_name NEQ ''){
				zemail.name=qE.contact_first_name;
			}else{
				zemail.name='Customer';
			}
			if(arguments.ss.showOptInReminder and qE.contact_confirm NEQ '1'){
				showOptinMessage=true;
			}
			zemail.fromEmail=arguments.ss.from;
			zemail.domain=application.zcore.functions.zvar('domain',arguments.ss.site_id);
			if(request.zos.istestserver EQ false){
				zemail.domain=replace(zemail.domain,'http://www.','http://','all');
			}
			//zemail.subject="Registration confirmation for #zemail.domain#";
			zemail.shortdomain=replace(zemail.domain,'http://','','all');
					zemail.confirmURL="##DELAYzemail.confirmURL##";
					zemail.replaceDelayconfirmURL="#zemail.domain#/z/-einm#qE.contact_id#.#qE.contact_key#";
					zemail.preferencesURL="";//#zemail.domain#/z/-eprm#qE.contact_id#.#qE.contact_key#";
			if(structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0){
				zemail.unsubscribeURL="#zemail.domain#/z/-eoum#qE.contact_id#.#arguments.ss.zemail_campaign_id#.#qE.contact_key#";
				zemail.trackString="#zemail.domain#/z/-eckm#qE.contact_id#.#qE.contact_key#.#arguments.ss.zemail_campaign_id#.";
				zemail.viewEmailURL="#zemail.domain#/z/-evmm#qE.contact_id#.#arguments.ss.zemail_campaign_id#.#qE.contact_key#.#qEmailTemplate.zemail_template_type_id##newParamList#";
				zemail.openImageUrl="#zemail.domain#/z/-eckm#qE.contact_id#.#qE.contact_key#.#arguments.ss.zemail_campaign_id#.1.0.0";
			}else{
				zemail.unsubscribeURL="#zemail.domain#/z/user/out/index";
			}
			</cfscript>
		</cfloop>
	<cfelse>
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_id = #db.param(arguments.ss.user_id)# and 
		user_deleted = #db.param(0)# and 
		(site_id = #db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(arguments.ss.user_id_siteIDType))# or site_id = #db.param(arguments.ss.site_id)# 
		<cfif arguments.ss.user_key NEQ ""> or user_key = #db.param(arguments.ss.user_key)# </cfif>)
		<cfif arguments.ss.force EQ false>
			<cfif qEmailTemplate.zemail_template_type_name EQ 'confirm opt-in'>
				and user_sent_datetime <= #db.param(previousDateFormatted)# and 
				user_confirm_count < #db.param(3)# and user_confirm = #db.param(0)#
			<cfelse>
				and ((user_confirm = #db.param(1)# )
				<cfif arguments.ss.forceOptInDatetime neq false>
				or user_created_datetime < #db.param(dateformat(arguments.ss.forceOptInDatetime,'yyyy-mm-dd')&' '&timeformat(arguments.ss.forceOptInDatetime,'HH:mm:ss'))#
				</cfif>
				) and (user_pref_list = #db.param(1)# and user_pref_email = #db.param('1')#)
			</cfif> and user_active =#db.param(1)#
		</cfif>
		</cfsavecontent><cfscript>qE=db.execute("qE");
		arguments.ss.zemail_campaign_id=0;
		if(qE.recordcount EQ 0){
			rCom.setError("User doesn't exist or hasn't opt-in yet.",5);
			return rCom;
		}
		showOptinMessage=false;
		</cfscript>
		<cfloop query="qE">
			<cfscript>
			// setup autoresponder variables
			zemail=StructNew();
			zemail.username=qE.user_username;
			//zemail.password=qE.user_password;
			if(qE.user_first_name NEQ ''){
				zemail.name=qE.user_first_name;
			}else{
				zemail.name='Customer';
			}
			if(qE.user_pref_html EQ '0'){
				arguments.ss.html=false;
			}
			if(arguments.ss.showOptInReminder and qE.user_confirm EQ 0){// and EmailTemplate.zemail_template_type_name EQ 'confirm opt-in'
				showOptinMessage=true;
			}
			if(qE.user_confirm EQ 1){
				useConfirmedOptInIp=true;
			}
			zemail.fromEmail=arguments.ss.from;
			zemail.domain=application.zcore.functions.zvar('domain',arguments.ss.site_id);
			if(request.zos.istestserver EQ false){
				zemail.domain=replace(zemail.domain,'http://www.','http://','all');
			}
			//zemail.subject="Registration confirmation for #zemail.domain#";
			zemail.shortdomain=replace(zemail.domain,'http://','','all');
			zemail.confirmURL="##DELAYzemail.confirmURL##";
			zemail.replaceDelayconfirmURL="#zemail.domain#/z/-ein#qE.user_id#.#qE.user_key#";
			zemail.preferencesURL="#zemail.domain#/z/-epr#qE.user_id#.#qE.user_key#";
			if(structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0){
				zemail.unsubscribeURL="#zemail.domain#/z/-eou#qE.user_id#.#arguments.ss.zemail_campaign_id#.#qE.user_key#";
				zemail.trackString="#zemail.domain#/z/-eck#qE.user_id#.#qE.user_key#.#arguments.ss.zemail_campaign_id#.";
				zemail.viewEmailURL="#zemail.domain#/z/-evm#qE.user_id#.#arguments.ss.zemail_campaign_id#.#qE.user_key#.#qEmailTemplate.zemail_template_type_id##newParamList#";
				zemail.openImageUrl="#zemail.domain#/z/-eck#qE.user_id#.#qE.user_key#.#arguments.ss.zemail_campaign_id#.1.0.0";
			}else{
				zemail.unsubscribeURL="#zemail.domain#/z/-eou#qE.user_id#.0.#qE.user_key#";
				//zemail.unsubscribeURL="#zemail.domain#/z/user/out/index";	
			}
			</cfscript>
		</cfloop>
	</cfif>
	<cfscript>
	zemail.protectedData=StructNew(); // prevent includes from overwriting system variables.
	
	if(arguments.ss.subject NEQ ""){
		zemail.subject=arguments.ss.subject;
	}else if(qEmailTemplate.zemail_template_subject NEQ ''){
		zemail.subject=qEmailTemplate.zemail_template_subject;
	}
	ts2=StructNew();
	ts2.from=arguments.ss.from;
	ts2.to=arguments.ss.to;
	if(ts2.to EQ "" or ts2.to EQ false){
		ts2.to=zemail.username;
	}
	if(arguments.ss.failto neq ""){
		ts2.failto=arguments.ss.failto;
	}
	if(arguments.ss.bcc NEQ ""){
		ts2.bcc=arguments.ss.bcc;
	}
	//ts2.autotext=true;
	ts2.preview=arguments.ss.preview;
	ts2.embedImages=true;
	ts2.overrideMailServer=true;
	/*if(useConfirmedOptInIp){
		ts2.popserver="mailserver";
		ts2.username="username";
		ts2.password="password";
	}else{*/
		ts2.popserver=arguments.ss.popserver;
		ts2.username=arguments.ss.username;
		ts2.password=arguments.ss.password;
	//}
	ts2.spoolenable=true;
	zemail.protectedData.emailStruct=ts2;
	htmlContent='';
	textContent='';
	</cfscript>
<cfsavecontent variable="zemail.protectedData.html">
#application.zcore.functions.zHTMLDoctype()#
<head>
<title>##zemail.subject##</title>
<meta charset="utf-8" />
</head><body>
<cfif structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0 and arguments.ss.hideViewEmailUrl EQ false><a href="#zemail.viewEmailUrl#" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px; line-height:14px;">Email display problems? Click here to view full version</a><br /><br /></cfif>
<table style="width:100%;font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px; line-height:14px; border:1px solid ##AA9999;">
<cfif showOptinMessage>
<tr><td style="padding:5px; background-color:##009900; color:##FFFFFF;"><strong>Opt-in Action Required Below:</strong></td></tr>
<tr>
<td style="padding:10px;background-color:##EFFFEF; font-weight:bold; font-size:13px; line-height:18px;"><span style="font-weight:normal;">You received this email because you've joined a mailing list on <a href="#zemail.domain#/">#application.zcore.functions.zvar('shortdomain',arguments.ss.site_id)#</a>.<br />
Please add <a href="mailto:#zemail.protectedData.emailStruct.from#">#zemail.protectedData.emailStruct.from#</a> to your address book to receive our emails.</span><br /><br />

May we send you future emails? <a href="#zemail.confirmURL#">Yes, Opt-in</a> or <a href="#zemail.unsubscribeURL#">No, Opt-out</a></td>
</tr>
<tr><td></td></tr>
</table><br />

</cfif>
##htmlContent##

<table style="width:100%; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px; background-color:##EFEFEF; border:1px solid ##999999;">
<!--- 
removed since this is not secure
<cfif qEmailTemplate.zemail_template_type_name EQ 'confirm opt-in' and cgi.QUERY_STRING DOES NOT CONTAIN request.zos.urlRoutingParameter&"=-evm">
<tr><td colspan="2" style="padding:5px; background-color:##FFFFFF; line-height:18px;border-bottom:1px solid ##AA9999;">
<p style="font-size:13px; line-height:21px; font-weight:bold;">Please keep a copy of your login information:<br /><br />
Login URL:<a href="#zemail.domain#/z/user/preference/index">#zemail.domain#/z/user/preference/index</a><br />
Username:#zemail.username#<br />
Password:#zemail.password#</p></td></tr>
</cfif> --->
<tr>
<td rowspan="2" style="padding:5px;vertical-align:top; border-right:1px solid ##CCCCCC; white-space:nowrap;" ><cfif isDefined('request.zOverrideEmailSignature')>#application.zcore.functions.zparagraphformat(trim(request.zOverrideEmailSignature))#<cfelse>#application.zcore.functions.zparagraphformat(trim(application.zcore.functions.zvar('emailsignature',arguments.ss.site_id)))#</cfif></td>
<td style="vertical-align:top;padding:5px; white-space:nowrap;">
We respect your privacy. <cfif structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0>Unsubscribe will stop our newsletters.</cfif><br />
This email was sent to: #zemail.protectedData.emailStruct.to#
</td></tr><tr><td style="border-top:1px solid ##CCCCCC;padding:5px;vertical-align:top;padding-top:5px;">
<a href="#request.zos.globals.domain#/z/user/privacy/index">Privacy Policy</a>
<!--- <cfif structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0> --->
<cfif zemail.preferencesURL NEQ "" and arguments.ss.user_id NEQ 0>
 | <a href="#zemail.preferencesURL#" style=" line-height:24px;">Contact Preferences</a>
</cfif> | 
<a href="#zemail.unsubscribeURL#" style="font-weight:bold;">Unsubscribe</a><!---  </cfif> ---><br /></td></tr></table>
<cfif structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0><img src="#zemail.openImageUrl#" width="5" height="5"></cfif>
</body></html>
</cfsavecontent>
<cfsavecontent variable="zemail.protectedData.text"><cfif structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0 and arguments.ss.hideViewEmailUrl EQ false>Click below to view full HTML version
#zemail.viewEmailUrl#</cfif>
<cfif showOptinMessage>
Email Permission Reminders:
You received this email because you've joined a mailing list on #application.zcore.functions.zvar('shortdomain',arguments.ss.site_id)#.
Please add #zemail.protectedData.emailStruct.from# to your address book to receive our emails.

Click the link below to continue receiving our emails:
#zemail.confirmURL#
</cfif>
##textContent##
------------------------
<cfif isDefined('request.zOverrideEmailSignature')>#trim(request.zOverrideEmailSignature)#<cfelse>#trim(application.zcore.functions.zvar('emailsignature',arguments.ss.site_id))#
</cfif>------------------------

We respect your privacy. Unsubscribe will stop our newsletters.
Unsubscribe:
#zemail.unsubscribeURL#
<cfif zemail.preferencesURL NEQ "" and arguments.ss.user_id NEQ 0>------------------------
Contact preferences:
#zemail.preferencesURL# </cfif>
------------------------
Privacy Policy:
#zemail.domain#/z/user/privacy/index
</cfsavecontent>
	<cfif qEmailTemplate.zemail_template_script NEQ ''>
			<!--- might want to add url support so it can be another language --->
			<cfinclude template="#qEmailTemplate.zemail_template_script#">
		<!--- <cftry>
			<cfcatch type="any">
			<cfscript>
			rCom.setError("The script for this email template had a critical error and must be fixed by the developer. #qEmailTemplate.zemail_template_script#",6);
			return rCom;
			//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: Email template had an error when included.  See coldfusion template: #qEmailTemplate.zemail_template_script#.");
			</cfscript>
			</cfcatch>
		</cftry> --->
		<cfscript>
		htmlContent=trim(htmlContent);
		textContent=trim(textContent);
		if(htmlContent EQ '' or textContent EQ ''){
			rCom.setError("All email templates must generate html and plain text versions of the email using variables named htmlContent and textContent.",7);
			return rCom;
			//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: All email templates must generate variables named htmlContent and textContent. Template path: #qEmailTemplate.zemail_template_script#.");
		}
		</cfscript>
	<cfelse>
		<cfscript>
		htmlContent=trim(qEmailTemplate.zemail_template_html);
		textContent=trim(qEmailTemplate.zemail_template_text);
		for(i in zemail){
			if(isSimpleValue(zemail[i])){
				htmlContent=replaceNoCase(htmlContent, "##zemail."&i&'##', zemail[i],'ALL');
				textContent=replaceNoCase(textContent, "##zemail."&i&'##', trim(zemail[i]),'ALL');
			}
		}
		</cfscript>
	</cfif>	 
	<cfscript>		
	if(StructKeyExists(zemail,'subject') EQ false or trim(zemail.subject) EQ ''){
		rCom.setError("zemail.subject is required.  You can set this variable in the zemail_template table or in the template script.",8);
		return rCom;
		//application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.app.email.cfc FUNCTION: sendEmailTemplate: zemail.subject is required.  You can set this in the zemail_template table or in the template script.");
	}
	if((arguments.ss.forceHTML or arguments.ss.html) and htmlContent NEQ ''){
		zemail.protectedData.html=replaceNoCase(zemail.protectedData.html,'##htmlContent##',htmlContent);
		zemail.protectedData.html=replaceNoCase(zemail.protectedData.html, '##DELAYzemail.confirmURL##', zemail.replaceDelayconfirmURL,'ALL');
		zemail.protectedData.emailStruct.html=replaceNoCase(zemail.protectedData.html,'##zemail.subject##',zemail.subject);
	}
	if(textContent NEQ ''){
		zemail.protectedData.emailStruct.text=replaceNoCase(zemail.protectedData.text,'##textContent##',textContent);
	}
	if(structkeyexists(arguments.ss,'zemail_campaign_id') and arguments.ss.zemail_campaign_id NEQ 0){
		// add tracking url string
		if(isDefined('zemail.protectedData.emailStruct.html')){
			zemail.protectedData.emailStruct.html=this.rewriteHTMLLinks(zemail.protectedData.emailStruct.html,zemail.trackString&"1.",arguments.ss.site_id);
		}
		if(isDefined('zemail.protectedData.emailStruct.text')){
			if(arguments.ss.preview){
				allowLongUrls=true;
			}else{
				allowLongUrls=false;
			}
			zemail.protectedData.emailStruct.text=this.rewriteTextLinks(zemail.protectedData.emailStruct.text,zemail.trackString&"0.",zemail.viewEmailURL,arguments.ss.site_id,allowLongUrls);
			zemail.protectedData.emailStruct.text=replaceNoCase(zemail.protectedData.emailStruct.text, '##DELAYzemail.unsubscribeURL##', zemail.unsubscribeURL,'ALL');
			zemail.protectedData.emailStruct.text=replaceNoCase(zemail.protectedData.emailStruct.text, '##DELAYzemail.confirmURL##', zemail.replaceDelayconfirmURL,'ALL');
		}
	}	
	if(arguments.ss.replyto NEQ ""){
		zemail.protectedData.emailStruct.replyTo=arguments.ss.replyto;
	}else{
		zemail.protectedData.emailStruct.replyTo=arguments.ss.from;
	}
	zemail.protectedData.emailStruct.subject=zemail.subject;
	
	//application.zcore.functions.zdump(zemail);
	//application.zcore.functions.zabort();
	//zemail.protectedData.emailStruct.to=request.zos.developerEmailTo; // FOR DEBUGGING
	rCom2=this.send(zemail.protectedData.emailStruct);
	if(rCom2.isOK() EQ false){
		rCom2.copyErrorsToReturnCom(rCom);
		rCom.setError("Failed to Send E-Mail.",9);
	}else{
		rs.sendReturnData=rCom2.getData();
	}
	</cfscript>
	<cfif rCom2.isOK()>
		<cfif arguments.ss.to NEQ false>
		<cfelseif arguments.ss.contact_id NEQ false>
			<!--- update sent date and maybe the confirmation count --->
			<cfif arguments.ss.preview EQ false>
				<cfsavecontent variable="db.sql">
				UPDATE #db.table("contact", request.zos.zcoreDatasource)#  
				SET contact_sent_datetime = #db.param(request.zos.mysqlnow)#, 
				contact_updated_datetime = #db.param(request.zos.mysqlnow)# 
				<cfif qEmailTemplate.zemail_template_type_name EQ 'confirm opt-in'>,  contact_confirm_count=contact_confirm_count+#db.param(1)#</cfif>
				WHERE contact_id = #db.param(arguments.ss.contact_id)# and 
				contact_deleted = #db.param(0)# and 
				site_id = #db.param(arguments.ss.site_id)# 
				</cfsavecontent><cfscript>qE=db.execute("qE");</cfscript>
			</cfif>
		<cfelse>
			<!--- update sent date and maybe the confirmation count --->
			<cfif arguments.ss.preview EQ false>
				<cfsavecontent variable="db.sql">
				UPDATE #db.table("user", request.zos.zcoreDatasource)#  
				SET user_sent_datetime = #db.param(request.zos.mysqlnow)#, 
				user_updated_datetime = #db.param(request.zos.mysqlnow)# 
				<cfif qEmailTemplate.zemail_template_type_name EQ 'confirm opt-in'>,  user_confirm_count=user_confirm_count+#db.param(1)#</cfif>
				WHERE user_id = #db.param(arguments.ss.user_id)# and 
				user_deleted = #db.param(0)# and 
				site_id = #db.param(arguments.ss.site_id)# 
				</cfsavecontent><cfscript>qE=db.execute("qE");</cfscript>
			</cfif>
		</cfif>
	</cfif>
	<cfscript>
	rs.emailData=zemail.protectedData.emailStruct;
	rCom.setData(rs);
	return rCom;
	</cfscript>
	
</cffunction>



<!--- arrLinks=emailCom.rewriteHTMLLinks(html); --->
<cffunction name="rewriteHTMLLinks" localmode="modern" output="no" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="urlString" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var newhtml=arguments.text;
	var links=0;
	var links2=newhtml;
	var n=0;
	var arrLinks=0;
	var u=0;
	var ru=0;
	var i=0;
	var dt=0;
	var ht=0;
	var up=0;
	var np=0;
	var upf=0;
	var arrImage=0;
	var d=application.zcore.functions.zvar('domain',arguments.site_id);
	links=replace(newhtml,chr(9),' ','ALL');
	links=replace(links,chr(10),'','ALL');
	//links2=links;
	//links2=rereplacenocase(links2,"[^:]*?\s*(:\s*url\s*?\(\s*)([^\)]*)(\s*\))\s*(;|}|""|')[^:]*",chr(9)&'\2'&chr(10)&'\1\2\3'&chr(9),'ALL');		
	links=rereplacenocase(links,".*?<.*?(href\s*=\s*?(""|')*)([^\2^>^\s\^'^\""]*)((\2)*)?[^>]*>[^<^>]*",'\3'&chr(9),'ALL');//&links2;
	links2=rereplacenocase(links2,"(.*?<.*?(href\s*=\s*?(""|')*))([^\3^>^\s\^'^\""]*)(((\3)*)?[^>]*>[^<^>]*)",'\1##ZLINKHERE##\5','ALL');//&links2;
	// remove everything but the links
	//links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1"&chr(9), 'ALL');
	//links=replace(links,chr(10),chr(9),'ALL');
	arrLinks=listtoarray(links,chr(9),true);
	if(arraylen(arrLinks) NEQ 0){
		arrayDeleteAt(arrLinks,arraylen(arrLinks));
		newhtml=links2;
		for(i=1;i LTE arrayLen(arrLinks);i++){
			if(i NEQ 1 and left(trim(arrLinks[i]),7) NEQ 'mailto:' and left(trim(arrLinks[i]),10) NEQ 'javascript:'){
				// replace same domain to make the redirect relative url otherwise redirect full abs url
				newhtml=replace(newhtml, '##ZLINKHERE##',arguments.urlString&i&"."&replacenocase(replacenocase(urlencodedformat(replaceNoCase(arrLinks[i],d,'','ONE')),'%2F','/','ALL'),'%3A',':','ALL'),'ONE');
				//newhtml=replace(newhtml, '##ZLINKHERE##',application.zcore.functions.zURLAppend(arrLinks[i],replace(arguments.appendUrl,arguments.replaceString,i,'ALL')),'ONE');
			}else{
				newhtml=replace(newhtml, '##ZLINKHERE##',arrLinks[i],'ONE');
			}
		}
	}
	return newhtml;
	</cfscript>
</cffunction>
	
	
<!--- arrLinks=emailCom.rewriteTextLinks(text); --->
<cffunction name="rewriteTextLinks" localmode="modern" output="yes" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="urlString" type="string" required="yes">
	<cfargument name="viewEmailUrl" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="allowLongUrls" type="string" required="no" default="#false#">
	<cfscript>
	var arrWord=0;
	var n=1;
	var ns="";
	var i=1;
	var np=0;
	var n2=0;
	var last4='';
	var body=arguments.text;
	var body2=rereplacenocase(body,'([\s''"\[\]<>])',' \1 ','all');
	var arrLinks=arraynew(1);
	var linkCount=0;
	var linkurl="";
	var appendlinkurl="";
	var d=application.zcore.functions.zvar('domain',arguments.site_id);
	//body2=replacenocase(body2,'mailto:','mailto: ','all');
	body2=rereplacenocase(body2,'([^http|https]):','\1: ','all');
	arrWord=listtoarray(body2,' ');
	n=1;
	ns="";
	for(i=1;i LTE arraylen(arrWord);i++){
		if(len(trim(arrWord[i])) LTE 4) continue;
		if(application.zcore.functions.zEmailValidate(arrWord[i])){
			// ignore
		}else{
			linkurl="";
			appendlinkurl="";
			last4=right(arrWord[i],4);
			if(left(arrWord[i],7) EQ 'http://' and find('.',arrWord[i]) NEQ 0){
				linkurl=arrWord[i];
			}else if(left(arrWord[i],8) EQ 'https://' and find('.',arrWord[i]) NEQ 0){
				linkurl=arrWord[i];
			}else if(left(arrWord[i],4) EQ 'www.' and find('.',arrWord[i],5) NEQ 0){
				linkurl=arrWord[i];
				appendlinkurl="http://";
			}else if(left(last4,1) EQ '.' and findnocase(','&right(last4,3)&',', ',com,net,org,biz,gov,edu,')){
				linkurl=arrWord[i];
				appendlinkurl="http://";
			}
			if(linkurl NEQ ''){
				linkCount++;
				np=find(arrWord[i],body,n);
				if(np EQ 0) continue;
				n2=arguments.urlString&linkCount&"."&replacenocase(replacenocase(urlencodedformat(replaceNoCase(appendlinkurl&linkurl,d,'','ONE')),'%2F','/','ALL'),'%3A',':','ALL');
				if(linkCount EQ 1 or arguments.allowLongUrls){
					ns=appendlinkurl&linkurl;
				}else if(len(n2) GT 72){
					if(len(appendlinkurl&linkurl) GT 72){
						ns='<link removed, please view email online>';
					}else{
						ns=appendlinkurl&linkurl;
					}
				}else{
					ns=n2;
				}
				//arrayAppend(arrLinks,ns);
				n=np+len(ns);
				body=removeChars(body,np,len(arrWord[i]));
				body=insert(ns,body,np-1);
			}
		}
	}
	//application.zcore.functions.zdump(arrWord);
	//application.zcore.functions.zdump(arrLinks);
	return body;
	</cfscript>
</cffunction>

<!--- 
// this was made to deal with escaping the name label correctly
i.e. echo(application.zcore.email.formatEmailWithName("bruce+testid2@skyflare.com", "Test#chr(10)# <Bad> characters "" like quote"));

formattedEmail=application.zcore.email.formatEmailWithName(email, name);
 --->
<cffunction name="formatEmailWithName" localmode="modern" access="public">
	<cfargument name="email" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfscript>
	arguments.name=replacelist(arguments.name, "#chr(13)#,#chr(10)#,#chr(9)#,"",<,>", ",,,',[,]", ",", ",", true);
	return '"'&arguments.name&'" <'&arguments.email&'>';
	</cfscript>
</cffunction>



</cfoutput>
</cfcomponent>