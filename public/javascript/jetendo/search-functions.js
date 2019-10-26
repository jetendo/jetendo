
(function($, window, document, undefined){
	"use strict";

	var searchCriteriaTrackSubGroup=[];

	function clickSearchCriteriaSubGroup(obj){
		var groupId=parseInt(obj.target.getAttribute("data-group-id"));
		$(".zSearchCriteriaSubGroup").each(function(){
			var currentGroupId=parseInt(this.getAttribute("data-group-id"));
			if(typeof searchCriteriaTrackSubGroup[currentGroupId] === "undefined"){
				searchCriteriaTrackSubGroup[currentGroupId]={};
				if(document.getElementById("zSearchCriteriaSubGroupContainer"+currentGroupId).style.display=== "block"){
					searchCriteriaTrackSubGroup[currentGroupId].open=true;
				}else{
					searchCriteriaTrackSubGroup[currentGroupId].open=false;
				}
			}
			if(currentGroupId === groupId){
				if(currentGroupId !== groupId || searchCriteriaTrackSubGroup[currentGroupId].open){
					// close the group.
					$("#zSearchCriteriaSubGroupContainer"+currentGroupId).slideUp("fast");
					searchCriteriaTrackSubGroup[currentGroupId].open=false;
					$("#zSearchCriteriaSubGroupToggle"+currentGroupId).html("+");
				}else{
					$("#zSearchCriteriaSubGroupContainer"+currentGroupId).slideDown("fast");
					searchCriteriaTrackSubGroup[currentGroupId].open=true;
					$("#zSearchCriteriaSubGroupToggle"+currentGroupId).html("-");
				}
			}
		});
		return false;
	}
	var searchResultsTimeoutID=0;
	var searchCriteriaTimeoutID=0;
	var searchDisableJump=false;
	function ajaxSearchResultsCallback(r){
		clearTimeout(searchResultsTimeoutID);
		var searchForm=$("#zSearchResultsDiv");
		searchForm.fadeIn('fast');
		// uncomment next line to debug easier
		//searchForm.html(r);return;
		var r2=eval('(' + r + ')');
		if(r2.success){ 
			searchForm.html(r2.html);
		}else{
			searchForm.html(r2.errorMessage);
		}
		if(!searchDisableJump){
			zJumpToId("zSearchTitleDiv", -20);
		}
		searchDisableJump=false;
	}
	var delayedSearchResultsTimeoutId=0;
	function getDelayedSearchResults(){
		$("#zSearchTrackerzIndex").val(1);
		clearTimeout(delayedSearchResultsTimeoutId);
		searchDisableJump=true;
		delayedSearchResultsTimeoutId=setTimeout(getSearchResults, 500);
	}
	function getSearchResults(groupId, zIndex){
		if(typeof groupId === "undefined"){
			groupId=$("#zSearchTrackerGroupId").val();
		}
		if(typeof zIndex=== "undefined"){
			zIndex=$("#zSearchTrackerzIndex").val();
		}
		var tempObj={};
		$("#zSearchTrackerGroupId").val(groupId);
		$("#zSearchTrackerzIndex").val(zIndex);
		tempObj.id="ajaxGetSearchResults";
		tempObj.postObj=zGetFormDataByFormId("searchForm"+groupId);
		tempObj.postObj.groupId=groupId;
		tempObj.postObj.zIndex=zIndex;
		tempObj.postObj.disableSidebar=$("#zSearchFormDiv").attr("data-disable-sidebar");
		
		searchResultsTimeoutID=setTimeout(function(){
			$("#zSearchResultsDiv").html("One moment while we load your search results.");
		}, 500);
		if(groupId === 0){
			if($("#zSearchTextInput").length){
				tempObj.postObj.searchtext=$("#zSearchTextInput").val();
			}
		}else{
			
		}
		tempObj.method="post";
		tempObj.url="/z/misc/search-site/ajaxGetPublicSearchResults";
		
		tempObj.cache=false;
		tempObj.callback=ajaxSearchResultsCallback;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);
		if(document.getElementById('contenttop')){
			window.location.href='#contenttop';
		}else{
			var d=$('h1').first();
			if(d.length){
				if(d[0].id===""){
					d[0].id="zHeadingSearchTopLinkId";
				}
				window.location.href='#'+d[0].id;
			}else{
				window.scrollTo(0, 0);
			}
		}
	}
	function zSearchCriteriaSetupSubGroupButtons(){
			$(".zSearchCriteriaSubGroup").bind("click", clickSearchCriteriaSubGroup);
			$(".zSearchCriteriaSubGroupToggle").bind("click", clickSearchCriteriaSubGroup);
			$(".zSearchCriteriaSubGroupLabel").bind("click", clickSearchCriteriaSubGroup);
		
	}
	function ajaxSearchCriteriaCallback(r){
		clearTimeout(searchCriteriaTimeoutID);
		var r2=eval('(' + r + ')');
		var searchForm=$("#zSearchFormDiv");
		var searchTitle=$("#zSearchTitleDiv");
		if(r2.success){ 
			searchTitle.html(r2.title);
			searchForm.html(r2.html);
			zSearchCriteriaSetupSubGroupButtons();
			if(r2.groupId === "0"){
				if($("#zSearchTextInput").val() === ""){
					return;
				}
			}
			getSearchResults(r2.groupId, r2.zIndex);
		}else{
			searchForm.html(r2.errorMessage);
		}
	}
	function getSearchCriteria(groupId, clearCache){
		if(typeof clearCache === "undefined"){
			clearCache=false;
		}
		$("#zSearchTrackerzIndex").val(1);
		$("#zSearchTabDiv a").each(function(){
			var currentGroupId=parseInt(this.getAttribute("data-groupId"));
			
			if(groupId===currentGroupId){
				$(this).addClass("zSearchTabDivSelected");
			}else{
				$(this).removeClass("zSearchTabDivSelected");
			}
		});
		if(typeof disableSearchLoadMessage == "undefined"){
			searchCriteriaTimeoutID=setTimeout(function(){
				$("#zSearchFormDiv").html("One moment while we load the search form.");
			}, 500);
		}
		
		var tempObj={};
		tempObj.id="ajaxGetSearchCriteria";
		tempObj.url="/z/misc/search-site/ajaxGetPublicSearchCriteria?groupId="+encodeURIComponent(groupId)+"&clearCache="+encodeURIComponent(clearCache);
		if(groupId==0){
			tempObj.url+="&searchtext="+encodeURIComponent(zGetURLParameter("searchtext"));
		}
		
		tempObj.cache=false;
		tempObj.callback=ajaxSearchCriteriaCallback;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);
	}
	function reloadResultsIfBackDetected(){
		var zSearchGroupId=$("#zSearchTrackerGroupId").val();
		if(zSearchGroupId!==""){
			getSearchCriteria(zSearchGroupId);
		}
	}
	window.getSearchCriteria=getSearchCriteria;
	window.getSearchResults=getSearchResults;
	window.getDelayedSearchResults=getDelayedSearchResults;
	window.zSearchCriteriaSetupSubGroupButtons=zSearchCriteriaSetupSubGroupButtons;
	window.reloadResultsIfBackDetected=reloadResultsIfBackDetected;
})(jQuery, window, document, "undefined"); 