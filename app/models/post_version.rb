# frozen_string_literal: true

class PostVersion < ApplicationRecord
  # The maximum number of tags to display in a tag edit. If an edit has more than this many tags, then they will be
  # collapsed instead of showing the full list on the post versions page.
  MAX_DISPLAY_TAGS = 300

  class RevertError < StandardError; end
  extend Memoist

  belongs_to :post
  belongs_to :parent, class_name: "Post", optional: true
  belongs_to_updater counter_cache: "post_update_count"

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

    def search(params, current_user)
      q = search_attributes(params, [:id, :updater, :post, :tags, :added_tags, :removed_tags, :rating, :rating_changed, :parent, :parent_changed, :source, :source_changed, :version, :updated_at], current_user: current_user)

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

  extend SearchMethods

  def tag_array
    tags.split
  end

  def previous
    @previous ||= begin
      # HACK: if all the post versions for this post have already been preloaded,
      # we can use that to avoid a SQL query.
      if association(:post).loaded? && post && post.association(:versions).loaded?
        [post.versions.sort_by(&:version).reverse.find { |v| v.version < version }]
      else
        PostVersion.where("post_id = ? and version < ?", post_id, version).order("version desc").limit(1).to_a
      end
    end
    @previous.first
  end

  def current
    @current ||= PostVersion.where(post_id: post_id).order("version desc").limit(1).to_a
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
    Post::RATINGS[rating] # XXX some old post versions have nil ratings.
  end

  def changes
    delta = {
      added_tags: added_tags,
      removed_tags: removed_tags,
      obsolete_removed_tags: [],
      obsolete_added_tags: [],
      unchanged_tags: [],
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
    source.gsub(%r{^http://}, "").sub(%r{/.+}, "")
  end

  def undo!
    raise RevertError unless post.visible?

    added = changes[:added_tags] - changes[:obsolete_added_tags]
    removed = changes[:removed_tags] - changes[:obsolete_removed_tags]

    added.each do |tag|
      case tag
      when /^source:/
        post.source = ""
      when /^parent:/
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
