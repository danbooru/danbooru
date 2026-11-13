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

  # Whether the user can resize the image or convert it to another format (with e.g. `/media_assets/1.webp?width=100`).
  def can_convert_image?
    user.is_owner?
  end

  def can_see_image?
    !record.removed? && (record.post.blank? || record.post.visible?(user))
  end

  def rate_limit_for_image(**_options)
    { rate: 5.0 / 1.second, burst: 50 }
  end

  # Only allow exact matches on file hashes for non-moderators, so partial searches can't be used to find the md5s of
  # images the user can't see.
  def searchable_attributes
    hashes = %i[md5 pixel_hash file_key]
    hashes = [hashes.index_with(:exact)] unless user.is_moderator?

    %i[id created_at updated_at status file_ext file_size image_width image_height duration is_public] + hashes
  end

  def api_attributes
    attributes = super + [:variants]
    attributes -= [:md5, :file_key, :variants] if !can_see_image?
    attributes
  end
end
