FactoryBot.define do
  factory(:artist) do
    name {rand(1_000_000).to_s}
    is_active true
    association :creator, factory: :user
  end
end

