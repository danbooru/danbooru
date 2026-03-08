FactoryBot.define do
  factory(:post_version) do
    updater
    post
    parent_changed { false }
    rating_changed { false }
    source_changed { false }
    rating { "s" }
    source { "" }
    tags { "tagme" }
    added_tags { ["tagme"] }
    removed_tags { [] }
  end
end
