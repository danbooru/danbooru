FactoryBot.define do
  factory(:user_event) do
    user
    user_session
    category { :login }
    ip_addr { Faker::Internet.ip_v4_address }
    session_id { Faker::Crypto.md5 }
    user_agent { Faker::Internet.user_agent }
  end
end
