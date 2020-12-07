class AddStripeFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :price_id, :string
  end
end
