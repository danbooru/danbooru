# frozen_string_literal: true

class PostQuery
  extend Memoist

  private attr_reader :current_user, :tag_limit, :safe_mode, :hide_deleted_posts, :builder

  delegate :tag?, :metatag?, :wildcard?, :metatags, :wildcards, :tag_names, :metatags, to: :ast
  alias_method :safe_mode?, :safe_mode
  alias_method :hide_deleted_posts?, :hide_deleted_posts

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

  def fast_count(...)
    builder.normalized_query.fast_count(...)
  end

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

  def is_single_tag?
    ast.tag?
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

  # Return a new PostQuery with aliases replaced, implicit metatags added, and the query converted to conjunctive normal form.
  def normalize
    replace_aliases.with_implicit_metatags.to_cnf
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

  memoize :tags, :normalize, :replace_aliases, :with_implicit_metatags, :to_cnf, :aliases, :implicit_metatags, :hide_deleted?
end
