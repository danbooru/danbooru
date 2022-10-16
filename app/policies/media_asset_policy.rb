# frozen_string_literal: true

class MediaAssetPolicy < ApplicationPolicy
  def index?
    true
  end

  def can_see_image?
    record.post.blank? || record.post.visible?(user)
  end

  def api_attributes
    attributes = super + [:variants]
    attributes -= [:md5, :file_key, :variants] if !can_see_image?
    attributes
  end
end
