FactoryGirl.define do
  factory(:ban) do |f|
    reason {FFaker::Lorem.words.join(" ")}
    duration 60
  end
end
