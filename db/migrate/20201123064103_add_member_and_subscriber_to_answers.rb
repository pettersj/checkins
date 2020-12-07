class AddMemberAndSubscriberToAnswers < ActiveRecord::Migration[6.0]
  def change
    add_reference :answers, :member, null: false, foreign_key: true
    add_reference :answers, :subscriber, null: false, foreign_key: true
  end
end
