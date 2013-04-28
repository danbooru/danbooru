FactoryGirl.define do
  factory(:ban) do |f|
    reason {Faker::Lorem.words.join(" ")}
    duration 60
  end
end
