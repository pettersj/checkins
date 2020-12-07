class CreateCheckIns < ActiveRecord::Migration[6.0]
  def change
    create_table :check_ins do |t|
      t.string :name
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :schedule_period
      t.string :weekday, array: true
      t.time :time

      t.timestamps
    end
  end
end
