class PostQueryBuilder
  attr_accessor :query_string, :read_only

  def initialize(query_string, read_only: false)
    @query_string = query_string
    @read_only = read_only
  end

  def add_range_relation(arr, field, relation)
    return relation if arr.nil?

    case arr[0]
    when :eq
      if arr[1].is_a?(Time)
        relation.where("#{field} between ? and ?", arr[1].beginning_of_day, arr[1].end_of_day)
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
    array.map do |token|
      token.to_escaped_for_tsquery
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
    if SavedSearch.enabled?
      saved_searches.each do |saved_search|
        if saved_search == "all"
          post_ids = SavedSearch.post_ids_for(CurrentUser.id)
        else
          post_ids = SavedSearch.post_ids_for(CurrentUser.id, label: saved_search)
        end

        post_ids = [0] if post_ids.empty?
        relation = relation.where("posts.id": post_ids)
      end
    end

    relation
  end

  def table_for_metatag(metatag)
    if metatag.in?(Tag::COUNT_METATAGS)
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
      q = Tag.parse_query(query_string)
    end

    relation = read_only ? PostReadOnly.all : Post.all

    if q[:tag_count].to_i > Danbooru.config.tag_query_limit
      raise ::Post::SearchError.new("You cannot search for more than #{Danbooru.config.tag_query_limit} tags at a time")
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
    TagCategory.categories.each do |category|
      relation = add_range_relation(q["#{category}_tag_count".to_sym], "posts.tag_count_#{category}", relation)
    end
    relation = add_range_relation(q[:post_tag_count], "posts.tag_count", relation)

    Tag::COUNT_METATAGS.each do |column|
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

    # The SourcePattern SQL function replaces Pixiv sources with "pixiv/[suffix]", where
    # [suffix] is everything past the second-to-last slash in the URL.  It leaves non-Pixiv
    # URLs unchanged.  This is to ease database load for Pixiv source searches.
    if q[:source]
      if q[:source] == "none%"
        relation = relation.where("posts.source = ''")
      elsif q[:source] == "http%"
        relation = relation.where("(lower(posts.source) like ?)", "http%")
      elsif q[:source] =~ /^(?:https?:\/\/)?%\.?pixiv(?:\.net(?:\/img)?)?(?:%\/img\/|%\/|(?=%$))(.+)$/i
        relation = relation.where("SourcePattern(lower(posts.source)) LIKE lower(?) ESCAPE E'\\\\'", "pixiv/" + $1)
      else
        relation = relation.where("SourcePattern(lower(posts.source)) LIKE SourcePattern(lower(?)) ESCAPE E'\\\\'", q[:source])
      end
    end

    if q[:source_neg]
      if q[:source_neg] == "none%"
        relation = relation.where("posts.source != ''")
      elsif q[:source_neg] == "http%"
        relation = relation.where("(lower(posts.source) not like ?)", "http%")
      elsif q[:source_neg] =~ /^(?:https?:\/\/)?%\.?pixiv(?:\.net(?:\/img)?)?(?:%\/img\/|%\/|(?=%$))(.+)$/i
        relation = relation.where("SourcePattern(lower(posts.source)) NOT LIKE lower(?) ESCAPE E'\\\\'", "pixiv/" + $1)
      else
        relation = relation.where("SourcePattern(lower(posts.source)) NOT LIKE SourcePattern(lower(?)) ESCAPE E'\\\\'", q[:source_neg])
      end
    end

    if q[:pool] == "none"
      relation = relation.where("posts.pool_string = ''")
    elsif q[:pool] == "any"
      relation = relation.where("posts.pool_string != ''")
    end

    if q[:saved_searches]
      relation = add_saved_search_relation(q[:saved_searches], relation)
    end

    if q[:uploader_id_neg]
      relation = relation.where.not("posts.uploader_id": q[:uploader_id_neg])
    end

    if q[:uploader_id]
      relation = relation.where("posts.uploader_id": q[:uploader_id])
    end

    if q[:approver_id_neg]
      relation = relation.where.not("posts.approver_id": q[:approver_id_neg])
    end

    if q[:approver_id]
      if q[:approver_id] == "any"
        relation = relation.where("posts.approver_id is not null")
      elsif q[:approver_id] == "none"
        relation = relation.where("posts.approver_id is null")
      else
        relation = relation.where("posts.approver_id": q[:approver_id])
      end
    end

    if q[:disapproval]
      q[:disapproval].each do |disapproval|
        disapprovals = CurrentUser.user.post_disapprovals.select(:post_id)

        if disapproval.in?(%w[none false])
          relation = relation.where.not("posts.id": disapprovals)
        elsif disapproval.in?(%w[any all true])
          relation = relation.where("posts.id": disapprovals)
        else
          relation = relation.where("posts.id": disapprovals.where(reason: disapproval))
        end
      end
    end

    if q[:disapproval_neg]
      q[:disapproval_neg].each do |disapproval|
        disapprovals = CurrentUser.user.post_disapprovals.select(:post_id)

        if disapproval.in?(%w[none false])
          relation = relation.where("posts.id": disapprovals)
        elsif disapproval.in?(%w[any all true])
          relation = relation.where.not("posts.id": disapprovals)
        else
          relation = relation.where.not("posts.id": disapprovals.where(reason: disapproval))
        end
      end
    end

    if q[:flagger_ids_neg]
      q[:flagger_ids_neg].each do |flagger_id|
        if CurrentUser.can_view_flagger?(flagger_id)
          post_ids = PostFlag.unscoped.search({:creator_id => flagger_id, :category => "normal"}).reorder("").select {|flag| flag.not_uploaded_by?(CurrentUser.id)}.map {|flag| flag.post_id}.uniq
          if post_ids.any?
            relation = relation.where.not("posts.id": post_ids)
          end
        end
      end
    end

    if q[:flagger_ids]
      q[:flagger_ids].each do |flagger_id|
        if flagger_id == "any"
          relation = relation.where('EXISTS (' + PostFlag.unscoped.search({:category => "normal"}).where('post_id = posts.id').reorder('').select('1').to_sql + ')')
        elsif flagger_id == "none"
          relation = relation.where('NOT EXISTS (' + PostFlag.unscoped.search({:category => "normal"}).where('post_id = posts.id').reorder('').select('1').to_sql + ')')
        elsif CurrentUser.can_view_flagger?(flagger_id)
          post_ids = PostFlag.unscoped.search({:creator_id => flagger_id, :category => "normal"}).reorder("").select {|flag| flag.not_uploaded_by?(CurrentUser.id)}.map {|flag| flag.post_id}.uniq
          relation = relation.where("posts.id": post_ids)
        end
      end
    end

    if q[:appealer_ids_neg]
      q[:appealer_ids_neg].each do |appealer_id|
        relation = relation.where.not("posts.id":  PostAppeal.unscoped.where(creator_id: appealer_id).select(:post_id).distinct)
      end
    end

    if q[:appealer_ids]
      q[:appealer_ids].each do |appealer_id|
        if appealer_id == "any"
          relation = relation.where('EXISTS (' + PostAppeal.unscoped.where('post_id = posts.id').select('1').to_sql + ')')
        elsif appealer_id == "none"
          relation = relation.where('NOT EXISTS (' + PostAppeal.unscoped.where('post_id = posts.id').select('1').to_sql + ')')
        else
          relation = relation.where("posts.id": PostAppeal.unscoped.where(creator_id: appealer_id).select(:post_id).distinct)
        end
      end
    end

    if q[:commenter_ids]
      q[:commenter_ids].each do |commenter_id|
        if commenter_id == "any"
          relation = relation.where("posts.last_commented_at is not null")
        elsif commenter_id == "none"
          relation = relation.where("posts.last_commented_at is null")
        else
          relation = relation.where("posts.id": Comment.unscoped.where(creator_id: commenter_id).select(:post_id).distinct)
        end
      end
    end

    if q[:noter_ids]
      q[:noter_ids].each do |noter_id|
        if noter_id == "any"
          relation = relation.where("posts.last_noted_at is not null")
        elsif noter_id == "none"
          relation = relation.where("posts.last_noted_at is null")
        else
          relation = relation.where("posts.id": Note.unscoped.where(creator_id: noter_id).select("post_id").distinct)
        end
      end
    end

    if q[:note_updater_ids]
      q[:note_updater_ids].each do |note_updater_id|
        relation = relation.where("posts.id": NoteVersion.unscoped.where(updater_id: note_updater_id).select("post_id").distinct)
      end
    end

    if q[:artcomm_ids]
      q[:artcomm_ids].each do |artcomm_id|
        relation = relation.where("posts.id": ArtistCommentaryVersion.unscoped.where(updater_id: artcomm_id).select("post_id").distinct)
      end
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

    if q[:pixiv_id]
      if q[:pixiv_id] == "any"
        relation = relation.where("posts.pixiv_id IS NOT NULL")
      elsif q[:pixiv_id] == "none"
        relation = relation.where("posts.pixiv_id IS NULL")
      else
        relation = add_range_relation(q[:pixiv_id], "posts.pixiv_id", relation)
      end
    end

    if q[:rating] =~ /^q/
      relation = relation.where("posts.rating = 'q'")
    elsif q[:rating] =~ /^s/
      relation = relation.where("posts.rating = 's'")
    elsif q[:rating] =~ /^e/
      relation = relation.where("posts.rating = 'e'")
    end

    if q[:rating_negated] =~ /^q/
      relation = relation.where("posts.rating <> 'q'")
    elsif q[:rating_negated] =~ /^s/
      relation = relation.where("posts.rating <> 's'")
    elsif q[:rating_negated] =~ /^e/
      relation = relation.where("posts.rating <> 'e'")
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

    relation = add_tag_string_search_relation(q[:tags], relation)

    if q[:ordpool].present?
      pool_id = q[:ordpool].to_i

      pool_posts = Pool.joins("CROSS JOIN unnest(pools.post_ids) WITH ORDINALITY AS row(post_id, pool_index)").where(id: pool_id).select(:post_id, :pool_index)
      relation = relation.joins("JOIN (#{pool_posts.to_sql}) pool_posts ON pool_posts.post_id = posts.id").order("pool_posts.pool_index ASC")
    end

    if q[:favgroups_neg].present?
      q[:favgroups_neg].each do |favgroup_rec|
        favgroup_id = favgroup_rec.to_i
        favgroup = FavoriteGroup.where("favorite_groups.id = ?", favgroup_id).first
        if favgroup
          relation = relation.where.not("posts.id": favgroup.post_id_array)
        end
      end
    end

    if q[:favgroups].present?
      q[:favgroups].each do |favgroup_rec|
        favgroup_id = favgroup_rec.to_i
        favgroup = FavoriteGroup.where("favorite_groups.id = ?", favgroup_id).first
        if favgroup
          relation = relation.where("posts.id": favgroup.post_id_array)
        end
      end
    end

    if q[:upvote].present?
      user_id = q[:upvote]
      post_ids = PostVote.where(:user_id => user_id).where("score > 0").limit(400).pluck(:post_id)
      relation = relation.where("posts.id": post_ids)
    end

    if q[:downvote].present?
      user_id = q[:downvote]
      post_ids = PostVote.where(:user_id => user_id).where("score < 0").limit(400).pluck(:post_id)
      relation = relation.where("posts.id": post_ids)
    end

    if q[:ordfav].present?
      user_id = q[:ordfav].to_i
      relation = relation.joins("INNER JOIN favorites ON favorites.post_id = posts.id")
      relation = relation.where("favorites.user_id % 100 = ? and favorites.user_id = ?", user_id % 100, user_id).order("favorites.id DESC")
    end

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

    case q[:order]
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

    when /\A(?<column>#{Tag::COUNT_METATAGS.join("|")})(_(?<direction>asc|desc))?\z/i
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

    when "custom"
      if q[:post_id].present? && q[:post_id][0] == :in
        relation = relation.find_ordered(q[:post_id][1])
      end

    else
      relation = relation.order("posts.id DESC")
    end

    relation
  end
end
