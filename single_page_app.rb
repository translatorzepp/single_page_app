# require autoloader, for gems, configuration, and constants
require "./autoloader_braintree_config.rb"
 
class SinglePageApp < Sinatra::Base

    get '/' do

        # Generate client token, make it accessible to view
        @client_token = Braintree::ClientToken.generate()

        # Display checkout page
        erb :single_page_checkout

    end

    post '/create_transaction' do

        # Match currency code to appropriate merchant account
        case params[:currency]
        when "CAD"
            merchant_account_id = MERCHANT_ACCOUNT_ID_CAD
        when "EUR"
            merchant_account_id = MERCHANT_ACCOUNT_ID_EUR
        when "GBP"
            merchant_account_id = MERCHANT_ACCOUNT_ID_GBP
        else
            # TO DO: add error handling
            merchant_account_id = MERCHANT_ACCOUNT_ID_USD
        end

        puts MERCHANT_ID

        # Create sale 
        result = Braintree::Transaction.sale(
          :amount => params[:amount],
          # :merchant_account_id => merchant_account_id,
          :payment_method_nonce => params[:noncense],
          # :device_data => params[:device_data],
          # :options => {
            # :submit_for_settlement => true
          # },
        )

        # Check for success of sale; set text for display on result page
        # Variables will be printed out as follows:
        # @successful @message
        # @link
        if result.success?
        # Transaction created successfully
            @successful = "Success!"
            @link = 'https://sandbox.braintreegateway.com/merchants/' + MERCHANT_ID + '/transactions/' + result.transaction.id
            @message = "Transaction created."
        else
            @successful = "Failure!"
            if result.transaction
                # Transaction created unsuccessfully
                @link = 'https://sandbox.braintreegateway.com/merchants/' + MERCHANT_ID + '/transactions/' + result.transaction.id
                if result.transaction.status === Braintree::Transaction::Status::ProcessorDeclined
                    # BIN lookup to identify bank and point customer to call
                    @message = result.message + " Try again later."
                elsif result.transaction.status === Braintree::Transaction::Status::GatewayRejected
                    @message = result.message + " Check your payment information and try again."
                end
            else
                # Transaction not created; validation error
                @link = 'https://developers.braintreepayments.com'
                @message = result.message + " Send this to the webmaster:"
            end
        end

        # Display results page
        erb :single_page_result

    end

end

SinglePageApp.run!