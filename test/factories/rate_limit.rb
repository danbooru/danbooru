FactoryBot.define do
  factory(:rate_limit) do
    limited { false }
    points { 0 }
    action { "test" }
    key { "1234" }
  end
end
