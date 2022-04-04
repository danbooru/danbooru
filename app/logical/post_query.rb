# frozen_string_literal: true

class PostQuery
  extend Memoist

  attr_reader :current_user
  private attr_reader :tag_limit, :safe_mode, :hide_deleted_posts, :builder

  delegate :tag?, :metatag?, :wildcard?, :metatags, :wildcards, :tag_names, :metatags, :to_infix, to: :ast
  alias_method :safe_mode?, :safe_mode
  alias_method :hide_deleted_posts?, :hide_deleted_posts
  alias_method :to_s, :to_infix

  # Return a new PostQuery with aliases replaced.
  def self.normalize(...)
    PostQuery.new(...).replace_aliases.trim
  end

  def initialize(search_or_ast, current_user: User.anonymous, tag_limit: nil, safe_mode: false, hide_deleted_posts: false)
    if search_or_ast.is_a?(AST)
      @ast = search_or_ast
    else
      @search = search_or_ast.to_s
    end

    @current_user = current_user
    @tag_limit = tag_limit
    @safe_mode = safe_mode
    @hide_deleted_posts = hide_deleted_posts
  end

  # Build a new PostQuery from the given AST and the current settings.
  def build(ast)
    PostQuery.new(ast, current_user: current_user, tag_limit: tag_limit, safe_mode: safe_mode, hide_deleted_posts: hide_deleted_posts)
  end

  def builder
    @builder ||= PostQueryBuilder.new(search, current_user, tag_limit: tag_limit, safe_mode: safe_mode, hide_deleted_posts: hide_deleted_posts)
  end

  def search
    @search ||= ast.to_infix
  end

  def ast
    @ast ||= Parser.parse(search)
  end

  def posts
    builder.posts(to_cnf)
  end

  def paginated_posts(...)
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

  # True if the search is a single metatag search for the given metatag.
  def is_metatag?(name, value = nil)
    if value.nil?
      is_single_term? && has_metatag?(name)
    else
      is_single_term? && find_metatag(name) == value.to_s
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
      metatag.name.in?(%w[upvoter upvote downvoter downvote search flagger fav ordfav favgroup ordfavgroup]) ||
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

  # Return a new PostQuery converted to conjunctive normal form.
  def to_cnf
    build(ast.to_cnf)
  end

  # Return a hash mapping aliased tag names to real tag names.
  def aliases
    TagAlias.aliases_for(tag_names)
  end

  # Implicit metatags are metatags added by the user's account settings. rating:s is implicit
  # under safe mode. -status:deleted is implicit when the "hide deleted posts" setting is on.
  def implicit_metatags
    metatags = []
    metatags << AST.metatag("rating", "s") if safe_mode?
    metatags << -AST.metatag("status", "deleted") if hide_deleted?
    metatags
  end

  # XXX unify with PostSets::Post#show_deleted?
  def hide_deleted?
    has_status_metatag = select_metatags(:status).any? { |metatag| metatag.value.downcase.in?(%w[deleted active any all unmoderated modqueue appealed]) }
    hide_deleted_posts? && !has_status_metatag
  end

  concerning :CountMethods do
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
      count = estimated_count if estimate_count
      count = cached_count(timeout) if count.nil? && !skip_cache
      count = exact_count(timeout) if count.nil? && skip_cache
      count
    end

    def estimated_count
      if is_empty_search?
        estimated_row_count
      elsif is_simple_tag?
        tag.try(:post_count)
      elsif is_metatag?(:rating)
        estimated_row_count
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

  memoize :tags, :replace_aliases, :with_implicit_metatags, :to_cnf, :aliases, :implicit_metatags, :hide_deleted?
end
