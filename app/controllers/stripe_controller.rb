class StripeController < ApplicationController
	skip_before_action :set_account!
  skip_before_action :authenticate_user!
  protect_from_forgery except: [:webhook]


	before_action :set_stripe_key


  def webhook
    endpoint_secret = Rails.application.credentials.send(Rails.env)[:stripe][:signing_secret]
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    data = event['data']
    # Handle the event
    case event.type
      when 'checkout.session.completed'
        #when customer signs up - catch subscription_id and customer_id
        # data = event['data']
        # data_object = data['object']
        checkout_session = event.data.object
        customer_id = checkout_session.customer
        customer_email = checkout_session.customer_email
        subscription_id = checkout_session.subscription

        # customer = Stripe::Customer.retrieve({id: customer_id, expand: ['subscriptions']})
        @account = Account.find_by(billing_email: customer_email)
        # @account.update(stripe_customer_id: customer_id, stripe_subscription_id: subscription_id)

      when 'invoice.payment_action_required'
        puts "Invoice Payment Action Required"
        puts data
        # send_email(event)
        # sputs 

      when 'invoice.paid'
        puts "Invoice Paid"
        puts data
        # send_email(event)

      when 'invoice.payment_failed'
        puts "Invoice Payment Failed"
        puts data
    end






    rescue JSON::ParserError => e
      puts e
      # Invalid payload
      # StripeMailer.with(event: event, error: e).stripe_error.deliver_now
      render json: {error: e}, status: 400
      # return
      
    rescue Stripe::SignatureVerificationError => e
      puts e
    #   # Invalid signature
    #   StripeMailer.with(event: event, error: e).stripe_error.deliver_now
      render json: {error: e}, status: 400
    #   return


    rescue => e
      puts e
      # StripeMailer.with(error: e, event: event).stripe_error.deliver_now
  end

  def create_checkout_session
    @account = Account.find(params[:account_id])

	  # See https://stripe.com/docs/api/checkout/sessions/create
	  # for additional parameters to pass.
	  # {CHECKOUT_SESSION_ID} is a string literal; do not change it!
	  # the actual Session ID is returned in the query parameter when your customer
	  # is redirected to the success page.
    session = Stripe::Checkout::Session.create(
      success_url: account_root_url(@account, session_id: '{CHECKOUT_SESSION_ID}'),
      cancel_url: 'https://www.yourcancelurl.com/',
      payment_method_types: ['card'],
      mode: 'subscription',
      customer_email: @account.billing_email,
      line_items: [{
        quantity: @account.members.size,
        price: params[:price_id],
      }],
      subscription_data: {
        trial_period_days: 14,
      }
    )

    puts session.id

 		render json: {sessionId: session.id}

	  rescue => e
	    render json: {status: 400, error: { message: e.message } }
  end

  def create_customer_portal_session
    @account = Account.find(params[:account_id])

    portal = Stripe::BillingPortal::Session.create({
      customer: @account.stripe_customer_id,
      return_url: account_billing_url(@account)
    })

    redirect_to portal.url
  end

  def create_subscription
    @account = Account.find(params[:account_id])

    metered_price_id = Rails.application.credentials.send(Rails.env)[:stripe][:metered_price_id]

    if @account.stripe_customer_id.nil?
      customer = Stripe::Customer.create(email: params[:email])
      customer_id = customer.id
      @account.update!(stripe_customer_id: customer_id, billing_email: params[:email])
    else
      customer_id = @account.stripe_customer_id
    end

    Stripe::PaymentMethod.attach(
      params[:paymentMethodId],
      { customer: customer_id }
    )

    # Set the default payment method on the customer
    Stripe::Customer.update(
      customer_id,
      invoice_settings: { default_payment_method: params[:paymentMethodId] }
    )

    # Create the subscription
    if @account.stripe_subscription_id.nil?
      subscription =
        Stripe::Subscription.create(
          customer: customer_id,
          trial_period_days: 14,
          items: [{ price: metered_price_id }],
          expand: %w[latest_invoice.payment_intent pending_setup_intent]
        )
        @account.update!(stripe_subscription_id: subscription.id)
    else
      subscription = Stripe::Subscription.retrieve(@account.stripe_subscription_id)
    end

    # puts subscription

    if @account.stripe_price_id.nil?
      @account.update!(stripe_price_id: metered_price_id)
    end

    render json: {subscription: subscription}


    rescue Stripe::CardError => e
      # puts e
      render json: { status: e.error.code, error: { message: e.error.message } }
  end

  def finalize_subscription
    @account = Account.find(params[:account_id])
    @account.update!(stripe_subscription_id: params[:subscription_id])

    subscription_item_id = Stripe::Subscription.retrieve( @account.stripe_subscription_id ).items.data.first.id
    quantity = @account.members.size

    idempotency_key = SecureRandom.uuid

    Stripe::SubscriptionItem.create_usage_record(
      subscription_item_id,
      { quantity: quantity, timestamp: Time.now.to_i, action: 'set' }, {
        idempotency_key: idempotency_key
      }
    )
    
    render json: {status: 200, url: account_root_path(@account)}
  end

  def subscription_status
    @account = Account.find(params[:account_id])

    @subscription = Stripe::Subscription.retrieve(
      @account.stripe_subscription_id,
    )

    render json: {subscription: subscription}
  end

  def retry_invoice
    @account = Account.find(params[:account_id])

    Stripe::PaymentMethod.attach(
      params[:paymentMethodId],
      { customer: @account.stripe_customer_id }
    )

    Stripe::Customer.update(
      @account.stripe_customer_id,
      invoice_settings: { default_payment_method: params[:paymentMethodId] }
    )

    invoice =
      Stripe::Invoice.retrieve(
        { id: params[:invoiceId], expand: %w[payment_intent] }
      )

      render json: {invoice: invoice}


    rescue Stripe::CardError => e
      render json: {status: e.error.code, error: {message: e.error.message}}

  end

  def success
    @account = Account.find(params[:account_id])

    @subscription = params[:session_id]
  end


  def set_stripe_key
    Stripe.api_key = Rails.application.credentials.send(Rails.env)[:stripe][:secret_key]
  end

end
