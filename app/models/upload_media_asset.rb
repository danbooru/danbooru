# frozen_string_literal: true

class UploadMediaAsset < ApplicationRecord
  belongs_to :upload
  belongs_to :media_asset
end
