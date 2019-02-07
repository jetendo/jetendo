<cfcomponent> 
<cfoutput>
<!--- 
// USAGE
directorySearchCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.directory.controller.directory-search' );

// required
ts={};

// for database search:
ts.mode = 'query';
ts.defaultOrderBy = ''; // order by is not used for loop mode
ts.tableName = 'member';
// note custom tables must have these columns: X_active (Yes/No values), X_deleted (1/0 values) where X is the table name

// or for in memory search:
ts.mode = 'loop';
ts.groupName = 'Member';

// Implement a function that accepts a struct argument in order to customize the rendering of each search result:
ts.renderCFC    = this;
ts.renderMethod = 'renderDirectorySearchItem';

ts.directoryURL = '/member-directory/index'; // the url of the directory search result page

ts.perPage       = 10; // limit how many results per page


ts.offsetName='zIndex'; // a name for the form variable to check for the current offset position

ts.showSearchFormLabels = true; // true to show labels on the form, or false to hide them
ts.showPlaceholders     = false; // false will remove the form element "placeholder" attribute, true will add one
ts.searchFormClass      = 'sidebar-member-form'; // Add any css class(es) you want on the search form element
ts.searchResultsClass   = ''; // css class(es) for the results container element
ts.searchButtonText     = 'Search'; // the search form submit value
ts.resetButton          = true; // true to show a reset button on the form, or false to hide it
ts.resetButtonText      = 'Reset Filters'; // the reset button text

directorySearchCom.init(ts);


// getDistinctValues returns an array of unique values from the table
// if you need something more complex, write your own query instead
arrCategory = directorySearchCom.getDistinctValues( 'member_category' );
arrCity     = directorySearchCom.getDistinctValues( 'member_city' );

// each item in the array allows another kind of search form field
arrField = [
	{
		'fieldLabel':   'Keyword', // The label of form element
		'fieldKey':     'keyword', // The form field name.
		'fieldType':    'text', // The type of html form element. Valid values: checkboxes|hidden|select|selectMultiple|text
		'defaultValue': '', // specify a default form value.
		'searchFields': [
			// All the fields here should be part of a single FULLTEXT in mysql.
			// If multiple fields are used, the exact match search will operate on the concatenated string
			// for best performance, it is better to make a merged search field in the table at data creation time and create an index on that new field, instead of searching across multiple fields.
			// loop mode doesn't support more then one field here
			'member_title',
			'member_address',
			'member_zip',
		],
		// matchFilter can be contains or exact or list or range.  
		// List allows searching within a comma separated list of values, usually used in combination with a multiple select manager field which stores ids or values without commas in them.
		// contains performs a match against AND "like" search sorting exact matches first, and then relevance sorting the rest.
		// exact matches uses "=" in query
		'matchFilter': 'contains', 
		'disableFullText':false, // Optional, set to true to force phrase matching via LIKE
		'valueDelimiter':'|' // Optional, but required if searching a field that has multiple values in it | this allows the search form posted value to have multiple values delimited by this value. required for search to work on fields that have multiple values in them. If you use this feature, the values must be stored in database with delimiter before, inbetween and after all values, i.e. |value1|value2|  and also like this after search form is posted with code like this: form.category=application.zcore.functions.zso(form, 'category');if(isarray(form.category)){for(i=1;i<=arraylen(form.category);i++){form.category[i]="|"&form.category[i]&"|";}}
	},
	{
		'fieldLabel':  'Category',
		'fieldKey':    'category[]', // If you end the form field name with brackets, an array will be posted which allows multiple value searching to work
		'fieldType':   'selectMultiple', // selectMultiple will allow multiple values to be selected
		'fieldValues': arrCategory,
		'defaultValue': '',
		'searchFields': [
			'member_category'
		],
		'matchFilter': 'exact'
	},
	{
		'fieldLabel':  'City',
		'fieldKey':    'city',
		'fieldType':   'select',
		'fieldValues': arrCity,
		'defaultValue': '',
		'searchFields': [
			'member_city'
		],
		'matchFilter': 'exact' // exact matches use "=" in query
	}
];
directorySearchCom.setFields(arrField); // defines and validates the search parameters

directorySearchCom.outputSearchForm(); // displays the search form
directorySearchCom.outputSearchResults(); // displays the search results

This is the structure of the renderMethod function
<cffunction name="renderDirectorySearchItem" localmode="modern" access="public">
	<cfargument name="item" type="struct" required="yes">
	
