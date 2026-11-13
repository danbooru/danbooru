# frozen_string_literal: true

class WikiPageVersionPolicy < ApplicationPolicy
  alias_method :diff?, :show?

  def searchable_attributes
    %i[id created_at updated_at title body other_names is_locked is_deleted updater wiki_page tag]
  end
end
