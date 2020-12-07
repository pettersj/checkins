class CheckInsController < ApplicationController
  before_action :set_check_in, only: [:show, :edit, :update, :destroy, :send_test, :send_now]

  # GET /check_ins
  # GET /check_ins.json
  def index
    @title = "Check-ins"
    @check_ins = @account.check_ins.order(name: :asc)
  end

  # GET /check_ins/1
  # GET /check_ins/1.json
  def show
    @title = @check_in.name
  end

  # GET /check_ins/new
  def new
    @title = "New Check-in"
    @check_in = CheckIn.new
  end

  # GET /check_ins/1/edit
  def edit
    @title = "Edit #{@check_in.name}"
  end

  def send_test

    subscriber =  @member.subscribers.find_by(check_in_id: @check_in.id)

    if subscriber.nil?
      subscriber = Subscriber.create(member: @member, check_in: @check_in, account_id: @account)
    end

    CheckInMailer.with(check_in_id: @check_in.id, account_id: @account.id, subscriber_id: subscriber.id).check_in.deliver_later

  end

  def send_now
    @check_in.subscribers.each do |subscriber|
      CheckInMailer.with(check_in_id: @check_in.id, account_id: @account.id, subscriber_id: subscriber.id).check_in.deliver_later
    end

    redirect_back fallback_location: account_check_in_path(@account, @check_in), notice: "Sent Check-in to #{@check_in.subscribers.size} #{"subscriber".pluralize(@check_in.subscribers.size)}"

  end

  # POST /check_ins
  # POST /check_ins.json
  def create
    @check_in = CheckIn.new(check_in_params)

    respond_to do |format|
      if @check_in.save
        if params[:check_in][:weekday].present?
          @check_in.update(weekday: params[:check_in][:weekday])
        end
        account_id = @account.id

        format.html { redirect_to account_subscribers_path(@account, @check_in), notice: 'Check in was successfully created.' }
        format.json { render :show, status: :created, location: @check_in }
      else
        format.html { render :new }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_ins/1
  # PATCH/PUT /check_ins/1.json
  def update
    respond_to do |format|
      if @check_in.update(check_in_params)
        if params[:check_in][:weekday].present?
          @check_in.update(weekday: params[:check_in][:weekday])
        end
        format.html { redirect_to account_check_in_path(@account, @check_in), notice: 'Check in was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_in }
      else
        format.html { render :edit }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_ins/1
  # DELETE /check_ins/1.json
  def destroy
    @check_in.destroy
    respond_to do |format|
      format.html { redirect_to account_root_path(@account), notice: 'Check in was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check_in
      @check_in = CheckIn.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def check_in_params
      params.require(:check_in).permit(:name, :weekday, :start_date, :account_id, :user_id, :schedule_period, :time, :status)
    end
end
