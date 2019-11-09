<cfcomponent>
<cfoutput>
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
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	application.zcore.template.setPlainTemplate();
	</cfscript>
	<style>
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
			<a href="##" class="zcart-navigation-button zcart-view cart1" data-zcart-hideHTML="Hide Saved Listings" data-zcart-viewHTML="View Saved Listings">View Saved Listings</a> 
			<a href="##" class="zcart-navigation-button zcart-refresh cart1">Refresh</a>
			<div class="zcart-navigation-button zcart-count-container cart1"><span class="zcart-count cart1">0</span> Saved Listings</div> 
			<a href="##" class="zcart-navigation-button zcart-checkout cart1">Inquire About Listings</a>
			<a href="##" class="zcart-navigation-button zcart-clear cart1">Remove All</a>
		</div>
		<div class="zcart cart1" style="display:none;">
		
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
			<a href="##" class="zcart-navigation-button zcart-add cart1" data-zcart-json="{ id:'1', label:'cart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' }">Add Item 1</a>
			<a href="##" class="zcart-navigation-button zcart-add cart1"data-zcart-json="{ id:'2', label:'cart1 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  }">Add Item 2</a>
			<a href="##" class="zcart-navigation-button zcart-add cart1"data-zcart-json="{ id:'3', label:'cart1 Item 3', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 3', removeHTML:'Remove Item 3', viewURL: '##view3'  }">Add Item 3</a>
		</div>
		<hr style="margin-top:30px; margin-bottom:30px;" />
		<h2>More then one cart can be displayed on a page</h2> 
		<div class="zcart cart2" style="display:none;">
		</div>
		
		<div class="demo-navlinks">
			<a id="addLink1" href="##" class="zcart-navigation-button zcart-add cart2" data-zcart-json="{ id:'1', label:'cart2 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1'  }">Add Item 1</a>
			<a href="##" class="zcart-navigation-button zcart-add cart2" data-zcart-json="{ id:'2', label:'cart2 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  }">Add Item 2</a>
			
			
			<a href="##" class="zcart-navigation-button zcart-add cart2" data-zcart-json="{ id:'1', label:'cart2 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Another Add Item 1 Button', removeHTML:'Another Remove Item 1 Button', viewURL: '##view1'  }">Another Add Item 1 Button</a> 
		</div>

		<hr style="margin-top:30px; margin-bottom:30px;" />
		<h2>Ecommerce Example With Editable Quantities 100% Javascript</h2> 
		<div class="zcart-navigation">
			<a href="##" class="zcart-navigation-button zcart-view cart3" data-zcart-hideHTML="Hide Cart" data-zcart-viewHTML="View Cart">View Cart</a> 
			<a href="##" class="zcart-navigation-button zcart-refresh cart3">Refresh</a>
			<div class="zcart-navigation-button zcart-count-container cart3"><span class="zcart-count cart3">0</span> Products In Cart</div> 
			<a href="##" class="zcart-navigation-button zcart-checkout cart3">Checkout</a>
			<a href="##" class="zcart-navigation-button zcart-clear cart3">Empty Cart</a>
		</div>
		<div class="zcart cart3" style="display:none;">
		</div>
		
		<div class="demo-navlinks">
			<span style="padding:5px; display:block; float:left; padding-bottom:20px;">Item 1 Quantity: <input type="text" name="quantity" class="zcart-quantity" data-zcart-item-id="1" value="5" /></span>
			<a id="addLink1" href="##" class="zcart-navigation-button zcart-add cart3" data-zcart-json="{ id:'1', label:'cart3 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1'  }">Add Item 1</a> 
			<br style="clear:both;">

			<span style="padding:5px; display:block; float:left; padding-bottom:20px;">Item 2 Quantity: <input type="text" name="quantity" class="zcart-quantity" data-zcart-item-id="2" value="3" /></span>
			<a href="##" class="zcart-navigation-button zcart-add cart3" data-zcart-json="{ id:'2', label:'cart3 Item 3', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  }">Add Item 2</a>
		</div>
	</div>
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.animate-colors.js");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.easing.1.3.js");
	application.zcore.skin.includeJS("/z/javascript/jetendo/zCart.js");
	</cfscript>
	<script>
	var cart1Data=[];
	cart1Data[1]={ id:'1', label:'cart1 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };
	cart1Data[2]={ id:'2', label:'cart1 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  };
	cart1Data[3]={ id:'3', label:'cart1 Item 3', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 3', removeHTML:'Remove Item 3', viewURL: '##view3'  };
	var cart2Data=[];
	cart2Data[1]={ id:'1', label:'cart2 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };
	cart2Data[2]={ id:'2', label:'cart2 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  };
	var cart3Data=[];
	cart3Data[1]={ id:'1', label:'cart2 Item 1', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 1', removeHTML:'Remove Item 1', viewURL: '##view1' };
	cart3Data[2]={ id:'2', label:'cart2 Item 2', image: '/z/a/images/s2.gif', description: 'description', addHTML: 'Add Item 2', removeHTML:'Remove Item 2', viewURL: '##view2'  };
	
	zArrDeferredFunctions.push(function(){
		(function($, window, document, undefined){
			"use strict";
			var count=0;
			var listingCart=function(options){
				var self=this;
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
			};
			//window.listingCart=listingCart;
			var listingCartInstance=new listingCart({});
			
			var initObject={
				arrData:cart1Data,
				debug:false,
				name:"cart1",
				checkoutCallback:listingCartInstance.listingCheckout,
				changeCallback:listingCartInstance.changeCallback,
				emptyCartMessage:"You have no saved listings yet."
			};
			var a=new zCart(initObject);

			count=a.getCount();
			var initObject2={
				arrData:cart2Data,
				name:"cart2",
				emptyCartMessage:"Nothing is in your cart yet."
			};
			var a2=new zCart(initObject2); 


			count=a.getCount();
			var initObject3={
				arrData:cart3Data,
				name:"cart3",
				emptyCartMessage:"Nothing is in your cart yet.",
				checkoutCallback:function(){ alert('Checkout clicked'); },
				changeCallback:function(){ },
			};
			var a2=new zCart(initObject3); 
			/*if(zGetCookie("zcart-cart2") === ""){
				$("##addLink1").trigger("click");
			}*/
			
		})(jQuery, window, document, "undefined"); 
	});
	</script>
</cffunction>
</cfoutput>
</cfcomponent>