class Member < ApplicationRecord
  belongs_to :user
  belongs_to :account
  has_many :subscribers, dependent: :destroy
  has_many :answers, dependent: :nullify

  validates_uniqueness_of :user_id, scope: :account_id


  after_create :send_usage_to_stripe
  before_destroy :set_username_on_answers
  after_destroy :send_usage_to_stripe


  def set_username_on_answers
    self.answers.update_all(username: "#{self.user.name} (deleted)")
  end

  def send_usage_to_stripe
    if self.account.members.size > 0
      Stripe.api_key = Rails.application.credentials.send(Rails.env)[:stripe][:secret_key]

      account = self.account
      if !account.stripe_subscription_id.nil?
        subscription_item_id = Stripe::Subscription.retrieve( account.stripe_subscription_id ).items.data.first.id
        quantity = account.members.size

    		idempotency_key = SecureRandom.uuid

        Stripe::SubscriptionItem.create_usage_record(
    		  subscription_item_id,
    		  { quantity: quantity, timestamp: Time.now.to_i, action: 'set' }, {
    	      idempotency_key: idempotency_key
    	    }
    		)
      end
    end
  end
end
