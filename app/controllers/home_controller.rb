class HomeController < ApplicationController
	skip_before_action :authenticate_user!
  
  def index
  	if user_signed_in?
  		redirect_to account_root_path(current_user.accounts.first)
  	end
  end

  def terms
  end

  def privacy
  end

  def refund
  end

  def stripe
  end

  def loaderio_af3c851acf6060e461046fc57cdcd131
    render layout: false
    # respond_to do |format|
    #   format.html {layout: false}
    #   format.txt {layout: false}
    # end

  end
end
