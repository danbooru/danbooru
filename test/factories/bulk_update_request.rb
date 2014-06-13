FactoryGirl.define do
  factory(:bulk_update_request) do |f|
    script "create alias aaa -> bbb"
  end
end
