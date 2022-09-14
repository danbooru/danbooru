FactoryBot.define do
  factory(:user_event) do
    user
    user_session
    category { :login }
  end
end
