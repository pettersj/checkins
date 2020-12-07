class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, :invitable

  has_one_attached :avatar
  has_person_name

  has_many :notifications, as: :recipient
  has_many :services
  has_many :members, dependent: :destroy
  has_many :accounts, through: :members
  has_many :answers

  before_save :set_timezone
  after_create :create_account


  def create_account
  	if self.account_name == "new"
      # Stripe.api_key = Rails.application.credentials.send(Rails.env)[:stripe][:secret_key]
      # stripe_customer_id = Stripe::Customer.create(email: self.billing_email).id

  		account = Account.new(user_id: self.id, name: "Team #{self.name}", billing_email: self.email)
  		account.save
  		Member.new(user_id: self.id, account: account).save
  	end
  end

  def set_timezone
    if self.timezone.nil?
      timezone = "UTC"
    end
  end


end