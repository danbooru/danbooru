class AutocompleteService
  extend Memoist

  POST_STATUSES = %w[active deleted pending flagged appealed banned modqueue unmoderated]

  STATIC_METATAGS = {
    status: %w[any] + POST_STATUSES,
    child: %w[any none] + POST_STATUSES,
    parent: %w[any none] + POST_STATUSES,
    rating: %w[safe questionable explicit],
    locked: %w[rating note status],
    embedded: %w[true false],
    filetype: %w[jpg png gif swf zip webm mp4],
    commentary: %w[true false translated untranslated],
    disapproved: PostDisapproval::REASONS,
    order: PostQueryBuilder::ORDER_METATAGS
  }

  attr_reader :query, :type, :limit, :current_user

  def initialize(query, type, current_user: User.anonymous, limit: 10)
    @query = query.to_s
    @type = type.to_sym
    @current_user = current_user
    @limit = limit
  end

  def autocomplete_results
    case type
    when :tag_query
      autocomplete_tag_query(query)
    when :tag
      autocomplete_tag(query)
    when :artist
      autocomplete_artist(query)
    when :wiki_page
      autocomplete_wiki_page(query)
    when :user
      autocomplete_user(query)
    when :mention
      autocomplete_mention(query)
    when :pool
      autocomplete_pool(query)
    when :favorite_group
      autocomplete_favorite_group(query)
    when :saved_search_label
      autocomplete_saved_search_label(query)
    when :opensearch
      autocomplete_opensearch(query)
    else
      []
    end
  end

  def autocomplete_tag_query(string)
    term = PostQueryBuilder.new(string).terms.first
    return [] if term.nil?

    case term.type
    when :tag
      autocomplete_tag(term.name)
    when :metatag
      autocomplete_metatag(term.name, term.value)
    end
  end

  def autocomplete_tag(string)
    if string.starts_with?("/")
      string = string + "*" unless string.include?("*")
      results = tag_matches(string)
      results += tag_abbreviation_matches(string)
      results = results.uniq.sort_by { |r| [r[:antecedent].length, -r[:post_count]] }.take(limit)
    elsif string.include?("*")
      results = tag_matches(string)
    else
      results = tag_matches(string + "*")
      results = tag_autocorrect_matches(string) if results.blank?
    end

    results
  end

  def tag_matches(string)
    name_matches = Tag.nonempty.name_matches(string).order(post_count: :desc).limit(limit)
    alias_matches = Tag.nonempty.alias_matches(string).order(post_count: :desc).limit(limit)
    union = "((#{name_matches.to_sql}) UNION (#{alias_matches.to_sql})) AS tags"
    tags = Tag.from(union).order(post_count: :desc).limit(limit).includes(:consequent_aliases)

    tags.map do |tag|
      { type: "tag", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: tag.tag_alias_for_pattern(string)&.antecedent_name }
    end
  end

  def tag_abbreviation_matches(string)
    tags = Tag.nonempty.abbreviation_matches(string).order(post_count: :desc).limit(limit)

    tags.map do |tag|
      { type: "tag", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: "/" + tag.abbreviation }
    end
  end

  def tag_autocorrect_matches(string)
    tags = Tag.nonempty.fuzzy_name_matches(string).order_similarity(string).limit(limit)

    tags.map do |tag|
      { type: "tag", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count }
    end
  end

  def autocomplete_metatag(metatag, value)
    results = case metatag.to_sym
    when :user, :approver, :commenter, :comm, :noter, :noteupdater, :commentaryupdater,
         :artcomm, :fav, :ordfav, :appealer, :flagger, :upvote, :downvote
      autocomplete_user(value)
    when :pool, :ordpool
      autocomplete_pool(value)
    when :favgroup, :ordfavgroup
      autocomplete_favorite_group(value)
    when :search
      autocomplete_saved_search_label(value)
    when *STATIC_METATAGS.keys
      autocomplete_static_metatag(metatag, value)
    end

    results.map do |result|
      { **result, value: metatag + ":" + result[:value] }
    end
  end

  def autocomplete_static_metatag(metatag, value)
    values = STATIC_METATAGS[metatag.to_sym]
    results = values.select { |v| v.starts_with?(value) }.sort.take(limit)

    results.map do |v|
      { label: metatag + ":" + v, value: v }
    end
  end

  def autocomplete_pool(string)
    string = "*" + string + "*" unless string.include?("*")
    pools = Pool.undeleted.name_matches(string).search(order: "post_count").limit(limit)

    pools.map do |pool|
      { type: "pool", label: pool.pretty_name, value: pool.name, post_count: pool.post_count, category: pool.category }
    end
  end

  def autocomplete_favorite_group(string)
    string = "*" + string + "*" unless string.include?("*")
    favgroups = FavoriteGroup.visible(current_user).where(creator: current_user).name_matches(string).search(order: "post_count").limit(limit)

    favgroups.map do |favgroup|
      { label: favgroup.pretty_name, value: favgroup.name, post_count: favgroup.post_count }
    end
  end

  def autocomplete_saved_search_label(string)
    labels = SavedSearch.search_labels(current_user.id, label: string).take(limit)

    labels.map do |label|
      { label: label.tr("_", " "), value: label }
    end
  end

  def autocomplete_artist(string)
    string = string + "*" unless string.include?("*")
    artists = Artist.undeleted.name_matches(string).search(order: "post_count").limit(limit)

    artists.map do |artist|
      { type: "tag", label: artist.pretty_name, value: artist.name, category: Tag.categories.artist }
    end
  end

  def autocomplete_wiki_page(string)
    string = string + "*" unless string.include?("*")
    wiki_pages = WikiPage.undeleted.title_matches(string).search(order: "post_count").limit(limit)

    wiki_pages.map do |wiki_page|
      { type: "tag", label: wiki_page.pretty_title, value: wiki_page.title, category: wiki_page.tag&.category }
    end
  end

  def autocomplete_user(string)
    string = string + "*" unless string.include?("*")
    users = User.search(name_matches: string, current_user_first: true, order: "post_upload_count").limit(limit)

    users.map do |user|
      { type: "user", label: user.pretty_name, value: user.name, level: user.level_string }
    end
  end

  def autocomplete_mention(string)
    autocomplete_user(string).map do |result|
      { **result, value: "@" + result[:value] }
    end
  end

  def autocomplete_opensearch(string)
    results = autocomplete_tag(string).map { |result| result[:value] }
    [query, results]
  end

  def cache_duration
    if autocomplete_results.size == limit
      24.hours
    else
      1.hour
    end
  end

  # Queries that don't depend on the current user are safe to cache publicly.
  def cache_publicly?
    if type == :tag_query && parsed_search&.type == :tag
      true
    elsif type.in?(%i[tag artist wiki_page pool opensearch])
      true
    else
      false
    end
  end

  def parsed_search
    PostQueryBuilder.new(query).terms.first
  end

  memoize :autocomplete_results
end
