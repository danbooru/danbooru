FactoryGirl.define do
  factory(:advertisement) do
    referral_url "http://google.com"
    ad_type "vertical"
    status "active"
    width 728
    height 90
    file_name "google.gif"
  end
end
