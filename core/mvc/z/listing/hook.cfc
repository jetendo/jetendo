<cfcomponent>
    <cffunction name="registerHooks" localmode="modern" output="no" access="public">
    	<cfargument name="hookCom" type="zcorerootmapping.com.zos.hook" required="yes">
    	<cfscript>
		arguments.hookCom.add("listing", "blog.articleEditCustomFields", {object=this, functionName="onEditCustomFields", dataStruct={mlsSavedSearchIdField="mls_saved_search_id", fieldName="blog_search_mls"}});
		arguments.hookCom.add("listing", "blog.tagEditCustomFields", {object=this, functionName="onEditCustomFields", dataStruct={mlsSavedSearchIdField="blog_tag_saved_search_id", fieldName="blog_tag_search_mls"}});
		arguments.hookCom.add("listing", "blog.categoryEditCustomFields", {object=this, functionName="onEditCustomFields", dataStruct={mlsSavedSearchIdField="blog_category_saved_search_id", fieldName="blog_category_search_mls"}});
		/*
		blog.articleSave
		blog.articleSaveComplete
		blog.articleDelete
		blog.categorySave
		blog.categorySaveComplete
		blog.categoryDelete
		blog.tagSave
		blog.tagSaveComplete
		blog.tagDelete
		*/
		</cfscript>
    </cffunction>
    
    
    <cffunction name="onEditCustomFields" localmode="modern" output="yes" returntype="any">
    	<cfargument name="query" type="query" required="yes">
    	<cfargument name="dataStruct" type="struct" required="yes">
        <table class="table-list" style="width:100%; border-spacing:0px;">
		<tr> 
		<td style="vertical-align:top; "><strong>MLS Search Options</strong><br />
		<cfscript>
		if(arguments.query.recordcount EQ 0){
        	request.zos.listing.functions.zMLSSearchOptions("", arguments.dataStruct.fieldName, "");
		}else{
        	request.zos.listing.functions.zMLSSearchOptions(arguments.query[arguments.dataStruct.mlsSavedSearchIdField], arguments.dataStruct.fieldName, arguments.query[arguments.dataStruct.fieldName]);
        }
        </cfscript>
		</td>
		</tr>
        </table>
    </cffunction>
</cfcomponent>