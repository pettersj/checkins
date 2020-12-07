class AddStatusToCheckIns < ActiveRecord::Migration[6.0]
  def change
    add_column :check_ins, :status, :integer, default: 0, null: false
  end
end
