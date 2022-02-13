# frozen_string_literal: true

class UploadMediaAsset < ApplicationRecord
  extend Memoist

  belongs_to :upload
  belongs_to :media_asset, optional: true

  enum status: {
    pending: 0,
    processing: 100,
    active: 200,
    failed: 300,
  }

  def self.visible(user)
    if user.is_admin?
      all
    else
      where(upload: { uploader: user })
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :status, :source_url, :page_url, :error, :upload, :media_asset)
    q.apply_default_order(params)
  end

  def finished?
    active? || failed?
  end

  def source_strategy
    return nil if source_url.blank?
    Sources::Strategies.find(source_url, page_url)
  end

  memoize :source_strategy
end
