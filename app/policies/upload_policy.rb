class UploadPolicy < ApplicationPolicy
  def show?
    record.is_completed? || user.is_admin? || record.uploader_id == user.id
  end

  def batch?
    unbanned?
  end

  def image_proxy?
    unbanned?
  end

  def preprocess?
    unbanned?
  end

  def can_view_tags?
    user.is_admin? || record.uploader_id == user.id
  end

  def permitted_attributes
    %i[file source tag_string rating status parent_id artist_commentary_title
       artist_commentary_desc referer_url
       md5_confirmation as_pending translated_commentary_title translated_commentary_desc]
  end

  def api_attributes
    attributes = super
    attributes -= [:tag_string] unless can_view_tags?
    attributes
  end
end
