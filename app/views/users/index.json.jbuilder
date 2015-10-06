json.array!(@users) do |user|
  json.extract! user, :id, :user_name, :password_digest
  json.url user_url(user, format: :json)
end
