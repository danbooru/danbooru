FactoryGirl.define do
  factory(:bulk_update_request) do |f|
    title "xxx"
    script "create alias aaa -> bbb"
  end
end
