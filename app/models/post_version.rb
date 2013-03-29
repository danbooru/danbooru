class PostVersion < ActiveRecord::Base
  belongs_to :post
  belongs_to :updater, :class_name => "User"
  before_validation :initialize_updater

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end

    def updater_name(name)
      where("updater_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def search(params)
      q = scoped
      params = {} if params.blank?

      if params[:updater_name].present?
        q = q.updater_name(params[:updater_name])
      end

      if params[:updater_id].present?
        q = q.where("updater_id = ?", params[:updater_id].to_i)
      end

      if params[:post_id].present?
        q = q.where("post_id = ?", params[:post_id].to_i)
      end

      q
    end
  end

  extend SearchMethods

  def self.create_from_post(post)
    if post.created_at == post.updated_at
      create_from_created_post(post)
    else
      create_from_updated_post(post)
    end
  end

  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end

  def tag_array
    @tag_array ||= tags.scan(/\S+/)
  end

  def presenter
    PostVersionPresenter.new(self)
  end

  def reload
    @tag_array = nil
    super
  end

  def sequence_for_post
    versions = PostVersion.where(:post_id => post_id).order("updated_at desc").all
    diffs = []
    versions.each_index do |i|
      if i < versions.size - 1
        diffs << versions[i].diff(versions[i + 1])
      end
    end
    return diffs
  end

  def diff(version)
    latest_tags = post.tag_array
    new_tags = tag_array
    new_tags << "rating:#{rating}" if rating.present?
    new_tags << "parent:#{parent_id}" if parent_id.present?
    new_tags << "source:#{source}" if source.present?
    old_tags = version.present? ? version.tag_array : []
    if version.present?
      old_tags << "rating:#{version.rating}" if version.rating.present?
      old_tags << "parent:#{version.parent_id}" if version.parent_id.present?
      old_tags << "source:#{version.source}" if version.source.present?
    end

    return {
      :added_tags => new_tags - old_tags,
      :removed_tags => old_tags - new_tags,
      :unchanged_tags => new_tags & old_tags,
      :obsolete_added_tags => new_tags - latest_tags,
      :obsolete_removed_tags => old_tags & latest_tags,
    }
  end

  def previous
    PostVersion.where("post_id = ? and updated_at < ?", post_id, updated_at).order("updated_at desc").first
  end

  def truncated_source
    source.gsub(/^http:\/\//, "").sub(/\/.+/, "")
  end
end
