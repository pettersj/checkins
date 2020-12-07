class SubscribersController < ApplicationController
  before_action :set_subscriber, only: [:show, :edit, :update, :destroy]

  # GET /subscribers
  # GET /subscribers.json
  def index
    @check_in = @account.check_ins.find(params[:id])
    @members = @account.members.includes(:user, :subscribers).order('users.first_name asc').order('users.last_name asc')
    @subscribers = @check_in.subscribers.includes(member: :user).order('users.first_name asc').order('users.last_name asc')
  end

  # GET /subscribers/1
  # GET /subscribers/1.json
  def show
  end

  # GET /import
  def import
    @check_in = @account.check_ins.find(params[:id])

  end

  # POST import 
  def import_subscribers
    @check_in = @account.check_ins.find(params[:id])
    list = params[:list]
    list = list.downcase.gsub(' ', '').split(',').to_a
    subscribers = 0

    list.each do |email| 
      if User.find_by(email: email).present?
        @user = User.find_by(email: email)
        @member = Member.create(account_id: @account.id, user: @user)
        @subscriber = Subscriber.create!(member: @member, check_in: @check_in, account: @account)
        subscribers += 1
      else
        name = email.split('@').first.gsub(".", ' ').titleize
        @user = User.invite!({name: name, email: email, skip_invitation: true, timezone: current_user.timezone}, current_user)
        if @user.persisted?
          @member = Member.create(account_id: @account.id, user: @user)
          @subscriber = Subscriber.create!(member: @member, check_in: @check_in, account: @account)
          subscribers += 1
        end
      end

    end

    redirect_to account_subscribers_path(@account, @check_in), notice: "Added #{subscribers} subscribers"
  end

  # GET /subscribers/new
  def new
    @check_in = @account.check_ins.find(params[:id])
    @subscriber = Subscriber.new
  end

  # GET /subscribers/1/edit
  def edit
    @check_in = @account.check_ins.find(params[:id])
  end

  # POST /subscribers
  # POST /subscribers.json
  def create
    @check_in = @account.check_ins.find(params[:id])

    if params[:subscriber][:email].blank?
      @subscriber = Subscriber.new(subscriber_params)
      @subscriber.save
      @check_in = @subscriber.check_in
      @member = @subscriber.member
    else
      email = params[:subscriber][:email].downcase

      if User.find_by(email: email).present?
        @user = User.find_by(email: email)
        if @member.nil?
          @member = Member.create(account_id: @account.id, user: @user)
        end
        @subscriber = Subscriber.create!(member: @member, check_in: @check_in, account: @account)
      else
        name = email.split('@').first.gsub(".", ' ').titleize
        @user = User.invite!({name: name, email: email, skip_invitation: true}, current_user)
        @member = Member.create!(account_id: @account.id, user: @user)
        @subscriber = Subscriber.create!(member: @member, check_in: @check_in, account: @account)
      end

    end

    respond_to do |format|
        format.html { redirect_to account_subscribers_path(@account, @check_in), notice: 'Subscriber was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @subscriber }
    end
  end

  # PATCH/PUT /subscribers/1
  # PATCH/PUT /subscribers/1.json
  def update
    respond_to do |format|
      if @subscriber.update(subscriber_params)
        format.html { redirect_to @subscriber, notice: 'Subscriber was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @subscriber }
      else
        format.html { render :edit }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.json
  def destroy
    @member = @subscriber.member
    @check_in = @subscriber.check_in
    @subscriber.destroy
    respond_to do |format|
      format.html { redirect_to subscribers_url, notice: 'Subscriber was successfully destroyed.' }
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscriber
      @subscriber = Subscriber.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subscriber_params
      params.require(:subscriber).permit(:member_id, :check_in_id, :account_id)
    end
end
