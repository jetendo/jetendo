<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.zModalCancel(); 
	 
	var ts={}; 
	var db=request.zos.queryObject;   
	if(isDefined('request.zsession.user.id')){
		if(isDefined('request.zsession.listing.savedListingUserLoaded') EQ false){
			db.sql="select * from #request.zos.queryObject.table("saved_listing", request.zos.zcoreDatasource)# saved_listing 
			WHERE site_id=#db.param(request.zos.globals.id)# and 
			user_id=#db.param(request.zsession.user.id)# and 
			saved_listing_deleted = #db.param(0)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
			qC=db.execute("qC"); 
			if(qC.recordcount NEQ 0){
				ts=structnew();
				ts.name="savedListingStruct";
				ts.value=qc.saved_listing_idlist;
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="savedListingCount";
				ts.value=qc.saved_listing_count;
				ts.expires="never";
				application.zcore.functions.zCookie(ts); 
				arrKey=listtoarray(qc.saved_listing_idlist);
				if(isDefined('request.zsession.listing.savedListingStruct') EQ false){
					request.zsession.listing.savedListingStruct=structnew();
				}
				for(i=1;i LTE arraylen(arrKey);i++){
					request.zsession.listing.savedListingStruct[arrKey[i]]=true;
				} 
				
			}else if(isDefined('request.zsession.listing.savedListingStruct') and (structcount(request.zsession.listing.savedListingStruct) NEQ 0)){
				application.zcore.listingCom.updateUserSavedListings();	 
			}
			request.zsession.listing.savedListingUserLoaded=true;
		}
	}else if(isDefined('request.zsession.listing.savedListingUserLoaded')){
		ts=structnew();
		ts.name="savedListingStruct";
		ts.value="";
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedListingCount";
		ts.value=0;
		ts.expires="never";
		application.zcore.functions.zCookie(ts); 
		request.zsession.listing.savedListingStruct=structnew(); 
		structdelete(request.zsession.listing,"savedListingUserLoaded");
	}
	if(isDefined('request.zsession.listing.savedListingStruct') eq false){
		request.zsession.listing.savedListingStruct=structnew();
		if(isDefined('cookie.savedListingStruct')){
			arrKey=listtoarray(cookie.savedListingStruct);
			for(i=1;i LTE arraylen(arrKey);i++){
				request.zsession.listing.savedListingStruct[arrKey[i]]=true;
			}
		}
	} 
	if(not structkeyexists(cookie, 'savedListingCount')){
		cookie name="savedListingCount" value="0" expires="never";
	}
	</cfscript>

</cffunction>

<cffunction name="view" localmode="modern" access="remote" returntype="any">
	<cfscript>
request.zos.currentURLISAListingPage=true;
	application.zcore.template.setTag("title", "Your Saved Listings");
	application.zcore.template.setTag("pagetitle", "Your Saved Listings"); 
	form.returnURL=request.zos.originalURL; 
	pageNav='<a href="/">Home</a> / ';
	
	if(application.zcore.user.checkGroupAccess("user")){
		pageNav&='<a href="/z/user/home/index">User Dashboard</a> / ';
	}else{
		echo(application.zcore.user.createAccountMessage());
	}
	application.zcore.template.setTag("pagenav", pagenav);


	</cfscript>
	<div id="sl894nsdh783" style="width:100%; float:left; clear:both;"></div>
	<!--- 
	<cfif cookie.SAVEDLISTINGCOUNT EQ 0>
		<h2>You have no saved listings at this time.</h2>
	<cfelse>
		<hr />
		<button id="zSLEmailButton1" type="button" name="button1" onclick="zShowModalStandard('/z/listing/sl/inquiry', 540, 630);return false;" rel="nofollow" class="zSavedList-link" style="display:none;">Email your saved listings to us</button>
		<script type="text/javascript">
		/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){
			$("##zSLEmailButton1").show();
		});
		/* ]]> */
		</script>
	</cfif> --->
	<!--- this is empty on purpose to allow viewing ONLY the saved listings --->
</cffunction>

