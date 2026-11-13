# frozen_string_literal: true

class PoolVersionPolicy < ApplicationPolicy
  alias_method :diff?, :index?

  def searchable_attributes
    %i[id created_at updated_at pool_id post_ids added_post_ids removed_post_ids updater_id description description_changed name name_changed version is_active is_deleted category]
  end
end
