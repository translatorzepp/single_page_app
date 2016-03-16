A single-page checkout app, using [Braintree]("https://developers.braintreepayments.com"). Implements Hosted Fields, PayPal Checkout flow, 3D Secure, device data, teardown, and the transaction API.

<h4>Before using:</h4>

+ Verify that all files are present and in the following directory structure:
```
autoloader_braintree_config.rb
single_page_app.rb
views
	single_page_checkout.erb
	single_page_result.erb
```
+ Make sure rubygems, braintree, and sinatra are installed and up-to-date
 + This app was created with braintree v. 2.56.0-2.58.0, but should run with most recent versions of the gem. Minimum version: 2.43.0
 + See [developers.braintreepayments.com/start/hello-server/ruby]("developers.braintreepayments.com/start/hello-server/ruby") for Braintree's requirements for Ruby version, etc


<h4>To use:</h4>

Run single_page_app.rb from the command line with

`shotgun single_page_app.rb`

If you're using the modular branch, you can also use

`ruby single_page_app.rb` or `sinatra single_page_app.rb`

Then visit the appropriate localhost address to create a transaction. Choose an amount and a currency, fill in credit card information or click the PayPal button to use PayPal, verify 3D Secure information if prompted, confirm payment, and observe the results.

<h4>Breakdown of flow by files:</h4>

*autoloader_braintree_config*:
+ requires the necessary gems: rubygems, braintree, and sinatra for running the app  
+ implements Braintree::Configuration to set the API keys
+ sets constants for use throughout the app: merchant ID, merchant account IDs

*single_page_app*:
+ on loading, generates client token
+ presents checkout page

*single_page_checkout*:
+ contains two forms:
+ collector (`id="choose-your-own-adventure"`): used to get the amount and currency, which are then used in the call to initialize braintree
 + with jquery, the following is attached to the collector form's submit button:
   + disable inputs in the collector form so no changes can be made
	 + adds the values from the amount and currency inputs in the collector form to the second form
	 + runs braintree.setup
	 + prevents the form from submitting
+ hosted fields (`id="hosted-checkout"`): contains hosted fields divs, hidden fields for a nonce, device data, amount, and currency
 + is hidden when page loads
 + braintree.setup: implements Hosted Fields and PayPal Checkout flow with `onSuccess` and `onCancelled`, and the global callbacks `onError`, `onReady` (which shows )
		onError
		onReady
			shows the HF form
		onPaymentMethodReceived
			if payment method is credit card, runs 3DS verification
			adds nonce to existing hidden input in form
			submits hosted fields form

*single_page_app*:
 + on submission of hosted fields form, creates a transaction with the appropriate parameters, checks for success, grabs information about the success/failure/resulting transaction
 + presents result page

*single_page_result*:
+ displays information about the successful or failed transaction
+ allows you to go back and start over
