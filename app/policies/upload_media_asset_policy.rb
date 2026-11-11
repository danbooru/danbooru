# frozen_string_literal: true

class UploadMediaAssetPolicy < ApplicationPolicy
  def show?
    user.is_moderator? || record.upload.uploader_id == user.id
  end

  def searchable_attributes
    %i[id created_at updated_at status source_url page_url error upload media_asset post]
  end
end
