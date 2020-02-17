FactoryBot.define do
  factory(:pool) do
    name {"pool_" + rand(100..1000099).to_s}
    description {FFaker::Lorem.sentences.join(" ")}
  end
end
