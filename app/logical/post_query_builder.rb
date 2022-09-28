# frozen_string_literal: true

require "strscan"

# A PostQueryBuilder represents a post search. It contains all logic for parsing
# and executing searches.
#
# @example
#   PostQueryBuilder.new("touhou rating:s").build
#   #=> <set of posts>
#
class PostQueryBuilder
  extend Memoist

  # How many tags a `blah*` search should match.
  MAX_WILDCARD_TAGS = 100

  COUNT_METATAGS = %w[
    comment_count deleted_comment_count active_comment_count
    note_count deleted_note_count active_note_count
    flag_count
    child_count deleted_child_count active_child_count
    pool_count deleted_pool_count active_pool_count series_pool_count collection_pool_count
    appeal_count approval_count replacement_count
  ]

  # allow e.g. `deleted_comments` as a synonym for `deleted_comment_count`
  COUNT_METATAG_SYNONYMS = COUNT_METATAGS.map { |str| str.delete_suffix("_count").pluralize }

  # gentags, arttags, copytags, chartags, metatags
  CATEGORY_COUNT_METATAGS = TagCategory.short_name_list.map { |category| "#{category}tags" }

  METATAGS = %w[
    user approver commenter comm noter noteupdater artcomm commentaryupdater
    flagger appealer upvote downvote fav ordfav favgroup ordfavgroup pool
    ordpool note comment commentary id rating source status filetype
    disapproved parent child search embedded md5 width height mpixels ratio
    score upvotes downvotes favcount filesize date age order limit tagcount pixiv_id pixiv
    unaliased exif duration random is has ai
  ] + COUNT_METATAGS + COUNT_METATAG_SYNONYMS + CATEGORY_COUNT_METATAGS

  ORDER_METATAGS = %w[
    id id_desc
    md5 md5_asc
    score score_asc
    upvotes upvotes_asc
    downvotes downvotes_asc
    favcount favcount_asc
    created_at created_at_asc
    change change_asc
    comment comment_asc
    comment_bumped comment_bumped_asc
    note note_asc
    artcomm artcomm_asc
    mpixels mpixels_asc
    portrait landscape
    filesize filesize_asc
    tagcount tagcount_asc
    duration duration_asc
    rank
    curated
    modqueue
    random
    custom
    none
  ] +
    COUNT_METATAGS +
    COUNT_METATAG_SYNONYMS.flat_map { |str| [str, "#{str}_asc"] } +
    CATEGORY_COUNT_METATAGS.flat_map { |str| [str, "#{str}_asc"] }

  attr_reader :query_string, :current_user, :tag_limit, :safe_mode
  alias_method :safe_mode?, :safe_mode

  # Initialize a post query.
  # @param query_string [String] the tag search
  # @param current_user [User] the user performing the search
  # @param tag_limit [Integer] the user's tag limit
  # @param safe_mode [Boolean] whether safe mode is enabled. if true, return only rating:s posts.
  def initialize(query_string, current_user = User.anonymous, tag_limit: nil, safe_mode: false)
    @query_string = query_string
    @current_user = current_user
    @tag_limit = tag_limit
    @safe_mode = safe_mode
  end

  def metatag_matches(name, value, relation = Post.all, quoted: false)
    case name
    when "id"
      relation.attribute_matches(value, :id)
    when "md5"
      relation.attribute_matches(value, :md5, :md5)
    when "width"
      relation.attribute_matches(value, :image_width)
    when "height"
      relation.attribute_matches(value, :image_height)
    when "mpixels"
      relation.attribute_matches(value, "posts.image_width * posts.image_height / 1000000.0", :float)
    when "ratio"
      relation.attribute_matches(value, "ROUND(1.0 * posts.image_width / GREATEST(1, posts.image_height), 2)", :ratio)
    when "score"
      relation.attribute_matches(value, :score)
    when "upvotes"
      relation.attribute_matches(value, :up_score)
    when "downvotes"
      relation.attribute_matches(value, "ABS(posts.down_score)")
    when "favcount"
      relation.attribute_matches(value, :fav_count)
    when "filesize"
      relation.attribute_matches(value, :file_size, :filesize)
    when "filetype"
      relation.attribute_matches(value, :file_ext, :enum)
    when "date"
      relation.attribute_matches(value, :created_at, :date)
    when "age"
      relation.attribute_matches(value, :created_at, :age)
    when "pixiv", "pixiv_id"
      relation.attribute_matches(value, :pixiv_id)
    when "tagcount"
      relation.attribute_matches(value, :tag_count)
    when "duration"
      relation.attribute_matches(value, "media_assets.duration", :float).joins(:media_asset)
    when "is"
      relation.is_matches(value, current_user)
    when "has"
      relation.has_matches(value)
    when "status"
      relation.status_matches(value, current_user)
    when "parent"
      relation.parent_matches(value)
    when "child"
      relation.child_matches(value)
    when "rating"
      relation.rating_matches(value)
    when "embedded"
      relation.embedded_matches(value)
    when "source"
      relation.source_matches(value, quoted)
    when "disapproved"
      relation.disapproved_matches(value, current_user)
    when "commentary"
      relation.commentary_matches(value, quoted)
    when "note"
      relation.note_matches(value)
    when "comment"
      relation.comment_matches(value)
    when "search"
      relation.saved_search_matches(value, current_user)
    when "pool"
      relation.pool_matches(value)
    when "ordpool"
      relation.ordpool_matches(value)
    when "favgroup"
      relation.favgroup_matches(value, current_user)
    when "ordfavgroup"
      relation.ordfavgroup_matches(value, current_user)
    when "fav"
      relation.favorites_include(value, current_user)
    when "ordfav"
      relation.ordfav_matches(value, current_user)
    when "unaliased"
      relation.tags_include(value)
    when "exif"
      relation.exif_matches(value)
    when "ai"
      relation.ai_tags_include(value)
    when "user"
      relation.uploader_matches(value)
    when "approver"
      relation.approver_matches(value)
    when "flagger"
      relation.user_subquery_matches(PostFlag.unscoped.category_matches("normal"), value, current_user)
    when "appealer"
      relation.user_subquery_matches(PostAppeal.unscoped, value, current_user)
    when "commenter", "comm"
      relation.user_subquery_matches(Comment.unscoped, value, current_user)
    when "commentaryupdater", "artcomm"
      relation.user_subquery_matches(ArtistCommentaryVersion.unscoped, value, current_user, field: :updater)
    when "noter"
      relation.user_subquery_matches(NoteVersion.unscoped.where(version: 1), value, current_user, field: :updater)
    when "noteupdater"
      relation.user_subquery_matches(NoteVersion.unscoped, value, current_user, field: :updater)
    when "upvoter", "upvote"
      relation.user_subquery_matches(PostVote.active.positive.visible(current_user), value, current_user, field: :user)
    when "downvoter", "downvote"
      relation.user_subquery_matches(PostVote.active.negative.visible(current_user), value, current_user, field: :user)
    when "random"
      relation # handled in the `build` method
    when *CATEGORY_COUNT_METATAGS
      short_category = name.delete_suffix("tags")
      category = TagCategory.short_name_mapping[short_category]
      attribute = "tag_count_#{category}"
      relation.attribute_matches(value, attribute.to_sym)
    when *COUNT_METATAGS
      relation.attribute_matches(value, name.to_sym)
    when "limit"
      relation
    when "order"
      relation
    else
      raise NotImplementedError, "metatag not implemented"
    end
  end

  def table_for_metatag(metatag)
    if metatag.in?(COUNT_METATAGS)
      metatag[/(?<table>[a-z]+)_count\z/i, :table]
    else
      nil
    end
  end

  def tables_for_query(post_query)
    metatag_names = post_query.metatags.map(&:name)
    metatag_names << post_query.find_metatag(:order).remove(/_(asc|desc)\z/i) if post_query.has_metatag?(:order)

    tables = metatag_names.map { |metatag| table_for_metatag(metatag.to_s) }
    tables.compact.uniq
  end

  def add_joins(post_query, relation)
    tables = tables_for_query(post_query)
    relation = relation.with_stats(tables)
    relation
  end


  # Generate a SQL relation from a PostQuery.
  def build_relation(post_query, relation = Post.all)
    post_query.ast.visit do |node, *children|
      case node.type
      in :all
        relation.all
      in :none
        relation.none
      in :tag
        relation.tags_include(node.name)
      in :metatag
        metatag_matches(node.name, node.value, relation, quoted: node.quoted?)
      in :wildcard
        tag_names = Tag.wildcard_matches(node.name).limit(MAX_WILDCARD_TAGS).pluck(:name)
        relation.where_array_includes_any("string_to_array(posts.tag_string, ' ')", tag_names)
      in :not
        children.first.negate_relation
      in :and
        joins = children.flat_map(&:joins_values)
        orders = children.flat_map(&:order_values)
        nodes = children.map { |child| child.joins(joins).order(orders) }
        nodes.reduce(&:and)
      in :or
        joins = children.flat_map(&:joins_values)
        orders = children.flat_map(&:order_values)
        nodes = children.map { |child| child.joins(joins).order(orders) }
        nodes.reduce(&:or)
      end
    end
  end

  def posts(post_query, relation = Post.unscoped, includes: nil)
    relation = add_joins(post_query, relation)
    relation = build_relation(post_query, relation)

    # HACK: if we're using a date: or age: metatag, default to ordering by
    # created_at instead of id so that the query will use the created_at index.
    if post_query.has_metatag?(:date, :age) && post_query.find_metatag(:order).in?(["id", "id_asc"])
      relation = search_order(relation, "created_at_asc")
    elsif post_query.has_metatag?(:date, :age) && post_query.find_metatag(:order).in?(["id_desc", nil])
      relation = search_order(relation, "created_at_desc")
    elsif post_query.find_metatag(:order) == "custom"
      ids = post_query.select_metatags(:id).map(&:value)

      if ids.size == 1
        relation = relation.order_custom(ids.first)
      else
        relation = relation.none
      end
    elsif post_query.has_metatag?(:ordfav, :ordpool, :ordfavgroup)
      # no-op
    else
      relation = search_order(relation, post_query.find_metatag(:order))
    end

    if count = post_query.find_metatag(:random)
      count = Integer(count).clamp(0, PostSets::Post::MAX_PER_PAGE)
      relation = relation.random(count)
    end

    relation = relation.includes(includes)
    relation
  end

  def paginated_posts(post_query, page, count:, small_search_threshold: Danbooru.config.small_search_threshold.to_i, includes: nil, **options)
    posts = posts(post_query, includes: includes).paginate(page, count: count, **options)
    posts = optimize_search(posts, count, small_search_threshold)
    posts.load
  end

  # XXX This is an ugly hack to try to deal with slow searches. By default,
  # Postgres wants to do an index scan down the post id index for large
  # order:id searches, and a bitmap scan on the tag index for small searches.
  # The problem is that Postgres can't always tell whether a search is large or
  # small. For large mutually-exclusive tags like 1girl + multiple_girls,
  # Postgres assumes the search is large when actually it's small. For small
  # tags, Postgres sometimes assumes tags in the 10k-50k range are large enough
  # for a post id index scan, when in reality a tag index bitmap scan would be
  # better.
  def optimize_search(relation, post_count, small_search_threshold)
    return relation unless small_search_threshold.present?

    order_values = relation.order_values.map { |order| order.try(:to_sql) || order.to_s }.map(&:downcase)
    return relation unless order_values.in?([["posts.id desc"], ["posts.id asc"]])

    if post_count.nil?
      # If post_count is nil, then the search took too long to count and we don't
      # know whether it's large or small. First we try it normally assuming it's
      # large, then if that times out we try again assuming it's small.
      posts = Post.with_timeout(1000) { relation.load }
      posts = small_search(relation) if posts.nil?
    elsif post_count <= small_search_threshold
      # Otherwise if we know the search is small, then treat it as a small search.
      posts = small_search(relation)
    else
      # Otherwise if we know it's large, treat it normally
      posts = relation
    end

    posts
  end

  # Perform a search, forcing Postgres to do a bitmap scan on the tags index.
  # https://www.postgresql.org/docs/current/runtime-config-query.html
  def small_search(relation)
    Post.transaction do
      Post.connection.execute("SET LOCAL enable_seqscan = off")
      Post.connection.execute("SET LOCAL enable_indexscan = off")
      relation.load
    end
  end

  def search_order(relation, order)
    case order.to_s.downcase
    when "id", "id_asc"
      relation = relation.reorder("posts.id ASC")

    when "id_desc"
      relation = relation.reorder("posts.id DESC")

    when "md5", "md5_desc"
      relation = relation.reorder("posts.md5 DESC")

    when "md5_asc"
      relation = relation.reorder("posts.md5 ASC")

    when "score", "score_desc"
      relation = relation.reorder("posts.score DESC, posts.id DESC")

    when "score_asc"
      relation = relation.reorder("posts.score ASC, posts.id ASC")

    when "upvotes", "upvotes_desc"
      relation = relation.reorder("posts.up_score DESC, posts.id DESC")

    when "upvotes_asc"
      relation = relation.reorder("posts.up_score ASC, posts.id ASC")

    # XXX down_score is negative so order:downvotes sorts lowest-to-highest so that most downvoted is first.
    when "downvotes", "downvotes_desc"
      relation = relation.reorder("posts.down_score ASC, posts.id ASC")

    when "downvotes_asc"
      relation = relation.reorder("posts.down_score DESC, posts.id DESC")

    when "favcount"
      relation = relation.reorder("posts.fav_count DESC, posts.id DESC")

    when "favcount_asc"
      relation = relation.reorder("posts.fav_count ASC, posts.id ASC")

    when "created_at", "created_at_desc"
      relation = relation.reorder("posts.created_at DESC")

    when "created_at_asc"
      relation = relation.reorder("posts.created_at ASC")

    when "change", "change_desc"
      relation = relation.reorder("posts.updated_at DESC, posts.id DESC")

    when "change_asc"
      relation = relation.reorder("posts.updated_at ASC, posts.id ASC")

    when "comment", "comm"
      relation = relation.reorder("posts.last_commented_at DESC NULLS LAST, posts.id DESC")

    when "comment_asc", "comm_asc"
      relation = relation.reorder("posts.last_commented_at ASC NULLS LAST, posts.id ASC")

    when "comment_bumped"
      relation = relation.reorder("posts.last_comment_bumped_at DESC NULLS LAST")

    when "comment_bumped_asc"
      relation = relation.reorder("posts.last_comment_bumped_at ASC NULLS FIRST")

    when "note"
      relation = relation.reorder("posts.last_noted_at DESC NULLS LAST")

    when "note_asc"
      relation = relation.reorder("posts.last_noted_at ASC NULLS FIRST")

    when "artcomm"
      relation = relation.joins("INNER JOIN artist_commentaries ON artist_commentaries.post_id = posts.id")
      relation = relation.reorder("artist_commentaries.updated_at DESC")

    when "artcomm_asc"
      relation = relation.joins("INNER JOIN artist_commentaries ON artist_commentaries.post_id = posts.id")
      relation = relation.reorder("artist_commentaries.updated_at ASC")

    when "mpixels", "mpixels_desc"
      relation = relation.where(Arel.sql("posts.image_width is not null and posts.image_height is not null"))
      # Use "w*h/1000000", even though "w*h" would give the same result, so this can use
      # the posts_mpixels index.
      relation = relation.reorder(Arel.sql("posts.image_width * posts.image_height / 1000000.0 DESC"))

    when "mpixels_asc"
      relation = relation.where("posts.image_width is not null and posts.image_height is not null")
      relation = relation.reorder(Arel.sql("posts.image_width * posts.image_height / 1000000.0 ASC"))

    when "portrait"
      relation = relation.where("posts.image_width IS NOT NULL and posts.image_height IS NOT NULL")
      relation = relation.reorder(Arel.sql("1.0 * posts.image_width / GREATEST(1, posts.image_height) ASC"))

    when "landscape"
      relation = relation.where("posts.image_width IS NOT NULL and posts.image_height IS NOT NULL")
      relation = relation.reorder(Arel.sql("1.0 * posts.image_width / GREATEST(1, posts.image_height) DESC"))

    when "filesize", "filesize_desc"
      relation = relation.reorder("posts.file_size DESC")

    when "filesize_asc"
      relation = relation.reorder("posts.file_size ASC")

    when /\A(?<column>#{COUNT_METATAGS.join("|")})(_(?<direction>asc|desc))?\z/i
      column = $~[:column]
      direction = $~[:direction] || "desc"
      relation = relation.reorder(column => direction, :id => direction)

    when "tagcount", "tagcount_desc"
      relation = relation.reorder("posts.tag_count DESC")

    when "tagcount_asc"
      relation = relation.reorder("posts.tag_count ASC")

    when "duration", "duration_desc"
      relation = relation.joins(:media_asset).reorder("media_assets.duration DESC NULLS LAST, posts.id DESC")

    when "duration_asc"
      relation = relation.joins(:media_asset).reorder("media_assets.duration ASC NULLS LAST, posts.id ASC")

    # artags_desc, copytags_desc, chartags_desc, gentags_desc, metatags_desc
    when /(#{TagCategory.short_name_list.join("|")})tags(?:\Z|_desc)/
      relation = relation.reorder("posts.tag_count_#{TagCategory.short_name_mapping[$1]} DESC")

    # artags_asc, copytags_asc, chartags_asc, gentags_asc, metatags_asc
    when /(#{TagCategory.short_name_list.join("|")})tags_asc/
      relation = relation.reorder("posts.tag_count_#{TagCategory.short_name_mapping[$1]} ASC")

    when "random"
      relation = relation.reorder("random()")

    when "rank"
      relation = relation.where("posts.score > 0 and posts.created_at >= ?", 2.days.ago)
      relation = relation.reorder(Arel.sql("log(3, posts.score) + (extract(epoch from posts.created_at) - extract(epoch from timestamp '2005-05-24')) / 35000 DESC"))

    when "curated"
      contributors = User.bit_prefs_match(:can_upload_free, true)

      relation = relation
        .joins(:favorites)
        .where(favorites: { user: contributors })
        .group("posts.id")
        .select("posts.*, COUNT(*) AS contributor_fav_count")
        .reorder("contributor_fav_count DESC, posts.fav_count DESC, posts.id DESC")

    when "modqueue", "modqueue_desc"
      relation = relation.with_queued_at.reorder("queued_at DESC, posts.id DESC")

    when "modqueue_asc"
      relation = relation.with_queued_at.reorder("queued_at ASC, posts.id ASC")

    when "none"
      relation = relation.reorder(nil)

    else
      relation = relation.reorder("posts.id DESC")
    end

    relation
  end
end
