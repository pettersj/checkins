class AddStripeFieldsToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :stripe_customer_id, :string
    add_column :accounts, :stripe_subscription_id, :string
    add_column :accounts, :stripe_price_id, :string
  end
end
