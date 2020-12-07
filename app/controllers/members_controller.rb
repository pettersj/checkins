class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  # GET /members
  # GET /members.json
  def index
    @members = @account.members.includes(:answers, :subscribers, :user).order('users.first_name asc').order('users.last_name asc')
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    # @member = Member.new(member_params)

      email = params[:member][:email].downcase

      if User.find_by(email: email).present?
        @user = User.find_by(email: email)
        if @member.nil?
          @member = Member.create(account_id: @account.id, user: @user)
        end
      else
        name = email.split('@').first.gsub(".", ' ').titleize
        @user = User.invite!({name: name, email: email, timezone: current_user.timezone}, current_user)
        @member = Member.create!(account_id: @account.id, user: @user)
      end

    redirect_to account_members_path(@account), notice: "User was successfully created, and an invitation was sent to #{@member.user.email}"

    # respond_to do |format|
    #   if @member.save
    #     format.html { redirect_to @member, notice: 'Member was successfully created.' }
    #     format.json { render :show, status: :created, location: @member }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @member.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to account_members_path(@account), notice: 'User was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def member_params
      params.require(:member).permit(:user_id, :account_id)
    end
end
