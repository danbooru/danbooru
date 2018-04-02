class PostVersion < ApplicationRecord
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
      q = super

      if params[:updater_name].present?
        q = q.updater_name(params[:updater_name])
      end

      if params[:updater_id].present?
        q = q.where("updater_id = ?", params[:updater_id].to_i)
      end

      if params[:post_id].present?
        q = q.where("post_id = ?", params[:post_id].to_i)
      end

      if params[:start_id].present?
        q = q.where("id <= ?", params[:start_id].to_i)
      end

      q.apply_default_order(params)
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

  def reload
    @tag_array = nil
    super
  end

  def diff(version)
    latest_tags = post.tag_array
    latest_tags << "rating:#{post.rating}" if post.rating.present?
    latest_tags << "parent:#{post.parent_id}" if post.parent_id.present?
    latest_tags << "source:#{post.source}" if post.source.present?

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

    added_tags = new_tags - old_tags
    removed_tags = old_tags - new_tags

    return {
      :added_tags => added_tags,
      :removed_tags => removed_tags,
      :obsolete_added_tags => added_tags - latest_tags,
      :obsolete_removed_tags => removed_tags & latest_tags,
      :unchanged_tags => new_tags & old_tags,
    }
  end

  def changes
    @changes ||= diff(previous)
  end

  def added_tags
    changes[:added_tags].join(" ")
  end

  def removed_tags
    changes[:removed_tags].join(" ")
  end

  def obsolete_added_tags
    changes[:obsolete_added_tags].join(" ")
  end

  def obsolete_removed_tags
    changes[:obsolete_removed_tags].join(" ")
  end

  def unchanged_tags
    changes[:unchanged_tags].join(" ")
  end

  def previous
    if updated_at.to_i == Time.zone.parse("2007-03-14T19:38:12Z").to_i
      # Old post versions which didn't have updated_at set correctly
      PostVersion.where("post_id = ? and updated_at = ? and id < ?", post_id, updated_at, id).order("updated_at desc, id desc").first
    else
      PostVersion.where("post_id = ? and updated_at < ?", post_id, updated_at).order("updated_at desc, id desc").first
    end
  end

  def truncated_source
    source.gsub(/^http:\/\//, "").sub(/\/.+/, "")
  end

  def undo
    changes = diff(previous)
    added = changes[:added_tags] - changes[:obsolete_added_tags]
    removed = changes[:removed_tags] - changes[:obsolete_removed_tags]

    added.each do |tag|
      if tag =~ /^source:/
        post.source = ""
      elsif tag =~ /^parent:/
        post.parent_id = nil
      else
        escaped_tag = Regexp.escape(tag)
        post.tag_string = post.tag_string.sub(/(?:\A| )#{escaped_tag}(?:\Z| )/, " ").strip
      end
    end
    removed.each do |tag|
      if tag =~ /^source:(.+)$/
        post.source = $1
      else
        post.tag_string = "#{post.tag_string} #{tag}".strip
      end
    end
  end

  def undo!
    undo
    post.save!
  end

  def updater_name
    User.id_to_name(updater_id)
  end

  def method_attributes
    super + [:added_tags, :removed_tags, :obsolete_added_tags, :obsolete_removed_tags, :unchanged_tags, :updater_name]
  end
end
