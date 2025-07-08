FactoryBot.define do
  factory(:api_key) do
    user
    name { Faker::Name.first_name }

    request do
      request = ActionDispatch::TestRequest.create("REMOTE_ADDR" => Faker::Internet.public_ip_v4_address, "HTTP_USER_AGENT" => Faker::Internet.user_agent)
      request.session = { session_id: SecureRandom.hex(16) }
      request
    end
  end
end
