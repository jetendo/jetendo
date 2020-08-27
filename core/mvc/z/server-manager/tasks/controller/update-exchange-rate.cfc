<cfcomponent>
<cfoutput> 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="100";
	var db=request.zos.queryObject;
 
	debug=false;
	application.zcore.functions.checkIfCronJobAllowed();
	if(debug){
		js=deserializeJson('{"success":true,"terms":"https:\/\/currencylayer.com\/terms","privacy":"https:\/\/currencylayer.com\/privacy","timestamp":1533641183,"source":"USD","quotes":{"USDAED":3.673249,"USDAFN":73.211497,"USDALL":108.350219,"USDAMD":481.80499,"USDANG":1.84525,"USDAOA":259.802981,"USDARS":27.304005,"USDAUD":1.344545,"USDAWG":1.7925,"USDAZN":1.705044,"USDBAM":1.686701,"USDBBD":2.00185,"USDBDT":84.511966,"USDBGN":1.6862,"USDBHD":0.377795,"USDBIF":1768.5,"USDBMD":1,"USDBND":1.510875,"USDBOB":6.91085,"USDBRL":3.736101,"USDBSD":1.0001,"USDBTC":0.000142,"USDBTN":68.683724,"USDBWP":10.306007,"USDBYN":2.01045,"USDBYR":19600,"USDBZD":2.01025,"USDCAD":1.296585,"USDCDF":1615.999933,"USDCHF":0.994415,"USDCLF":0.022603,"USDCLP":646.865004,"USDCNY":6.826904,"USDCOP":2901.2,"USDCRC":567.405023,"USDCUC":1,"USDCUP":1.0005,"USDCVE":95.099498,"USDCZK":22.08775,"USDDJF":177.720152,"USDDKK":6.42387,"USDDOP":49.860243,"USDDZD":118.220081,"USDEGP":17.896502,"USDERN":14.999912,"USDETB":27.536499,"USDEUR":0.862015,"USDFJD":2.09815,"USDFKP":0.76999,"USDGBP":0.771485,"USDGEL":2.45225,"USDGGP":0.771588,"USDGHS":4.81055,"USDGIP":0.77004,"USDGMD":48.194973,"USDGNF":9040.492783,"USDGTQ":7.495974,"USDGYD":210.045019,"USDHKD":7.84932,"USDHNL":23.952004,"USDHRK":6.393598,"USDHTG":67.155503,"USDHUF":275.87696,"USDIDR":14431.5,"USDILS":3.694941,"USDIMP":0.771588,"USDINR":68.685496,"USDIQD":1193.35,"USDIRR":42105.000186,"USDISK":106.740141,"USDJEP":0.771588,"USDJMD":134.819965,"USDJOD":0.709499,"USDJPY":111.139496,"USDKES":100.407027,"USDKGS":68.129101,"USDKHR":4080.049618,"USDKMF":426.450245,"USDKPW":900.005179,"USDKRW":1120.720222,"USDKWD":0.30298,"USDKYD":0.83345,"USDKZT":348.800441,"USDLAK":8440.601791,"USDLBP":1513.249946,"USDLKR":159.760364,"USDLRD":151.813532,"USDLSL":13.439705,"USDLTL":3.048704,"USDLVL":0.62055,"USDLYD":1.383703,"USDMAD":9.44575,"USDMDL":16.504499,"USDMGA":3295.950405,"USDMKD":53.110246,"USDMMK":1469.850193,"USDMNT":2460.162462,"USDMOP":8.086899,"USDMRO":355.500819,"USDMUR":34.3515,"USDMVR":15.410294,"USDMWK":726.440321,"USDMXN":18.46854,"USDMYR":4.072023,"USDMZN":57.830125,"USDNAD":13.439563,"USDNGN":361.55004,"USDNIO":31.899501,"USDNOK":8.194503,"USDNPR":109.885016,"USDNZD":1.48104,"USDOMR":0.384995,"USDPAB":1.00015,"USDPEN":3.26865,"USDPGK":3.314199,"USDPHP":52.820975,"USDPKR":123.229881,"USDPLN":3.66419,"USDPYG":5738.250266,"USDQAR":3.641014,"USDRON":4.004992,"USDRSD":101.701353,"USDRUB":63.479597,"USDRWF":877.175,"USDSAR":3.75025,"USDSBD":7.822195,"USDSCR":13.590325,"USDSDG":18.002012,"USDSEK":8.90488,"USDSGD":1.364096,"USDSHP":1.320902,"USDSLL":7705.000155,"USDSOS":578.496424,"USDSRD":7.45801,"USDSTD":21096.310519,"USDSVC":8.751099,"USDSYP":515.000167,"USDSZL":13.328502,"USDTHB":33.228502,"USDTJS":9.417015,"USDTMT":3.51,"USDTND":2.710402,"USDTOP":2.270977,"USDTRY":5.322915,"USDTTD":6.74095,"USDTWD":30.567031,"USDTZS":2281.206089,"USDUAH":27.017012,"USDUGX":3695.498019,"USDUSD":1,"USDUYU":30.72996,"USDUZS":7783.99998,"USDVEF":206969.999845,"USDVND":23306.3,"USDVUV":112.155523,"USDWST":2.573915,"USDXAF":565.799774,"USDXAG":0.064664,"USDXAU":0.000823,"USDXCD":2.70255,"USDXDR":0.715364,"USDXOF":565.7103,"USDXPF":102.86989,"USDYER":250.350267,"USDZAR":13.321402,"USDZMK":9001.200733,"USDZMW":9.95198,"USDZWL":322.355011}}');

	}else{
		link="http://www.apilayer.net/api/live?access_key=52138b8e3bc9f10cbd3c8bcf361d1626"; 
		rs=application.zcore.functions.zDownloadLink(link, 10);
		if(not rs.success){
			throw("Failed to download #link#");
		}
		try{
			js=deserializeJson(rs.cfhttp.filecontent);
		}catch(Any e){
			savecontent variable="out"{
				echo('Response was not valid json format<br>');
				echo(link&'<br>');
				writedump(rs);
			}
			throw(out);
		} 

	}  

	db.sql="SELECT * FROM #db.table("exchange_rate", request.zos.zcoreDatasource)# WHERE  
	exchange_rate_deleted=#db.param('0')# ";
	qRate=db.execute("qRate");

	rateStruct={};
	for(row in qRate){
		rateStruct[row.exchange_rate_destination_abbr]=row;
	}
	if(not structkeyexists(js, 'quotes')){
		savecontent variable="out"{
			echo('Response was in an unexpected json format<br>');
			echo(link&'<br>');
			writedump(rs);
		}
		throw(out);
	}

	tz=gettimezoneinfo(); 
	count=0;

	for(k in js.quotes){ 
		count++;
		rate=js.quotes[k];
		sourceCurrency=mid(k, 1, 3);
		currency=removeChars(k, 1, 3);

		// this is UTC date
		d=DateAdd("s", js.timestamp, "January 1 1970 00:00:00");

		// this is local date
		d=DateAdd("h", tz.utcHourOffset, d);

		if(structkeyexists(rateStruct, currency)){
			db.sql="UPDATE #db.table("exchange_rate", request.zos.zcoreDatasource)# SET 
			exchange_rate_amount=#db.param(rate)#,
			exchange_rate_datetime=#db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))#,
			exchange_rate_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE 
			exchange_rate_source_abbr=#db.param(sourceCurrency)# and 
			exchange_rate_destination_abbr=#db.param(currency)# and
			exchange_rate_deleted=#db.param('0')# ";
			result=db.execute("qU"); 
		}else{
			db.sql="INSERT INTO #db.table("exchange_rate", request.zos.zcoreDatasource)# SET 
			exchange_rate_amount=#db.param(rate)#,
			exchange_rate_datetime=#db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))#,
			exchange_rate_updated_datetime=#db.param(request.zos.mysqlnow)#,
			exchange_rate_source_abbr=#db.param(sourceCurrency)#,
			exchange_rate_destination_abbr=#db.param(currency)#,
			exchange_rate_deleted=#db.param('0')# ";
			exchange_rate_id=db.execute("qInsert"); 
		}
	} 
	if(count GT 1){
		// remove unused currencies
		db.sql="DELETE FROM #db.table("exchange_rate", request.zos.zcoreDatasource)# WHERE
		exchange_rate_datetime < #db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))# and 
		exchange_rate_deleted=#db.param('0')# ";
		db.execute("qUpdate");
	}

	writeoutput('Updated #count# currency exchange rates.');
	abort;
	</cfscript>
