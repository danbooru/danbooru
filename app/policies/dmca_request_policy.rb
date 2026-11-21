# frozen_string_literal: true

class DmcaRequestPolicy < ApplicationPolicy
  def index?
    user.is_superadmin?
  end

  def update?
    user.is_superadmin?
  end

  def permitted_attributes_for_update
    [:status]
  end

  def visible(relation)
    if user.is_superadmin?
      relation
    else
      relation.none
    end
  end

  def searchable_attributes
    [:id, :created_at, :updated_at, :public_id, :status, :infringing_urls, :original_urls, :danbooru_urls, :post_ids, { name: :exact, email: :exact }]
  end
end
