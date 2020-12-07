class AccountsController < ApplicationController
  # skip_before_action :set_account!
  # before_action :set_account, only: [:show, :update, :destroy]

  def home
    @account = Account.find(params[:account_id])

    if @account.stripe_subscription_id.nil?
      redirect_to account_billing_path(@account.id)
    end

    @check_ins = @account.check_ins.order(name: :asc)
    @answers = @account.answers.order(created_at: :asc)
  end

  def admin
    @account = Account.find(params[:account_id])
  end

  def billing
    @account = Account.find(params[:account_id])

    Stripe.api_key = Rails.application.credentials.send(Rails.env)[:stripe][:secret_key]

    if !@account.stripe_subscription_id.nil?
      @subscription = Stripe::Subscription.retrieve( @account.stripe_subscription_id )
      # @price = Stripe::Price.retrieve({id: @subscription.items.data.first.plan.id, expand: ['tiers']})
      # @product = Stripe::Product.retrieve(@price.product)
      # @payment_method = Stripe::PaymentMethod.retrieve(data['paymentMethodId'])
      # @subscription_item_id = @subscription.items.data.first.id
      # @subscription_item = Stripe::SubscriptionItem.retrieve( @account.stripe_subscription_id )
    end
  end

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:account_id])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to account_root_path(@account), notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:account_id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :user_id)
    end
end
