<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
var matching=0;
var jsOutput=0;
var ms2=0;
var loop=0;
var arrOut=0;
var sp=0;
var tempZJsOutput9=0;
var arrT=0;
var tempSearchFormLabelOnInput=0;
var tempSearchFormEnabledDropDownMenus=0;
var curStr=0;
var ts=0;
var curPos=0;
var ms=0;
var i=0;
var arrOutHTML=0
if(request.zos.originalURL NEQ request.zos.listing.functions.getSearchFormLink()){
	application.zcore.tracking.backOneHit();
}
application.zcore.functions.zModalCancel();
application.zcore.template.setTemplate("zcorerootmapping.templates.simple");
request.hideMLSResults=true;
form.outputSearchForm=true;

tempSearchFormLabelOnInput=application.zcore.functions.zso(form, 'searchFormLabelOnInput');
tempSearchFormEnabledDropDownMenus=application.zcore.functions.zso(form, 'searchFormEnabledDropDownMenus');
form.searchFormHideCriteriaList=application.zcore.functions.zso(form, 'searchFormHideCriteriaList');
arrT=listtoarray(form.searchFormHideCriteriaList,",");
</cfscript>
<cfsavecontent variable="tempZJsOutput9">
<cfscript>
ts=structnew();
ts.output=true;
ts.disablejavascript=true;
if(tempSearchFormLabelOnInput NEQ ""){
	ts.searchFormLabelOnInput=tempSearchFormLabelOnInput;
}
if(tempSearchFormEnabledDropDownMenus NEQ ""){
	ts.searchFormEnabledDropDownMenus=tempSearchFormEnabledDropDownMenus;
}
if(form.searchformhidecriteriaList NEQ 0 and arraylen(arrT) NEQ 0){
	ts.searchFormHideCriteria=structnew();
	for(i=1;i LTE arraylen(arrT);i++){
		ts.searchFormHideCriteria[arrT[i]]=true;
	}
	if(application.zcore.functions.zso(form, 'searchId') NEQ ''){
		structdelete(ts.searchFormHideCriteria,'more_options');	
	}
}
//zdump(ts);
application.zcore.listingCom.includeSearchForm(ts);
</cfscript>
</cfsavecontent>
<cfscript>
matching=true;
curPos=1;
arrOut=arraynew(1);
arrOutHTML=arraynew(1);
loop=1;
tempZJsOutput9=replace(replace(tempZJsOutput9,'/* <![CDATA[ */','','all'),'/* ]]> */','','all');
while(matching){
	ms=refindnocase('<script [^>]*>',tempZJsOutput9, curPos,true);
	ms2=refindnocase('</script>',tempZJsOutput9,ms.pos[1]+1,true);
	
	if(ms.len[1] EQ 0 and ms2.len[1] EQ 0){
		matching=false;
		break;
	}
	
	if(ms.pos[1]-curPos LT 0){
		break;
	}
	curStr=mid(tempZJsOutput9,curPos,ms.pos[1]-curPos);
	arrayappend(arrOutHTML, curStr&chr(10));
	
	sp=ms.pos[1]+ms.len[1];
	arrayappend(arrOut, mid(tempZJsOutput9,sp,(ms2.pos[1])-sp)&chr(10));
	curPos=ms2.pos[1]+ms2.len[1];
	if(loop GT 1000){
		break;	
	}
	loop++;
}

// must append the final string here
curStr=mid(tempZJsOutput9,curPos,len(tempZJsOutput9)-curPos);


arrayappend(arrOutHTML, curStr);
jsOutput='function zSetSearchFormContentDiv(){
	var d1=document.getElementById("zSearchFormJSContentDiv"); 
	if(d1){ d1.innerHTML="'&replace(jsstringformat(arraytolist(arrOutHTML," ")),"</","<\/","all")&'"; '&arraytolist(arrOut, chr(10))&" 
	}else{
		setTimeout(zSetSearchFormContentDiv,100);
	}
}
zSetSearchFormContentDiv(); ";
	
if(structkeyexists(form, 'debug')){
	writeoutput('<div id="zSearchFormJSContentDiv">test</div>');
	//writeoutput(' /* ]]> */</script>');//</body></html>');
	writeoutput('<script>'&jsOutput&'</script>');
	
}else{
	writeoutput(jsOutput);
	application.zcore.functions.zabort();
}

</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>