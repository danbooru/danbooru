# frozen_string_literal: true

class PostQuery
  extend Memoist

  class Error < StandardError; end
  class TagLimitError < Error; end

  # Metatags that don't count against the user's tag limit.
  UNLIMITED_METATAGS = %w[
    status rating limit is id date age filesize filetype parent child md5 width
    height duration mpixels ratio score upvote downvotes favcount embedded
    tagcount pixiv_id pixiv
  ]

  # Metatags that define the order of search results. These metatags can't be used more than once per query.
  ORDER_METATAGS = %w[order ordfav ordfavgroup ordpool]

  # Metatags that can't be used more than once per query, and that can't be used with OR or NOT operators.
  SINGLETON_METATAGS = ORDER_METATAGS + %w[limit random]

  attr_reader :current_user
  private attr_reader :tag_limit, :safe_mode, :builder

  delegate :tag?, :metatag?, :wildcard?, :metatags, :wildcards, :tag_names, :to_infix, :to_pretty_string, to: :ast
  alias_method :safe_mode?, :safe_mode
  alias_method :to_s, :to_infix

  # Return a new PostQuery with aliases replaced.
  def self.normalize(search, ...)
    search = search.to_s.strip

    # Optimize zero tag and single tag searches
    if search.blank?
      PostQuery.new(AST.all, ...)
    elsif search.match?(%r{\A[a-zA-Z0-9][a-zA-Z0-9();/+!?&'._~-]*\z}) && !search.downcase.in?(["and", "or"])
      PostQuery.new(AST.tag(search), ...).replace_aliases
    else
      PostQuery.new(search, ...).replace_aliases.rewrite_opts.trim
    end
  end

  # Perform a search and return the resulting posts
  def self.search(search, ...)
    post_query = PostQuery.normalize(search, ...)
    post_query.validate_tag_limit!
    post_query.with_implicit_metatags.posts
  end

  def initialize(search_or_ast, current_user: User.anonymous, tag_limit: nil, safe_mode: false)
    if search_or_ast.is_a?(AST)
      @ast = search_or_ast
    else
      @search = search_or_ast.to_s
    end

    @current_user = current_user
    @tag_limit = tag_limit
    @safe_mode = safe_mode
  end

  # Build a new PostQuery from the given AST and the current settings.
  def build(ast)
    PostQuery.new(ast, current_user: current_user, tag_limit: tag_limit, safe_mode: safe_mode)
  end

  def builder
    @builder ||= PostQueryBuilder.new(search, current_user, tag_limit: tag_limit, safe_mode: safe_mode)
  end

  def search
    @search ||= ast.to_infix
  end

  def ast
    @ast ||= Parser.parse(search)
  end

  def posts
    validate_metatags!
    builder.posts(to_cnf)
  end

  def paginated_posts(...)
    validate_metatags!
    builder.paginated_posts(to_cnf, ...)
  end

  # The name of the only tag in the query, if the query contains a single tag. The tag may not exist. The query may contain other metatags or wildcards, and the tag may be negated.
  def tag_name
    tag_names.first if has_single_tag?
  end

  # The only tag in the query, if the query contains a single tag. The query may contain other metatags or wildcards, and the tag may be negated.
  def tag
    tags.first if has_single_tag?
  end

  # The list of all tags contained in the query.
  def tags
    Tag.where(name: tag_names)
  end

  # True if this search would return all posts (normally because the search is the empty string).
  def is_empty_search?
    ast.all?
  end

  # True if this search would return nothing (normally because there was a syntax error).
  def is_null_search?
    ast.none?
  end

  # True if the search is a single, non-negated metatag search for the given metatag. Assumes the query has been normalized.
  def is_metatag?(name, value = nil)
    if value.nil?
      metatag? && has_metatag?(name)
    else
      metatag? && find_metatag(name) == value.to_s
    end
  end

  # True if the search consists of a single tag, metatag, or wildcard.
  def is_single_term?
    tag_names.size + metatags.size + wildcards.size == 1
  end

  # True if this search consists only of a single non-negated tag, with no other metatags or operators.
  def is_simple_tag?
    ast.tag?
  end

  # True if the search contains a single tag. It may have other metatags or wildcards, and the tag may be negated.
  def has_single_tag?
    tag_names.one?
  end

  # True if the search depends on the current user because of permissions or privacy settings.
  def is_user_dependent_search?
    metatags.any? do |metatag|
      metatag.name.in?(%w[upvoter upvote downvoter downvote commenter comm search flagger fav ordfav favgroup ordfavgroup]) ||
      metatag.name == "status" && metatag.value == "unmoderated" ||
      metatag.name == "disapproved" && !metatag.value.downcase.in?(PostDisapproval::REASONS)
    end
  end

  def select_metatags(*names)
    metatags.select { |metatag| metatag.name.in?(names.map(&:to_s).map(&:downcase)) }
  end

  def has_metatag?(*names)
    select_metatags(*names).present?
  end

  def find_metatag(*names)
    select_metatags(*names).first&.value
  end

  # Return a new PostQuery with unnecessary AND and OR clauses eliminated.
  def trim
    build(ast.trim)
  end

  # Return a new PostQuery with the '~' operator replaced with OR clauses.
  def rewrite_opts
    build(ast.rewrite_opts)
  end

  # Return a new PostQuery with aliases replaced.
  def replace_aliases
    return self if aliases.empty?
    build(ast.replace_tags(aliases))
  end

  # Return a new PostQuery with implicit metatags (rating:safe and -status:deleted) added.
  def with_implicit_metatags
    return self if implicit_metatags.empty?
    build(AST.new(:and, [ast, *implicit_metatags]))
  end

  # Return a new PostQuery with terms sorted into alphabetical order.
  def sort
    build(ast.sort)
  end

  # Return a new PostQuery converted to conjunctive normal form.
  def to_cnf
    build(ast.to_cnf)
  end

  # Return a hash mapping aliased tag names to real tag names.
  def aliases
    TagAlias.aliases_for(tag_names)
  end

  # Implicit metatags are metatags added by the user's account settings. rating:g,s is implicit under safe mode.
  def implicit_metatags
    return [] unless safe_mode?

    tags = Danbooru.config.safe_mode_restricted_tags.map { |tag| -AST.tag(tag) }
    [AST.metatag("rating", "g"), *tags]
  end

  concerning :CountMethods do
    # @return [Integer, nil] The number of posts returned by the search, or nil on timeout.
    def post_count
      @post_count ||= fast_count
    end

    # Return an estimate of the number of posts returned by the search. By default, we try to use an
    # estimated or cached count before doing an exact count.
    #
    # @param timeout [Integer] The database timeout in milliseconds
    # @param estimate_count [Boolean] If true, estimate the count with inexact methods.
    # @param skip_cache [Boolean] If true, don't use the cached count.
    # @return [Integer, nil] The number of posts, or nil on timeout.
    def fast_count(timeout: 1_000, estimate_count: true, skip_cache: false)
      count = nil
      count = estimated_count(timeout) if estimate_count
      count = cached_count(timeout) if count.nil? && !skip_cache
      count = exact_count(timeout) if count.nil? && skip_cache
      count
    end

    def estimated_count(timeout = 1_000)
      if is_empty_search?
        estimated_row_count
      elsif is_simple_tag?
        tag.try(:post_count)
      elsif is_metatag?(:rating)
        estimated_row_count
      elsif (is_metatag?(:status) || is_metatag?(:is)) && metatags.sole.value.in?(%w[pending flagged appealed modqueue unmoderated])
        exact_count(timeout)
      elsif is_metatag?(:pool) || is_metatag?(:ordpool)
        name = find_metatag(:pool, :ordpool)
        Pool.find_by_name(name)&.post_count || 0
      elsif is_metatag?(:fav) || is_metatag?(:ordfav)
        name = find_metatag(:fav, :ordfav)
        user = User.find_by_name(name)

        if user.nil?
          0
        elsif Pundit.policy!(current_user, user).can_see_favorites?
          user.favorite_count
        else
          nil
        end
      end
    end

    # Estimate the count by parsing the Postgres EXPLAIN output.
    def estimated_row_count
      ExplainParser.new(posts).row_count
    end

    def cached_count(timeout, duration: 5.minutes)
      Cache.get(count_cache_key, duration) do
        exact_count(timeout)
      end
    end

    def exact_count(timeout)
      Post.with_timeout(timeout) do
        posts.count
      end
    end

    def count_cache_key
      if is_user_dependent_search?
        "pfc[#{current_user.id.to_i}]:#{to_s}"
      else
        "pfc:#{to_s}"
      end
    end
  end

  concerning :ValidationMethods do
    def validate_tag_limit!
      return if is_empty_search? || is_simple_tag?
      raise TagLimitError if tag_limit.present? && term_count > tag_limit
    end

    def validate_metatags!
      return if is_empty_search? || is_simple_tag?
      return if metatags.empty?

      order_metatags = select_metatags(*ORDER_METATAGS)
      raise Error, "#{order_metatags.to_sentence} can't be used together." if order_metatags.size > 1

      SINGLETON_METATAGS.each do |name|
        metatag = select_metatags(name).first
        raise Error, "'#{name}:' can't be used more than once." if select_metatags(name).size > 1
        raise Error, "'#{metatag}' can't be negated." if metatag&.parents&.any?(&:not?)
        raise Error, "'#{metatag}' can't be used with the 'or' operator." if metatag&.parents&.any?(&:or?)
      end
    end

    # The number of unique tags, wildcards, and metatags in the search, excluding metatags that don't count against the user's tag limit.
    def term_count
      tag_names.size + wildcards.size + metatags.count { !_1.name.in?(UNLIMITED_METATAGS) }
    end
  end

  memoize :tags, :replace_aliases, :with_implicit_metatags, :to_cnf, :aliases, :implicit_metatags, :term_count
end