</cffunction>
 --->
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	ts={
	 	mode : 'loop',

		groupName : '',
		tableName : '',

		renderCFC    : '',
		renderMethod : '',

		directoryURL : request.zos.originalURL,

		offsetName:'zIndex',

		perPage        : 10,
		defaultOrderBy : '',
		defaultLoopOrderByField:'',
		defaultLoopOrderByDirection:'',
		fields         : [],

		showSearchFormLabels : true,
		showPlaceholders     : true,
		searchFormClass      : '',
		searchResultsClass   : '',
		searchButtonText     : 'Search',
		resetButton          : false,
		resetButtonText      : 'Reset'

	}
	structappend(ss, ts, false);

	form[ss.offsetName]=application.zcore.functions.zso(form, ss.offsetName, true, 1);
	if(form[ss.offsetName] EQ 0){
		form[ss.offsetName]=1;
	}

	ss.offset=( ( form[ss.offsetName] - 1 ) * ss.perPage );
	structappend(variables, ss);


	if ( variables.mode EQ 'query' ) {
		if ( request.zos.globals.datasource EQ request.zos.zcoreDatasource OR request.zos.globals.datasource EQ '' ) {
			throw( 'Directory Search: The directory search needs to have a custom database table for performance benefits. You can configure this atServer Manager > Edit This Site > Globals > Advanced > Datasource' );
		}

		if ( variables.tableName EQ '' ) {
			throw( 'Directory Search: variables.tableName is required when variables.mode is query' );
		}
	} else if ( variables.mode EQ 'loop' ) {
		if ( variables.groupName EQ '' ) {
			throw( 'Directory Search: variables.groupName is required' );
		}
	} else {
		throw( 'Directory Search: variables.mode is invalid. Must be either "loop" or "query"' );
	}

	if ( isSimpleValue( variables.renderCFC ) OR NOT structKeyExists( variables.renderCFC, variables.renderMethod ) ) {
		throw( 'Directory Search: variables.renderCFC does not appear to be a valid component or is missing the renderMethod "' & variables.renderMethod & '"' );
	}

	if ( variables.renderMethod EQ '' ) {
		throw( 'Directory Search: variables.renderMethod is required' );
	}

	</cfscript>
</cffunction>

<cffunction name="setFields" localmode="modern" access="public">
	<cfargument name="arrField" type="array" required="yes">
	<cfscript>
	variables.arrField=arguments.arrField;

	if(arraylen(variables.arrField) EQ 0){
		throw("Directory Search: arrField must not be an empty array");
	}
	for ( field in variables.arrField ) {
		fieldKey=replace(field["fieldKey"], '[]', '');
		cookie[ fieldKey ] = cookie[ fieldKey ] ?: '';

		form[ fieldKey ] = form[ fieldKey ] ?: '';
	}

	ds={
		'fieldLabel': '',
		'fieldKey': '',
		'fieldType': '',
		'defaultValue': '',
		'searchFields': [], 
		'matchFilter': 'exact',
		'custom': false
	};
	validType={
		"checkboxes":true,
		"hidden":true,
		"select":true,
		"selectMultiple":true,
		"text":true
	}
	validMatch={
		"contains":true,
		"exact":true,
		"list":true,
		"range":true
	}
	for(i=1;i<=arraylen(variables.arrField);i++){
		field=variables.arrField[i];
		structappend(field, ds, false);

		if(field.fieldLabel EQ ""){
			throw("Directory Search: field #i# is missing fieldLabel");
		}
		e='Directory Search: field #i# with label, "#field.fieldLabel#", '
		if(field.fieldKey EQ ""){
			throw(e&' is missing fieldKey');
		}
		if(field.fieldLabel EQ ""){
			throw(e&' is missing fieldLabel');
		}
		if(field.fieldType EQ ""){
			throw(e&' is missing fieldType');
		}
		if(not structkeyexists(validType, field.fieldType)){
			throw(e&' is not a valid field type, "#field.fieldType#".  Accepted values are #structkeylist(validType, ', ')#');
		}
		if(not isarray(field.searchFields)){
			throw(e&' must be an array like: searchFields=["member_title"]; ');
		}
		if(not structkeyexists(validMatch, field.matchFilter)){
			throw(e&' is not a valid match filter, "#field.matchFilter#".  Accepted values are #structkeylist(validMatch, ', ')#');
		}
		if ( field.custom NEQ true AND field.custom NEQ false ) {
			throw(e&' is not a valid value for custom. Accepted values are true, false.');
		}
	}
	</cfscript>
</cffunction>

<cffunction name="outputSearchResults" localmode="modern" access="public">
	<cfargument name="noResultsText" type="string" required="no" default="No results matched your search.">
	<cfscript>
	noResultsText = arguments.noResultsText;

	results = getSearchResults();
	</cfscript> 
	<cfif variables.currentOffset GT 0>
		<cfscript>
			searchStruct            = StructNew();
			searchStruct.showString = 'Results ';
			searchStruct.url        = getPaginationURL();
			searchStruct.indexName  = variables.offsetName;
			searchStruct.buttons    = 5;
			searchStruct.allowUnlimitedPages=true;
			searchStruct.count      = variables.currentOffset;
			searchStruct.index      = form[variables.offsetName];
			searchStruct.perpage    = variables.perpage;

			searchNav = application.zcore.functions.zSearchResultsNav( searchStruct );
		</cfscript>

		<div class="#variables.searchResultsClass#">
			#results#

			<div class="search-navigation" style="padding-bottom: 20px; width: 100%; float: left;">
				#searchNav#
			</div>
		</div>
	<cfelse>
		<div class="#variables.searchResultsClass#">
			#noResultsText#
		</div>
	</cfif> 
</cffunction>


