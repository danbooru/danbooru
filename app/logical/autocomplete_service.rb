# frozen_string_literal: true

# Autocomplete tags, usernames, pools, and more.
#
# @example
#   AutocompleteService.new("touho", :tag).autocomplete_results
#   #=> [{ type: :tag, label: "touhou", value: "touhou", category: 3, post_count: 42 }]
#
# @see AutocompleteController
class AutocompleteService
  extend Memoist

  POST_STATUSES = %w[active deleted pending flagged appealed banned modqueue unmoderated]

  STATIC_METATAGS = {
    is: %w[parent child sfw nsfw wiki_image] + POST_STATUSES + MediaAsset::FILE_TYPES + Post::RATINGS.values.map(&:downcase),
    has: %w[parent children source appeals flags replacements comments commentary notes pools],
    status: %w[any] + POST_STATUSES,
    child: %w[any none] + POST_STATUSES,
    parent: %w[any none] + POST_STATUSES,
    rating: Post::RATINGS.values.map(&:downcase),
    embedded: %w[true false],
    filetype: MediaAsset::FILE_TYPES,
    commentary: %w[true false translated untranslated],
    disapproved: PostDisapproval::REASONS,
    order: PostQueryBuilder::ORDER_METATAGS
  }

  TAG_PREFIXES = TagCategory.mapping.keys.map { |prefix| prefix + ":" }

  attr_reader :query, :type, :limit, :current_user, :enabled
  alias_method :enabled?, :enabled

  # A Result represents a single autocomplete entry. `label` is the pretty name to
  # display in the autocomplete menu and `value` is the actual string to insert.
  class Result < Struct.new(:type, :label, :value, :category, :post_count, :id, :level, :antecedent, :tag, keyword_init: true)
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    def serializable_hash(...)
      to_h.compact_blank
    end
  end

  # Perform completion for the given search type and query.
  # @param query [String] the string being completed
  # @param type [String] the type of completion being performed
  # @param current_user [User] the user we're performing completion for
  # @param limit [Integer] the max number of results to return
  def initialize(query, type, current_user: User.anonymous, limit: 10, enabled: Danbooru.config.autocomplete_enabled?.to_s.truthy?)
    @query = query.to_s
    @type = type.to_s.to_sym
    @current_user = current_user
    @limit = limit
    @enabled = enabled
  end

  # Return the results of the completion.
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_results
    return [] if !enabled?
    return autocomplete_opensearch(query) if type == :opensearch

    case type
    when :tag_query
      autocomplete_tag_query
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
    when :emoji
      autocomplete_emoji(query)
    when :pool
      autocomplete_pool(query)
    when :favorite_group
      autocomplete_favorite_group(query)
    when :saved_search_label
      autocomplete_saved_search_label(query)
    else
      []
    end.map { |result| Result.new(result) }
  end

  # Complete a tag search (a regular tag or a metatag)
  #
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_tag_query
    if metatag.present?
      autocomplete_metatag(metatag.name, metatag.value)
    else
      tag = Tag.normalize_name(query)
      autocomplete_tag(tag)
    end
  end

  # Find tags matching a search.
  #
  # If the string is non-English, translate it to a Danbooru tag.
  # If the string is a slash abbreviation, expand the abbreviation.
  # If the string has a wildcard, do a wildcard search.
  # If the string doesn't match anything, perform autocorrect.
  #
  # @param string [String] the string to complete
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_tag(string)
    return [] if string.size > TagNameValidator::MAX_TAG_LENGTH
    return [] if string.start_with?("http://", "https://")

    # XXX convert to NFKC? deaccent?
    if !string.ascii_only?
      results = tag_other_name_matches(string)
    elsif string.starts_with?("/")
      results = tag_abbreviation_matches(string)
    elsif string.include?("*")
      results = tag_wildcard_matches(string)
    elsif Tag.parsable_into_words?(string) # do a word match if the search contains at least 2 contiguous letters or numbers
      results = tag_word_matches(string)
      results = tag_autocorrect_matches(string) if results.blank?
    else
      results = tag_prefix_matches(string)
    end

    results
  end

  # Find tags or tag aliases containing all the words in the search string, in any order.
  # Example: "haruhi_suzumiya" => "suzumiya_haruhi_no_yuuutsu"
  #
  # Rank results with exact matches first (unless it's a small tag), then substring matches
  # next (e.g. tags where the words are in the same order and next to each other), then word
  # matches last (e.g. tag where the words are in a different order, or not next to each other).
  #
  # @param string [String] the string to complete
  # @return [Array<Hash>] the autocomplete results
  def tag_word_matches(string)
    query = Tag.parse_query(string)

    name_matches = Tag.nonempty.where_all_in_array_like(:words, query)
    alias_matches = Tag.nonempty.where(name: TagAlias.active.joins(:antecedent_tag).where_all_in_array_like("tags.words", query).select(:consequent_name))
    union = "((#{name_matches.to_sql}) UNION (#{alias_matches.to_sql})) AS tags"
    tags = Tag.from(union).includes(:consequent_aliases).order(post_count: :desc, name: :asc).limit(100)

    results = tags.map do |tag|
      antecedent = tag.tag_alias_for_word_pattern(string)&.antecedent_name
      { type: "tag-word", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: antecedent, tag: tag }
    end

    results = results.sort_by do |result|
      name = result[:antecedent] || result[:value]
      post_count = result[:post_count]

      large = post_count > 100 ? 1 : 0
      exact = name == string ? 1 : 0
      substr = name.include?(string) ? 1 : 0

      # If the search contains punctuation, rank exact matches first then substring matches. Otherwise, if it
      # doesn't contain any punctuation, rank exact matches among large tags before small tags. This is so we
      # rank exact matches first, but not if they're random small character or artist tags with simple names.
      if string.match?(/[^a-zA-Z0-9]/)
        [-exact, -substr, -post_count, result[:value]]
      else
        [-large, -exact, -substr, -post_count, result[:value]]
      end
    end

    results.take(limit)
  end

  # Find tags or tag aliases starting with the given search string.
  #
  # @param string [String] the string to complete
  # @return [Array<Hash>] the autocomplete results
  def tag_prefix_matches(string)
    tag_wildcard_matches(string.escape_wildcards + "*")
  end

  # Find tags or tag aliases matching a wildcard search.
  #
  # @param string [String] the string to complete
  # @return [Array<Hash>] the autocomplete results
  def tag_wildcard_matches(string)
    name_matches = Tag.nonempty.name_matches(string).order(post_count: :desc).limit(limit)
    alias_matches = Tag.nonempty.alias_matches(string).order(post_count: :desc).limit(limit)
    union = "((#{name_matches.to_sql}) UNION (#{alias_matches.to_sql})) AS tags"
    tags = Tag.from(union).order(post_count: :desc).limit(limit).includes(:consequent_aliases)

    tags.map do |tag|
      antecedent = tag.tag_alias_for_pattern(string)&.antecedent_name
      type = antecedent.present? ? "tag-alias" : "tag"
      { type: type, label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: antecedent, tag: tag }
    end
  end

  # Find tags matching a slash abbreviation.
  # Example: /evth => eyebrows_visible_through_hair
  #
  # @param string [String] the string to complete
  # @param max_length [Integer] the max abbreviation length
  # @return [Array<Hash>] the autocomplete results
  def tag_abbreviation_matches(string, max_length: 10)
    return [] if string.size > max_length

    string += "*" unless string.include?("*")
    tags = Tag.nonempty.abbreviation_matches(string).order(post_count: :desc).limit(limit)

    results = tags.map do |tag|
      { type: "tag-abbreviation", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: "/" + tag.abbreviation, tag: tag }
    end.sort_by do |r|
      [r[:antecedent].to_s.size, -r[:post_count]]
    end

    results.uniq { |r| r[:value] }.take(limit)
  end

  # Find tags matching a mispelled tag.
  # Example: logn_hair => long_hair
  #
  # @param string [String] the string to complete
  # @return [Array<Hash>] the autocomplete results
  def tag_autocorrect_matches(string)
    # autocorrect uses trigram indexing, which needs at least 3 alphanumeric characters to work.
    return [] if string.remove(/[^a-zA-Z0-9]/).size < 3

    tags = Tag.nonempty.autocorrect_matches(string).limit(limit)

    tags.map do |tag|
      { type: "tag-autocorrect", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: string, tag: tag }
    end
  end

  # Find tags matching a non-English string. Does a `name*` search in wiki page
  # and artist other names to translate the non-English tag to a Danbooru tag.
  # Example: 東方 => touhou.
  #
  # @param string [String] the string to complete
  # @return [Array<Hash>] the autocomplete results
  def tag_other_name_matches(string)
    artists = Artist.undeleted.where_any_in_array_starts_with(:other_names, string)
    wikis = WikiPage.undeleted.where_any_in_array_starts_with(:other_names, string)
    tags = Tag.where(name: wikis.select(:title)).or(Tag.where(name: artists.select(:name)))
    tags = tags.nonempty.order(post_count: :desc).limit(limit).includes(:wiki_page, :artist)

    tags.map do |tag|
      other_names = tag.artist&.other_names.to_a + tag.wiki_page&.other_names.to_a
      antecedent = other_names.find { |other_name| other_name.ilike?(string + "*") }
      { type: "tag-other-name", label: tag.pretty_name, value: tag.name, category: tag.category, post_count: tag.post_count, antecedent: antecedent, tag: tag }
    end
  end

  # Complete a metatag.
  # @param metatag [String] the type of metatag to complete
  # @param value [String] the value of the metatag
  # @return [Array<Hash>] the autocomplete results
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
    when :ai, :unaliased
      autocomplete_tag(value)
    when *STATIC_METATAGS.keys
      autocomplete_static_metatag(metatag, value)
    else
      []
    end

    results.map do |result|
      { **result, value: metatag + ":" + result[:value] }
    end
  end

  # Complete a static metatag: rating, filetype, etc.
  # @param metatag [String] the type of metatag to complete
  # @param value [String] the value of the metatag
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_static_metatag(metatag, value)
    values = STATIC_METATAGS[metatag.to_sym]
    results = values.select { |v| v.starts_with?(value.downcase) }.sort.take(limit)

    results.map do |v|
      { type: "static", label: v, value: v }
    end
  end

  # Complete a pool name. Does a `*name*` search.
  # @param string [String] the name of the pool
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_pool(string)
    pools = Pool.undeleted.name_contains(string).search({ order: "post_count" }, current_user).limit(limit)

    pools.map do |pool|
      { type: "pool", label: pool.pretty_name, value: pool.name, id: pool.id, post_count: pool.post_count, category: pool.category }
    end
  end

  # Complete a favorite group name. Does a `*name*` search.
  # @param string [String] the name of the favgroup
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_favorite_group(string)
    favgroups = FavoriteGroup.visible(current_user).where(creator: current_user).name_contains(string).search({ order: "post_count" }, current_user).limit(limit)

    favgroups.map do |favgroup|
      { label: favgroup.pretty_name, value: favgroup.name, post_count: favgroup.post_count }
    end
  end

  # Complete a saved search label. Does a `*name*` search.
  # @param string [String] the name of the label
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_saved_search_label(string)
    string = "*" + string + "*" unless string.include?("*")
    labels = current_user.saved_searches.labels_like(string).take(limit)

    labels.map do |label|
      { label: label.tr("_", " "), value: label }
    end
  end

  # Complete an artist name. Does a `name*` search.
  # @param string [String] the name of the artist
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_artist(string)
    string = string + "*" unless string.include?("*")
    artists = Artist.undeleted.name_matches(string).search({ order: "post_count" }, current_user).limit(limit)

    artists.map do |artist|
      { type: "tag", label: artist.pretty_name, value: artist.name, category: Tag.categories.artist }
    end
  end

  # Complete a wiki name. Does a `name*` search.
  # @param string [String] the name of the wiki
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_wiki_page(string)
    string = string + "*" unless string.include?("*")
    wiki_pages = WikiPage.undeleted.title_matches(string).search({ order: "post_count" }, current_user).limit(limit)

    wiki_pages.map do |wiki_page|
      { type: "tag", label: wiki_page.pretty_title, value: wiki_page.title, category: wiki_page.tag&.category }
    end
  end

  # Complete a user name. Does a `name*` search.
  # @param string [String] the name of the user
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_user(string)
    string = string + "*" unless string.include?("*")
    users = User.search({ name_matches: string, current_user_first: true, order: "post_upload_count" }, current_user).limit(limit)

    users.map do |user|
      { type: "user", label: user.pretty_name, value: user.name, id: user.id, level: user.level_string.downcase }
    end
  end

  # Complete an @mention for a user name. Does a `name*` search.
  # @param string [String] the name of the user
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_mention(string)
    autocomplete_user(string).map do |result|
      { **result, type: "mention", value: "@" + result[:value] }
    end
  end

  # Complete an emoji reference (e.g. `:smile:`).

  # @param string [String] The name of the emoji (e.g. `smile`, not `:smile:`)
  # @return [Array<Hash>] the autocomplete results
  def autocomplete_emoji(emoji)
    normalized_emoji = emoji.downcase.chomp(":")
    emojis = Danbooru.config.dtext_emojis.keys

    results = emojis.grep(/#{normalized_emoji}/i).sort_by do |match|
      exact = match.casecmp?(normalized_emoji) ? 1 : 0
      prefix = match.downcase.starts_with?(normalized_emoji) ? 1 : 0

      # Sort exact name matches first, then prefix matches, then sort by name.
      [-exact, -prefix, match]
    end.take(limit)

    results.map do |v|
      { type: "emoji", label: ":#{v}:", value: ":#{v}:" }
    end
  end

  # Complete a search typed in the browser address bar.
  # @param string [String] the name of the tag
  # @return [Array<(String, [Array<String>])>] the autocomplete results
  # @see https://en.wikipedia.org/wiki/OpenSearch
  # @see https://developer.mozilla.org/en-US/docs/Web/OpenSearch
  def autocomplete_opensearch(string)
    results = autocomplete_tag(string).map { |result| result[:value] }
    [query, results]
  end

  # How long autocomplete results can be cached by the browser. Stale results will be refreshed in the background.
  def cache_duration
    10.minutes
  end

  # How long stale results can be used while they're refreshed in the background.
  def stale_while_revalidate_duration
    1.day
  end

  # Whether the results can be safely cached with `Cache-Control: public`.
  # Queries that don't depend on the current user are safe to cache publicly.
  def cache_publicly?
    if type == :tag_query && parsed_query.tag_names.one?
      true
    elsif type.in?(%i[tag artist wiki_page pool emoji opensearch])
      true
    else
      false
    end
  end

  def parsed_query
    PostQuery.new(query)
  end

  def metatag
    parsed_query.metatags.first if type == :tag_query && parsed_query.metatags.one?
  end

  memoize :autocomplete_results, :parsed_query, :metatag
end
