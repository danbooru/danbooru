# frozen_string_literal: true

class UploadMediaAssetPolicy < ApplicationPolicy
  def show?
    user.is_moderator? || record.upload.uploader_id == user.id
  end
end
