# frozen_string_literal: true

class DtextLinkPolicy < ApplicationPolicy
  def searchable_attributes
    %i[id created_at updated_at link_type link_target model linked_wiki linked_tag]
  end
end
