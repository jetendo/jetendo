<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="stripeConfig" type="struct" required="yes">
	<cfscript>
		stripeConfig = arguments.stripeConfig;

		variables.apiEndpoint = 'https://api.stripe.com/v1';

		variables.environment = this.determineEnvironment();

		if ( this.inProduction() ) {
			variables.secretKey = stripeConfig.liveSecretKey;
			variables.publicKey = stripeConfig.livePublicKey;
		} else {
			variables.secretKey = stripeConfig.testSecretKey;
			variables.publicKey = stripeConfig.testPublicKey;
		}
	</cfscript>
</cffunction>

<!--- CHECKOUT FORM --->
<cffunction name="checkoutForm" localmode="modern" access="public">
	<cfargument name="checkoutForm" type="struct" required="yes">
	<!--- <form action="/z/ecommerce/stripe-checkout/process" method="post"> --->
	<form action="/stripe-test/process" method="post">
		<script src="https://checkout.stripe.com/checkout.js"
			class="stripe-button"
			data-key="#variables.publicKey#"
			data-amount="#htmlEditFormat( arguments.checkoutForm.amount )#"
			data-name="#htmlEditFormat( arguments.checkoutForm.name )#"
			data-description="#htmlEditFormat( arguments.checkoutForm.description )#"
		<cfif structKeyExists( arguments.checkoutForm, 'image' ) AND arguments.checkoutForm.image NEQ "">
			data-image="#htmlEditFormat( arguments.checkoutForm.image )#"
		</cfif>
			data-locale="auto">
		</script>
	</form>
</cffunction>

<!--- CUSTOMERS --->
<!--- https://stripe.com/docs/api/curl#customers --->

<cffunction name="createCustomer" localmode="modern" access="public">
	<cfargument name="customer" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/customers', arguments.customer );
	</cfscript>
</cffunction>

<cffunction name="getCustomer" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId, {}, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="updateCustomer" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="customer" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId, arguments.customer );
	</cfscript>
</cffunction>

<cffunction name="deleteCustomer" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId, {}, 'DELETE' );
	</cfscript>
</cffunction>

<cffunction name="getAllCustomers" localmode="modern" access="public">
	<cfargument name="limit" type="numeric" required="no" default="10">
	<cfargument name="customers" type="struct" required="no" default="#{}#">
	<cfscript>
		return this.sendRequest( '/customers?limit=' & arguments.limit, arguments.customers, 'GET' );
	</cfscript>
</cffunction>

<!--- CARDS --->
<!--- https://stripe.com/docs/api/curl#cards --->

<cffunction name="createCard" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="card" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId & '/sources', arguments.card );
	</cfscript>
</cffunction>

<cffunction name="getCard" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="cardId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId & '/sources/' & arguments.cardId, {}, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="updateCard" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="cardId" type="string" required="yes">
	<cfargument name="card" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId & '/sources/' & arguments.cardId, arguments.card );
	</cfscript>
</cffunction>

<cffunction name="deleteCard" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="cardId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId & '/sources/' & arguments.cardId, {}, 'DELETE' );
	</cfscript>
</cffunction>

<cffunction name="listAllCards" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="cards" type="struct" required="no" default="#{}#">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId & '/sources?object=card', arguments.cards, 'GET' );
	</cfscript>
</cffunction>

<!--- CHARGES --->
<!--- https://stripe.com/docs/api/curl#charges --->

<cffunction name="createCharge" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="cardId" type="string" required="yes">
	<cfargument name="amount" type="numeric" required="yes">
	<cfargument name="charge" type="struct" required="yes">
	<cfscript>
		customerId = arguments.customerId;
		cardId     = arguments.cardId;
		amount     = arguments.amount;
		charge     = arguments.charge;

		// The charge amount must be a positive integer and include the cents.
		// To charge $10.00 you would put in '1000' as the amount.
		// @see https://stripe.com/docs/api/curl#create_charge-amount
		amount = replace( amount, '.', '', 'all' );
		amount = replace( amount, ',', '', 'all' );
		amount = replace( amount, '$', '', 'all' );

		charge.amount   = amount;
		charge.currency = 'USD';
		charge.customer = customerId;
		charge.source   = cardId;

		return this.sendRequest( '/charges', charge );
	</cfscript>
</cffunction>

