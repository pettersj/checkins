class ChangeMemberToOptionalForAnswers < ActiveRecord::Migration[6.0]
  def change
  	change_column_null :answers, :member_id, true
  end
end