<cffunction name="outputSearchForm" localmode="modern" access="public"> 
	<cfscript> 
	if ( arraylen( variables.arrField ) EQ 0 ) {
		throw( 'Directory Search: variables.arrField array must have at least one field' );
	}
	</cfscript>
	<form action="#variables.directoryURL#" method="get" class="directory-search-form #variables.searchFormClass#">
		<input type="hidden" name="#variables.offsetName#" value="1">
		<cfloop from="1" to="#arrayLen( variables.arrField )#" index="fieldIndex">
			<cfscript>
			field = variables.arrField[ fieldIndex ];

			field["placeholder"] = field["placeholder"] ?: '';
 			fieldKey=replace(field["fieldKey"], '[]', '');

 			if(right(field["fieldKey"], 2) EQ '[]'){
 				multiple=true;
 			}else{
 				multiple=false;
 			}

 			selectStruct={};

			if ( isArray( form[ fieldKey ] ) ) {
				for(i in form[ fieldKey ]){
					selectStruct[i]=true;
				}
			}else{
				selectStruct[form[fieldKey]]=true;
			}

			field["valueDelimiter"]=application.zcore.functions.zso(field, 'valueDelimiter');
			if(field["valueDelimiter"] NEQ ""){
				uniqueSelectStruct={};
				for(i in selectStruct){
					arrValue=listToArray(i, field["valueDelimiter"]);
					for(value in arrValue){
						value=trim(value);
						if(value NEQ ""){
							uniqueSelectStruct[value]=true;
						}
					}
				}
				selectStruct=uniqueSelectStruct;
					//#writedump(selectStruct)#
				//	writedump(field["fieldValues"]);
			}
			</cfscript>
			<cfif field["fieldType"] EQ 'text'>
				<div class="directory-search-field">
					<cfif variables.showSearchFormLabels>
						<label for="#fieldKey#">#field["fieldLabel"]#</label><br />
					</cfif>
					<input type="text" name="#field["fieldKey"]#" id="#fieldKey#" value="#htmleditformat( form[ field["fieldKey"] ] )#"<cfif variables.showPlaceholders AND field["placeholder"] NEQ ""> placeholder="#htmleditformat( field["placeholder"] )#"</cfif> />
				</div>
			<cfelseif field["fieldType"] EQ 'select'>
				<div class="directory-search-field">
					<cfif variables.showSearchFormLabels>
						<label for="#fieldKey#">#field["fieldLabel"]#</label><br />
					</cfif>
					<select name="#field["fieldKey"]#" <cfif multiple>multiple="multiple"</cfif> id="#fieldKey#">
						<cfif variables.showPlaceholders AND field["placeholder"] NEQ "">
							<option value="">#field["placeholder"]#</option>
							<option value=""></option>
						<cfelse>
							<option value=""></option>
						</cfif>
						<cfscript> 
							for ( fieldValue in field["fieldValues"] ) {
								echo( '<option value="' & htmleditformat( trim(fieldValue.value) ) & '"' );

								if (structkeyexists(selectStruct, trim(fieldValue.value)) ) { 
									echo( ' selected="selected" data-value="#fieldValue.value#" ' );
								}

								echo( '>' & fieldValue.key & '</option>' );
							}
						</cfscript>
					</select>
					<cfscript>
					if(multiple){
						v=application.zcore.functions.zso(form, fieldKey); 
						if(isArray(v)){
							v=arrayToList(v, ',');
						}
						application.zcore.functions.zSetupMultipleSelect(fieldKey, v);
					}
					</cfscript>
				</div>
			<cfelseif field["fieldType"] EQ 'checkboxes'>
				<div class="directory-search-field">
					<cfif variables.showSearchFormLabels>
						<label for="#fieldKey#">#field["fieldLabel"]#</label><br />
					</cfif>
					<div class="directory-search-checkboxes">
						<cfscript>
							checkboxIndex = 0; 
							for ( fieldValue in field["fieldValues"] ) { 
								checked = ''; 
								if (structkeyexists(selectStruct, fieldValue["value"] ) ) {
									checked = ' checked="checked"'; 
								}

								echo( '<div class="directory-search-checkbox">' );
								echo( '<input type="checkbox" name="' & field["fieldKey"] & '" id="' & fieldKey & '_' & checkboxIndex & '" value="' & fieldValue["value"] & '"' & checked & ' />' );
								echo( '<label for="' & fieldKey & '_' & checkboxIndex & '">' & fieldValue["key"] & '</label>' );
								echo( '</div>' );
								checkboxIndex++;
							}
						</cfscript>
					</div>
				</div>
			<cfelseif field["fieldType"] EQ 'hidden'>
				<input type="hidden" name="#field["fieldKey"]#" id="#fieldKey#" value="#htmleditformat( form[ field["fieldKey"] ] )#" />
			<cfelse>
				<div class="directory-search-field">
					<cfif variables.showSearchFormLabels>
						<label for="#fieldKey#">#field["fieldLabel"]#</label><br />
					</cfif>
					<input type="text" name="#field["fieldKey"]#" id="#fieldKey#" value="#htmleditformat( form[ field["fieldKey"] ] )#"<cfif variables.showPlaceholders AND field["placeholder"] NEQ ""> placeholder="#htmleditformat( field["placeholder"] )#"</cfif> />
				</div>
			</cfif>
		</cfloop>
		<div class="directory-search-submit">
			<button type="submit" class="z-button"><span class="z-t-24">#variables.searchButtonText#</span></button>
		</div>
		<cfif variables.resetButton EQ true>
			<div class="directory-search-reset">
				<a href="#variables.directoryURL#" class="z-button"><span class="z-t-18">#variables.resetButtonText#</span></a>
			</div>
		</cfif>
	</form> 
