class PostReplacement < ApplicationRecord
  DELETION_GRACE_PERIOD = 30.days

  belongs_to :post
  belongs_to :creator, class_name: "User"
  before_validation :initialize_fields, on: :create
  attr_accessor :replacement_file, :final_source, :tags

  def initialize_fields
    self.creator = CurrentUser.user
    self.original_url = post.source
    self.tags = post.tag_string + " " + self.tags.to_s

    self.old_file_ext = post.file_ext
    self.old_file_size = post.file_size
    self.old_image_width = post.image_width
    self.old_image_height = post.image_height
    self.old_md5 = post.md5
  end

  concerning :Search do
    class_methods do
      def search(params = {})
        q = search_attributes(params, :id, :created_at, :updated_at, :md5, :old_md5, :file_ext, :old_file_ext, :original_url, :replacement_url, :creator, :post)
        q.apply_default_order(params)
      end
    end
  end

  def suggested_tags_for_removal
    tags = post.tag_array.select do |tag|
      Danbooru.config.post_replacement_tag_removals.any? do |pattern|
        tag.match?(/\A#{pattern}\z/i)
      end
    end

    tags = tags.map { |tag| "-#{tag}" }
    tags.join(" ")
  end

  def self.available_includes
    [:creator, :post]
  end
end
