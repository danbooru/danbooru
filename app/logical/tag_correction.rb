class TagCorrection
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  attr_reader :tag
  delegate :category, :post_count, :real_post_count, to: :tag

  def initialize(tag_id)
    @tag = Tag.find(tag_id)
  end

  def attributes
    { post_count: post_count, real_post_count: real_post_count, category: category, category_cache: category_cache, tag: tag }
  end

  def category_cache
    Cache.get("tc:" + Cache.hash(tag.name))
  end

  def fix!
    FixTagPostCountJob.perform_later(tag)
    tag.update_category_cache
  end
end
