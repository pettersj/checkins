class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_account!
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :masquerade_user!

  add_flash_types :info, :success, :warning, :danger, :notice


  def owner?
    @owner = @account.user == current_user
  end

  protected
  	def set_account!
      if params[:account_id].present?
  		  @account ||= Account.find(params[:account_id])
        @member ||= @account.members.find_by(user_id: current_user.id)

        
        if @member.nil?
           redirect_to root_path, danger: "Not Authorized"
        end
      end
  	end

    # def after_sign_in_path_for(user)
    #   # account_root_path(user.accounts.first) || root_path
    # end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :account_name, :timezone])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :timezone])
    end
end
