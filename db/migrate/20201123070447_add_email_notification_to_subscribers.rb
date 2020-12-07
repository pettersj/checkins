class AddEmailNotificationToSubscribers < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :email_notification, :boolean, default: true
  end
end
