Factory.define(:advertisement) do |f|
  f.referral_url "http://google.com"
  f.ad_type "vertical"
  f.status "active"
  f.width 728
  f.height 90
  f.file_name "google.gif"
end
