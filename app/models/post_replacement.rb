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

    self.file_ext_was =  post.file_ext
    self.file_size_was = post.file_size
    self.image_width_was = post.image_width
    self.image_height_was = post.image_height
    self.md5_was = post.md5
  end

  concerning :Search do
    class_methods do
      def search(params = {})
        q = super
        q = q.search_attributes(params, :md5, :md5_was, :file_ext, :file_ext_was, :original_url, :replacement_url)
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

  def self.searchable_includes
    [:creator, :post]
  end

  def self.available_includes
    [:creator, :post]
  end
end
