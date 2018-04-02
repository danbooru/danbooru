FactoryBot.define do
  factory(:pool) do
    name {"pool_" + (rand(1_000_000) + 100).to_s}
    association :creator, :factory => :user
    description {FFaker::Lorem.sentences.join(" ")}
  end
end
