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
      def post_tags_match(query)
        PostQueryBuilder.new(query).build(self.joins(:post))
      end

      def search(params = {})
        q = super

        q = q.attribute_matches(:replacement_url, params[:replacement_url])
        q = q.attribute_matches(:original_url, params[:original_url])
        q = q.attribute_matches(:file_ext_was, params[:file_ext_was])
        q = q.attribute_matches(:file_ext, params[:file_ext])
        q = q.attribute_matches(:md5_was, params[:md5_was])
        q = q.attribute_matches(:md5, params[:md5])

        if params[:creator_id].present?
          q = q.where(creator_id: params[:creator_id].split(",").map(&:to_i))
        end

        if params[:creator_name].present?
          q = q.where(creator_id: User.name_to_id(params[:creator_name]))
        end

        if params[:post_id].present?
          q = q.where(post_id: params[:post_id].split(",").map(&:to_i))
        end

        if params[:post_tags_match].present?
          q = q.post_tags_match(params[:post_tags_match])
        end

        q.apply_default_order(params)
      end
    end
  end

  def suggested_tags_for_removal
    tags = post.tag_array.select { |tag| Danbooru.config.remove_tag_after_replacement?(tag) }
    tags = tags.map { |tag| "-#{tag}" }
    tags.join(" ")
  end

end
