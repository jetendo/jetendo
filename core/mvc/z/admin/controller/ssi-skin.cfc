<cfcomponent>
	<cffunction name="index" localmode="modern" access="remote" roles="member">
		<cfscript>
		local.splitToken='~SSISPLIT~';
		writeoutput('<h2>Manual Skin Update</h2>
		<p>This script is run once per day, so it only needs to be run when you want it to update faster.</p>
		<p>Downloading: <a href="'&request.zos.currentHostName&'/z/misc/system/getSplitTemplate">'&request.zos.currentHostName&"/z/misc/system/getSplitTemplate</a></p>");
		local.r1=application.zcore.functions.zdownloadlink(request.zos.currentHostName&"/z/misc/system/getSplitTemplate");
		if(local.r1.success){
			
			local.pBeginHead=find('<!-- ssibeginhead -->', local.r1.cfhttp.FileContent);
			local.beginHeadLength=len('<!-- ssibeginhead -->');
			local.pEndHead=find('<!-- ssiendhead -->', local.r1.cfhttp.FileContent);
			local.endHeadLength=len('<!-- ssiendhead -->');
			local.pBeginBody=find('<!-- ssibeginbody -->', local.r1.cfhttp.FileContent);
			local.beginBodyLength=len('<!-- ssibeginbody -->');
			local.pEndBody=find('<!-- ssiendbody -->', local.r1.cfhttp.FileContent);
			local.endBodyLength=len('<!-- ssiendbody -->');
			if(local.pBeginHead EQ 0){
				writeoutput(htmleditformat('Failed because <!-- ssibeginhead --> was missing.'));
			}else if(local.pEndHead EQ 0){
				writeoutput(htmleditformat('Failed because <!-- ssiendhead --> was missing.'));
			}else if(local.pBeginBody EQ 0){
				writeoutput(htmleditformat('Failed because <!-- ssibeginbody --> was missing.'));
			}else if(local.pEndBody EQ 0){
				writeoutput(htmleditformat('Failed because <!-- ssiendbody --> was missing.'));
			}else{
				local.headHTML=mid(local.r1.cfhttp.FileContent, local.pBeginHead+local.beginHeadLength, local.pEndHead-(local.pBeginHead+local.beginHeadLength));
				local.bodyHTML=mid(local.r1.cfhttp.FileContent, local.pBeginBody+local.beginBodyLength, local.pEndBody-(local.pBeginBody+local.beginBodyLength));
				
				local.pSplit=find(local.splitToken, local.bodyHTML);
				if(local.pSplit EQ 0){
					writeoutput(htmleditformat('Failed because #local.splitToken# was missing.'));
				}else{
					local.endStart=local.pSplit-1+len(local.splitToken);
					local.headerHTML=left(local.bodyHTML, local.pSplit-1);
					local.footerHTML=mid(local.bodyHTML, local.endStart+1, len(local.bodyHTML)-(len(local.endStart)+1));
					/*
					writedump(local.headHTML);
					writedump(local.headerHTML);
					writedump(local.footerHTML);
					application.zcore.functions.zabort();
					*/
					application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"zupload/ssi/zssihead.html", local.headHTML);
					application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"zupload/ssi/zssiheader.html", local.headerHTML);
					application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"zupload/ssi/zssifooter.html", local.footerHTML);
					writeoutput('<h2>Successfully completed</h2>');
				}
			}
		}else{
			writeoutput('Failed to run cfhttp to download the skin.');	
		}
		</cfscript>
	</cffunction>
	<cffunction name="taskPublish" localmode="modern" access="remote">
		<cfscript>
		application.zcore.functions.checkIfCronJobAllowed();
		this.index();
		application.zcore.functions.zabort();
		</cfscript>
	</cffunction>
</cfcomponent>