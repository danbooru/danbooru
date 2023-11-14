FactoryBot.define do
  factory(:mod_action) do
    creator factory: :user
    subject factory: :post
    description { "undeleted post ##{subject_id}" }
    category { "post_undelete" }
  end
end
