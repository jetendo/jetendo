<cfcomponent>
<cfoutput>
<cffunction name="getProjectFile" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="shortDomainPath" type="string" required="yes">
	<cfscript>
	row=arguments.row;

	</cfscript>
<cfsavecontent variable="out">
{
	"cfc_folders":
	[
		{
			"accessors": false,
			"path": "#request.zos.sharedTestServer.jetendo_core_path#",
			"variable_names":
			[
				"{cfc}",
				"{cfc_folder}.{cfc}"
			]
		}
	],
	"folders":
	[
		{
			"binary_file_patterns":
			[
				"*.svg",
				"*.woff",
				"*.woff2",
				"*.jpg",
				"*.png",
				"*.jpeg",
				"*.fla",
				"*.swf",
				"*.png",
				"*.gif",
				"*.ttf",
				"*.tga",
				"*.dds",
				"*.ico",
				"*.eot",
				"*.pdf",
				"*.swf",
				"*.jar",
				"*.zip",
				".woff",
				".otf",
				".woff2"
			],
			"file_exclude_patterns":
			[
				"*.svg",
				"*.woff",
				"*.woff2",
				"*.jpg",
				"*.jpeg",
				"*.gif",
				"*.fla",
				"*.swf",
				"*.wmv",
				"*.mp4",
				"*.ttf",
				"*.otf",
				"*.woff",
				"*.eot",
				"*.png"
			],
			"folder_exclude_patterns":
			[
				"*/images",
				"zcompiled"
			],
			"follow_symlinks": true,
			"path": "."
		}
	],
	"mappings":
	[
		{
			"mapping": "/zcorerootmapping",
			"path": "#request.zos.sharedTestServer.jetendo_core_path#"
		}
	],
	"settings":
	{
		"rsync_ssh":
		{
			"excludes":
			[
				".git*",
				".DS_Store",
				"_build",
				"blib",
				"Build",
				"*.sublime-project",
				"*.sublime-workspace"
			],
			"options":
			[ 
				"--no-perms",
				"--chmod=ugo=rwX",
				"--dry-run",
				"--delete"
			],
			"remotes":
			{
				"#arguments.shortDomainPath#":
				[
					{
						"enabled": 1,
						"excludes":
						[
						],
						"options":
						[
						],
						"remote_host": "#request.zos.sharedTestServer.remote_host#",
						"remote_path": "#request.zos.installPath#sites/#arguments.shortDomainPath#/",
						"remote_port": #request.zos.sharedTestServer.remote_port#,
						"ssh_key_path":"#request.zos.sharedTestServer.ssh_key_path#",
						"remote_user": "#request.zos.sharedTestServer.remote_user#",
						"remote_post_command": "",
						"remote_pre_command": ""
					}
				]
			},
			"sync_on_save": false
		}
	}
} 
</cfsavecontent>
	<cfscript>
	return out;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	db=request.zos.queryObject;
	if(not request.zos.isTestserver){
		application.zcore.functions.z404("This script only works on the test server.");
	}
	if(not structkeyexists(request.zos, 'sharedTestServer')){			
		throw('request.zos.sharedTestServer is undefined in config.cfc.  It must have a structure like this:
		{
			"arrDeployEnabledDeveloperEmail": ["developer@email.com"],
			"jetendo_core_path": "C:/ServerData/jetendo-server/jetendo/core",
			"remote_host": "jetendodev.yourdomain.com",
			"remote_path": "/path/to/jetendo/sites/",
			"remote_port": 22,
			"ssh_key_path":"C:/ServerData/jetendo-server/custom-secure-scripts/jetendodev-rsync-key"
		}');
	}
	/*
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId();
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(form.zid, 'site_id', form.sid);
		}
	}
	form.sid = application.zcore.status.getField(form.zid, 'site_id');*/

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_deleted=#db.param(0)# and 
	site_active=#db.param(1)# and 
	site_id<>#db.param(-1)# ";
	qSite=db.execute("qSite");

	arrSite=[];
	for(row in qSite){

		shortDomainPath=replace(replace(replace(row.site_short_domain,'www.',''),"."&request.zos.testDomain,""), ".", "_", "all");
		contents=getProjectFile(row, shortDomainPath);
		path=request.zos.installPath&"sites-writable/"&shortDomainPath&"/";
		arrayAppend(arrSite, shortDomainPath);
		//writedump(path);abort;
		//writedump(shortDomainPath);
		application.zcore.functions.zWriteFile(path&shortDomainPath&".sublime-project", contents);
		//break;
	} 
	result=application.zcore.functions.zSecureCommand("installSublimeProjectFiles"&chr(9)&arrayToList(arrSite, ","), 20);
	//writedump(result);
	if(result EQ 1){
		echo("Project files installed.");
	}else{
		echo("Project files install failed.");
	}
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>