</cffunction>

<!--- 
yahoo finance api was discontinued
<cffunction name="yahoo" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="100";
	var db=request.zos.queryObject;

	
	application.zcore.functions.checkIfCronJobAllowed();

/*
	contents=application.zcore.functions.zReadFile(request.zos.globals.serverPrivateHomeDir&"yahoo-exchange-rate.json");
	rs=contents; 
*/
	link="http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"; 
	rs=application.zcore.functions.zDownloadLink(link, 10);
	if(not rs.success){
		throw("Failed to download #link#");
	}
	contents=rs.cfhttp.filecontent; 
	try{
		js=deserializeJson(contents);
	}catch(Any e){
		savecontent variable="out"{
			echo('Response was not valid json format<br>');
			echo(link&'<br>');
			writedump(rs);
		}
		throw(out);
	} 

	db.sql="SELECT * FROM #db.table("exchange_rate", request.zos.zcoreDatasource)# WHERE  
	exchange_rate_deleted=#db.param('0')# ";
	qRate=db.execute("qRate");

	rateStruct={};
	for(row in qRate){
		rateStruct[row.exchange_rate_destination_abbr]=row;
	}
	if(not structkeyexists(js, 'list')){
		savecontent variable="out"{
			echo('Response was in an unexpected json format<br>');
			echo(link&'<br>');
			writedump(rs);
		}
		throw(out);
	}

	tz=gettimezoneinfo(); 
	count=0;

	for(k in js.list.resources){ 
		count++;
		cs=k.resource;
		if(not structkeyexists(cs.fields, 'name') or cs.fields.name DOES NOT CONTAIN "/"){
			// skip gold, etc
			continue;
		}
		arrName=listToArray(cs.fields.name, "/");
		if(arrayLen(arrName) NEQ 2){
			savecontent variable="out"{
				echo('Invalid resource name format<br>');
				echo(link&'<br>');
				writedump(resource);
			}
			throw(out);
		}

		// this is UTC date
		d=DateAdd("s", cs.fields.ts, "January 1 1970 00:00:00");

		// this is local date
		d=DateAdd("h", tz.utcHourOffset, d);

		if(structkeyexists(rateStruct, arrName[2])){
			db.sql="UPDATE #db.table("exchange_rate", request.zos.zcoreDatasource)# SET 
			exchange_rate_amount=#db.param(cs.fields.price)#,
			exchange_rate_datetime=#db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))#,
			exchange_rate_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE 
			exchange_rate_source_abbr=#db.param(arrName[1])# and 
			exchange_rate_destination_abbr=#db.param(arrName[2])# and
			exchange_rate_deleted=#db.param('0')# ";
			result=db.execute("qU"); 
		}else{
			db.sql="INSERT INTO #db.table("exchange_rate", request.zos.zcoreDatasource)# SET 
			exchange_rate_amount=#db.param(cs.fields.price)#,
			exchange_rate_datetime=#db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))#,
			exchange_rate_updated_datetime=#db.param(request.zos.mysqlnow)#,
			exchange_rate_source_abbr=#db.param(arrName[1])#,
			exchange_rate_destination_abbr=#db.param(arrName[2])#,
			exchange_rate_deleted=#db.param('0')# ";
			exchange_rate_id=db.execute("qInsert"); 
		}
	} 

	writeoutput('Updated #count# currency exchange rates.');
	abort;
	</cfscript>
</cffunction>
 --->
</cfoutput>
</cfcomponent>