# frozen_string_literal: true

class UploadPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def show?
    user.is_admin? || record.uploader_id == user.id
  end

  def batch?
    unbanned?
  end

  def image_proxy?
    unbanned?
  end

  def permitted_attributes
    %i[file source referer_url]
  end
end
