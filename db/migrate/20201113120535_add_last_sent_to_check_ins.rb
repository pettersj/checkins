class AddLastSentToCheckIns < ActiveRecord::Migration[6.0]
  def change
    add_column :check_ins, :last_sent, :datetime
  end
end
