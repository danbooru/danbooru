FactoryBot.define do
  factory(:login_session) do
    user
    session_id { Faker::Crypto.md5 }
  end
end
