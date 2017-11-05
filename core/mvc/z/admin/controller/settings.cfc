<cfcomponent>
<cfoutput> 
<cffunction name="processFavicon" access="remote" localmode="modern" roles="administrator">
	<cfscript>
	setting requesttimeout="100";
	//application.zcore.functions.z404("this is not working yet");	abort;
	form.iconFile=application.zcore.functions.zso(form, 'iconFile');

	destination=request.zos.globals.privatehomedir&"zupload/settings/";
	application.zcore.functions.zCreateDirectory(destination); 
	if(structkeyexists(form,'iconFile_delete')){
		application.zcore.functions.zDeleteFile(destination&'icon-logo-original.png');
		application.zcore.functions.zDeleteFile(destination&'favicon.ico');
		application.zcore.functions.zDeleteFile(destination&'apple-icon-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-144x144-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-114x114-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-72x72-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-57x57-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon.png');
		structdelete(application.siteStruct[request.zos.globals.id], 'iconLogoExists');
	}
	fail=false;
	if(form.iconFile NEQ ""){
		form.iconFile=application.zcore.functions.zUploadFile("iconFile", destination, false);
		if(right(form.iconFile, 4) NEQ ".png"){
			application.zcore.functions.zDeleteFile(destination&form.iconFile);
			application.zcore.status.setStatus(request.zsid, "The Icon Logo file must be a png.", form, true);
			fail=true;
		}
		if(not fail){
			if(form.iconFile NEQ "icon-logo-original.png"){
				application.zcore.functions.zDeleteFile(destination&'icon-logo-original.png');
				application.zcore.functions.zRenameFile(destination&form.iconFile, destination&'icon-logo-original.png');
			}

			source=destination&'icon-logo-original.png';

			result=application.zcore.functions.zSecureCommand("saveFaviconSet#chr(9)##source##chr(9)##destination#", "50");
			if(result EQ 0){
				application.zcore.status.setStatus(request.zsid, "Failed to save icon set", form, true);
				fail=true;
			}else{
				application.siteStruct[request.zos.globals.id].iconLogoExists=true;
			}
		}
	}
	if(not fail){
		application.zcore.status.setStatus(request.zsid, "Settings saved successfully"); 
	}
	application.zcore.functions.zRedirect("/z/admin/settings/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.functions.zStatusHandler(request.zsid, true); 
	</cfscript>	
	<h2>Settings</h2>
	<form class="zFormCheckDirty" id="uploadForm1" action="/z/admin/settings/processFavicon" enctype="multipart/form-data" method="post">
		<table class="table-list">
			<tr>
				<th>Icon Logo</th>
				<td>
					<cfscript>
					form.iconFile="icon-logo-original.png";
					if(!fileexists(request.zos.globals.privateHomeDir&"zupload/settings/"&form.iconFile)){
						form.iconFile="";
					}
					echo(application.zcore.functions.zInputImage("iconFile", request.zos.globals.privateHomeDir&"zupload/settings/", "/zupload/settings/"));
					</cfscript><br />
					Please upload a 24-bit transparent png at least 256x256. It should be pre-cropped to be a square image.  <br />
					This will be used for the touch icons and the favicon.  This feature generates many different images sizes.
				</td>
			</tr>
<!---
Consider creation of setting table.
 CREATE TABLE `setting`(  
  `setting_id` INT UNSIGNED NOT NULL,
  `site_id` INT UNSIGNED NOT NULL,
  `setting_name` VARCHAR(100) NOT NULL,
  `setting_address` VARCHAR(100) NOT NULL,
  `setting_address2` VARCHAR(100) NOT NULL,
  `setting_city` VARCHAR(100) NOT NULL,
  `setting_state` VARCHAR(2) NOT NULL,
  `setting_zip` VARCHAR(10) NOT NULL,
  `setting_country` VARCHAR(2) NOT NULL,
  `setting_map_location` VARCHAR(50) NOT NULL,
  `setting_phone` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`site_id`, `setting_id`),
  INDEX `NewIndex1` (`site_id`)
)
			<tr>
				<th>Company</th>
				<td><input type="text" name="setting_company" id="setting_company" value="#htmleditformat(form.setting_company)#"></td>
			</tr>
			<tr>
				<th>Address</th>
				<td><input type="text" name="setting_address" id="setting_address" value="#htmleditformat(form.setting_address)#"></td>
			</tr>
			<tr>
				<th>Address 2</th>
				<td><input type="text" name="setting_address2" id="setting_address2" value="#htmleditformat(form.setting_address2)#"></td>
			</tr>
			<tr>
				<th>City</th>
				<td><input type="text" name="setting_city" id="setting_city" value="#htmleditformat(form.setting_cityty)#"></td>
			</tr>
			<tr>
				<th>State</th>
				<td>#application.zcore.functions.zStateSelect("setting_state")#</td>
			</tr>
			<tr>
				<th>Postal Code</th>
				<td><input type="text" name="setting_zip" id="setting_zip" value="#htmleditformat(form.setting_zip)#"></td>
			</tr>
			<tr>
				<th>Country</th>
				<td>#application.zcore.functions.zCountrySelect("setting_country")#</td>
			</tr>
			<tr>
				<th>Map Location</th>
				<td>
					<cfscript>
					ts={
						name:"setting_map_location",
						fields:{
							address:"setting_address",
							city:"setting_city",
							state:"setting_state",
							zip:"setting_zip",
							country:"setting_country",
						}
					};
					echo(application.zcore.functions.zMapLocationPicker(ts));
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Phone</th>
				<td><input type="text" name="setting_phone" id="setting_phone" value="#htmleditformat(form.setting_phone)#"></td>
			</tr>  --->
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" name="submit1" value="Save" class="z-manager-search-button" /></td>
			</tr>
		</table>
	</form>
</cffunction>

</cfoutput>
</cfcomponent>