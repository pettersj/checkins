class AddBillingEmailToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :billing_email, :string
  end
end
