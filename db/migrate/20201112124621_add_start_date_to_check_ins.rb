class AddStartDateToCheckIns < ActiveRecord::Migration[6.0]
  def change
    add_column :check_ins, :start_date, :date
  end
end
