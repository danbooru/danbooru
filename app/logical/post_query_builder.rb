require "strscan"

class PostQueryBuilder
  extend Memoist

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
    ordpool note comment commentary id rating locked source status filetype
    disapproved parent child search embedded md5 width height mpixels ratio
    score favcount filesize date age order limit tagcount pixiv_id pixiv
    unaliased
  ] + COUNT_METATAGS + COUNT_METATAG_SYNONYMS + CATEGORY_COUNT_METATAGS

  ORDER_METATAGS = %w[
    id id_desc
    md5 md5_asc
    score score_asc
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

  UNLIMITED_METATAGS = %w[status rating limit]

  attr_reader :query_string, :current_user, :safe_mode, :hide_deleted_posts
  alias_method :safe_mode?, :safe_mode
  alias_method :hide_deleted_posts?, :hide_deleted_posts

  def initialize(query_string, current_user = User.anonymous, safe_mode: false, hide_deleted_posts: false)
    @query_string = query_string
    @current_user = current_user
    @safe_mode = safe_mode
    @hide_deleted_posts = hide_deleted_posts
  end

  def tags_match(tags, relation)
    tsquery = []

    negated_wildcard_tags, negated_tags = tags.select(&:negated).partition(&:wildcard)
    optional_wildcard_tags, optional_tags = tags.select(&:optional).partition(&:wildcard)
    required_wildcard_tags, required_tags = tags.reject(&:negated).reject(&:optional).partition(&:wildcard)

    negated_tags = negated_tags.map(&:name)
    optional_tags = optional_tags.map(&:name)
    required_tags = required_tags.map(&:name)

    negated_tags += negated_wildcard_tags.flat_map { |tag| Tag.wildcard_matches(tag.name) }
    optional_tags += optional_wildcard_tags.flat_map { |tag| Tag.wildcard_matches(tag.name) }
    optional_tags += required_wildcard_tags.flat_map { |tag| Tag.wildcard_matches(tag.name) }

    tsquery << "!(#{negated_tags.sort.uniq.map(&:to_escaped_for_tsquery).join(" | ")})" if negated_tags.present?
    tsquery << "(#{optional_tags.sort.uniq.map(&:to_escaped_for_tsquery).join(" | ")})" if optional_tags.present?
    tsquery << "(#{required_tags.sort.uniq.map(&:to_escaped_for_tsquery).join(" & ")})" if required_tags.present?

    return relation if tsquery.empty?
    relation.where("posts.tag_index @@ to_tsquery('danbooru', E?)", tsquery.join(" & "))
  end

  def metatags_match(metatags, relation)
    metatags.each do |metatag|
      clause = metatag_matches(metatag.name, metatag.value, quoted: metatag.quoted)
      clause = clause.negate if metatag.negated
      relation = relation.and(clause)
    end

    relation
  end

  def metatag_matches(name, value, quoted: false)
    case name
    when "id"
      attribute_matches(value, :id)
    when "md5"
      attribute_matches(value, :md5, :md5)
    when "width"
      attribute_matches(value, :image_width)
    when "height"
      attribute_matches(value, :image_height)
    when "mpixels"
      attribute_matches(value, "posts.image_width * posts.image_height / 1000000.0", :float)
    when "ratio"
      attribute_matches(value, "ROUND(1.0 * posts.image_width / GREATEST(1, posts.image_height), 2)", :ratio)
    when "score"
      attribute_matches(value, :score)
    when "favcount"
      attribute_matches(value, :fav_count)
    when "filesize"
      attribute_matches(value, :file_size, :filesize)
    when "filetype"
      attribute_matches(value, :file_ext, :enum)
    when "date"
      attribute_matches(value, :created_at, :date)
    when "age"
      attribute_matches(value, :created_at, :age)
    when "pixiv", "pixiv_id"
      attribute_matches(value, :pixiv_id)
    when "tagcount"
      attribute_matches(value, :tag_count)
    when "status"
      status_matches(value)
    when "parent"
      parent_matches(value)
    when "child"
      child_matches(value)
    when "rating"
      Post.where(rating: value.first.downcase)
    when "locked"
      locked_matches(value)
    when "embedded"
      embedded_matches(value)
    when "source"
      source_matches(value, quoted)
    when "disapproved"
      disapproved_matches(value)
    when "commentary"
      commentary_matches(value, quoted)
    when "note"
      note_matches(value)
    when "comment"
      comment_matches(value)
    when "search"
      saved_search_matches(value)
    when "pool"
      pool_matches(value)
    when "ordpool"
      ordpool_matches(value)
    when "favgroup"
      favgroup_matches(value)
    when "ordfavgroup"
      ordfavgroup_matches(value)
    when "fav"
      favorites_include(value)
    when "ordfav"
      ordfav_matches(value)
    when "unaliased"
      unaliased_matches(value)
    when "user"
      user_matches(:uploader, value)
    when "approver"
      user_matches(:approver, value)
    when "flagger"
      flagger_matches(value)
    when "appealer"
      user_subquery_matches(PostAppeal.unscoped, value)
    when "commenter", "comm"
      user_subquery_matches(Comment.unscoped, value)
    when "commentaryupdater", "artcomm"
      user_subquery_matches(ArtistCommentaryVersion.unscoped, value, field: :updater)
    when "noter"
      user_subquery_matches(NoteVersion.unscoped.where(version: 1), value, field: :updater)
    when "noteupdater"
      user_subquery_matches(NoteVersion.unscoped, value, field: :updater)
    when "upvoter", "upvote"
      user_subquery_matches(PostVote.positive.visible(current_user), value, field: :user)
    when "downvoter", "downvote"
      user_subquery_matches(PostVote.negative.visible(current_user), value, field: :user)
    when *CATEGORY_COUNT_METATAGS
      short_category = name.delete_suffix("tags")
      category = TagCategory.short_name_mapping[short_category]
      attribute = "tag_count_#{category}"
      attribute_matches(value, attribute.to_sym)
    when *COUNT_METATAGS
      attribute_matches(value, name.to_sym)
    when "limit"
      Post.all
    when "order"
      Post.all
    else
      raise NotImplementedError, "metatag not implemented"
    end
  end

  def tags_include(*tags)
    query = tags.map(&:to_escaped_for_tsquery).join(" & ")
    Post.where("posts.tag_index @@ to_tsquery('danbooru', E?)", query)
  end

  def unaliased_matches(tag)
    # don't let users use unaliased:fav:1 to view private favorites
    if tag =~ /\Afav:\d+\z/
      Post.none
    else
      tags_include(tag)
    end
  end

  def attribute_matches(value, field, type = :integer)
    operator, *args = parse_metatag_value(value, type)
    Post.where_operator(field, operator, *args)
  end

  def user_matches(field, username)
    case username.downcase
    when "any"
      Post.where.not(field => nil)
    when "none"
      Post.where(field => nil)
    else
      Post.where(field => User.name_matches(username))
    end
  end

  def user_subquery_matches(subquery, username, field: :creator, &block)
    subquery = subquery.where("post_id = posts.id").select(1)

    if username == "any"
      Post.where("EXISTS (#{subquery.to_sql})")
    elsif username == "none"
      Post.where("NOT EXISTS (#{subquery.to_sql})")
    elsif block.nil?
      subquery = subquery.where(field => User.name_matches(username))
      Post.where("EXISTS (#{subquery.to_sql})")
    else
      subquery = subquery.merge(block.call(username))
      return Post.none if subquery.to_sql.blank?
      Post.where("EXISTS (#{subquery.to_sql})")
    end
  end

  def flagger_matches(username)
    flags = PostFlag.unscoped.category_matches("normal")

    user_subquery_matches(flags, username) do |username|
      flagger = User.find_by_name(username)
      PostFlag.unscoped.creator_matches(flagger, current_user)
    end
  end

  def saved_search_matches(label)
    case label.downcase
    when "all"
      Post.where(id: SavedSearch.post_ids_for(current_user.id))
    else
      Post.where(id: SavedSearch.post_ids_for(current_user.id, label: label))
    end
  end

  def status_matches(status)
    case status.downcase
    when "pending"
      Post.pending
    when "flagged"
      Post.flagged
    when "appealed"
      Post.appealed
    when "modqueue"
      Post.in_modqueue
    when "deleted"
      Post.deleted
    when "banned"
      Post.banned
    when "active"
      Post.active
    when "unmoderated"
      Post.in_modqueue.available_for_moderation(current_user, hidden: false)
    when "all", "any"
      Post.all
    else
      Post.none
    end
  end

  def disapproved_matches(query)
    if query.downcase.in?(PostDisapproval::REASONS)
      Post.where(disapprovals: PostDisapproval.where(reason: query.downcase))
    elsif User.normalize_name(query) == current_user.name
      Post.where(disapprovals: PostDisapproval.where(user: current_user))
    else
      Post.none
    end
  end

  def parent_matches(parent)
    case parent.downcase
    when "none"
      Post.where(parent: nil)
    when "any"
      Post.where.not(parent: nil)
    when "pending", "flagged", "appealed", "modqueue", "deleted", "banned", "active", "unmoderated"
      Post.where.not(parent: nil).where(parent: status_matches(parent))
    when /\A\d+\z/
      Post.where(id: parent).or(Post.where(parent: parent))
    else
      Post.none
    end
  end

  def child_matches(child)
    case child.downcase
    when "none"
      Post.where(has_children: false)
    when "any"
      Post.where(has_children: true)
    when "pending", "flagged", "appealed", "modqueue", "deleted", "banned", "active", "unmoderated"
      Post.where(has_children: true).where(children: status_matches(child))
    else
      Post.none
    end
  end

  def source_matches(source, quoted = false)
    if source.empty?
      Post.where_like(:source, "")
    elsif source.downcase == "none" && !quoted
      Post.where_like(:source, "")
    else
      Post.where_ilike(:source, source + "*")
    end
  end

  def embedded_matches(embedded)
    if embedded.truthy?
      Post.bit_flags_match(:has_embedded_notes, true)
    elsif embedded.falsy?
      Post.bit_flags_match(:has_embedded_notes, false)
    else
      Post.none
    end
  end

  def pool_matches(pool_name)
    case pool_name.downcase
    when "none"
      Post.where.not(id: Pool.select("unnest(post_ids)"))
    when "any"
      Post.where(id: Pool.select("unnest(post_ids)"))
    when "series"
      Post.where(id: Pool.series.select("unnest(post_ids)"))
    when "collection"
      Post.where(id: Pool.collection.select("unnest(post_ids)"))
    when /\*/
      Post.where(id: Pool.name_matches(pool_name).select("unnest(post_ids)"))
    else
      Post.where(id: Pool.named(pool_name).select("unnest(post_ids)"))
    end
  end

  def ordpool_matches(pool_name)
    # XXX unify with Pool#posts
    pool_posts = Pool.named(pool_name).joins("CROSS JOIN unnest(pools.post_ids) WITH ORDINALITY AS row(post_id, pool_index)").select(:post_id, :pool_index)
    Post.joins("JOIN (#{pool_posts.to_sql}) pool_posts ON pool_posts.post_id = posts.id").order("pool_posts.pool_index ASC")
  end

  def ordfavgroup_matches(query)
    # XXX unify with FavoriteGroup#posts
    favgroup = FavoriteGroup.visible(current_user).name_or_id_matches(query, current_user)
    favgroup_posts = favgroup.joins("CROSS JOIN unnest(favorite_groups.post_ids) WITH ORDINALITY AS row(post_id, favgroup_index)").select(:post_id, :favgroup_index)
    Post.joins("JOIN (#{favgroup_posts.to_sql}) favgroup_posts ON favgroup_posts.post_id = posts.id").order("favgroup_posts.favgroup_index ASC")
  end

  def favgroup_matches(query)
    favgroup = FavoriteGroup.visible(current_user).name_or_id_matches(query, current_user)
    Post.where(id: favgroup.select("unnest(post_ids)"))
  end

  def favorites_include(username)
    favuser = User.find_by_name(username)

    if favuser.present? && Pundit.policy!([current_user, nil], favuser).can_see_favorites?
      tags_include("fav:#{favuser.id}")
    else
      Post.none
    end
  end

  def ordfav_matches(username)
    user = User.find_by_name(username)
    favorites_include(username).joins(:favorites).merge(Favorite.for_user(user.id)).order("favorites.id DESC")
  end

  def note_matches(query)
    Post.where(notes: Note.search(body_matches: query).reorder(nil))
  end

  def comment_matches(query)
    Post.where(comments: Comment.search(body_matches: query).reorder(nil))
  end

  def commentary_matches(query, quoted = false)
    case query.downcase
    in "none" | "false" unless quoted
      Post.where.not(artist_commentary: ArtistCommentary.all).or(Post.where(artist_commentary: ArtistCommentary.deleted))
    in "any" | "true" unless quoted
      Post.where(artist_commentary: ArtistCommentary.undeleted)
    in "translated" unless quoted
      Post.where(artist_commentary: ArtistCommentary.translated)
    in "untranslated" unless quoted
      Post.where(artist_commentary: ArtistCommentary.untranslated)
    else
      Post.where(artist_commentary: ArtistCommentary.text_matches(query))
    end
  end

  def locked_matches(query)
    case query.downcase
    when "rating"
      Post.where(is_rating_locked: true)
    when "note", "notes"
      Post.where(is_note_locked: true)
    when "status"
      Post.where(is_status_locked: true)
    else
      Post.none
    end
  end

  def table_for_metatag(metatag)
    if metatag.in?(COUNT_METATAGS)
      metatag[/(?<table>[a-z]+)_count\z/i, :table]
    else
      nil
    end
  end

  def tables_for_query
    metatag_names = metatags.map(&:name)
    metatag_names << find_metatag(:order).remove(/_(asc|desc)\z/i) if has_metatag?(:order)

    tables = metatag_names.map { |metatag| table_for_metatag(metatag.to_s) }
    tables.compact.uniq
  end

  def add_joins(relation)
    tables = tables_for_query
    relation = relation.with_stats(tables)
    relation
  end

  def self.is_unlimited_tag?(term)
    term.type == :metatag && term.name.in?(UNLIMITED_METATAGS)
  end

  def build
    tag_count = terms.count { |term| !PostQueryBuilder.is_unlimited_tag?(term) }
    if tag_count > current_user.tag_query_limit
      raise ::Post::SearchError
    end

    relation = Post.all
    relation = add_joins(relation)
    relation = metatags_match(metatags, relation)
    relation = tags_match(tags, relation)

    # HACK: if we're using a date: or age: metatag, default to ordering by
    # created_at instead of id so that the query will use the created_at index.
    if has_metatag?(:date, :age) && find_metatag(:order).in?(["id", "id_asc"])
      relation = search_order(relation, "created_at_asc")
    elsif has_metatag?(:date, :age) && find_metatag(:order).in?(["id_desc", nil])
      relation = search_order(relation, "created_at_desc")
    elsif find_metatag(:order) == "custom"
      relation = search_order_custom(relation, select_metatags(:id).map(&:value))
    else
      relation = search_order(relation, find_metatag(:order))
    end

    relation
  end

  def search_order(relation, order)
    case order.to_s.downcase
    when "id", "id_asc"
      relation = relation.order("posts.id ASC")

    when "id_desc"
      relation = relation.order("posts.id DESC")

    when "md5", "md5_desc"
      relation = relation.order("posts.md5 DESC")

    when "md5_asc"
      relation = relation.order("posts.md5 ASC")

    when "score", "score_desc"
      relation = relation.order("posts.score DESC, posts.id DESC")

    when "score_asc"
      relation = relation.order("posts.score ASC, posts.id ASC")

    when "favcount"
      relation = relation.order("posts.fav_count DESC, posts.id DESC")

    when "favcount_asc"
      relation = relation.order("posts.fav_count ASC, posts.id ASC")

    when "created_at", "created_at_desc"
      relation = relation.order("posts.created_at DESC")

    when "created_at_asc"
      relation = relation.order("posts.created_at ASC")

    when "change", "change_desc"
      relation = relation.order("posts.updated_at DESC, posts.id DESC")

    when "change_asc"
      relation = relation.order("posts.updated_at ASC, posts.id ASC")

    when "comment", "comm"
      relation = relation.order("posts.last_commented_at DESC NULLS LAST, posts.id DESC")

    when "comment_asc", "comm_asc"
      relation = relation.order("posts.last_commented_at ASC NULLS LAST, posts.id ASC")

    when "comment_bumped"
      relation = relation.order("posts.last_comment_bumped_at DESC NULLS LAST")

    when "comment_bumped_asc"
      relation = relation.order("posts.last_comment_bumped_at ASC NULLS FIRST")

    when "note"
      relation = relation.order("posts.last_noted_at DESC NULLS LAST")

    when "note_asc"
      relation = relation.order("posts.last_noted_at ASC NULLS FIRST")

    when "artcomm"
      relation = relation.joins("INNER JOIN artist_commentaries ON artist_commentaries.post_id = posts.id")
      relation = relation.order("artist_commentaries.updated_at DESC")

    when "artcomm_asc"
      relation = relation.joins("INNER JOIN artist_commentaries ON artist_commentaries.post_id = posts.id")
      relation = relation.order("artist_commentaries.updated_at ASC")

    when "mpixels", "mpixels_desc"
      relation = relation.where(Arel.sql("posts.image_width is not null and posts.image_height is not null"))
      # Use "w*h/1000000", even though "w*h" would give the same result, so this can use
      # the posts_mpixels index.
      relation = relation.order(Arel.sql("posts.image_width * posts.image_height / 1000000.0 DESC"))

    when "mpixels_asc"
      relation = relation.where("posts.image_width is not null and posts.image_height is not null")
      relation = relation.order(Arel.sql("posts.image_width * posts.image_height / 1000000.0 ASC"))

    when "portrait"
      relation = relation.where("posts.image_width IS NOT NULL and posts.image_height IS NOT NULL")
      relation = relation.order(Arel.sql("1.0 * posts.image_width / GREATEST(1, posts.image_height) ASC"))

    when "landscape"
      relation = relation.where("posts.image_width IS NOT NULL and posts.image_height IS NOT NULL")
      relation = relation.order(Arel.sql("1.0 * posts.image_width / GREATEST(1, posts.image_height) DESC"))

    when "filesize", "filesize_desc"
      relation = relation.order("posts.file_size DESC")

    when "filesize_asc"
      relation = relation.order("posts.file_size ASC")

    when /\A(?<column>#{COUNT_METATAGS.join("|")})(_(?<direction>asc|desc))?\z/i
      column = $~[:column]
      direction = $~[:direction] || "desc"
      relation = relation.order(column => direction, :id => direction)

    when "tagcount", "tagcount_desc"
      relation = relation.order("posts.tag_count DESC")

    when "tagcount_asc"
      relation = relation.order("posts.tag_count ASC")

    when /(#{TagCategory.short_name_regex})tags(?:\Z|_desc)/
      relation = relation.order("posts.tag_count_#{TagCategory.short_name_mapping[$1]} DESC")

    when /(#{TagCategory.short_name_regex})tags_asc/
      relation = relation.order("posts.tag_count_#{TagCategory.short_name_mapping[$1]} ASC")

    when "rank"
      relation = relation.where("posts.score > 0 and posts.created_at >= ?", 2.days.ago)
      relation = relation.order(Arel.sql("log(3, posts.score) + (extract(epoch from posts.created_at) - extract(epoch from timestamp '2005-05-24')) / 35000 DESC"))

    when "curated"
      contributors = User.bit_prefs_match(:can_upload_free, true)

      relation = relation
        .joins(:favorites)
        .where(favorites: { user: contributors })
        .group("posts.id")
        .select("posts.*, COUNT(*) AS contributor_fav_count")
        .order("contributor_fav_count DESC, posts.fav_count DESC, posts.id DESC")

    when "modqueue", "modqueue_desc"
      relation = relation.with_queued_at.order("queued_at DESC, posts.id DESC")

    when "modqueue_asc"
      relation = relation.with_queued_at.order("queued_at ASC, posts.id ASC")

    when "none"
      relation = relation.reorder(nil)

    else
      relation = relation.order("posts.id DESC")
    end

    relation
  end

  def search_order_custom(relation, id_metatags)
    return relation.none unless id_metatags.present? && id_metatags.size == 1

    operator, ids = parse_range(id_metatags.first, :integer)
    return relation.none unless operator == :in

    relation.find_ordered(ids)
  end

  concerning :ParseMethods do
    def scan_query
      terms = []
      query = query_string.to_s.gsub(/[[:space:]]/, " ")
      scanner = StringScanner.new(query)

      until scanner.eos?
        scanner.skip(/ +/)

        if scanner.scan(/(-)?(#{METATAGS.join("|")}):/io)
          operator = scanner.captures.first
          metatag = scanner.captures.second.downcase
          value, quoted = scan_string(scanner)

          if metatag.in?(COUNT_METATAG_SYNONYMS)
            metatag = metatag.singularize + "_count"
          elsif metatag == "order"
            attribute, direction, _tail = value.to_s.downcase.partition(/_(asc|desc)\z/i)
            if attribute.in?(COUNT_METATAG_SYNONYMS)
              value = attribute.singularize + "_count" + direction
            end
          end

          terms << OpenStruct.new(type: :metatag, name: metatag, value: value, negated: (operator == "-"), quoted: quoted)
        elsif scanner.scan(/([-~])?([^ ]+)/)
          operator = scanner.captures.first
          tag = scanner.captures.second
          terms << OpenStruct.new(type: :tag, name: tag.downcase, negated: (operator == "-"), optional: (operator == "~"), wildcard: tag.include?("*"))
        elsif scanner.scan(/[^ ]+/)
          terms << OpenStruct.new(type: :tag, name: scanner.matched.downcase)
        end
      end

      terms
    end

    def scan_string(scanner)
      if scanner.scan(/"((?:\\"|[^"])*)"/)
        value = scanner.captures.first.gsub(/\\(.)/) { $1 }
        quoted = true
      elsif scanner.scan(/'((?:\\'|[^'])*)'/)
        value = scanner.captures.first.gsub(/\\(.)/) { $1 }
        quoted = true
      else
        value = scanner.scan(/(\\ |[^ ])*/)
        value = value.gsub(/\\ /) { " " }
        quoted = false
      end

      [value, quoted]
    end

    def split_query
      terms.map do |term|
        type, name, value = term.type, term.name, term.value

        str = ""
        str += "-" if term.negated
        str += "~" if term.optional

        if type == :tag
          str += name
        elsif type == :metatag && (term.quoted || value.include?(" "))
          value = value.gsub(/\\/) { '\\\\' }
          value = value.gsub(/"/) { '\\"' }
          str += "#{name}:\"#{value}\""
        elsif type == :metatag
          str += "#{name}:#{value}"
        end

        str
      end
    end

    def parse_tag_edit
      split_query
    end

    def parse_cast(object, type)
      case type
      when :enum
        object.to_s.downcase

      when :integer
        object.to_i

      when :float
        object.to_f

      when :md5
        object.to_s.downcase

      when :date, :datetime
        Time.zone.parse(object) rescue nil

      when :age
        DurationParser.parse(object).ago

      when :ratio
        object =~ /\A(\d+(?:\.\d+)?):(\d+(?:\.\d+)?)\Z/i

        if $1 && $2.to_f != 0.0
          ($1.to_f / $2.to_f).round(2)
        else
          object.to_f.round(2)
        end

      when :filesize
        object =~ /\A(\d+(?:\.\d*)?|\d*\.\d+)([kKmM]?)[bB]?\Z/

        size = $1.to_f
        unit = $2

        conversion_factor = case unit
        when /m/i
          1024 * 1024
        when /k/i
          1024
        else
          1
        end

        (size * conversion_factor).to_i
      end
    end

    def parse_metatag_value(string, type)
      if type == :enum
        [:in, string.split(/[, ]+/).map { |x| parse_cast(x, type) }]
      else
        parse_range(string, type)
      end
    end

    def parse_range(string, type)
      range = case string
      when /\A(.+?)\.\.\.(.+)/ # A...B
        lo, hi = [parse_cast($1, type), parse_cast($2, type)].sort
        [:between, (lo...hi)]
      when /\A(.+?)\.\.(.+)/
        lo, hi = [parse_cast($1, type), parse_cast($2, type)].sort
        [:between, (lo..hi)]
      when /\A<=(.+)/, /\A\.\.(.+)/
        [:lteq, parse_cast($1, type)]
      when /\A<(.+)/
        [:lt, parse_cast($1, type)]
      when /\A>=(.+)/, /\A(.+)\.\.\Z/
        [:gteq, parse_cast($1, type)]
      when /\A>(.+)/
        [:gt, parse_cast($1, type)]
      when /[, ]/
        [:in, string.split(/[, ]+/).map {|x| parse_cast(x, type)}]
      when "any"
        [:not_eq, nil]
      when "none"
        [:eq, nil]
      else
        # add a 5% tolerance for float and filesize values
        if type == :float || (type == :filesize && string =~ /[km]b?\z/i)
          value = parse_cast(string, type)
          [:between, (value * 0.95..value * 1.05)]
        elsif type.in?([:date, :age])
          value = parse_cast(string, type)
          [:between, (value.beginning_of_day..value.end_of_day)]
        else
          [:eq, parse_cast(string, type)]
        end
      end

      range = reverse_range(range) if type == :age
      range
    end

    def reverse_range(range)
      case range
      in [:lteq, value]
        [:gteq, value]
      in [:lt, value]
        [:gt, value]
      in [:gteq, value]
        [:lteq, value]
      in [:gt, value]
        [:lt, value]
      else
        range
      end
    end
  end

  concerning :CountMethods do
    def fast_count(timeout: 1_000, estimate_count: true, skip_cache: false)
      count = nil
      count = estimated_count if estimate_count
      count = cached_count if count.nil? && !skip_cache
      count = exact_count(timeout) if count.nil?
      count
    end

    def estimated_count
      if is_empty_search?
        estimated_row_count
      elsif is_simple_tag?
        Tag.find_by(name: tags.first.name).try(:post_count)
      elsif is_metatag?(:rating)
        estimated_row_count
      end
    end

    def estimated_row_count
      ExplainParser.new(build.to_sql).row_count
    end

    def cached_count
      Cache.get(count_cache_key)
    end

    def exact_count(timeout)
      count = Post.with_timeout(timeout, nil) do
        build.count
      end

      set_cached_count(count) if count.present?
      count
    rescue Post::SearchError
      nil
    end

    def set_cached_count(count)
      expiry = count.seconds.clamp(3.minutes, 20.hours).to_i
      Cache.put(count_cache_key, count, expiry)
    end

    def count_cache_key
      if is_user_dependent_search?
        "pfc[#{current_user.id.to_i}]:#{to_s}"
      else
        "pfc:#{to_s}"
      end
    end

    def is_user_dependent_search?
      metatags.any? do |metatag|
        metatag.name.in?(%w[upvoter upvote downvoter downvote search flagger fav ordfav favgroup ordfavgroup]) ||
        metatag.name == "status" && metatag.value == "unmoderated" ||
        metatag.name == "disapproved" && User.normalize_name(metatag.value) == current_user.name
      end
    end
  end

  concerning :NormalizationMethods do
    def normalized_query(implicit: true, sort: true)
      post_query = dup
      post_query.terms.concat(implicit_metatags) if implicit
      post_query.normalize_aliases!
      post_query.normalize_order! if sort
      post_query
    end

    def normalize_aliases!
      tag_names = tags.map(&:name)
      tag_aliases = tag_names.zip(TagAlias.to_aliased(tag_names)).to_h

      terms.map! do |term|
        term.name = tag_aliases[term.name] if term.type == :tag
        term
      end
    end

    def normalize_order!
      terms.sort_by!(&:to_s).uniq!
    end

    def implicit_metatags
      metatags = []
      metatags << OpenStruct.new(type: :metatag, name: "rating", value: "s") if safe_mode?
      metatags << OpenStruct.new(type: :metatag, name: "status", value: "deleted", negated: true) if hide_deleted?
      metatags
    end

    # XXX unify with PostSets::Post#show_deleted?
    def hide_deleted?
      has_status_metatag = select_metatags(:status).any? { |metatag| metatag.value.downcase.in?(%w[deleted active any all unmoderated modqueue appealed]) }
      hide_deleted_posts? && !has_status_metatag
    end
  end

  concerning :UtilityMethods do
    def to_s
      split_query.join(" ")
    end

    def terms
      @terms ||= scan_query
    end

    def tags
      terms.select { |term| term.type == :tag }
    end

    def metatags
      terms.select { |term| term.type == :metatag }
    end

    def select_metatags(*names)
      metatags.select { |term| term.name.in?(names.map(&:to_s)) }
    end

    def find_metatag(metatag)
      select_metatags(metatag).first.try(:value)
    end

    def has_metatag?(*metatag_names)
      metatags.any? { |term| term.name.in?(metatag_names.map(&:to_s).map(&:downcase)) }
    end

    def has_single_tag?
      tags.size == 1 && !tags.first.wildcard
    end

    def is_metatag?(name, value = nil)
      if value.nil?
        is_single_term? && has_metatag?(name)
      else
        is_single_term? && find_metatag(name) == value.to_s
      end
    end

    def is_empty_search?
      terms.size == 0
    end

    def is_single_term?
      terms.size == 1
    end

    def is_single_tag?
      is_single_term? && tags.size == 1
    end

    def is_simple_tag?
      tag = tags.first
      is_single_tag? && !tag.negated && !tag.optional && !tag.wildcard
    end

    def is_wildcard_search?
      is_single_tag? && tags.first.wildcard
    end
  end

  memoize :split_query, :normalized_query
end
