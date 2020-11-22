class PostRegeneration < ApplicationRecord
  belongs_to :creator, :class_name => "User"
  belongs_to :post

  validates :category, inclusion: %w[iqdb resizes]

  module SearchMethods
    def search(params)
      q = search_attributes(params, :id, :created_at, :updated_at, :category, :creator, :post)
      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def execute_category_action!
    if category == "iqdb"
      post.update_iqdb_async
    elsif category == "resizes"
      media_file = MediaFile.open(post.file, frame_data: post.pixiv_ugoira_frame_data)
      UploadService::Utils.process_resizes(post, nil, post.id, media_file: media_file)
    else
      # should never happen
      raise Error, "Unknown category: #{category}"
    end
  end

  def self.searchable_includes
    [:creator, :post]
  end
end
