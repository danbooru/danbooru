class PostVersion < ApplicationRecord
  class RevertError < StandardError; end
  extend Memoist

  belongs_to :post
  belongs_to_updater counter_cache: "post_update_count"

  def self.enabled?
    Rails.env.test? || Danbooru.config.aws_sqs_archives_url.present?
  end

  def self.database_url
    ENV["ARCHIVE_DATABASE_URL"] || "archive_#{Rails.env}".to_sym
  end

  establish_connection database_url if enabled?

  module SearchMethods
    def changed_tags_include(tag)
      where_array_includes_all(:added_tags, [tag]).or(where_array_includes_all(:removed_tags, [tag]))
    end

    def changed_tags_include_all(tags)
      tags.reduce(all) do |relation, tag|
        relation.changed_tags_include(tag)
      end
    end

    def changed_tags_include_any(tags)
      where_array_includes_any(:added_tags, tags).or(where_array_includes_any(:removed_tags, tags))
    end

    def tag_matches(string)
      tag = string.match(/\S+/)[0]
      return all if tag.nil?
      tag = "*#{tag}*" unless tag =~ /\*/
      where_ilike(:tags, tag)
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :updater_id, :post_id, :tags, :added_tags, :removed_tags, :rating, :rating_changed, :parent_id, :parent_changed, :source, :source_changed, :version)

      if params[:changed_tags]
        q = q.changed_tags_include_all(params[:changed_tags].scan(/[^[:space:]]+/))
      end

      if params[:all_changed_tags]
        q = q.changed_tags_include_all(params[:all_changed_tags].scan(/[^[:space:]]+/))
      end

      if params[:any_changed_tags]
        q = q.changed_tags_include_any(params[:any_changed_tags].scan(/[^[:space:]]+/))
      end

      if params[:tag_matches]
        q = q.tag_matches(params[:tag_matches])
      end

      if params[:updater_name].present?
        q = q.where(updater_id: User.name_to_id(params[:updater_name]))
      end

      if params[:is_new].to_s.truthy?
        q = q.where(version: 1)
      elsif params[:is_new].to_s.falsy?
        q = q.where("version != 1")
      end

      q.apply_default_order(params)
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
        sqs_service.send_message(msg, message_group_id: "post:#{post.id}")
      end
    end
  end

  extend SearchMethods
  include ArchiveServiceMethods

  def tag_array
    tags.split
  end

  def reload
    flush_cache
    super
  end

  def previous
    @previous ||= begin
      # HACK: if all the post versions for this post have already been preloaded,
      # we can use that to avoid a SQL query.
      if association(:post).loaded? && post && post.association(:versions).loaded?
        ver = [post.versions.sort_by(&:version).reverse.find { |v| v.version < version }]
      else
        ver = PostVersion.where("post_id = ? and version < ?", post_id, version).order("version desc").limit(1).to_a
      end
    end
    @previous.first
  end

  def subsequent
    @subsequent ||= begin
      PostVersion.where("post_id = ? and version > ?", post_id, version).order("version asc").limit(1).to_a
    end
    @subsequent.first
  end

  def current
    @current ||= begin
      PostVersion.where("post_id = ?", post_id).order("version desc").limit(1).to_a
    end
    @current.first
  end

  def visible?
    post&.visible?
  end

  def self.status_fields
    {
      tags: "Tags",
      rating: "Rating",
      parent_id: "Parent",
      source: "Source",
    }
  end

  def pretty_rating
    case rating
    when "q"
      "Questionable"

    when "e"
      "Explicit"

    when "s"
      "Safe"
    end
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

  def undo!
    raise RevertError unless post.visible?

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

    post.save!
  end

  def self.available_includes
    [:updater, :post]
  end

  memoize :previous, :tag_array, :changes, :added_tags_with_fields, :removed_tags_with_fields, :obsolete_removed_tags, :obsolete_added_tags, :unchanged_tags
end