</cffunction>


<!--- if you need something more complex, write your own query instead --->
<cffunction name="getDistinctValues" localmode="modern" access="public">
	<cfargument name="fieldKey" type="string" required="yes">
	<cfargument name="sort" type="string" required="no" default="ASC"> 
	<cfargument name="delimiter" type="string" required="no" default="" hint="If specified, the values will be split by the delimiter and unique values returned."> 
	<cfargument name="whereParams" type="string" required="no" default=""> 
	<cfscript>
	fieldKey = arguments.fieldKey;
	sort     = arguments.sort;
	returnArray = [];
	uniqueStruct={};

	if ( variables.mode EQ 'query' ) {
		db = request.zos.queryObject;
		distinctValues = []; 

		db.sql = 'SELECT DISTINCT `#fieldKey#` value
			FROM #db.table( variables.tableName, request.zos.globals.datasource )#
			WHERE `#fieldKey#` <> #db.param('')# ';
			if(arguments.whereParams NEQ ""){
				db.sql&=' and '&db.trustedSQL(arguments.whereParams);
			}
			//db.sql&=' ORDER BY `#fieldKey#` ' & sort;

		qValues = db.execute( 'distinctValues' );
		if(arguments.delimiter NEQ ""){
			for (row in qValues ) {
				arrValue=listToArray(row.value, arguments.delimiter);
				for(value in arrValue){
					if(not structkeyexists(uniqueStruct, value)){
						uniqueStruct[value]=true;
						arrayAppend( distinctValues, value ); 
					}
				}
			}
		}else{
			for (row in qValues ) {
				if(not structkeyexists(uniqueStruct, row.value)){
					uniqueStruct[row.value]=true;
					arrayAppend( distinctValues, row.value ); 
				}
			}
		}
		arraySort( distinctValues, 'textnocase', sort );
		for ( distinctValue in distinctValues ) {  
			arrayAppend( returnArray, {
				'key': application.zcore.functions.zFirstLetterCaps(distinctValue),
				'value': distinctValue
			} ); 
		}
	} else {
		items = application.zcore.siteOptionCom.optionGroupStruct( variables.groupName );
 
		uniqueValues={};
		distinctValues = []; 
		if(arguments.delimiter NEQ ""){
			for (item in items ) {
				if(structkeyexists(uniqueValues, item[fieldKey]) or item[fieldKey] EQ ""){
					continue;
				} 
				arrValue=listToArray(item[ fieldKey ], arguments.delimiter);
				for(value in arrValue){
					if(not structkeyexists(uniqueStruct, value)){
						uniqueStruct[value]=true;
						uniqueValues[value]=true;
						arrayAppend( distinctValues, value );
					}
				}
			}
		}else{
			for ( item in items ) {
				if(structkeyexists(uniqueValues, item[fieldKey]) or item[fieldKey] EQ ""){
					continue;
				} 
				uniqueValues[item[fieldKey]]=true;
				arrayAppend( distinctValues, item[ fieldKey ] );
			}
 		}
		arraySort( distinctValues, 'textnocase', sort );
		for ( distinctValue in distinctValues ) {  
			arrayAppend( returnArray, {
				'key': application.zcore.functions.zFirstLetterCaps(distinctValue),
				'value': distinctValue
			} ); 
		}
	} 
	return returnArray;
	</cfscript>
</cffunction>

<cffunction name="getPaginationURL" localmode="modern" access="private">
	<cfscript>
	paginationURL = '';

	for ( field in variables.arrField ) {
		fieldKey=replace(field["fieldKey"], '[]', '');
		if ( paginationURL EQ '' ) {
			if ( isArray( form[ fieldKey ] ) ) {
				for ( fieldValue in form[ fieldKey ] ) {
					if ( paginationURL EQ '' ) {
						paginationURL = request.zos.originalURL & '?' & field["fieldKey"] & '=' & urlencodedformat( fieldValue );
					} else {
						paginationURL &= '&' & field["fieldKey"] & '=' & urlencodedformat( fieldValue );
					}
				}
			} else {
				paginationURL = request.zos.originalURL & '?' & field["fieldKey"] & '=' & urlencodedformat( form[ fieldKey ] );
			}
		} else {
			if ( isArray( form[ fieldKey ]) ) {
				for ( fieldValue in form[ fieldKey ] ) {
					paginationURL &= '&' & field["fieldKey"] & '=' & urlencodedformat( fieldValue );
				}
			} else {
				paginationURL &= '&' & field["fieldKey"] & '=' & urlencodedformat( form[ fieldKey ] );
			}
		}
	}

	if ( paginationURL EQ '' ) {
		paginationURL = request.zos.originalURL;
	}

	return paginationURL;
	</cfscript>
</cffunction>

