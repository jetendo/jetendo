<cfcomponent>
<cffunction name="getVersion" localmode="modern" access="public">
	<cfscript>
	// increment manually when database schema changes or source release version changes
	return {
		databaseVersion: 401, // change to match the highest database-upgrade script created so far
		sourceVersion: "0.1.009", // change when releasing open source version
		javascriptVersion: "2" // increment when changing jetendo-init or other non-versioned files
	};
	</cfscript>
</cffunction>
</cfcomponent>
