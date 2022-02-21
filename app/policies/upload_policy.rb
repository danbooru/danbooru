# frozen_string_literal: true

class UploadPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def show?
    user.is_admin? || record.uploader_id == user.id
  end

  def permitted_attributes
    [:source, :referer_url, files: {}]
  end
end
