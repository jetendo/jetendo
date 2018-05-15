<cfcomponent displayname="ecommerce">
<cfoutput>
<cfscript>
this.app_id=15;
</cfscript>
<!--- 
CREATE TABLE `paypal_ipn_log` (
  `paypal_ipn_log_id` int(11) unsigned NOT NULL,
  `paypal_ipn_log_data` longtext NOT NULL,
  `paypal_ipn_log_datetime` datetime NOT NULL,
  `paypal_ipn_log_verified` char(1) NOT NULL DEFAULT '0',
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `paypal_ipn_log_updated_datetime` datetime NOT NULL,
  `paypal_ipn_log_deleted` char(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`paypal_ipn_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
 
vrentals2003
	service
		type
		subscription
			subscription_type_id

		payment
			subscription_id
			order_id

	


subscription_x_category

Subscription service
	

product siteOptionType options:
	Field mapping:
		Title: 
		Summary:
		Photo:
		Unique ID: 

	Add Payment Option
		Type: purchase or subscription
		Purchase options
			Amount
		Subscription options
			Amount
			Period
			Frequency
			Length
	SKIP FOR NOW: Shipping options
		Length
		Width
		Height
		Weight
		or
		Fixed Rate
		or
		Percentage
	SKIP FOR NOW: product options
		By default, all options are the same price as the product record.
		Show each option drop down in separate column with Override Price button.   Each option combination should only be allow to be created once.
			With price override, you can Add 1 or more payment options that are unique to that option combination
		
		Add product option
			All fields can be edited for this product only.
		Add product option template
			Only the value of each option in the template can be edited.
		Add product option group
			This allows you to assign an entire set of product option templates to the product in one step.

	SKIP FOR NOW: Product option template
		Option templates that allow chart based product comparisons.

		Shared options in the group can't be deleted, but additional product specific options can be added/deleted.



	CREATE TABLE `subscription_type` (
	  `subscription_type_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	  `subscription_type_name` varchar(150) NOT NULL DEFAULT '',
	  `subscription_type_description` text NOT NULL,
	  `subscription_type_price` decimal(11,2) NOT NULL DEFAULT '0.00',
	  `subscription_type_recurring` char(1) NOT NULL DEFAULT '0',
	  `subscription_type_period_days` int(11) unsigned NOT NULL DEFAULT '0',
	  `subscription_type_active` char(1) NOT NULL DEFAULT '0',
	  `subscription_service_id` int(11) unsigned NOT NULL DEFAULT '0',
	  `subscription_type_trial` char(1) NOT NULL DEFAULT '0',
	  `subscription_type_photo_limit` int(11) unsigned NOT NULL DEFAULT '4',
	  `subscription_type_sort` int(11) unsigned NOT NULL DEFAULT '0',
	  `subscription_type_joinus` char(1) NOT NULL DEFAULT '0',
	  `subscription_type_code` varchar(20) NOT NULL DEFAULT '',
	  `subscription_type_renewal` char(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`subscription_type_id`)
	) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8

CREATE TABLE `order` (
  `order_id` int(10) unsigned NOT NULL, 
  `order_paid_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `order_sent_datetime` datetime NOT NULL,
  `order_cost` decimal(11,2) unsigned NOT NULL DEFAULT '0.00',
  `order_paid` decimal(11,2) unsigned NOT NULL DEFAULT '0.00',
  `order_discount` decimal(11,2) unsigned NOT NULL DEFAULT '0.00',
  `order_key` varchar(50) NOT NULL DEFAULT '',
  `order_archived` char(1) NOT NULL DEFAULT '0',
  `order_admin_notes` text NOT NULL,
  `user_id` int(11) unsigned NOT NULL DEFAULT '0',
  `order_status` char(1) NOT NULL DEFAULT '0',
  `order_credit` decimal(11,2) unsigned NOT NULL DEFAULT '0.00',
  `order_credit_card` char(1) NOT NULL DEFAULT '0',

  `subscription_type_id` int(11) NOT NULL DEFAULT '0',
  `order_paypal_subscription_active` char(1) NOT NULL DEFAULT '0',
  `order_paypal_email` varchar(100) NOT NULL,
  `order_paypal_ipn_data` text NOT NULL,
  `order_paypal_merchant_fee` decimal(11,2) unsigned NOT NULL DEFAULT '0.00',
  `paypal_ipn_log_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',

  `order_due_date` date NOT NULL DEFAULT '0000-00-00',
  `order_recurring` char(1) NOT NULL DEFAULT '0',
  `order_paypal_enabled` char(1) NOT NULL DEFAULT '0',
  `order_income_type` char(1) NOT NULL DEFAULT '0',

  `order_recurring_billing_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_recurring_paid_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_recurring_reminder_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_recurring_late_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_recurring_charge_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_recurring_paid_notice_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_recurring_nextpayment_cycles` int(11) unsigned NOT NULL DEFAULT '0',
  `order_reminder_datetime` datetime NOT NULL,
  `order_late_datetime` datetime NOT NULL,
  `order_cancel_datetime` datetime NOT NULL,
  `order_paid_notice_datetime` datetime NOT NULL,

  `order_custom_json` longtext NOT NULL,
  `order_created_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `order_updated_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `order_deleted` char(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`, `order_id`),
  KEY `NewIndex1` (`site_id`,`user_id`,`order_due_date`),
  KEY `NewIndex2` (`site_id`,`user_id`,`order_status`),
  KEY `NewIndex3` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC

Order should have copy of all customer, shipping, price fields


don't delete.  copy when updated and deactivate old record.  ask user if they want to move existing orders to new address - if recurring orders exist.
user_address
	user_address_id
	site_id
	user_id
	user_id_siteIDType
	user_address_default char(1) 0 - only one can be 1 per user_address_type per user.
	user_address_type char(1) 0 | 0 is billing, 1 is shipping
	user_address_address
	user_address_address2
	user_address_city
	user_address_zip
	user_address_state
	user_address_country
	user_address_address_active char(1) 0
	order_id

	guest order doesn't need user_id and the order gets associated with user_address_id, but user can't retrieve access to the order.


getActiveSubscription()
	select * from order where user_id = #user_id# and 
	order_deleted = '0' and 
	order_status = '1' and 
	order_paypal_subscription_active='1' and 
	subscription_type_id = #subscription_type_id#

	site with more then one subscription_type, I'd need to filter based on subscription_type_id

order_item
	order_item_id
	order_item_title
	order_item_description
	order_item_photo
	order_item_sku
	order_item_quantity
	order_item_price
	order_item_type (site option group | specific table)
	order_item_key_data (json - like {"site_id":1,"table_id":1} )
	order_item_updated_datetime
	order_item_deleted
	order_item_custom_json  longtext - option config - could be in another table like order_item_x_option
	site_id
CREATE TABLE `product_category` (
  `product_category_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_category_name` varchar(255) NOT NULL,
  `product_category_text` text NOT NULL,
  `product_category_sort` int(11) unsigned NOT NULL DEFAULT '0',
  `product_category_url` varchar(255) NOT NULL,
  `product_category_parent_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_category_metakey` text NOT NULL,
  `product_category_metadesc` text NOT NULL,
  `product_category_image_library_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_category_updated_datetime` datetime NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_category_searchable` char(1) NOT NULL DEFAULT '0',
  `product_category_email` varchar(100) NOT NULL,
  `product_category_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`product_category_id`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8


CREATE TABLE `product_x_category` (
  `product_x_category_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_id` int(11) unsigned NOT NULL,
  `product_category_id` int(11) unsigned NOT NULL,
  `product_x_category_sort` int(11) unsigned NOT NULL,
  `product_x_category_updating` char(1) NOT NULL DEFAULT '0',
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_x_category_updated_datetime` datetime NOT NULL,
  `product_x_category_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`product_x_category_id`),
  UNIQUE KEY `NewIndex1` (`site_id`,`product_category_id`,`product_id`,`product_x_category_deleted`),
  KEY `NewIndex2` (`product_id`),
  KEY `NewIndex3` (`product_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8


CREATE TABLE `product` (
  `product_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_active` char(1) NOT NULL DEFAULT '1',
  `product_name` varchar(100) NOT NULL DEFAULT '',
  `product_description` longtext NOT NULL,
  `product_sort` int(11) unsigned NOT NULL DEFAULT '0',
  `product_metakey` text NOT NULL,
  `product_metadesc` text NOT NULL,
  `product_category_id_list` varchar(255) NOT NULL,
  `product_image_library_id` int(11) unsigned NOT NULL DEFAULT '0',
  `product_updated_datetime` datetime NOT NULL,
  `product_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  `product_searchtext` longtext NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`product_id`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
	product fields:
		product_min_order_quantity
		product_max_order_quantity
		product_enable_inventory char(1) 0
		min/max quantity per user
		product_available_quantity int (including the option combinations)
		product_list_available_quantity char(1) 0
		product_min_available_to_allow_order 1 or more
		product_hide_when_unavailable
		rules for when out of stock - allow backorder or not
		product_returnable
		product_metatitle
		product_msrp_price
		product_summary TEXT

	shipping rules per product...

product_x_option_group
	product_x_option_group_id
	product_x_option_group_required char(1)
	product_option_group_id
	product_id
	site_id

product_x_option
	product_option_original_image
	product_option_full_image
	product_option_thumbnail_image
	

product_x_option_x_group
	product_x_option_x_group_id
	product_option_id_list  (product_x_option_group_id sorted ascending)
	product_x_option_x_group_quantity
	product_x_option_x_group_price

product_option_group
	product_option_group_id
	product_id
	site_id
	product_option_group_name

product_option
	product_option_id
	product_id
	site_id
	product_option_name


product_filter
	product_filter_id
	product_filter_name
	product_category_id
	site_id
	product_filter_show_on_home
	product_filter_display_limit
	product_filter_show_count char(1) 0
	product_filter_data_type varchar(10) range, indexed or list
	product_filter_label_list
	product_filter_value_list
	product_filter_search_field_type from/to range, select menu, radio group, checkbox group, text field

product_filter_x_section
	product_filter_x_section_id
	site_id
	section_id
	product_filter
	product_filter_x_section_sort

product_filter_x_product_category
	product_filter_x_product_category_id
	product_filter_id
	product_category_id
	product_filter_x_product_category_sort
	site_id

product_filter_range
	product_filter_id
	site_id

product_filter_index
	product_filter_index_id
	site_id
	product_filter_index_value
	product_filter_index_active char(1) 0

product_filter_count
	product_filter_index_id_list

product_search
	product_search_title varchar 100
	product_search_summary VARCHAR 255
	product_option_id
	product_option_id_list
	product_search_text longtext
	product_search_image
	product_search_in_stock
	product_search_allow_order
	product_search_price
	product_search_text fulltext index

product_search_memory

	how to filter on product options with fastest performance
		lucene, sphinx, solr
	product_search_filter1

Using custom form builder and 30 hours or more, I could have most of the ecommerce stuff in Jetendo.   For product based sites, it would take a couple more days to have UPS quotes / coupons which are probably required.

The store would not have structure like categories / directories / site map etc,  the custom form builder allows those things.   If I made them permanent, they would not be as flexible, but that would save time for boilerplate stores.  Probably 20 hours for this, and more to have a variety of layouts.

1 hour
Done: Add Built-in function for paypal buy now and subscription buttons with 1 or more payment types allowed.  I.e. one time / monthly / yearly - partially done

2 hours
make this paypal button integrate with custom form builder as a site option type with user interface to configure the struct below.
	Select fields:
	Price:
	Shipping:  

2 hours
Done: New application plugin: Ecommerce
	This is a new app_id which lets it have isolated options, memory cache and on/off configuration per site like we can do with rental / listing / content / blog are other app_id in jetendo
	need global options available for ecommerce that are set in config in server manager

1 hour	
Integrate with lead routing, to allow site admin to send Ecommerce emails to different departments.
Done: Integrate with security filter to allow limited access to ecommerce admin features.	

Done: New Ecommerce menu button in site manager for Orders / Customers / Subscriptions / Coupons / Products / Bundles / Reporting / Accounting / etc

8 hours
Bring my new Ajax JS Cart to jetendo project.
	Done: Add support for changing quantity
	Make sure if multiple browser windows affect the cart, that the latest version of cart is always shown after user updates it.
	
	Add custom form builder site_option_type for Add to Cart

	Allow 1 or more options to be selected before clicking Add To Cart.

2 hours
Make simple CFML functions for placing Add To Cart, Cart Status & Checkout widgets in new designs

Done: Checkout should post the separate items to paypal like this:
	<input type="hidden" name="item_name_1" value="beach ball">
	<input type="hidden" name="amount_1" value="15">

	<input type="hidden" name="item_name_2" value="towel">
	<input type="hidden" name="amount_2" value="20">

10+ hours
Tracking successful payments is impossile without integrating with PayPal Instant Payment Notification.

Some progress:	IPN alerts /z/ecommerce/paypal/ipn - might want to use the main jetendo server admin url instead of site urls so I can guarantee security.  Partially built for FBC invoice system already.

	Test all situations using IPN simulator: https://developer.paypal.com/docs/classic/ipn/integration-guide/IPNTesting/#simulator

	New transactions become orders after successful processing of the paypal IPN.  If these fail, they are permanently logged for manual review and developer is notified.

	IPN stores full information for products.  If product data changes, the order history must not change or become corrupted.  If an URL is not available, it will prevent 404, by removing the links in order history reports.
		paypal allows 256 character custom field.  This is not long enough to represent all order information.  I will have to store a permanent copy of the information in the tables on our end, and then the IPN will just mark the status of the order to make it visible and send related emails.   I.e. when someone clicks "checkout", everything is inserted with ajax, then the page goes to paypal on success.   Orders that are not paid for within 30 minutes, are removed from database.   The user's cart is not cleared until the IPN notification is successful and the next time that the Ajax cart polls the site for changes.

8+ hours
Common needs for order admin:
	View/Search order history as admin or customer
	View/Edit Shipping Address

	Change status: Processing | Processed | Shipped | Cancelled | Payment Failure // Shipped not relevant for digital orders
	
	Re-send Order Email To:
	Edit Order i.e. change item details only not price.
	

Future Features:
	Wish list management
	Multiple vendors within one domain with separate access to manage products
	Inventory management
	Accounting integration / reporting
	Integration with third party product directories / google, etc.
	Secure & automated delivery of digital goods with options to limit time or quantity of views.  I.e. video subscriptions, software downloads.
	License key generation / activation / storage features for software license management with user portal to view consolidated list of licenses.
	Allow modification of paypal subscription through interface by admin or customer.   Allow updating price of existing subscriptions with user confirming terms & conditions.
	Integrate digital contract feature require scroll and checkbox before purchase is allowed.  Could be used for service / subscription payments - digital contract management.
	UPS tracking integration
	UPS Shipping quote API with postal code before paypal checkout.
	FedEx shipping quote API
	Allow creation of multi-product bundles at discounted price, but with itemized records.
	Coupons / Gift certificates
	Allow customer to re-order past orders (if available)
	Allow customer to purchase product as a recurring subscription if they want to receive the same product every X months.  May require approval of price changes.
	Purchase by invoice
	Support Paypal eCheck payments.
	Support foreign currencies and currency conversion for prices to help user.
	Mobile / responsive 320+ width compatibility
 --->
<cffunction name="testFacets" access="remote" localmode="modern"> 
    <cfscript>
	if(not request.zos.istestserver){
		application.zcore.functions.z404("Only available on test server");
	}

	// https://mariadb.com/kb/en/mariadb/fulltext-index-overview/
	/*
	zdead.a5 table has fulltext index tests with facets in the fulltext column instead outside columns - it is fast. need to test with too much data


when a facet field is varchar, the maximum key length is 255 because of utf8 - this is up to 30 facet values for one product when the primary key ids are big.  This is too low.
if we generate new tables from the indexing process, the problem is that they have to be completely replaced (create table _safe, rename _safe to live and make it live to users) , if the facet names change.  But the values 

this format is better:
	facetId:valueId facetId:valueId - this will index better.

best performance is facet in separate field, with text not using boolean mode.  also found innodb is faster then myisam because of in memory caching.
	SELECT SQL_NO_CACHE * FROM a5  FORCE INDEX(`a5_text`)
	WHERE MATCH(a5_text) AGAINST ('lacinia nlor nisi') 
	AND a5_price BETWEEN 0 AND 30000
	AND (a5_facet LIKE '%:facet1:2|%' OR a5_facet LIKE '%:facet1%'  )    
	  LIMIT 0,100;
	SELECT SQL_NO_CACHE * FROM a5  FORCE INDEX(`a5_text`)
	WHERE MATCH(a5_text) AGAINST ('lacinia nlor nisi') 
	AND a5_price BETWEEN 0 AND 30000
	AND (a5_facet LIKE '%:facet1:2|%' OR a5_facet LIKE '%:facet1%'  )    
	ORDER BY a5_price ASC
	  LIMIT 0,100;


#this query work for relevance with facets.   for search without facets, i could use natural language mode instead.
SELECT SQL_NO_CACHE *, MATCH(a5_text) AGAINST ('+"facet2:2|"' IN BOOLEAN MODE) AS relevance FROM a5 
WHERE MATCH(a5_text) AGAINST ('+":facet1:2|"' IN BOOLEAN MODE) 
ORDER BY relevance DESC LIMIT 0,100;

SELECT *, MATCH(a5_text) AGAINST ('"facet3:1"') AS relevance FROM a5 ORDER BY relevance DESC;
SELECT *, MATCH(a5_text) AGAINST ('":facet3:1|" ":facet2:2|" "imagine magic"') AS relevance FROM a5 ORDER BY relevance DESC;
SELECT *, MATCH(a5_text) AGAINST ('+":facet3:1|" -":facet2:2|" +"imagine magic"' IN BOOLEAN MODE) AS relevance FROM a5 ORDER BY relevance DESC;
SELECT *, MATCH(a5_text) AGAINST ('+:facet1:2| +magic' IN BOOLEAN MODE) AS relevance FROM a5 ORDER BY relevance DESC;
SELECT *, MATCH(a5_text) AGAINST (':facet1:2| magic') AS relevance FROM a5;
*/

	// filter format: :filter_option_id:value|:filter_option_id:value
	fieldStruct={ facet1:3, facet2:3, facet3:2};//, facet4:3, facet5:5, facet6:3};
	arrField=structkeyarray(fieldStruct);
	arraySort(arrField, "text", "asc");

	dataStruct={};
	for(i=1;i LTE 200;i++){ 
		arrRow=[];
		for(n=1;n LTE arraylen(arrField);n++){
			v=randrange(0, fieldStruct[arrField[n]]);
			if(v GT 0){
				arrayAppend(arrRow, ":"&arrField[n]&":"&v);
			}
		}
		v=arrayToList(arrRow, "|");
		if(not structkeyexists(dataStruct, v)){
			dataStruct[v]=0;
		}
		dataStruct[v]++; 
	}
	structdelete(dataStruct, "");
	for(i in dataStruct){
		echo(i&"<br>");
	}
	writedump(dataStruct);
	abort;
	arrList=[];
	index=1;
	for(i in fieldStruct){
		arrList[index]=[];
		for(n=1;n LTE fieldStruct[i];n++){
			arrayAppend(arrList[index], i&"-"&n);
		}
		index++;
	}
	//writedump(arrList);
	arrResult=[];
	arrResult2=[];
	generatePermutations(dataStruct, arrList, 1, "");
	echo("permutations:"&arrayLen(arrResult2)&"<hr>");
	for(i in dataStruct){
		if(dataStruct[i] NEQ 0){
			echo(i&"="&dataStruct[i]&"<br>");
		}
	}

	abort;
    echo('done');
    abort;
	</cfscript>
</cffunction>


<cffunction name="generatePermutations" access="public" localmode="modern">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="arrList" type="array" required="yes"> 
	<cfargument name="depth" type="numeric" required="yes"> 
	<cfargument name="current" type="string" required="yes"> 
	<cfscript>
	arrList=arguments.arrList;
	dataStruct=arguments.dataStruct;
	current=arguments.current;
	depth=arguments.depth;
    echo(current&"<br>");

    if(structkeyexists(dataStruct, current)){
    	dataStruct[current]++;
    }
    if(depth GT arrayLen(arrList)){
       return;
    }
    if(len(current)){
    	current="|"&current;
    }
    for(i =1; i LTE arrayLen(arrList[depth]); i++){ 
        GeneratePermutations(dataStruct, arrList, depth+1, arrList[depth][i]&current);
    }
    </cfscript>
</cffunction>

<!--- working - returns instead of outputs --->
<cffunction name="generatePermutations3" access="public" localmode="modern">
	<cfargument name="arrList" type="array" required="yes"> 
	<cfargument name="arrResult" type="array" required="yes"> 
	<cfargument name="depth" type="numeric" required="yes"> 
	<cfargument name="current" type="string" required="yes"> 
	<cfargument name="arrResult2" type="array" required="yes"> 
	<cfargument name="currentStruct" type="struct" required="yes"> 
	<cfscript>
	arrList=arguments.arrList;
    //arguments.currentStruct[arguments.current]=true;
    //echo(arguments.current&"<br>");
    arrayAppend(arguments.arrResult2, arguments.currentStruct);
    arrayAppend(arguments.arrResult, arguments.current);
    if(arguments.depth GT arrayLen(arrList)){
       return;
    }
    if(arguments.current NEQ ""){
    	arguments.current="|"&arguments.current;
    }

    for(i =1; i LTE arrayLen(arrList[arguments.depth]); i++){ 
    	v=arrList[arguments.depth][i]&arguments.current;
    	arr=listToArray(v, "|");
    	arguments.currentStruct={};
    	arguments.currentStruct[arrList[arguments.depth][i]]=true;
    	for(n=1;n LTE arraylen(arr);n++){
	    	arguments.currentStruct[arr[n]]=true;
	    }
        GeneratePermutations(arrList, arguments.arrResult, arguments.depth + 1, v, arguments.arrResult2, arguments.currentStruct);
    }
    </cfscript>
</cffunction>

<cffunction name="onSiteStart" localmode="modern" output="no" access="public"  returntype="struct" hint="Runs on application start and should return arguments.sharedStruct">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;
	return arguments.arrURL;
	</cfscript>
</cffunction>

<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Ecommerce") EQ false){
			ts=structnew();
			ts.featureName="Content Manager";
			ts.link='/z/ecommerce/admin/ecommerce-admin/index';
			ts.children=structnew();
			arguments.linkStruct["Ecommerce"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Ecommerce"].children,"Orders") EQ false){
			ts=structnew();
			ts.featureName="Manager Orders";
			ts.link="/z/ecommerce/admin/order/index";
			arguments.linkStruct["Ecommerce"].children["Orders"]=ts;
		}
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("ecommerce_config", request.zos.zcoreDatasource)# ecommerce_config 
	where 
	site_id = #db.param(arguments.site_id)# and 
	ecommerce_config_deleted = #db.param(0)#";
	qData=db.execute("qData");
	for(row in qData){
		return row;
	}
	throw("ecommerce_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var theText="";
	var qconfig=0;
	var t9=0;
	var qcontent=0;
	var link=0;
	var t999=0;
	var pos=0;
	db.sql="SELECT * FROM #db.table("ecommerce_config", request.zos.zcoreDatasource)# ecommerce_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = ecommerce_config.site_id and 
	ecommerce_config.site_id = #db.param(arguments.site_id)# and 
	ecommerce_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig"); 
	/*
	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.ecommerce_config_url_article_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.ecommerce_config_url_section_id]=[];
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/content/content/viewPage";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="content_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.ecommerce_config_url_article_id],t9);
		if(qConfig.ecommerce_config_url_listing_user_id NEQ 0 and qConfig.ecommerce_config_url_listing_user_id NEQ ""){
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.ecommerce_config_url_listing_user_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/listing/agent-listings/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/agent-listings/index";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_listing_user_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.ecommerce_config_url_listing_user_id],t9);
		}
		t999=application.zcore.functions.zvar('contenturlid',qConfig.site_id);
		if(t999 NEQ 0 and t999 NEQ ''){
			arguments.sharedStruct.reservedAppUrlIdStruct[t999]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/content/content/viewPage";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
			t9.mapStruct=structnew();
			t9.mapStruct.entireURL="content_unique_name";
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_listing_user_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[t999],t9);
			
		}
	}

	t9=structnew();
	t9.type=1;
	t9.scriptName="/z/content/content/displayContentSection";
	t9.ifStruct=structnew();
	t9.ifStruct.ext="html";
	t9.urlStruct=structnew();
	t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/displayContentSection";
	t9.mapStruct=structnew();
	t9.mapStruct.urlTitle="zURLName";
	t9.mapStruct.dataId="site_x_option_group_set_id";
	arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.ecommerce_config_url_section_id],t9);

	*/
	</cfscript>
</cffunction>
	
<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("ecommerce_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	ecommerce_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();

	df.ecommerce_config_sandbox_enabled=0;
	df.ecommerce_config_order_confirmation_email_list="1,2,3";
	df.ecommerce_config_order_change_email_list="1,2,3";
	df.ecommerce_config_paypal_ipn_failure_email_list=1;
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"ecommerce_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';
	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	
	form.site_id=form.sid;
	ts=StructNew();
	ts.arrId=arrayNew(1);
	ts.app_id=this.app_id;
	ts.site_id=form.site_id;
	// arrayappend(ts.arrId,trim(form.ecommerce_config_category_url_id)); 
	arrayappend(ts.arrId,trim(form.ecommerce_config_paypal_custom_ipn_url_id));

	arrayappend(ts.arrId,trim(form.ecommerce_config_product_url_id));
	arrayappend(ts.arrId,trim(form.ecommerce_config_category_url_id));
	arrayappend(ts.arrId,trim(form.ecommerce_config_misc_url_id));
	
	rCom=application.zcore.app.reserveAppUrlId(ts); 
	if(rCom.isOK() EQ false){
		return rCom;
		/*application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();*/
	}		
	form.ecommerce_config_updated_datetime=request.zos.mysqlnow;
	ts.table="ecommerce_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'ecommerce_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts); 
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("ecommerce_config", request.zos.zcoreDatasource)# ecommerce_config 
		WHERE site_id = #db.param(form.sid)# and 
		ecommerce_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		/*


		Tax Rate:
		Tax State(s):
			*/
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="ecommerce_config_id" value="#form.ecommerce_config_id#" />
		<table style="border-spacing:0px;" class="table-list">
		<tr>
		<th>Sandbox Enabled?</th>
		<td>');
		form.ecommerce_config_sandbox_enabled=application.zcore.functions.zso(form, 'ecommerce_config_sandbox_enabled',true);
		ts = StructNew();
		ts.name = "ecommerce_config_sandbox_enabled";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (Yes, will disable real money transactions.)</td>
		</tr>');
		echo('<tr>
		<th>Order Confirmation Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "ecommerce_config_order_confirmation_email_list";
		selectStruct.hideSelect=true;
		selectStruct.multiple=true;
		selectStruct.size=3;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');

		echo('<tr>
		<th>Order Change Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "ecommerce_config_order_change_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		selectStruct.multiple=true;
		selectStruct.size=3;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');

		
		echo('<tr>
		<th>Product URL ID:</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("ecommerce_config_product_url_id", form.ecommerce_config_product_url_id, 15));
		echo('</td>
		</tr>');
		
		echo('<tr>
		<th>Category URL ID:</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("ecommerce_config_category_url_id", form.ecommerce_config_category_url_id, 15));
		echo('</td>
		</tr>');
		
		echo('<tr>
		<th>Misc URL ID:</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("ecommerce_config_misc_url_id", form.ecommerce_config_misc_url_id, 15));
		echo('</td>
		</tr>');
		 
		echo('

		<tr>
		<th colspan="2"><h2>Payment Integration</h2></th>
		</tr>

		<tr>
		<th colspan="2"><h3>Stripe.com</h3></th>
		</tr>
		<tr>
		<th>Secret Key:</th>
		<td>');
		ts = StructNew();
		ts.name = "ecommerce_config_stripe_secret_key";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Public Key:</th>
		<td>');
		ts = StructNew();
		ts.name = "ecommerce_config_stripe_public_key";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th colspan="2"><h3>Paypal.com</h3></th>
		</tr>
		<tr>
		<th>Paypal Merchant ID:</th>
		<td>');
		ts = StructNew();
		ts.name = "ecommerce_config_paypal_merchant_id";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Paypal IPN Failure Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "ecommerce_config_paypal_ipn_failure_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator";
		selectStruct.listValues = "1,2";
		selectStruct.multiple=true;
		selectStruct.size=2;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');
		
		
		echo('<tr>
		<th>Paypal IPN Custom App ID:</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("ecommerce_config_paypal_custom_ipn_url_id", form.ecommerce_config_paypal_custom_ipn_url_id, 15));
		echo('</td>
		</tr>');
		



		/*
		<tr>
		<th>Category URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("ecommerce_config_category_url_id", form.ecommerce_config_category_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Sidebar Tag</th>
		<td>');
		ts=StructNew();
		ts.label="";
		ts.name="ecommerce_config_sidebar_tag";
		ts.size="20";
		application.zcore.functions.zInput_Text(ts);
		echo(' (i.e. type "sidebar" for &lt;z_sidebar&gt;)</td>
		</tr>
		
		<tr>
		<th>Default Parent Page<br />Link Layout</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "ecommerce_config_default_parentpage_link_layout";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Invisible,Top with numbered columns,Top with columns,Top on one line";//,Bottom with summary (default),Bottom without summary,Left Sidebar,Right Sidebar";
		selectStruct.listValues = "7,2,3,4";//,0,1,5,6";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>
		<tr>
		<th>Section Title Affix:</th>
		<td>');
		ts = StructNew();
		ts.name = "ecommerce_config_section_title_affix";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>*/
		echo('
		
		</table>');
	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>



<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
	var db=request.zos.queryObject; 
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>