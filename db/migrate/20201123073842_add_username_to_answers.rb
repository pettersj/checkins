class AddUsernameToAnswers < ActiveRecord::Migration[6.0]
  def change
    add_column :answers, :username, :string
  end
end