<cffunction name="getSearchResults" localmode="modern" access="private">
	<cfscript> 
 	variables.currentOffset=0;
 	variables.outputCount=0;

	if ( variables.mode == 'loop' ) {
		return filterItemsWithLoop();
	} else if ( variables.mode == 'query' ) {
		return filterItemsWithQuery();
	} else {
		return filterItemsWithLoop();
	}
	</cfscript>
</cffunction>

<cffunction name="filterItemsWithQuery" localmode="modern" access="private">
	<cfscript>
	variables.outputCount = 0;

	db = request.zos.queryObject;

	if(not isnumeric(form[variables.offsetName]) or form[variables.offsetName] > 100000){
		// robot or bug, kill request to avoid error
		application.zcore.functions.z404("Invalid request");
	}

	// Build the query to get the total number of items.
	db.sql = 'SELECT COUNT( ' & variables.tableName & '_id ) AS count
		FROM ' & db.table( variables.tableName, request.zos.globals.datasource ) & '
		WHERE ' & variables.tableName & '_deleted = ' & db.param( '0' ) & '
			AND ' & variables.tableName & '_active = ' & db.param( 'Yes' );

	// Loop over each of the fields and add it to the query.
	//writedump(variables.arrField);
	//writedump(form);abort;
	for ( field in variables.arrField ) {
		if ( field['custom'] EQ true ) {
			// Don't process custom fields within the filter query.
			continue;
		}
		fieldKey=replace(field['fieldKey'], '[]', '');
		arrValue=form[ fieldKey ];
		if(not isArray(form[ fieldKey ])){
			arrValue=[form[ fieldKey ]];
		} 
		if(not structkeyexists(field, 'disableFullText')){
			field.disableFullText=false;
		}
		first2=true;
		for(value in arrValue){
			if ( value NEQ '' OR ( structKeyExists( field, 'allowQueryEmpty' ) AND field['allowQueryEmpty'] EQ true ) ) {
				if(not first2){
					db.sql&=" OR ";
				}else{
					db.sql &= ' AND ( ';
				}  
				if(field['matchFilter'] EQ 'list') {
					fields=arrayToList(field['searchFields'], '`, `');
					db.sql &= ' concat(#db.param(",")#, `' & fields & '`, #db.param(",")#) LIKE #db.param("%,#application.zcore.functions.zescape(value)#,%")# ';
 
				}else if(field['matchFilter'] EQ 'contains') {
					fields=arrayToList(field['searchFields'], '`, `');
					db.sql &= ' ( ';
					if(not field.disableFullText){
						db.sql&=' MATCH( `' & fields & '` ) AGAINST ( ' & db.param( replace(value, '*', ' ', 'all') ) & ' ) OR ';
					}
					if(arrayLen(field['searchFields']) EQ 1){
						db.sql&= '`'&fields&'` LIKE ' & db.param( '%' & value & '%' );
					}else{
						db.sql&= 'concat(`'&fields&'`) LIKE ' & db.param( '%' & value & '%' );
					}
					db.sql&=' ) ';
				} else if ( field['matchFilter'] EQ 'range' ) {
					// range
					db.sql &= ' ( ';

					if ( right( value, 1 ) EQ '+' ) {
						// 10000+
						rangeMinimum = left( value, ( len( value ) - 1 ) );

						first = true;

						for ( searchField in field['searchFields'] ) {
							if ( not first ) {
								db.sql &= ' or ';
							}
							first = false;

							db.sql &= " ( `" & searchField & "` >= " & db.param( rangeMinimum ) & " ) ";
						}
					} else {
						// 7500-10000
						range = listToArray( value, '-' );
						if(arrayLen(range) EQ 2){
							rangeMinimum = range[ 1 ];
							rangeMaximum = range[ 2 ];

							first = true;

							for ( searchField in field['searchFields'] ) {
								if ( not first ) {
									db.sql &= ' or ';
								}
								first = false;

								db.sql &= " ( `" & searchField & "` >= " & db.param( rangeMinimum ) & "
									AND `" & searchField & "` <= " & db.param( rangeMaximum ) & " ) ";
							}
						}
					}

					db.sql &= ' ) ';
				} else {
					// exact 
					db.sql&=" ( ";
					first=true;
					for ( searchField in field['searchFields'] ) {
						if(not first){
							db.sql&=" or ";
						}
						first=false;
						db.sql &= "`"&searchField & '` = ' & db.param( value );
					}
					db.sql&=' ) ';
				}
				first2=false;
			}
		}
		if(not first2){
			db.sql&=" ) ";
		}
	} 
	total_items = db.execute( 'total_items' ); 

	// Set the currentOffset to the total number of items found. We need
	// to do this for pagination.
	variables.currentOffset = total_items['count'];

	// Build the query to get the actual list of items with the proper
	// ORDER BY clause and LIMIT offsets for pagination to work.
	db.sql = 'SELECT * ';

	// Loop over each of the fields and determine if an exact match or
	// a partial match. Exact matches are listed first.
	for(i=1;i<=arraylen(variables.arrField);i++){
		field=variables.arrField[i];

		if ( field['custom'] EQ true ) {
			// Don't process custom fields within the filter query.
			continue;
		}

		fieldKey=replace(field['fieldKey'], '[]', '');
		arrValue=form[ fieldKey ];
		if(not isArray(form[ fieldKey ])){
			arrValue=[form[ fieldKey ]];
		}
		first2=true;

		if(field['matchFilter'] EQ 'contains'){
			values=arrayToList(arrValue, ' ');
			fields=arrayToList(field['searchFields'], '`, `');

			if(arrayLen(field['searchFields']) EQ 1){ 
				// faster without concat
				db.sql &= ', IF ( `'&fields&'` LIKE ' & db.param( '%' & application.zcore.functions.zURLEncode( values, '%' ) & '%' ) & ', ' & db.param( '1' ) & ', ' & db.param( '0' ) & ' ) exactMatch_'&i&', 
					MATCH( `' & fields & '` ) AGAINST( ' & db.param( replace(values, '*', ' ', 'all') ) & ' ) relevance_'&i&' ';
			}else{
				db.sql &= ', IF ( concat(`'&fields&'`) LIKE ' & db.param( '%' & application.zcore.functions.zURLEncode( values, '%' ) & '%' ) & ', ' & db.param( '1' ) & ', ' & db.param( '0' ) & ' ) exactMatch_'&i&', 
					MATCH( `' & fields & '` ) AGAINST( ' & db.param( replace(values, '*', ' ', 'all') ) & ' ) relevance_'&i&' ';
			}
		}else{
			// exact needs no special sort fields.

		} 
	}

	db.sql &= ' FROM ' & db.table( variables.tableName, request.zos.globals.datasource ) & '
		WHERE ' & variables.tableName & '_deleted = ' & db.param( '0' ) & '
			AND ' & variables.tableName & '_active = ' & db.param( 'Yes' );

	// Loop over each of the fields and add it to the query.
	for ( field in variables.arrField ) {

		if ( field['custom'] EQ true ) {
			// Don't process custom fields within the filter query.
			continue;
		}

		fieldKey=replace(field['fieldKey'], '[]', '');
		arrValue=form[ fieldKey ];
		if(not isArray(form[ fieldKey ])){
			arrValue=[form[ fieldKey ]];
		}
		if(not structkeyexists(field, 'disableFullText')){
			field.disableFullText=false;
		}
		first2=true;
		for(value in arrValue){
			if ( value NEQ '' OR ( structKeyExists( field, 'allowQueryEmpty' ) AND field['allowQueryEmpty'] EQ true ) ) {
				if(not first2){
					db.sql&=" OR ";
				}else{
					db.sql &= ' AND ( ';
				}
				if(field['matchFilter'] EQ 'list') {
					fields=arrayToList(field['searchFields'], '`, `');
					db.sql &= ' concat(#db.param(",")#, `' & fields & '`, #db.param(",")#) LIKE #db.param("%,#application.zcore.functions.zescape(value)#,%")# ';
 
				}else if(field['matchFilter'] EQ 'contains') {
					fields=arrayToList(field['searchFields'], '`, `');
					db.sql &= ' ( ';
					if(not field.disableFullText){
						db.sql&=' MATCH( `' & fields & '` ) AGAINST ( ' & db.param( replace(value, '*', ' ', 'all') ) & ' ) OR ';
					}
					if(arrayLen(field['searchFields']) EQ 1){
						// faster without concat
						db.sql&= ' `'&fields&'` LIKE ' & db.param( '%' & value & '%' );
					}else{
						db.sql&= ' concat(`'&fields&'`) LIKE ' & db.param( '%' & value & '%' );
					}
					db.sql&=' ) ';
				} else if ( field['matchFilter'] EQ 'range' ) {
					// range
					db.sql &= ' ( ';

					if ( right( value, 1 ) EQ '+' ) {
						// 10000+
						rangeMinimum = left( value, ( len( value ) - 1 ) );

						first = true;

						for ( searchField in field['searchFields'] ) {
							if ( not first ) {
								db.sql &= ' or ';
							}
							first = false;

							db.sql &= " ( `" & searchField & "` >= " & db.param( rangeMinimum ) & " ) ";
						}
					} else {
						// 7500-10000
						range = listToArray( value, '-' );

						rangeMinimum = range[ 1 ];
						rangeMaximum = range[ 2 ];

						first = true;

						for ( searchField in field['searchFields'] ) {
							if ( not first ) {
								db.sql &= ' or ';
							}
							first = false;

							db.sql &= " ( `" & searchField & "` >= " & db.param( rangeMinimum ) & "
								AND `" & searchField & "` <= " & db.param( rangeMaximum ) & " ) ";
						}
					}

					db.sql &= ' ) ';
				} else {
					// exact 
					db.sql&=" ( ";
					first=true;
					for ( searchField in field['searchFields'] ) {
						if(not first){
							db.sql&=" or ";
						}
						first=false;
						db.sql &= "`"&searchField & '` = ' & db.param( value );
					}
					db.sql&=' ) ';
				}
				first2=false;
			}
		}
		if(not first2){
			db.sql&=" ) ";
		}
	}

	orderBy = '';

	orderExactMatches = '';
	orderRelevance    = ''; 

	// Loop over each of the fields and set up the ORDER BY clause.
	for(i=1;i<=arraylen(variables.arrField);i++){
		field=variables.arrField[i];

		if ( field['custom'] EQ true ) {
			// Don't process custom fields within the filter query.
			continue;
		}

		fieldKey=replace(field['fieldKey'], '[]', '');
		arrValue=form[ fieldKey ];
		if(not isArray(form[ fieldKey ])){
			arrValue=[form[ fieldKey ]];
		}
		first2=true;
		if(arrayToList(arrValue, '') NEQ ""){
			if(field['matchFilter'] EQ 'contains'){
				orderExactMatches &= ', exactMatch_'&i&' DESC';
				orderRelevance    &= ', relevance_'&i&' DESC';   
			}else{
				// exact
			} 
		} 
	}

	orderBy = '';
	if ( orderExactMatches EQ '' AND orderRelevance EQ '' ) {
		if ( variables.defaultOrderBy NEQ '' ) {
			orderBy = variables.defaultOrderBy; 
		}
	} else {
		orderBy = orderExactMatches & orderRelevance;
	}

	if ( orderBy NEQ '' ) {
		// Remove the initial comma and space.
		if ( left( orderBy, 2 ) EQ ', ' ) {
			orderBy = right( orderBy, ( len( orderBy ) - 2 ) );
		}

		db.sql &= ' ORDER BY ' & orderBy;
	}

	db.sql &= ' LIMIT ' & db.param( ( form[variables.offsetName] - 1 ) * variables.perPage ) & ', ' & db.param( variables.perPage ) & ' ';

	items = db.execute( 'items' ); 

	savecontent variable="output"{

		// Loop through each item and render it. We also need to increment
		// the outputCount for pagination purposes.
		for ( item in items ) {
			variables.outputCount++;
			variables.renderCFC[ variables.renderMethod ]( item );
		}
	}
	return output; 
	</cfscript> 
