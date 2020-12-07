json.extract! subscriber, :id, :member_id, :check_in_id, :account_id, :created_at, :updated_at
json.url subscriber_url(subscriber, format: :json)
