# frozen_string_literal: true

# A PostQueryBuilder represents a post search. It contains all logic for parsing
# and executing searches.
#
# @example
#   PostQueryBuilder.new(PostQuery.new("touhou rating:s")).build
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
    flagger appealer upvote downvote fav ordfav favgroup ordfavgroup reacted pool
    ordpool note comment commentary id rating source status filetype
    disapproved parent child search embedded md5 pixelhash width height mpixels ratio
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
    disapproved disapproved_asc
    rank
    modqueue
    random
    custom
    none
  ] +
    COUNT_METATAGS +
    COUNT_METATAG_SYNONYMS.flat_map { |str| [str, "#{str}_asc"] } +
    CATEGORY_COUNT_METATAGS.flat_map { |str| [str, "#{str}_asc"] }

  attr_reader :post_query, :current_user, :tag_limit, :safe_mode
  alias_method :safe_mode?, :safe_mode

  # @param post_query [PostQuery] the tag search
  # @param current_user [User] the user performing the search
  # @param tag_limit [Integer] the user's tag limit
  # @param safe_mode [Boolean] whether safe mode is enabled. if true, return only rating:g posts.
  def initialize(post_query, current_user = User.anonymous, tag_limit: nil, safe_mode: false)
    @post_query = post_query
    @current_user = current_user
    @tag_limit = tag_limit
    @safe_mode = safe_mode
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
        relation.metatag_matches(node.name, node.value, current_user, quoted: node.quoted?)
      in :wildcard
        tag_names = Tag.wildcard_matches(node.name).limit(MAX_WILDCARD_TAGS).pluck(:name)
        relation.where_array_includes_any("string_to_array(posts.tag_string, ' ')", tag_names)
      in :not
        children.first.negate_relation
      in :and
        joins = children.flat_map(&:joins_values)
        orders = children.flat_map(&:order_values)
        nodes = children.map { |child| child.except(:joins).joins(joins).order(orders) }
        nodes.reduce(&:and)
      in :or
        joins = children.flat_map(&:joins_values)
        orders = children.flat_map(&:order_values)
        nodes = children.map { |child| child.except(:joins).joins(joins).order(orders) }
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
      relation = relation.order_matches("created_at_asc")
    elsif post_query.has_metatag?(:date, :age) && post_query.find_metatag(:order).in?(["id_desc", nil])
      relation = relation.order_matches("created_at_desc")
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
      relation = relation.order_matches(post_query.find_metatag(:order))
    end

    if count = post_query.find_metatag(:random)
      count = Integer(count).clamp(0, PostSets::Post::MAX_PER_PAGE)
      relation = relation.random(count)
    end

    relation = relation.includes(includes) if includes.present?
    relation
  end

  def paginated_posts(post_query, page, count:, small_search_threshold: Danbooru.config.small_search_threshold.to_i, includes: :media_asset, **options)
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

    if post_query.is_empty_search?
      # If there are no tags in the search, then treat it normally because forcing a bitmap scan wouldn't be beneficial.
      posts = relation
    elsif post_count.nil?
      # If post_count is nil, then the search took too long to count and we don't
      # know whether it's large or small. First we try it normally assuming it's
      # large, then if that times out we try again assuming it's small.
      posts = Post.with_timeout(1000) { relation.load }
      posts = small_search(relation) if posts.nil?
    elsif post_count <= small_search_threshold
      # Otherwise if we know the search is small, then treat it as a small search.
      posts = small_search(relation)
    elsif post_query.tags.any?(&:is_deprecated?)
      # If the search contains a deprecated tag, then assume the tag is small, even if it's over the threshold. Most
      # deprecated tags are small enough that a bitmap scan is faster than a sequential scan.
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
end
