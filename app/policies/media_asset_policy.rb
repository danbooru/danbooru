# frozen_string_literal: true

class MediaAssetPolicy < ApplicationPolicy
  def index?
    true
  end

  def can_see_image?
    record.post.blank? || record.post.visible?(user)
  end

  def api_attributes
    if can_see_image?
      super
    else
      super.excluding(:md5)
    end
  end
end
