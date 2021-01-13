FactoryBot.define do
  factory(:user_session) do
    ip_addr { create(:ip_geolocation).ip_addr }
    session_id { SecureRandom.hex(32) }
    user_agent { "Mozilla/5.0" }
  end
end
