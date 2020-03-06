FactoryBot.define do
  factory(:artist) do
    name { rand(1_000_000).to_s }
    is_deleted { false }
  end
end
