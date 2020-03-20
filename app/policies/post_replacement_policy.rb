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
    [:file_ext_was, :file_size_was, :image_width_was, :image_height_was,
     :md5_was, :file_ext, :file_size, :image_width, :image_height, :md5,
     :original_url, :replacement_url]
  end
end
