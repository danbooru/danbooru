# frozen_string_literal: true

class MediaAssetPolicy < ApplicationPolicy
  def index?
    true
  end

  def destroy?
    user.is_admin?
  end

  def image?
    can_see_image?
  end

  def can_see_image?
    !record.removed? && (record.post.blank? || record.post.visible?(user))
  end

  def reportable?
    record.post.blank?
  end

  def api_attributes
    attributes = super + [:variants]
    attributes -= [:md5, :file_key, :variants] if !can_see_image?
    attributes
  end
end
