

(function($, window, document, undefined){
	"use strict";
	var searchType = ""; 
	zArrDeferredFunctions.push(function() {
		var popHTML=$("#zls-quick-search-html-pop").html();
		$("body").append(popHTML);

		$(document).on("click", function(){
			if(zMouseHitTest($(".zls-quick-search-mode-button")[0], 0)){
				// leave it open
			}else{
				$(".zls-quick-search-list").hide();
			}
		});
		searchType=$(".zls-quick-search-link-selected").attr("data-type");
		$(".zls-quick-search-mode-button").on("click", function(e){
			// zls-quick-search-mode-button
			var p=zGetAbsPosition(this);
			$('.zls-quick-search-list').css({
				"top":(p.y+p.height)+"px",
				"left":(p.x)+"px"
			});
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
		function resizeQuickSearch(){
			$(".zls-quick-search-mode-button").each(function(){
				var p=zGetAbsPosition(this);
				$('.zls-quick-search-list').css({
					"top":(p.y+p.height)+"px",
					"left":(p.x)+"px"
				});
			});
			$(".zls-quick-search-mode-input").each(function(){
				var p=zGetAbsPosition(this);
				$('.zls-quick-search-autocomplete-container').css({
					"top":(p.y+p.height)+"px",
					"left":(p.x)+"px"
				});
			});
		}
		function scrollQuickSearch(){
			resizeQuickSearch();
			setTimeout(function(){ resizeQuickSearch(); }, 100);
		}
	    zArrScrollFunctions.push({functionName:resizeQuickSearch});
	    zArrResizeFunctions.push({functionName:scrollQuickSearch});
		$(".zls-quick-search-mode-input").on("focus", function(){
			$('.zls-quick-search-list').hide();
			var p=zGetAbsPosition(this);
			$('.zls-quick-search-autocomplete-container').css({
				"top":(p.y+p.height)+"px",
				"left":(p.x)+"px"
			});
			// console.log("y:"+p.y, "height:"+p.height, this, $('.zls-quick-search-autocomplete-container')[0]);

			$(".zls-quick-search-autocomplete").slideDown('fast');
 
			var j=JSON.parse($(this).attr("data-negative-offset")); 
			if(zWindowSize.width <= 479){
				zJumpToId("zls-quick-search-mode-input", j.bp479);
			}else if(zWindowSize.width <= 767){
				zJumpToId("zls-quick-search-mode-input", j.bp767);
			}else if(zWindowSize.width <= 992){
				console.log(j.bp992);
				zJumpToId("zls-quick-search-mode-input", j.bp992);
			// }else if(zWindowSize.width <= 1362){
			// 	zJumpToId("zls-quick-search-mode-input", j.bp1362);
			// }else{
			// 	zJumpToId("zls-quick-search-mode-input", j.default);
			}
		});
		var cancelBlur=false;
		// $(".zls-quick-search-mode-input").on("blur", function(){
		// 	setTimeout(function(){
	 //  			if(!cancelBlur){
		// 			$(".zls-quick-search-autocomplete").slideUp('fast');
		// 			cancelBlur=false;
		// 		}
		// 	}, 500);
		// });

		// remove after debugging placement
		// $(".zls-quick-search-mode-input").val("DAYTONA");
		// setTimeout(function(){
		// 	$(".zls-quick-search-mode-input").trigger("focus");
		// 	$(".zls-quick-search-mode-input").trigger("keyup");
		// }, 1000);

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

			console.log("submitted: "+$selected.val()+":"+type+":"+value+":"+field);

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
