FactoryBot.define do
  factory(:user_event) do
    user
    login_session { build(:login_session, user: user, session_id: session_id) }
    category { :login }
    ip_addr { Faker::Internet.ip_v4_address }
    session_id { Faker::Crypto.md5 }
    user_agent { Faker::Internet.user_agent }
  end
end
