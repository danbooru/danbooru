FactoryBot.define do
  factory(:bulk_update_request) do |f|
    user
    title {"xxx"}
    script {"create alias aaa -> bbb"}
    skip_secondary_validations {true}
  end
end