</cffunction>

<cffunction name="filterItemsWithLoop" localmode="modern" access="private">
	<cfscript> 
	items = application.zcore.siteOptionCom.optionGroupStruct( variables.groupName );
	variables.outputCount = 0;
	arrItem=[];
	// TODO this can be made faster if we build lookup tables from the form arrays first, and then use structkeyexists.

	for ( item in items ) {
		searches = {};
		matches  = {};

		for ( field in variables.arrField ) {
 
			if( structKeyExists( field, 'allowQueryEmpty' ) AND field['allowQueryEmpty'] EQ true ){
				throw("allowQueryEmpty was not tested/implemented in filterItemsWithLoop yet.");
			}

			if ( field['custom'] EQ true ) {
				// Don't process custom fields within the filter loop.
				continue;
			}

			fieldKey=replace(field["fieldKey"], '[]', '');
			searches[fieldKey ] = false;
			matches[ fieldKey ]  = false;

			if ( isArray( form[ fieldKey ] ) ) {
				if ( arrayToList( form[ fieldKey ] , '') NEQ '' ) {
					searches[ fieldKey ] = true;
				} else {
					matches[ fieldKey ] = true;
				}
			} else {
				if ( form[ fieldKey ] NEQ '' ) {
					searches[ fieldKey ] = true;
				} else {
					matches[ fieldKey ] = true;
				}
			}

			if(arrayLen(field["searchFields"]) NEQ 1){
				throw("Directory Search: Loop mode can't have more then one column in the searchFields array.");
			}

			if ( searches[ fieldKey ]) {
				if(field['matchFilter'] EQ 'list') {
					if ( isArray( form[ fieldKey ] ) ) {
						for(value in form[fieldKey]){ 
							if ( findnocase( ","&form[ fieldKey ]&",", ","&item[ field["searchFields"][1] ]&"," ) ) {
								matches[ fieldKey ] = true;
								break;
							}
						}
					}else{
						if ( findnocase( ","&form[ fieldKey ]&",", ","&item[ field["searchFields"][1] ]&"," ) ) {
							matches[ fieldKey ] = true;
						}
					} 
				}else if(field["matchFilter"] EQ 'contains'){
					if ( isArray( form[ fieldKey ] ) ) {
						for(value in form[fieldKey]){ 
							if ( findnocase( form[ fieldKey ], item[ field["searchFields"][1] ] ) ) {
								matches[ fieldKey ] = true;
								break;
							}
						}
					}else{
						if ( findnocase( form[ fieldKey ], item[ field["searchFields"][1] ] ) ) {
							matches[ fieldKey ] = true;
						}
					}
				}else{
					// exact
					if ( isArray( form[ fieldKey ] ) ) {
						listArray = listToArray( item[ field["searchFields"][1] ], ',' );

						if ( arrayLen( listArray ) EQ 0 ) {
							break;
						}

						arrayMatch = false;
						for ( fieldValue in form[ fieldKey ] ) { 
							if ( arrayContains( listArray, fieldValue ) ) {
								arrayMatch = true;
								break; 
							}
						}

						if ( arrayMatch) {
							matches[ fieldKey ] = true;
						}
					} else {
						if ( form[ fieldKey ] EQ item[ field["searchFields"][1] ] ) {
							matches[ fieldKey ] = true;
						}
					} 
				}
			}
		}

		does_item_match = false;

		for ( match in matches ) {
			if ( matches[ match ] EQ true ) {
				does_item_match = true;
			} else {
				does_item_match = false;
				break;
			}
		}

		if (not does_item_match) {
			continue;
		}

		variables.currentOffset++;

		if ( variables.currentOffset LTE variables.offset ) {
			continue;
		} else {
			if ( variables.outputCount GTE variables.perPage ) {
				continue;
			}

			variables.outputCount++;
		}

		if ( does_item_match ) {
			arrayAppend(arrItem, item);
		}
	} 
	if(variables.defaultOrderBy NEQ ""){
		arrOrder=listToArray(variables.defaultOrderBy, ',');
		arrSort=[];
		for(i in arrOrder){
			arrSort=listToArray(i, ' ', false);
			if(arrayLen(arrSort) EQ 2){ 
				arrayAppend(arrSort, {key:trim(arrSort[1]), direction: trim(arrSort[2])});
			}else if(arrayLen(arrSort) EQ 1){
				arrayAppend(arrSort, {key:trim(arrSort[1]), direction: "asc"});
			}else{
				throw("Invalid syntax for defaultOrderBy");
			}
		}
		// we can sort multiple columns at once with custom callback function
		if(arrayLen(arrSort) EQ 1){
			if(arrSort[1].direction EQ "asc"){
				arraySort( members, function() {  
					return comparenocase( arguments[ 1 ][arrSort[1].key], arguments[ 2 ][arrSort[1].key] ); 
				} );
			}else{ // desc
				arraySort( members, function() {  
					return comparenocase( arguments[ 2 ][arrSort[1].key], arguments[ 1 ][arrSort[1].key] ); 
				} );
			}
		}else if(arrayLen(arrSort) EQ 2){
			arraySort( members, function() {  
				if(arrSort[1].direction EQ "asc"){
					if(comparenocase(arguments[ 1 ][arrSort[1].key], arguments[ 2 ][arrSort[1].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 1 ][arrSort[1].key], arguments[ 2 ][arrSort[1].key]) < 0){
						return -1;
					}
				}else{
					if(comparenocase(arguments[ 2 ][arrSort[1].key], arguments[ 1 ][arrSort[1].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 2 ][arrSort[1].key], arguments[ 1 ][arrSort[1].key]) < 0){
						return -1;
					}

				}
				if(arrSort[2].direction EQ "asc"){
					if(comparenocase(arguments[ 1 ][arrSort[2].key], arguments[ 2 ][arrSort[2].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 1 ][arrSort[2].key], arguments[ 2 ][arrSort[2].key]) < 0){
						return -1;
					}
				}else{
					if(comparenocase(arguments[ 2 ][arrSort[2].key], arguments[ 1 ][arrSort[2].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 2 ][arrSort[2].key], arguments[ 1 ][arrSort[2].key]) < 0){
						return -1;
					}

				}
				return 0;
			} ); 
		}else if(arrayLen(arrSort) EQ 3){
			arraySort( members, function() {  
				if(arrSort[1].direction EQ "asc"){
					if(comparenocase(arguments[ 1 ][arrSort[1].key], arguments[ 2 ][arrSort[1].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 1 ][arrSort[1].key], arguments[ 2 ][arrSort[1].key]) < 0){
						return -1;
					}
				}else{
					if(comparenocase(arguments[ 2 ][arrSort[1].key], arguments[ 1 ][arrSort[1].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 2 ][arrSort[1].key], arguments[ 1 ][arrSort[1].key]) < 0){
						return -1;
					}

				}
				if(arrSort[2].direction EQ "asc"){
					if(comparenocase(arguments[ 1 ][arrSort[2].key], arguments[ 2 ][arrSort[2].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 1 ][arrSort[2].key], arguments[ 2 ][arrSort[2].key]) < 0){
						return -1;
					}
				}else{
					if(comparenocase(arguments[ 2 ][arrSort[2].key], arguments[ 1 ][arrSort[2].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 2 ][arrSort[2].key], arguments[ 1 ][arrSort[2].key]) < 0){
						return -1;
					}

				}
				if(arrSort[3].direction EQ "asc"){
					if(comparenocase(arguments[ 1 ][arrSort[3].key], arguments[ 2 ][arrSort[3].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 1 ][arrSort[3].key], arguments[ 2 ][arrSort[3].key]) < 0){
						return -1;
					}
				}else{
					if(comparenocase(arguments[ 2 ][arrSort[3].key], arguments[ 1 ][arrSort[3].key]) > 0){
						return 1;
					}
					if(comparenocase(arguments[ 2 ][arrSort[3].key], arguments[ 1 ][arrSort[3].key]) < 0){
						return -1;
					}

				}
				return 0;
			} ); 
		}else{
			throw("Loop doesn't support more then 3 columns in defaultOrderBy");
		} 
	} 

	savecontent variable="output"{
		for ( item in arrItem ) {
			variables.renderCFC[ variables.renderMethod ]( item );
		}
	}
	return output;
	</cfscript> 
</cffunction>

</cfoutput>
</cfcomponent>
