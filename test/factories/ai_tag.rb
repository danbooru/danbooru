FactoryBot.define do
  factory(:ai_tag) do
    tag
    media_asset
    score { 1.0 }
  end
end
