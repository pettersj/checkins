class Account < ApplicationRecord
  belongs_to :user
  has_many :members
  has_many :check_ins
  has_many :answers
  has_many :users, through: :members

  before_save :set_stripe_email

  def set_stripe_email
  	if self.billing_email_changed? && !self.stripe_customer_id.nil?
    	Stripe.api_key = Rails.application.credentials.send(Rails.env)[:stripe][:secret_key]
    	Stripe::Customer.update(self.stripe_customer_id, {email: self.billing_email})
  	end
  end

end