<cffunction name="getCharge" localmode="modern" access="public">
	<cfargument name="chargeId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/charges/' & arguments.chargeId, {}, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="updateCharge" localmode="modern" access="public">
	<cfargument name="chargeId" type="string" required="yes">
	<cfargument name="charge" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/charges/' & arguments.chargeId, arguments.charge );
	</cfscript>
</cffunction>

<cffunction name="captureCharge" localmode="modern" access="public">
	<cfargument name="chargeId" type="string" required="yes">
	<cfargument name="charge" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/charges/' & arguments.chargeId & '/capture', charge );
	</cfscript>
</cffunction>

<cffunction name="listAllCharges" localmode="modern" access="public">
	<cfargument name="limit" type="numeric" required="no" default="10">
	<cfargument name="charges" type="struct" required="no" default="#{}#">
	<cfscript>
		return this.sendRequest( '/charges?limit=' & arguments.limit, arguments.charges );
	</cfscript>
</cffunction>

<!--- SUBSCRIPTION PLANS --->
<!--- https://stripe.com/docs/api/curl#plans --->

<cffunction name="createSubscriptionPlan" localmode="modern" access="public">
	<cfargument name="subscriptionPlanId" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="amount" type="string" required="yes">
	<cfargument name="interval" type="string" required="yes">
	<cfargument name="subscriptionPlan" type="struct" required="no" default="#{}#">
	<cfscript>
		subscriptionPlanId = arguments.subscriptionPlanId;
		name               = arguments.name;
		amount             = arguments.amount;
		interval           = arguments.interval;
		subscriptionPlan   = arguments.subscriptionPlan;

		subscriptionPlan.id       = subscriptionPlanId;
		subscriptionPlan.amount   = amount;
		subscriptionPlan.currency = 'USD';
		subscriptionPlan.interval = interval;
		subscriptionPlan.name     = name;

		return this.sendRequest( '/plans', arguments.subscriptionPlan );
	</cfscript>
</cffunction>

<cffunction name="getSubscriptionPlan" localmode="modern" access="public">
	<cfargument name="subscriptionPlanId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/plans/' & arguments.subscriptionPlanId, {}, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="updateSubscriptionPlan" localmode="modern" access="public">
	<cfargument name="subscriptionPlanId" type="string" required="yes">
	<cfargument name="subscriptionPlan" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/plans/' & arguments.subscriptionPlanId, arguments.subscriptionPlan );
	</cfscript>
</cffunction>

<cffunction name="deleteSubscriptionPlan" localmode="modern" access="public">
	<cfargument name="subscriptionPlanId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/plans/' & arguments.subscriptionPlanId, {}, 'DELETE' );
	</cfscript>
</cffunction>

<cffunction name="listAllSubscriptionPlans" localmode="modern" access="public">
	<cfargument name="limit" type="numeric" required="no" default="10">
	<cfargument name="subscriptionPlans" type="struct" required="no" default="#{}#">
	<cfscript>
		return this.sendRequest( '/plans?limit=' & arguments.limit, arguments.subscriptionPlans, 'GET' );
	</cfscript>
</cffunction>

<!--- SUBSCRIPTIONS --->
<!--- https://stripe.com/docs/api/curl#subscriptions --->

<cffunction name="createSubscription" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="subscriptionPlanId" type="string" required="yes">
	<cfargument name="subscription" type="struct" required="no" default="#{}#">
	<cfscript>
		customerId         = arguments.customerId;
		subscriptionPlanId = arguments.subscriptionPlanId;
		subscription       = arguments.subscription;

		subscription.customer = customerId;
		subscription.plan     = subscriptionPlanId;

		return this.sendRequest( '/subscriptions', subscription );
	</cfscript>
</cffunction>

