FactoryGirl.define do
  factory(:tag_subscription) do
    name {FFaker::Lorem.words.join(" ")}
    is_public true
    tag_query "aaa"
  end
end
