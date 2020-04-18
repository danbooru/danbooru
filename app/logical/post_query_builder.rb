class PostQueryBuilder
  COUNT_METATAGS = %w[
    comment_count deleted_comment_count active_comment_count
    note_count deleted_note_count active_note_count
    flag_count resolved_flag_count unresolved_flag_count
    child_count deleted_child_count active_child_count
    pool_count deleted_pool_count active_pool_count series_pool_count collection_pool_count
    appeal_count approval_count replacement_count
  ]

  # allow e.g. `deleted_comments` as a synonym for `deleted_comment_count`
  COUNT_METATAG_SYNONYMS = COUNT_METATAGS.map { |str| str.delete_suffix("_count").pluralize }

  METATAGS = %w[
    -user user
    -approver approver
    -commenter commenter comm
    -noter noter
    -noteupdater noteupdater
    -artcomm artcomm
    -commentaryupdater commentaryupdater
    -flagger flagger
    -appealer appealer
    -upvote upvote
    -downvote downvote
    -fav fav
    -ordfav ordfav
    -favgroup favgroup
    -pool pool ordpool
    -commentary commentary
    -id id
    -rating rating
    -locked locked
    -source source
    -status status
    -filetype filetype
    -disapproved disapproved
    -parent parent
    md5
    width
    height
    mpixels
    ratio
    score
    favcount
    filesize
    date
    age
    order
    limit
    tagcount
    child
    pixiv_id pixiv
    search
    embedded
  ] + TagCategory.short_name_list.map {|x| "#{x}tags"} + COUNT_METATAGS + COUNT_METATAG_SYNONYMS

  ORDER_METATAGS = %w[
    id id_desc
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
  ] +
    COUNT_METATAGS +
    COUNT_METATAG_SYNONYMS.flat_map { |str| [str, "#{str}_asc"] } +
    TagCategory.short_name_list.flat_map { |str| ["#{str}tags", "#{str}tags_asc"] }

  attr_accessor :query_string

  def initialize(query_string)
    @query_string = query_string
  end

  def add_range_relation(arr, field, relation)
    return relation if arr.nil?

    case arr[0]
    when :eq
      case arr[1]
      when Time
        relation.where("#{field} between ? and ?", arr[1].beginning_of_day, arr[1].end_of_day)
      when :any
        relation.where(["#{field} IS NOT NULL"])
      when :none
        relation.where(["#{field} IS NULL"])
      else
        relation.where(["#{field} = ?", arr[1]])
      end

    when :gt
      relation.where(["#{field} > ?", arr[1]])

    when :gte
      relation.where(["#{field} >= ?", arr[1]])

    when :lt
      relation.where(["#{field} < ?", arr[1]])

    when :lte
      relation.where(["#{field} <= ?", arr[1]])

    when :in
      relation.where(["#{field} in (?)", arr[1]])

    when :between
      relation.where(["#{field} BETWEEN ? AND ?", arr[1], arr[2]])

    else
      relation
    end
  end

  def escape_string_for_tsquery(array)
    array.map(&:to_escaped_for_tsquery)
  end

  def user_matches(field, username)
    if username == "any"
      Post.where.not(field => nil)
    elsif username == "none"
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
      PostFlag.unscoped.creator_matches(flagger, CurrentUser.user)
    end
  end

  def add_tag_string_search_relation(tags, relation)
    tag_query_sql = []

    if tags[:include].any?
      tag_query_sql << "(" + escape_string_for_tsquery(tags[:include]).join(" | ") + ")"
    end

    if tags[:related].any?
      tag_query_sql << "(" + escape_string_for_tsquery(tags[:related]).join(" & ") + ")"
    end

    if tags[:exclude].any?
      tag_query_sql << "!(" + escape_string_for_tsquery(tags[:exclude]).join(" | ") + ")"
    end

    if tag_query_sql.any?
      relation = relation.where("posts.tag_index @@ to_tsquery('danbooru', E?)", tag_query_sql.join(" & "))
    end

    relation
  end

  def add_saved_search_relation(saved_searches, relation)
    saved_searches.each do |saved_search|
      if saved_search == "all"
        post_ids = SavedSearch.post_ids_for(CurrentUser.id)
      else
        post_ids = SavedSearch.post_ids_for(CurrentUser.id, label: saved_search)
      end

      post_ids = [0] if post_ids.empty?
      relation = relation.where("posts.id": post_ids)
    end

    relation
  end

  def commentary_matches(query)
    case query
    when "none", "false"
      Post.where.not(artist_commentary: ArtistCommentary.all).or(Post.where(artist_commentary: ArtistCommentary.deleted))
    when "any", "true"
      Post.where(artist_commentary: ArtistCommentary.undeleted)
    when "translated"
      Post.where(artist_commentary: ArtistCommentary.translated)
    when "untranslated"
      Post.where(artist_commentary: ArtistCommentary.untranslated)
    else
      Post.where(artist_commentary: ArtistCommentary.text_matches(query))
    end
  end

  def table_for_metatag(metatag)
    if metatag.in?(COUNT_METATAGS)
      metatag[/(?<table>[a-z]+)_count\z/i, :table]
    else
      nil
    end
  end

  def tables_for_query(q)
    metatags = q.keys
    metatags << q[:order].remove(/_(asc|desc)\z/i) if q[:order].present?

    tables = metatags.map { |metatag| table_for_metatag(metatag.to_s) }
    tables.compact.uniq
  end

  def add_joins(q, relation)
    tables = tables_for_query(q)
    relation = relation.with_stats(tables)
    relation
  end

  def hide_deleted_posts?(q)
    return false if CurrentUser.admin_mode?
    return false if q[:status].in?(%w[deleted active any all])
    return false if q[:status_neg].in?(%w[deleted active any all])
    return CurrentUser.user.hide_deleted_posts?
  end

  def build
    unless query_string.is_a?(Hash)
      q = PostQueryBuilder.parse_query(query_string)
    end

    relation = Post.all

    if q[:tag_count].to_i > Danbooru.config.tag_query_limit
      raise ::Post::SearchError
    end

    if CurrentUser.safe_mode?
      relation = relation.where("posts.rating = 's'")
    end

    relation = add_joins(q, relation)
    relation = add_range_relation(q[:post_id], "posts.id", relation)
    relation = add_range_relation(q[:mpixels], "posts.image_width * posts.image_height / 1000000.0", relation)
    relation = add_range_relation(q[:ratio], "ROUND(1.0 * posts.image_width / GREATEST(1, posts.image_height), 2)", relation)
    relation = add_range_relation(q[:width], "posts.image_width", relation)
    relation = add_range_relation(q[:height], "posts.image_height", relation)
    relation = add_range_relation(q[:score], "posts.score", relation)
    relation = add_range_relation(q[:fav_count], "posts.fav_count", relation)
    relation = add_range_relation(q[:filesize], "posts.file_size", relation)
    relation = add_range_relation(q[:date], "posts.created_at", relation)
    relation = add_range_relation(q[:age], "posts.created_at", relation)
    relation = add_range_relation(q[:pixiv_id], "posts.pixiv_id", relation)
    TagCategory.categories.each do |category|
      relation = add_range_relation(q["#{category}_tag_count".to_sym], "posts.tag_count_#{category}", relation)
    end
    relation = add_range_relation(q[:post_tag_count], "posts.tag_count", relation)

    COUNT_METATAGS.each do |column|
      relation = add_range_relation(q[column.to_sym], "posts.#{column}", relation)
    end

    if q[:md5]
      relation = relation.where("posts.md5": q[:md5])
    end

    if q[:status] == "pending"
      relation = relation.where("posts.is_pending = TRUE")
    elsif q[:status] == "flagged"
      relation = relation.where("posts.is_flagged = TRUE")
    elsif q[:status] == "modqueue"
      relation = relation.where("posts.is_pending = TRUE OR posts.is_flagged = TRUE")
    elsif q[:status] == "deleted"
      relation = relation.where("posts.is_deleted = TRUE")
    elsif q[:status] == "banned"
      relation = relation.where("posts.is_banned = TRUE")
    elsif q[:status] == "active"
      relation = relation.where("posts.is_pending = FALSE AND posts.is_deleted = FALSE AND posts.is_banned = FALSE AND posts.is_flagged = FALSE")
    elsif q[:status] == "unmoderated"
      relation = relation.merge(Post.pending_or_flagged.available_for_moderation)
    elsif q[:status] == "all" || q[:status] == "any"
      # do nothing
    elsif q[:status_neg] == "pending"
      relation = relation.where("posts.is_pending = FALSE")
    elsif q[:status_neg] == "flagged"
      relation = relation.where("posts.is_flagged = FALSE")
    elsif q[:status_neg] == "modqueue"
      relation = relation.where("posts.is_pending = FALSE AND posts.is_flagged = FALSE")
    elsif q[:status_neg] == "deleted"
      relation = relation.where("posts.is_deleted = FALSE")
    elsif q[:status_neg] == "banned"
      relation = relation.where("posts.is_banned = FALSE")
    elsif q[:status_neg] == "active"
      relation = relation.where("posts.is_pending = TRUE OR posts.is_deleted = TRUE OR posts.is_banned = TRUE OR posts.is_flagged = TRUE")
    end

    if hide_deleted_posts?(q)
      relation = relation.where("posts.is_deleted = FALSE")
    end

    if q[:filetype]
      relation = relation.where("posts.file_ext": q[:filetype])
    end

    if q[:filetype_neg]
      relation = relation.where.not("posts.file_ext": q[:filetype_neg])
    end

    if q[:source]
      if q[:source] == "none"
        relation = relation.where_like(:source, '')
      else
        relation = relation.where_ilike(:source, q[:source].downcase + "*")
      end
    end

    if q[:source_neg]
      if q[:source_neg] == "none"
        relation = relation.where_not_like(:source, '')
      else
        relation = relation.where_not_ilike(:source, q[:source_neg].downcase + "*")
      end
    end

    q[:pool].to_a.each do |pool_name|
      case pool_name
      when "none"
        relation = relation.where.not(id: Pool.select("unnest(post_ids)"))
      when "any"
        relation = relation.where(id: Pool.select("unnest(post_ids)"))
      when "series"
        relation = relation.where(id: Pool.series.select("unnest(post_ids)"))
      when "collection"
        relation = relation.where(id: Pool.collection.select("unnest(post_ids)"))
      when /\*/
        relation = relation.where(id: Pool.name_matches(pool_name).select("unnest(post_ids)"))
      else
        relation = relation.where(id: Pool.named(pool_name).select("unnest(post_ids)"))
      end
    end

    q[:pool_neg].to_a.each do |pool_name|
      case pool_name
      when "none"
        relation = relation.where(id: Pool.select("unnest(post_ids)"))
      when "any"
        relation = relation.where.not(id: Pool.select("unnest(post_ids)"))
      when "series"
        relation = relation.where.not(id: Pool.series.select("unnest(post_ids)"))
      when "collection"
        relation = relation.where.not(id: Pool.collection.select("unnest(post_ids)"))
      when /\*/
        relation = relation.where.not(id: Pool.name_matches(pool_name).select("unnest(post_ids)"))
      else
        relation = relation.where.not(id: Pool.named(pool_name).select("unnest(post_ids)"))
      end
    end

    q[:commentary_neg].to_a.each do |query|
      relation = relation.merge(commentary_matches(query).negate)
    end

    q[:commentary].to_a.each do |query|
      relation = relation.merge(commentary_matches(query))
    end

    if q[:saved_searches]
      relation = add_saved_search_relation(q[:saved_searches], relation)
    end

    q[:user_neg].to_a.each do |username|
      relation = relation.merge(user_matches(:uploader, username).negate)
    end

    q[:user].to_a.each do |username|
      relation = relation.merge(user_matches(:uploader, username))
    end

    q[:approver_neg].to_a.each do |username|
      relation = relation.merge(user_matches(:approver, username).negate)
    end

    q[:approver].to_a.each do |username|
      relation = relation.merge(user_matches(:approver, username))
    end

    if q[:disapproved]
      q[:disapproved].each do |disapproved|
        if disapproved == CurrentUser.name
          disapprovals = CurrentUser.user.post_disapprovals.select(:post_id)
        else
          disapprovals = PostDisapproval.where(reason: disapproved)
        end

        relation = relation.where("posts.id": disapprovals.select(:post_id))
      end
    end

    if q[:disapproved_neg]
      q[:disapproved_neg].each do |disapproved|
        if disapproved == CurrentUser.name
          disapprovals = CurrentUser.user.post_disapprovals.select(:post_id)
        else
          disapprovals = PostDisapproval.where(reason: disapproved)
        end

        relation = relation.where.not("posts.id": disapprovals.select(:post_id))
      end
    end

    q[:flagger_neg].to_a.each do |username|
      relation = relation.merge(flagger_matches(username).negate)
    end

    q[:flagger].to_a.each do |username|
      relation = relation.merge(flagger_matches(username))
    end

    q[:appealer_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(PostAppeal.unscoped, username).negate)
    end

    q[:appealer].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(PostAppeal.unscoped, username))
    end

    q[:commenter_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(Comment.unscoped, username).negate)
    end

    q[:commenter].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(Comment.unscoped, username))
    end

    q[:noter_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(NoteVersion.unscoped.where(version: 1), username, field: :updater).negate)
    end

    q[:noter].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(NoteVersion.unscoped.where(version: 1), username, field: :updater))
    end

    q[:note_updater_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(NoteVersion.unscoped, username, field: :updater).negate)
    end

    q[:note_updater].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(NoteVersion.unscoped, username, field: :updater))
    end

    q[:commentary_updater_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(ArtistCommentaryVersion.unscoped, username, field: :updater).negate)
    end

    q[:commentary_updater].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(ArtistCommentaryVersion.unscoped, username, field: :updater))
    end

    if q[:post_id_negated]
      relation = relation.where("posts.id <> ?", q[:post_id_negated])
    end

    if q[:parent] == "none"
      relation = relation.where("posts.parent_id IS NULL")
    elsif q[:parent] == "any"
      relation = relation.where("posts.parent_id IS NOT NULL")
    elsif q[:parent]
      relation = relation.where("(posts.id = ? or posts.parent_id = ?)", q[:parent].to_i, q[:parent].to_i)
    end

    if q[:parent_neg_ids]
      neg_ids = q[:parent_neg_ids].map(&:to_i)
      neg_ids.delete(0)
      if neg_ids.present?
        relation = relation.where("posts.id not in (?) and (posts.parent_id is null or posts.parent_id not in (?))", neg_ids, neg_ids)
      end
    end

    if q[:child] == "none"
      relation = relation.where("posts.has_children = FALSE")
    elsif q[:child] == "any"
      relation = relation.where("posts.has_children = TRUE")
    end

    q[:rating].to_a.each do |rating|
      relation = relation.where(rating: rating.first.downcase)
    end

    q[:rating_neg].to_a.each do |rating|
      relation = relation.where.not(rating: rating.first.downcase)
    end

    if q[:locked] == "rating"
      relation = relation.where("posts.is_rating_locked = TRUE")
    elsif q[:locked] == "note" || q[:locked] == "notes"
      relation = relation.where("posts.is_note_locked = TRUE")
    elsif q[:locked] == "status"
      relation = relation.where("posts.is_status_locked = TRUE")
    end

    if q[:locked_negated] == "rating"
      relation = relation.where("posts.is_rating_locked = FALSE")
    elsif q[:locked_negated] == "note" || q[:locked_negated] == "notes"
      relation = relation.where("posts.is_note_locked = FALSE")
    elsif q[:locked_negated] == "status"
      relation = relation.where("posts.is_status_locked = FALSE")
    end

    if q[:embedded].to_s.truthy?
      relation = relation.bit_flags_match(:has_embedded_notes, true)
    elsif q[:embedded].to_s.falsy?
      relation = relation.bit_flags_match(:has_embedded_notes, false)
    end

    if q[:ordpool].present?
      pool_name = q[:ordpool]

      # XXX unify with Pool#posts
      pool_posts = Pool.named(pool_name).joins("CROSS JOIN unnest(pools.post_ids) WITH ORDINALITY AS row(post_id, pool_index)").select(:post_id, :pool_index)
      relation = relation.joins("JOIN (#{pool_posts.to_sql}) pool_posts ON pool_posts.post_id = posts.id").order("pool_posts.pool_index ASC")
    end

    q[:favgroup_neg].to_a.each do |favgroup_name|
      favgroup = FavoriteGroup.visible(CurrentUser.user).name_or_id_matches(favgroup_name, CurrentUser.user)
      relation = relation.where.not(id: favgroup.select("unnest(post_ids)"))
    end

    q[:favgroup].to_a.each do |favgroup_name|
      favgroup = FavoriteGroup.visible(CurrentUser.user).name_or_id_matches(favgroup_name, CurrentUser.user)
      relation = relation.where(id: favgroup.select("unnest(post_ids)"))
    end

    q[:upvoter].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(PostVote.positive.visible(CurrentUser.user), username, field: :user))
    end

    q[:upvoter_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(PostVote.positive.visible(CurrentUser.user), username, field: :user).negate)
    end

    q[:downvoter].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(PostVote.negative.visible(CurrentUser.user), username, field: :user))
    end

    q[:downvoter_neg].to_a.each do |username|
      relation = relation.merge(user_subquery_matches(PostVote.negative.visible(CurrentUser.user), username, field: :user).negate)
    end

    q[:fav_neg].to_a.each do |username|
      favuser = User.find_by_name(username)

      if favuser.present? && Pundit.policy!([CurrentUser.user, nil], favuser).can_see_favorites?
        q[:tags][:exclude] << "fav:#{favuser.id}"
      else
        relation = relation.all # no-op; excluding a nonexistent user returns everything
      end
    end

    q[:fav].to_a.each do |username|
      favuser = User.find_by_name(username)

      if favuser.present? && Pundit.policy!([CurrentUser.user, nil], favuser).can_see_favorites?
        q[:tags][:related] << "fav:#{favuser.id}"
      else
        relation = relation.none
      end
    end

    q[:ordfav].to_a.each do |username|
      favuser = User.find_by_name(username)

      if favuser.present? && Pundit.policy!([CurrentUser.user, nil], favuser).can_see_favorites?
        q[:tags][:related] << "fav:#{favuser.id}"
        relation = relation.joins("INNER JOIN favorites ON favorites.post_id = posts.id")
        relation = relation.where("favorites.user_id % 100 = ? and favorites.user_id = ?", favuser.id % 100, favuser.id).order("favorites.id DESC")
      else
        relation = relation.none
      end
    end

    relation = add_tag_string_search_relation(q[:tags], relation)

    # HACK: if we're using a date: or age: metatag, default to ordering by
    # created_at instead of id so that the query will use the created_at index.
    if q[:date].present? || q[:age].present?
      case q[:order]
      when "id", "id_asc"
        q[:order] = "created_at_asc"
      when "id_desc", nil
        q[:order] = "created_at_desc"
      end
    end

    if q[:order] == "rank"
      relation = relation.where("posts.score > 0 and posts.created_at >= ?", 2.days.ago)
    elsif q[:order] == "landscape" || q[:order] == "portrait"
      relation = relation.where("posts.image_width IS NOT NULL and posts.image_height IS NOT NULL")
    end

    if q[:order] == "custom" && q[:post_id].present? && q[:post_id][0] == :in
      relation = relation.find_ordered(q[:post_id][1])
    else
      relation = PostQueryBuilder.search_order(relation, q[:order])
    end

    relation
  end

  def self.search_order(relation, order)
    case order.to_s
    when "id", "id_asc"
      relation = relation.order("posts.id ASC")

    when "id_desc"
      relation = relation.order("posts.id DESC")

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
      relation = relation.order(Arel.sql("1.0 * posts.image_width / GREATEST(1, posts.image_height) ASC"))

    when "landscape"
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
      relation = relation.left_outer_joins(:flags).order(Arel.sql("GREATEST(posts.created_at, post_flags.created_at) DESC, posts.id DESC"))

    when "modqueue_asc"
      relation = relation.left_outer_joins(:flags).order(Arel.sql("GREATEST(posts.created_at, post_flags.created_at) ASC, posts.id ASC"))

    else
      relation = relation.order("posts.id DESC")
    end

    relation
  end

  concerning :ParseMethods do
    class_methods do
      def scan_query(query, strip_metatags: false)
        tagstr = query.to_s.gsub(/\u3000/, " ").strip
        list = tagstr.scan(/-?(?:source|commentary):".*?"/) || []
        list += tagstr.gsub(/-?(?:source|commentary):".*?"/, "").scan(/[^[:space:]]+/).uniq
        list = list.map { |tag| tag.sub(/^[-~]/, "") } if strip_metatags
        list
      end

      def normalize_query(query, normalize_aliases: true, sort: true)
        tags = scan_query(query.to_s)
        tags = tags.map { |t| Tag.normalize_name(t) }
        tags = TagAlias.to_aliased(tags) if normalize_aliases
        tags = tags.sort if sort
        tags = tags.uniq
        tags.join(" ")
      end

      def parse_query(query, options = {})
        q = {}

        q[:tag_count] = 0

        q[:tags] = {
          :related => [],
          :include => [],
          :exclude => []
        }

        scan_query(query).each do |token|
          q[:tag_count] += 1 unless Danbooru.config.is_unlimited_tag?(token)

          if token =~ /\A(#{METATAGS.join("|")}):(.+)\z/i
            g1 = $1.downcase
            g2 = $2
            case g1
            when "-user"
              q[:user_neg] ||= []
              q[:user_neg] << g2

            when "user"
              q[:user] ||= []
              q[:user] << g2

            when "-approver"
              q[:approver_neg] ||= []
              q[:approver_neg] << g2

            when "approver"
              q[:approver] ||= []
              q[:approver] << g2

            when "flagger"
              q[:flagger] ||= []
              q[:flagger] << g2

            when "-flagger"
              q[:flagger_neg] ||= []
              q[:flagger_neg] << g2

            when "appealer"
              q[:appealer] ||= []
              q[:appealer] << g2

            when "-appealer"
              q[:appealer_neg] ||= []
              q[:appealer_neg] << g2

            when "commenter", "comm"
              q[:commenter] ||= []
              q[:commenter] << g2

            when "-commenter", "-comm"
              q[:commenter_neg] ||= []
              q[:commenter_neg] << g2

            when "noter"
              q[:noter] ||= []
              q[:noter] << g2

            when "-noter"
              q[:noter_neg] ||= []
              q[:noter_neg] << g2

            when "noteupdater"
              q[:note_updater] ||= []
              q[:note_updater] << g2

            when "-noteupdater"
              q[:note_updater_neg] ||= []
              q[:note_updater_neg] << g2

            when "-commentaryupdater", "-artcomm"
              q[:commentary_updater_neg] ||= []
              q[:commentary_updater_neg] << g2

            when "commentaryupdater", "artcomm"
              q[:commentary_updater] ||= []
              q[:commentary_updater] << g2

            when "disapproved"
              q[:disapproved] ||= []
              q[:disapproved] << g2

            when "-disapproved"
              q[:disapproved_neg] ||= []
              q[:disapproved_neg] << g2

            when "-pool"
              q[:pool_neg] ||= []
              q[:pool_neg] << g2

            when "pool"
              q[:pool] ||= []
              q[:pool] << g2

            when "ordpool"
              q[:ordpool] = g2

            when "-favgroup"
              q[:favgroup_neg] ||= []
              q[:favgroup_neg] << g2

            when "favgroup"
              q[:favgroup] ||= []
              q[:favgroup] << g2

            when "-fav", "-ordfav"
              q[:fav_neg] ||= []
              q[:fav_neg] << g2

            when "fav"
              q[:fav] ||= []
              q[:fav] << g2

            when "ordfav"
              q[:ordfav] ||= []
              q[:ordfav] << g2

            when "-commentary"
              q[:commentary_neg] ||= []
              q[:commentary_neg] << g2.gsub(/\A"(.*)"\Z/, '\1')

            when "commentary"
              q[:commentary] ||= []
              q[:commentary] << g2.gsub(/\A"(.*)"\Z/, '\1')

            when "search"
              q[:saved_searches] ||= []
              q[:saved_searches] << g2

            when "md5"
              q[:md5] = g2.downcase.split(/,/)

            when "-rating"
              q[:rating_neg] ||= []
              q[:rating_neg] << g2

            when "rating"
              q[:rating] ||= []
              q[:rating] << g2

            when "-locked"
              q[:locked_negated] = g2.downcase

            when "locked"
              q[:locked] = g2.downcase

            when "id"
              q[:post_id] = parse_helper(g2)

            when "-id"
              q[:post_id_negated] = g2.to_i

            when "width"
              q[:width] = parse_helper(g2)

            when "height"
              q[:height] = parse_helper(g2)

            when "mpixels"
              q[:mpixels] = parse_helper(g2, :float)

            when "ratio"
              q[:ratio] = parse_helper(g2, :ratio)

            when "score"
              q[:score] = parse_helper(g2)

            when "favcount"
              q[:fav_count] = parse_helper(g2)

            when "filesize"
              q[:filesize] = parse_helper(g2, :filesize)

            when "source"
              q[:source] = g2.gsub(/\A"(.*)"\Z/, '\1')

            when "-source"
              q[:source_neg] = g2.gsub(/\A"(.*)"\Z/, '\1')

            when "date"
              q[:date] = parse_helper(g2, :date)

            when "age"
              q[:age] = reverse_parse_helper(parse_helper(g2, :age))

            when "tagcount"
              q[:post_tag_count] = parse_helper(g2)

            when /(#{TagCategory.short_name_regex})tags/
              q["#{TagCategory.short_name_mapping[$1]}_tag_count".to_sym] = parse_helper(g2)

            when "parent"
              q[:parent] = g2.downcase

            when "-parent"
              if g2.downcase == "none"
                q[:parent] = "any"
              elsif g2.downcase == "any"
                q[:parent] = "none"
              else
                q[:parent_neg_ids] ||= []
                q[:parent_neg_ids] << g2.downcase
              end

            when "child"
              q[:child] = g2.downcase

            when "order"
              g2 = g2.downcase

              order, suffix, _tail = g2.partition(/_(asc|desc)\z/i)
              if order.in?(COUNT_METATAG_SYNONYMS)
                g2 = order.singularize + "_count" + suffix
              end

              q[:order] = g2

            when "limit"
              # Do nothing. The controller takes care of it.

            when "-status"
              q[:status_neg] = g2.downcase

            when "status"
              q[:status] = g2.downcase

            when "embedded"
              q[:embedded] = g2.downcase

            when "filetype"
              q[:filetype] = g2.downcase

            when "-filetype"
              q[:filetype_neg] = g2.downcase

            when "pixiv_id", "pixiv"
              q[:pixiv_id] = parse_helper(g2)

            when "-upvote"
              q[:upvoter_neg] ||= []
              q[:upvoter_neg] << g2

            when "upvote"
              q[:upvoter] ||= []
              q[:upvoter] << g2

            when "-downvote"
              q[:downvoter_neg] ||= []
              q[:downvoter_neg] << g2

            when "downvote"
              q[:downvoter] ||= []
              q[:downvoter] << g2

            when *COUNT_METATAGS
              q[g1.to_sym] = parse_helper(g2)

            when *COUNT_METATAG_SYNONYMS
              g1 = "#{g1.singularize}_count"
              q[g1.to_sym] = parse_helper(g2)

            end

          else
            parse_tag(token, q[:tags])
          end
        end

        q[:tags][:exclude] = TagAlias.to_aliased(q[:tags][:exclude])
        q[:tags][:include] = TagAlias.to_aliased(q[:tags][:include])
        q[:tags][:related] = TagAlias.to_aliased(q[:tags][:related])

        return q
      end

      def parse_tag_operator(tag)
        tag = Tag.normalize_name(tag)

        if tag.starts_with?("-")
          ["-", tag.delete_prefix("-")]
        elsif tag.starts_with?("~")
          ["~", tag.delete_prefix("~")]
        else
          [nil, tag]
        end
      end

      def parse_tag(tag, output)
        operator, tag = parse_tag_operator(tag)

        if tag.blank?
          # XXX ignore "-", "~" operators without a tag.
        elsif tag.include?("*")
          tags = Tag.wildcard_matches(tag)

          if operator == "-"
            output[:exclude] += tags
          else
            tags = ["~no_matches~"] if tags.empty? # force empty results if wildcard found no matches.
            output[:include] += tags
          end
        elsif operator == "-"
          output[:exclude] << tag
        elsif operator == "~"
          output[:include] << tag
        else
          output[:related] << tag
        end
      end

      def parse_cast(object, type)
        case type
        when :integer
          object.to_i

        when :float
          object.to_f

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

      def parse_helper(range, type = :integer)
        # "1", "0.5", "5.", ".5":
        # (-?(\d+(\.\d*)?|\d*\.\d+))
        case range
        when /\A(.+?)\.\.(.+)/
          return [:between, parse_cast($1, type), parse_cast($2, type)]

        when /\A<=(.+)/, /\A\.\.(.+)/
          return [:lte, parse_cast($1, type)]

        when /\A<(.+)/
          return [:lt, parse_cast($1, type)]

        when /\A>=(.+)/, /\A(.+)\.\.\Z/
          return [:gte, parse_cast($1, type)]

        when /\A>(.+)/
          return [:gt, parse_cast($1, type)]

        when /[, ]/
          return [:in, range.split(/[, ]+/).map {|x| parse_cast(x, type)}]

        when "any"
          return [:eq, :any]

        when "none"
          return [:eq, :none]

        else
          # add a 5% tolerance for float and filesize values
          if type == :float || (type == :filesize && range =~ /[km]b?\z/i)
            value = parse_cast(range, type)
            [:between, value * 0.95, value * 1.05]
          else
            [:eq, parse_cast(range, type)]
          end
        end
      end

      def reverse_parse_helper(array)
        case array[0]
        when :between
          [:between, *array[1..-1].reverse]

        when :lte
          [:gte, *array[1..-1]]

        when :lt
          [:gt, *array[1..-1]]

        when :gte
          [:lte, *array[1..-1]]

        when :gt
          [:lt, *array[1..-1]]

        else
          array
        end
      end
    end
  end
end
