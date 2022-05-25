FactoryBot.define do
  factory(:upgrade_code) do
    creator factory: :user
  end
end
