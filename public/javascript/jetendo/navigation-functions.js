(function($, window, document, undefined){
	"use strict"; 



var zPagination=function(options){
	var self=this;
	if(typeof options === undefined){
		options={};
	}
	options.id=zso(options, 'id');
	if(options.id == ""){
		throw("zPagination: options.id is required");
	} 
	options.count=zso(options, 'count'); 
	if(options.count === ""){
		throw("zPagination: options.count is required");
	}
	options.perpage=zso(options, 'perpage', true, 20);
	options.offset=zso(options, 'offset', true, 0);
	options.loadFunction=zso(options, 'loadFunction', false, function(){});
	if(typeof options.loadFunction != "function"){
		throw("zPagination: options.loadFunction is required and must be a function");
	}
	self.updatePerPage=function(perpage){
		options.perpage=perpage;
		render();
	};
	self.updateCount=function(count){
		options.count=count;
		render();
	};
	self.updateOffset=function(offset){
		options.offset=offset;
		render();
	};
	function render(){
		drawNavLinks(options.id, options.count, options.offset, options.perpage);
	};
	function runLoad(){
		options.loadFunction(options);
	}
	function drawNavLinks(id, count, curOffset, perPage){
		var arrR=new Array();
		var firstOffset=0;
		var linkCount=5;
		var firstLinkCount=Math.floor((linkCount-1)/2); 
		var beforeLinkCount=Math.min(firstLinkCount, options.offset/options.perpage);
		
		var pageCount=Math.min(Math.ceil(1000/perPage), Math.ceil(count/perPage));
		var lastLinkCount=(linkCount-1)-firstLinkCount;
		
		var firstOffset=curOffset-(beforeLinkCount*perPage);
		
		var arrBind=[];
		if(firstOffset!=curOffset){ 
			arrR.push('<a href="##" class="zPagination-previousLink">Previous<\/a>');	

			arrBind.push({
				"selector":".zPagination-previousLink",
				"offset":curOffset-perPage
			});
		} 
		for(var i=0;i<linkCount;i++){
			var coff=((i*perPage)+firstOffset);
			var clabel=(coff/perPage)+1;
			if(clabel <= pageCount){
				if(clabel == pageCount && coff+perPage == curOffset){
					arrR.push('<span class="search-nav-t">'+clabel+'</span>');
				}else if(coff == curOffset){
					arrR.push('<span class="search-nav-t">'+clabel+'</span>');
				}else{
					arrR.push('<a href="##" class="zPagination-link'+clabel+'">'+clabel+'</a>');	 
					arrBind.push({
						"selector":'.zPagination-link'+clabel,
						"offset": coff
					});
				}
			}
		} 
		if(pageCount >= curOffset/perPage){
			var clabel=((curOffset+perPage)/perPage)+1;
			if(clabel <= pageCount){
				arrR.push('<a href="##" class="zPagination-nextLink">Next<\/a>'); 
				
				arrBind.push({
					"selector":".zPagination-nextLink",
					"offset":curOffset+perPage
				});
			}
		}

		var r='<div style="width:100%; float:left" class="zPagination-container">'+arrR.join("")+'</div>';
		$("#"+id).html(r);
		for(var i=0;i<arrBind.length;i++){
			$(arrBind[i].selector, "#"+id).unbind("click");
			var c=arrBind[i];
			$(arrBind[i].selector, "#"+id).attr("data-offset", c.offset);
			$(arrBind[i].selector, "#"+id).bind("click", function(){ 
				var offset=parseInt($(this).attr("data-offset")); 
				options.offset=offset;
				runLoad(); 
				return false;
			});
		}
	}
	render();

}
	function closeOtherMenus(){
		$(".z-manager-quick-menu").removeClass("active");
		if(typeof zCurrentEditButton =="object"){  
			$(".z-manager-edit-menu").removeClass("active");
			$(".z-manager-row-active").removeClass("z-manager-row-active"); 
			if(typeof zCurrentEditButton != "boolean" && zMouseHitTest(zCurrentEditButton)){

				$(".z-manager-edit-menu", $(zCurrentEditButton).parent()).addClass("active");
				$(zCurrentEditButton).parent().parent().parent().addClass("z-manager-row-active");
			}else{
				zCurrentEditButton=false;
			}
		}
	}

	function zManagerBindTableEvents(){
		// has to always be run because the gear links sometimes don't exist yet.
		$(document).on("click", ".z-manager-quick-menu-links a", function(e){
			e.stopPropagation(); 
			return true;
		});
		$(document).on("click", ".z-manager-quick-menu", function(e){
			e.preventDefault();
			closeOtherMenus(); 
			setTimeout(function(){
				$(".z-manager-quick-menu").addClass("active");
			},30);
		});

		$(document).on("click", ".z-manager-edit", function(e){
			closeOtherMenus(); 
			if($(".z-manager-edit-menu", $(this).parent()).length == 0){ 
				return true;
			}
			e.preventDefault();
			var self=this; 
			setTimeout(function(){
				zCurrentEditButton=self;
			}, 30);
			$(".z-manager-edit-menu", $(this).parent()).addClass("active");
			$(this).parent().parent().parent().addClass("z-manager-row-active"); 
		});
		$(document).on("click", function(e){ 
			closeOtherMenus();
		});
		$(document).on("click", ".z-manager-delete", function(e){

		});
	}

	var zCurrentEditButton=false;
	zArrDeferredFunctions.push(function(){
		zManagerBindTableEvents();

		$(".z-manager-list-tab-button").on("click", function(e){
			e.preventDefault();
			self=this;
			var link=$(this).attr("data-click-location");
			if(link && window.location.href.indexOf("searchOn=") != -1){
				window.location.href=link;
				return;
			}
			$(".z-manager-list-tab-button").each(function(){
				$(this).removeClass("active");
				$(this).toggleClass("mobileActive");
				if(self == this){
					return;
				}
				var tab=$(this).attr("data-tab");
				if(tab != ""){
					$("."+tab).removeClass("active");
					$("."+tab).removeClass("mobileActive");
				}
			});
			var tab=$(this).attr("data-tab");
			if(tab != ""){
				$(".z-manager-tab-container").show();
				$("."+tab).addClass("active");
				$("."+tab).toggleClass("mobileActive"); 
			}
			$(this).addClass("active");
			$(this).toggleClass("mobileActive");
		});
	});


	window.zPagination=zPagination;
})(jQuery, window, document, "undefined"); 
