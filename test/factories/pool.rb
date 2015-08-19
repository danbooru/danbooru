FactoryGirl.define do
  factory(:pool) do
    name {(rand(1_000_000) + 100).to_s}
    association :creator, :factory => :user
    description {FFaker::Lorem.sentences.join(" ")}
  end
end
