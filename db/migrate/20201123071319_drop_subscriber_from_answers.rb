class DropSubscriberFromAnswers < ActiveRecord::Migration[6.0]
  def change
  	remove_reference :answers, :subscriber, index: true, foreign_key: true
  end
end