<cffunction name="add" localmode="modern" access="remote">
	<cfscript>
	init();
	application.zcore.tracking.backOneHit();
	if(structkeyexists(form, 'listing_id')){
		
		if(structkeyexists(request.zsession.listing.savedListingStruct, form.listing_id) EQ false){
			request.zsession.listing.savedListingStruct[form.listing_id]=true;
			application.zcore.listingCom.updateUserSavedListings();
		}
		ts=structnew();
		ts.name="savedListingStruct";
		ts.value=structkeylist(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedListingCount";
		ts.value=structcount(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts); 
	}
	rs={
		success:true 
	};
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
	
</cffunction>
<cffunction name="deleteAll" localmode="modern" access="remote">
	<cfscript>
	init();
	request.zsession.listing.savedListingStruct=structnew(); 
	application.zcore.listingCom.updateUserSavedListings();
	ts=structnew();
	ts.name="savedListingStruct";
	ts.value="";
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedListingCount";
	ts.value=0;
	ts.expires="never";
	application.zcore.functions.zCookie(ts); 
	rs={
		success:true
	};
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
	
</cffunction>

<cffunction name="delete" localmode="modern" access="remote">
	<cfscript>
	init();
	if(structkeyexists(form, 'listing_id')){
		structdelete(request.zsession.listing.savedListingStruct, form.listing_id);
		application.zcore.listingCom.updateUserSavedListings();
		ts=structnew();
		ts.name="savedListingCount";
		ts.value=structcount(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedListingStruct";
		ts.value=structkeylist(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts); 
	} 
	rs={
		success:true
	};
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
</cffunction>

<cffunction name="inquiry" localmode="modern" access="remote">
	<cfscript>
request.zos.currentURLISAListingPage=true;
	init();
	form.modalpopforced=1;
	application.zcore.functions.zSetModalWindow();
	form.listing_id=structkeylist(request.zsession.listing.savedListingStruct); 
	
	tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.inquiry");
	tempCom.index();
	</cfscript> 
</cffunction>

<cffunction name="viewData" localmode="modern" access="private">
	
	<cfscript> 
	init();
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	// get select properties based on mls_id and listing_id
	ts.arrMLSPid=structkeyarray(request.zsession.listing.savedListingStruct);
	//ts.debug=true;
	ts.perpage=200;
	ts.showInactive=true;
	returnStruct = propertyDataCom.getProperties(ts);
	propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	ts = StructNew();
	ts.baseCity = 'db';
	ts.disableCount=true;
	ts.datastruct = returnStruct;
	ts.searchScript=false;
	ts.compact=true;
	propDisplayCom.init(ts);
	//zdump(ts.datastruct);
	ts=structnew();
	ts.name="savedListingCount";
	ts.value=returnStruct.count;
	ts.expires="never";
	application.zcore.functions.zCookie(ts);

	if(returnStruct.count NEQ structcount(request.zsession.listing.savedListingStruct)){
		ns={};
		for(row in returnStruct.arrData){
			ns[row.listing_id]=true;
		}
		request.zsession.listing.savedListingStruct=ns;

		ts=structnew();
		ts.name="savedListingStruct";
		ts.value=structkeylist(ns);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedListingCount";
		ts.value=structcount(ns);
		ts.expires="never";
		application.zcore.functions.zCookie(ts); 
		request.zsession.listing.savedListingStruct=structnew(); 
	}
	// inputStruct should contain all search parameters. (on daytona beach page, this would only be city_name and state_abbr)
	propertyHTML = propDisplayCom.displayTop();	 
	
	</cfscript>
    <cfcookie name="savedListingCount" value="#returnstruct.count#" expires="never">
    <cfif returnStruct.count>
		<table style="border-spacing:2px;width:#returnStruct.count*115#px; ">
			<tr>
				#propertyHTML# 
	        </tr>
		</table>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
 
	<cfscript>
request.zos.currentURLISAListingPage=true;
	init(); 
    request.znotemplate=1;
	if(cookie.SAVEDLISTINGCOUNT EQ 0){
		abort;	
	}
    </cfscript>
    <cfsavecontent variable="j">
		<table style="width:100%; border-spacing:5px; " class="zSavedList-table">
		<tr>
		<td class="zSavedList-title">Your Saved Listings</td>
		<td style="text-align:right;" class="zSavedList-left-td">Actions: <a href="##" onclick="zShowModalStandard('/z/listing/sl/inquiry', 540, 630);return false;" rel="nofollow" class="zSavedList-link">Send all to us</a> | 
		<cfif isDefined('request.zsession.user.id') EQ false>
			<a href="/z/user/preference/index?action=form&amp;zSignupMessage=#URLEncodedFormat("By creating an account below, your saved listings will be stored with the email and password you provide making it easy to retrieve them later.")#" rel="nofollow">Save to New Account</a> | 
		</cfif>
		<a href="##" class="zls-removeAllListingButton" rel="nofollow">Remove All</a>
		</td>
		</tr>
		</table>
		<div style="width:100%; margin-bottom:15px; float:left; overflow:auto; ">
			<cfscript>
			viewData();
			</cfscript> 
		</div>
    </cfsavecontent>
    <cfscript>
    rs={
    	output:j,
    	success:true
    };
	application.zcore.functions.zReturnJson(rs);
	</cfscript>   
 
</cffunction>


<cffunction name="ajaxGetCartData" access="remote" localmode="modern">
	<cfscript>
	rs={};
	rs.arrCartData=[];


	/*propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	// get select properties based on mls_id and listing_id
	ts.arrMLSPid=structkeyarray(request.zsession.listing.savedListingStruct);
	//ts.debug=true;
	ts.perpage=200;
	ts.showInactive=true;
	returnStruct = propertyDataCom.getProperties(ts);
	propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	ts = StructNew();
	ts.baseCity = 'db';
	ts.datastruct = returnStruct;
	ts.searchScript=false;
	ts.compact=true;
	propDisplayCom.init(ts);
	//zdump(ts.datastruct);

	// inputStruct should contain all search parameters. (on daytona beach page, this would only be city_name and state_abbr)
	propertyHTML = propDisplayCom.displayTop();	
	*/
	rs.form=form;
	/*
	rs.arrCartData
		var obj={ id:'1', label:'cart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };*/
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>
<!--- 
TODO: associate saved listings with a user_id if use is logged in.


check login status with cookie - so that it doesn't have to query server.  
	zArrDeferredFunctions.push(function(){
		zWatchCookie("ZLOGGEDIN", function(v){ console.log("logged in: "+zIsLoggedIn()); });
	});
	on each ajax request to CFML, return the login expiration date/time in a response header (cookie). 

		poll zLoginExpiresDate - when time has passed, zDeleteCookie("zLoginExpiresDate");
		
view cart needs to fire code that loads the json via ajax.
when page loads again, view cart will not continue to be expanded, so don't need the json again.
 --->
<cffunction name="testCart" access="remote" localmode="modern">
	<cfscript>
	application.zcore.template.setPlainTemplate();
	</cfscript>
	<style type="text/css">
	.zcart{ width:98%; padding:1%;float:left; background-color:##EEE; clear:both;}
	.zcart-add-saved, .zcart-add-saved:link, .zcart-add-saved:visited{ background-color:##000 !important;  color:##FFF !important; }
	.zcart-add-saved:hover{ background-color:##666 !important;  color:##FFF !important;}
	.zcart-navigation{  width:99%; padding:0.5%; float:left; border-radius:5px; background-color:##CCC; }
	a.zcart-navigation-button:link, a.zcart-navigation-button:visited, .zcart-navigation-button{display:block; background-color:##FFF; color:##666; border-radius:5px; padding:7px;  padding-top:3px; line-height:18px; padding-bottom:3px; font-size:14px; margin-right:5px; margin-bottom:5px; float:left; text-decoration:none;}
	a.zcart-navigation-button:hover{ text-decoration:underline;}
	.zcart-item{ width:120px; border-radius:5px; border:1px solid ##CCC; background-color:##FFF; color:##000; padding:5px; float:left; margin-right:10px; margin-bottom:10px;}
	.zcart-item a:link, .zcart-item a:visited{ color:##369; text-decoration:none; }
	.zcart-item-imagediv{ width:120px; height:80px; margin-bottom:5px; float:left; }
	.zcart-item-image{ max-width:120px; max-height:80px; float:left; }
	.zcart-item-label{ font-size:14px; line-height:18px; padding-bottom:3px;float:left; width:100%;}
	.zcart-item-description{ font-size:12px; height:40px; overflow:hidden; line-height:16px; padding-bottom:3px;float:left; width:100%;}
	.zcart-item-delete{ margin:0 auto; clear:both; width:60px;}
	.zcart-item-quantity{width: 100%;float: left;text-align: center;}
	.zcart-item-quantity-input{ width:30px; }
	.zcart-item-delete-link, .zcart-item-delete-link:link, .zcart-item-delete-link:visited{ cursor:pointer;text-align:center; font-size:12px; color:##000; display:block; padding:3px; border-radius:3px; float:left; width:100%;}
	.zcart-item-delete-link:hover{ background-color:##000 !important; color:##FFF !important; }
	.zcart-navigation-button:link, .zcart-navigation-button:visited, .zcart-navigation-button{display:block; background-color:##FFF; color:##666; border-radius:5px; padding:7px;  padding-top:3px; line-height:18px; padding-bottom:3px; font-size:14px; margin-right:5px; margin-bottom:5px; float:left; text-decoration:none;}
	.demo-navlinks{width:99%; float:left; background-color:##EEE; padding:0.5%; padding-top:10px; padding-bottom:10px;}
	</style>
	<div style="padding:10px;">
		<h2>Saved Listing Javascript Cart Demo</h2>
		<div class="zcart-navigation">
			<a href="##" class="zcart-navigation-button zcart-view listingcart1" data-zcart-hideHTML="Hide Saved Listings" data-zcart-viewHTML="View Saved Listings">View Saved Listings</a> 
			<a href="##" class="zcart-navigation-button zcart-refresh listingcart1">Refresh</a>
			<div class="zcart-navigation-button zcart-count-container listingcart1"><span class="zcart-count listingcart1">0</span> Saved Listings</div> 
			<a href="##" class="zcart-navigation-button zcart-checkout listingcart1">Inquire About Listings</a>
			<a href="##" class="zcart-navigation-button zcart-clear listingcart1">Remove All</a>
		</div>
		<div class="zcart listingcart1" style="display:none;">
		
		</div>
		<div class="zcart-templates" style="display:none;">
			<div id="{itemId}" class="zcart-item">
				<div class="zcart-item-imagediv"><a href="##" data-url="{viewURL}"><img src="/z/a/images/s.gif" data-image="{image}" class="zcart-item-image" /></a></div>
				<div class="zcart-item-label"><a href="##" data-url="{viewURL}">{label}</a></div>
				<div class="zcart-item-description">{description}</div>
				<div class="zcart-item-quantity">Quantity: <input type="text" name="zcart_item_quantity_text" class="zcart-item-quantity-input" data-zcart-id="{id}" value="{quantity}" /></div>
				<div class="zcart-item-delete"><a href="##" id="{deleteId}" data-zcart-id="{id}" class="zcart-item-delete-link">Remove</a></div>
			</div>
		</div>
		<div class="demo-navlinks">
			<a href="##" class="zcart-navigation-button zcart-add listingcart1" data-zcart-json="{ id:'1', label:'listingcart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' }">Add Item 1</a>
			<a href="##" class="zcart-navigation-button zcart-add listingcart1"data-zcart-json="{ id:'2', label:'listingcart1 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  }">Add Item 2</a>
			<a href="##" class="zcart-navigation-button zcart-add listingcart1"data-zcart-json="{ id:'3', label:'listingcart1 Item 3', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 3', removeHTML:'Remove Item 3', viewURL: '##view3'  }">Add Item 3</a>
		</div> 
	</div>
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.animate-colors.js");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.easing.1.3.js");
	application.zcore.skin.includeJS("/z/javascript/jetendo/zCart.js");
	</cfscript>
	<!--- 
	read cookie on server-side
	retrieve the cartData by id
	prefix the id with app_id so I can have more then one cart on a site
	create a function that builds the html for cartData from a simpler json object - reduces output size
	then zArrDeferredFunctions.push(function(){
		var listingCart=new zListingCart();

	});
	 --->
	<script type="text/javascript">

	function zListingGetCartObj(){
		var obj={ id:'1', label:'listingcart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };
	}
	var listingcart1Data=[];
	
	listingcart1Data[1]={ id:'1', label:'listingcart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };
	listingcart1Data[2]={ id:'2', label:'listingcart1 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  };
	listingcart1Data[3]={ id:'3', label:'listingcart1 Item 3', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 3', removeHTML:'Remove Item 3', viewURL: '##view3'  };
	/**/
	zArrDeferredFunctions.push(function(){
		(function($, window, document, undefined){
			"use strict";
			var count=0;
			var listingCart=function(options){
				var self=this;
				var createCartData=function(){
					for(var i in options.arrListingCartData){
						var data=options.arrListingCartData[i];
						var obj={ id:'1', label:'listingcart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };
					}
				};
				self.listingCheckout=function(obj){
					console.log("checkout");
					console.log(obj);
					var count=obj.getCount();
					var items=obj.getItems();
					var arrId=[];
					if(count ===0){
						alert("You must select a listing before you send an inquiry.");
						return;
					}
					for(var i in items){
						arrId.push(items[i].id);
					}
					alert("Soon this will go to a page passing the item ids: "+arrId.join(", "));
				};
				self.changeCallback=function(obj){
					console.log("changeCallback");
					console.log(obj);
					var currentCount=obj.getCount();
					console.log("counts:"+count+":"+currentCount);
					if(count < currentCount){
						console.log("Listing added");
					}else if(count > currentCount){
						console.log("Listing removed");
					}
					count=currentCount;
					
				}
				self.viewCartCallback=function(d){
					var rs=eval("("+d+")");
					console.log(rs);
					var cartData=[];

					return cartData;
				}
			};
			//window.listingCart=listingCart;
			var listingCartInstance=new listingCart({});
			
			var initObject={
				arrData:listingcart1Data,
				debug:false,
				name:"listingcart1",
				checkoutCallback:listingCartInstance.listingCheckout,
				changeCallback:listingCartInstance.changeCallback,
				viewCartURL:"/z/listing/sl/ajaxGetCartData",
				viewCartCallback:listingCartInstance.viewCartCallback,
				emptyCartMessage:"You have no saved listings yet."
			};
			var a=new zCart(initObject);

		})(jQuery, window, document, "undefined"); 
	});
	</script>
</cffunction>
</cfoutput>
</cfcomponent>