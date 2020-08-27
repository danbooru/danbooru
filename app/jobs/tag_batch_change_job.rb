class TagBatchChangeJob < ApplicationJob
  queue_as :bulk_update

  def perform(antecedent, consequent)
    normalized_antecedent = PostQueryBuilder.new(antecedent).split_query
    normalized_consequent = PostQueryBuilder.new(consequent).parse_tag_edit

    CurrentUser.scoped(User.system) do
      migrate_posts(normalized_antecedent, normalized_consequent)
      ModAction.log("processed mass update: #{antecedent} -> #{consequent}", :mass_update)
    end
  end

  def migrate_posts(normalized_antecedent, normalized_consequent)
    ::Post.system_tag_match(normalized_antecedent.join(" ")).find_each do |post|
      post.with_lock do
        tags = (post.tag_array - normalized_antecedent + normalized_consequent).join(" ")
        post.update(tag_string: tags)
      end
    end
  end
end
