class AddDeletedToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :deleted, :boolean, default: false
  end
end
