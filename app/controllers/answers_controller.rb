class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :edit, :update, :destroy]

  # GET /answers
  # GET /answers.json
  def index
    @check_in = @account.check_ins.find(params[:check_in_id])
    @answers = Answer.all
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
    @check_in = @answer.check_in
  end

  # GET /answers/new
  def new
    @check_in = @account.check_ins.find(params[:check_in_id])
    @answer = Answer.new
  end

  # GET /answers/1/edit
  def edit
    @check_in = @answer.check_in
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)

    respond_to do |format|
      if @answer.save
        format.html { redirect_to account_check_in_path(@account, @answer.check_in), notice: 'Answer was successfully created.' }
        format.json { render :show, status: :created, location: @answer }
      else
        format.html { render :new }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to account_check_in_path(@account, @answer.check_in), notice: 'Answer was successfully updated.' }
        format.json { render :show, status: :ok, location: @answer }
      else
        format.html { render :edit }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @check_in = @answer.check_in
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to account_check_in_path(@account, @check_in), notice: 'Answer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_answer
      @answer = Answer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def answer_params
      params.require(:answer).permit(:user_id, :account_id, :check_in_id, :body, :member_id)
    end
end
