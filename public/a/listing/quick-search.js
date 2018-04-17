

(function($, window, document, undefined){
	"use strict";
	var searchType = ""; 
	zArrDeferredFunctions.push(function() {
		$(document).on("click", function(){
			if(zMouseHitTest($(".zls-quick-search-mode-button")[0], 0)){
				// leave it open
			}else{
				$(".zls-quick-search-list").hide();
			}
		});
		searchType=$(".zls-quick-search-link-selected").attr("data-type");
		$(".zls-quick-search-mode-button").on("click", function(e){
			$('.zls-quick-search-list').slideToggle('fast');
		});
	    $(".zls-quick-search-link").each(function () {
		    var that = this;
	        $(that).click(function (e) {
	  	        var $elem 	= $(this);
				var searchType  	= $elem.attr("data-type");
	    		$(".zls-quick-search-link").removeClass("zls-quick-search-link-selected");
				$elem.addClass("zls-quick-search-link-selected");
				$(".zls-quick-search-mode-button").html($elem.text() + "<div class=\"zls-quick-search-mode-arrow-down\"></div>");

				$(".zls-quick-search-mode-input")[0].placeholder=$elem.attr("data-placeholder"); 
				$('.zls-quick-search-list').toggle(); 
			});
		});

		$(".zls-quick-search-mode-input").on("focus", function(){
			$(".zls-quick-search-autocomplete").slideDown('fast');
			if(zWindowSize.width < 768){
				zJumpToId("zls-quick-search-mode-input", -60);
			}else{
				zJumpToId("zls-quick-search-mode-input", -30);
			}
		});
		var cancelBlur=false;
		$(".zls-quick-search-mode-input").on("blur", function(){
			setTimeout(function(){
	  			if(!cancelBlur){
					$(".zls-quick-search-autocomplete").slideUp('fast');
					cancelBlur=false;
				}
			}, 500);
		});

		$(".zls-quick-search-mode-input").on("keyup", function(e){ 
			if(e.which == 9 || e.which == 40 || e.which == 38){
				return;
			}
			if(this.value.length > 3 && searchType != ""){
				var obj={
					id:"getterDATA",
					method:"post",
					postObj:{ 
						keyword: this.value, 
						searchType:searchType
					},
					callback:function(r){ 
						var r = JSON.parse(r); 
						var arrHTML = [];
						if(r.success){ 
							var hasResults=false;
							var firstResult=true; 
							for(var i=0;i<r.arrOrder.length;i++){
								var arrData=r[r.arrOrder[i]];
								if(arrData.length==0){
									continue;
								}
								hasResults=true;
								arrHTML.push('<div class="zls-quick-search-autocomplete-heading">'+htmlEntities.encode(r.arrLabel[i])+'</div><div class="zls-quick-search-autocomplete-values">'); 
								for(var n=0;n<arrData.length;n++){
				  					arrHTML.push('<a href="#" class="zls-quick-search-autocomplete-value');
				  					if(firstResult){
				  						firstResult=false;
				  						arrHTML.push(' selected');
				  					}
				  					arrHTML.push('" data-type="'+r.arrOrder[i]+'" data-field="'+arrData[n].field+'" data-value="'+htmlEntities.encode(arrData[n].value)+'">'+htmlEntities.encode(arrData[n].label)+'</a>'); 
								}
								arrHTML.push('</div>');
							}
							if(!hasResults){
								arrHTML.push('<div class="zls-quick-search-autocomplete-heading">Nothing matches your search</div>');
							}
							$('.zls-quick-search-autocomplete').html(arrHTML.join("")).slideDown('fast');
							$(".zls-quick-search-autocomplete-value").on("click", function(){ 
								$("#z-quick-search-form").trigger("submit");
							});
							$(".zls-quick-search-autocomplete-value").on("mousedown", function(){
								cancelBlur=true;
							});
						}else{
							alert('Sorry, there was a problem with this search feature, please try again later.');
						}
					},
					errorCallback:function(xmtp){ 
						alert('Sorry, there was a problem with the autocomplete or your network, please try again later.');
					},
					url:"/z/listing/quick-search-autocomplete/autocompleteSearch"
				}; 
				zAjax(obj);
			}
		});
		$(document).on("mouseover", ".zls-quick-search-autocomplete-value", function(){
			$(".zls-quick-search-autocomplete-value").removeClass("selected");
			$(this).addClass("selected");
		}); 
		$("#z-quick-search-form").on("submit", function(e){
			e.preventDefault();

			// we search based on the selected value in the autocomplete div only.
			var $selected=$(".zls-quick-search-autocomplete-value.selected");
			var type=$selected.attr("data-type");
			var value=$selected.attr("data-value");
			var field=$selected.attr("data-field");


			/*if(searchType == ""){
			 	alert("Select a Search Category");
			 	$("zls-quick-search-query")[0].focus();
			 	return;
			}*/
			window.location.href='/z/listing/search-form/index?'+field+'='+escape(htmlEntities.decode(value))+'#zls-matchinglistingsdiv';
			$(".zls-quick-search-mode-input").trigger("blur");
		});
		$(document).on("keyup", function(e){ 
			var selectedOffset=0;
			var offset=0;
			$(".zls-quick-search-autocomplete-value").each(function(){
				if($(this).hasClass("selected")){
					selectedOffset=offset;
				}
				offset++;
			});
			$(".zls-quick-search-autocomplete-value").removeClass("selected");

			if(e.which == 9){
				$(".zls-quick-search-list").hide();
			}else if(e.which == 40){ // down arrow
				var newOffset=selectedOffset+1;
				if(newOffset == offset){
					newOffset=0;
				}
			}else if(e.which == 38){ // up arrow
				var newOffset=selectedOffset-1;
				if(newOffset == -1){
					newOffset=offset-1;
				}
			}
			offset=0;
			$(".zls-quick-search-autocomplete-value").each(function(){
				if(offset == newOffset){
					$(this).addClass("selected");
				}
				offset++;
			});
		});
	});  


})(jQuery, window, document, "undefined");
