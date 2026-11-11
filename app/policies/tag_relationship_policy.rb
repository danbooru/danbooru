# frozen_string_literal: true

class TagRelationshipPolicy < ApplicationPolicy
  def searchable_attributes
    %i[
      id created_at updated_at antecedent_name consequent_name reason creator approver forum_post forum_topic
      antecedent_tag consequent_tag antecedent_wiki consequent_wiki
    ]
  end
end
