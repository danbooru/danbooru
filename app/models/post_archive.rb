class PostArchive < ActiveRecord::Base
  extend Memoist

  belongs_to :post
  belongs_to :updater, class_name: "User"

  def self.enabled?
    Danbooru.config.aws_sqs_archives_url.present?
  end

  establish_connection (ENV["ARCHIVE_DATABASE_URL"] || "archive_#{Rails.env}".to_sym) if enabled?
  self.table_name = "post_versions"

  module SearchMethods
    def for_user(user_id)
      if user_id
        where("updater_id = ?", user_id)
      else
        where("false")
      end
    end

    def for_user_name(name)
      user_id = User.name_to_id(name)
      for_user(user_id)
    end

    def search(params)
      q = where("true")
      params = {} if params.blank?

      if params[:updater_name].present?
        q = q.for_user_name(params[:updater_name])
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

      q
    end
  end

  module ArchiveServiceMethods
    extend ActiveSupport::Concern

    class_methods do
      def sqs_service
        SqsService.new(Danbooru.config.aws_sqs_archives_url)
      end

      def queue(post)
        # queue updates to sqs so that if archives goes down for whatever reason it won't
        # block post updates
        raise NotImplementedError.new("Archive service is not configured") if !enabled?

        json = {
          "post_id" => post.id,
          "rating" => post.rating,
          "parent_id" => post.parent_id,
          "source" => post.source,
          "updater_id" => CurrentUser.id,
          "updater_ip_addr" => CurrentUser.ip_addr.to_s,
          "updated_at" => post.updated_at.try(:iso8601),
          "created_at" => post.created_at.try(:iso8601),
          "tags" => post.tag_string
        }
        msg = "add post version\n#{json.to_json}"
        sqs_service.send_message(msg)
      end
    end
  end

  extend SearchMethods
  include ArchiveServiceMethods

  def tag_array
    tags.scan(/\S+/)
  end

  def presenter
    PostVersionPresenter.new(self)
  end

  def reload
    flush_cache
    super
  end

  def previous
    # HACK: if all the post versions for this post have already been preloaded,
    # we can use that to avoid a SQL query.
    if association(:post).loaded? && post && post.association(:versions).loaded?
      post.versions.sort_by(&:version).reverse.find { |v| v.version < version }
    else
      PostArchive.where("post_id = ? and version < ?", post_id, version).order("version desc").first
    end
  end

  def visible?
    post && post.visible?
  end

  def diff(version = nil)
    if post.nil?
      latest_tags = tag_array
    else
      latest_tags = post.tag_array
      latest_tags << "rating:#{post.rating}" if post.rating.present?
      latest_tags << "parent:#{post.parent_id}" if post.parent_id.present?
      latest_tags << "source:#{post.source}" if post.source.present?
    end

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
    delta = {
      :added_tags => added_tags,
      :removed_tags => removed_tags,
      :obsolete_removed_tags => [],
      :obsolete_added_tags => [],
      :unchanged_tags => []
    }

    return delta if post.nil?

    latest_tags = post.tag_array
    latest_tags << "rating:#{post.rating}" if post.rating.present?
    latest_tags << "parent:#{post.parent_id}" if post.parent_id.present?
    latest_tags << "source:#{post.source}" if post.source.present?

    if parent_changed
      if parent_id.present?
        delta[:added_tags] << "parent:#{parent_id}"
      end

      if previous
        delta[:removed_tags] << "parent:#{previous.parent_id}"
      end
    end

    if rating_changed
      delta[:added_tags] << "rating:#{rating}"

      if previous
        delta[:removed_tags] << "rating:#{previous.rating}"
      end
    end

    if source_changed
      if source.present?
        delta[:added_tags] << "source:#{source}"
      end

      if previous
        delta[:removed_tags] << "source:#{previous.source}"
      end
    end

    delta[:obsolete_added_tags] = delta[:added_tags] - latest_tags
    delta[:obsolete_removed_tags] = delta[:removed_tags] & latest_tags

    if previous
      delta[:unchanged_tags] = tag_array & previous.tag_array
    else
      delta[:unchanged_tags] = []
    end

    delta
  end

  def added_tags_with_fields
    changes[:added_tags].join(" ")
  end

  def removed_tags_with_fields
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

  def truncated_source
    source.gsub(/^http:\/\//, "").sub(/\/.+/, "")
  end

  def undo
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

  def method_attributes
    super + [:obsolete_added_tags, :obsolete_removed_tags, :unchanged_tags, :updater_name]
  end

  memoize :previous, :tag_array, :changes, :added_tags_with_fields, :removed_tags_with_fields, :obsolete_removed_tags, :obsolete_added_tags, :unchanged_tags
end
