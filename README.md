README


Single page checkout app
implementing Hosted Fields, PayPal Checkout flow, 3D Secure, device data, teardown


Before using:

verify that all files are present and in the following directory structure:
	auto.rb
	single_page_app.rb
	views ->
		single_page_checkout.erb
		single_page_result.erb
if not installed, make sure rubygems, braintree, sinatra are installed and up-to-date
	this app was created with braintree v 2.56.0-2.58.0, but should run with most recent versions of the gem (must be above 2.43.0)
	see developers.braintreepayments.com/start/hello-server/ruby for Braintree's requirements for Ruby version, etc
run single_page_app.rb from the command line with
	ruby single_page_app.rb
	or
	shotgun single_page_app.rb
if you're on the shotgun branch, make sure to use the latter


To use:

choose an amount and a currency, fill in credit card information or click the PayPal button to log in to PayPal, verify 3D Secure information if prompted, confirm payment, observe results.


Breakdown of flow by files:

autoloader:
	requires the necessary gems: rubygems, braintree, and sinatra for running the app
	implements Braintree::Configuration to set the API keys
	sets constants for use throughout the app: merchant ID, merchant account IDs

on loading: app generates client token, presents checkout page

checkout page:
	contains two forms
		collector (id="choose-your-own-adventure"): used to get the amount and currency, which are then used in the call to initialize braintree
		with jquery, the following is attached to the collector form's submit button:
			disable inputs in the collector form so no changes can be made
			adds the values from the amount and currency inputs in the collector form to the second form
			runs braintree.setup
			prevents the form from submitting
		hosted fields (id="hosted-checkout"): contains hosted fields divs, hidden fields for a nonce, device data, amount, and currency
			is hidden when page loads
	braintree.setup: includes
		PayPal, checkout flow, implementing onSuccess and onCancelled
		onError
		onReady
			shows the HF form
		onPaymentMethodReceived
			if payment method is credit card, runs 3DS verification
			adds nonce to existing hidden input in form
			submits hosted fields form

on submission of hosted fields form: app creates a transaction with the appropriate parameters, checks for success, grabs information about the success/failure/resulting transaction, displays result page

result page:
	displays information about the successful or failed transaction
	allows you to go back and start over