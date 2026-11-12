# frozen_string_literal: true

class DtextLinkPolicy < ApplicationPolicy
  def visible(relation)
    # XXX the double negation is to prevent postgres from choosing a bad query
    # plan (it doesn't know that most forum posts aren't mod-only posts).
    relation.wiki_page.or(relation.forum_post.where.not(model_id: ForumPost.not_visible(user))).or(relation.pool)
  end

  def searchable_attributes
    %i[id created_at updated_at link_type link_target model linked_wiki linked_tag]
  end
end