<cffunction name="getSubscription" localmode="modern" access="public">
	<cfargument name="subscriptionId" type="string" required="yes">
	<cfscript>
		return this.sendRequest( '/subscriptions/' & arguments.subscriptionId, {}, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="updateSubscription" localmode="modern" access="public">
	<cfargument name="subscriptionId" type="string" required="yes">
	<cfargument name="subscription" type="struct" required="yes">
	<cfscript>
		return this.sendRequest( '/subscriptions/' & arguments.subscriptionId, arguments.subscription );
	</cfscript>
</cffunction>

<cffunction name="cancelSubscription" localmode="modern" access="public">
	<cfargument name="customerId" type="string" required="yes">
	<cfargument name="subscriptionId" type="string" required="yes">
	<cfargument name="subscriptionStruct" type="struct" required="no" default="#{}#">
	<cfscript>
		return this.sendRequest( '/customers/' & arguments.customerId & '/subscriptions/' & arguments.subscriptionId, arguments.subscriptionStruct, 'DELETE' );
	</cfscript>
</cffunction>

<cffunction name="listAllSubscriptions" localmode="modern" access="public">
	<cfargument name="limit" type="numeric" required="no" default="10">
	<cfargument name="subscriptions" type="struct" required="no" default="#{}#">
	<cfscript>
		return this.sendRequest( '/subscriptions?limit=' & arguments.limit, arguments.subscriptions, 'GET' );
	</cfscript>
</cffunction>

<!--- EVENT WEBHOOK --->

<cffunction name="webhook" localmode="modern" access="remote">
	<cfscript>

	</cfscript>
</cffunction>

<!--- API REQUEST & HELPERS --->

<cffunction name="sendRequest" localmode="modern" access="public">
	<cfargument name="requestURL" type="string" required="yes">
	<cfargument name="params" type="struct" required="no" default="#{}#">
	<cfargument name="method" type="string" required="no" default="POST">
	<cfargument name="timeout" type="numeric" required="no" default="10">
	<cfscript>
		requestURL = arguments.requestURL;
		params     = arguments.params;
		method     = arguments.method;
		timeout    = arguments.timeout;

		requestURL = variables.apiEndpoint & requestURL;

		try {
			cfhttp( method=method, charset="utf-8", url=requestURL, username=variables.secretKey, password="", result="result" ) {
				if ( isStruct( params ) AND NOT structIsEmpty( params ) ) {
					for ( param in params ) {
						if ( isStruct( params[ param ] ) ) {
							for ( subparam in params[ param ] ) {
								if ( method EQ 'GET' ) {
									cfhttpparam( name=param & '[' & subparam & ']', type="url", value=params[ param ][ subparam ] );
								} else {
									cfhttpparam( name=param & '[' & subparam & ']', type="formfield", value=params[ param ][ subparam ] );
								}
							}
						} else {
							if ( method EQ 'GET' ) {
								cfhttpparam( name=param, type="url", value=params[ param ] );
							} else {
								cfhttpparam( name=param, type="formfield", value=params[ param ] );
							}
						}
					}
				}
			}
		} catch ( Any e ) {
			savecontent variable="out" {
				writeDump( arguments );
				writeDump( e );
			}
			throw( 'Stripe error:<br /><br />' & out );
		}

		if ( result.status_code NEQ 200 ) {
			savecontent variable="out" {
				writeDump( arguments );
				writeDump( result );
			}
			throw( 'Stripe error: ' & this.translateStatusCode( result.status_code ) & '<br /><br />Response:' & htmlEditFormat( result.filecontent ) & '<br /><br />' & out );
		}

		response = this.getResponse( result );

		return response;
	</cfscript>
</cffunction>

<cffunction name="getResponse" localmode="modern" access="private">
	<cfargument name="result" type="struct" required="yes">
	<cfscript>
		return deserializeJSON( arguments.result.filecontent );
	</cfscript>
</cffunction>

<cffunction name="determineEnvironment" localmode="modern" access="private">
	<cfscript>
		var environment = 'development';

		if ( request.zos.isTestServer ) {
			environment = 'development';
		} else {
			environment = 'production';
		}

		if ( structKeyExists( form, 'debug' ) ) {
			environment = 'development';
		}

		return environment;
	</cfscript>
</cffunction>

<cffunction name="inDevelopment" localmode="modern" access="public">
	<cfscript>
		if ( variables.environment EQ 'development' ) {
			return true;
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="inProduction" localmode="modern" access="public">
	<cfscript>
		if ( variables.environment EQ 'production' ) {
			return true;
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="translateStatusCode" localmode="modern" access="public">
	<cfargument name="statusCode" type="string" required="yes">
	<cfscript>
		statusCode = arguments.statusCode;

		switch ( statusCode ) {
			case '200':
				return 'OK';
			break;
			case '400':
				return 'The request was not accepted. Check for required parameters that may be missing.';
			break;
			case '401':
				return 'Unauthorized. API key appears to be invalid.';
			break;
			case '402':
				return 'Request failed.';
			break;
			case '404':
				return 'The requested resource was not found.';
			break;
			case '409':
				return 'The request conflicts with another request (perhaps due to using the same idempotent key).';
			break;
			case '429':
				return 'Too many requests.';
			break;
			case '500':
			case '502':
			case '503':
			case '504':
				return 'Something went wrong on Stripe''s end';
			break;
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
