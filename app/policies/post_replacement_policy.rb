class PostReplacementPolicy < ApplicationPolicy
  def create?
    user.is_moderator?
  end

  def update?
    user.is_moderator?
  end

  def permitted_attributes_for_create
    [:replacement_url, :replacement_file, :final_source, :tags]
  end

  def permitted_attributes_for_update
    [:old_file_ext, :old_file_size, :old_image_width, :old_image_height,
     :old_md5, :file_ext, :file_size, :image_width, :image_height, :md5,
     :original_url, :replacement_url]
  end
end
