# frozen_string_literal: true

class UploadMediaAssetPolicy < ApplicationPolicy
  def show?
    user.is_moderator? || record.upload.uploader_id == user.id
  end

  def visible(relation)
    if user.is_moderator?
      relation
    elsif user.is_anonymous?
      relation.none
    else
      relation.where(user: user)
    end
  end

  def searchable_attributes
    %i[id created_at updated_at status source_url page_url error upload media_asset post]
  end
end
