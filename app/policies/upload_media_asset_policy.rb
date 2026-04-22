# frozen_string_literal: true

class UploadMediaAssetPolicy < ApplicationPolicy
  def show?
    user.is_admin? || record.upload.uploader_id == user.id
  end

  def update?
    user.is_admin? || record.upload.uploader_id == user.id
  end

  def permitted_attributes_for_update
    [:is_hidden]
  end
end
