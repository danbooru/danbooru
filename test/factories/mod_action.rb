FactoryBot.define do
  factory(:mod_action) do
    creator :factory => :user
    description {"1234"}
    category {"other"}
  end
end
