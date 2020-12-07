json.extract! check_in, :id, :name, :account_id, :user_id, :schedule_period, :weekday, :time, :created_at, :updated_at
json.url check_in_url(check_in, format: :json)
