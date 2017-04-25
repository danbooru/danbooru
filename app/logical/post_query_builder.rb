class PostQueryBuilder
  attr_accessor :query_string, :has_constraints

  def initialize(query_string)
    @query_string = query_string
    @has_constraint = false
  end

  def has_constraints?
    @has_constraints
  end

  def has_constraints!
    @has_constraints = true
  end

  def add_range_relation(arr, field, relation)
    return relation if arr.nil?

    has_constraints!

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
      has_constraints!
    end

    if tags[:related].any?
      tag_query_sql << "(" + escape_string_for_tsquery(tags[:related]).join(" & ") + ")"
      has_constraints!
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
          post_ids = SavedSearch.post_ids(CurrentUser.id)
        else
          post_ids = SavedSearch.post_ids(CurrentUser.id, saved_search)
        end

        post_ids = [0] if post_ids.empty?
        relation = relation.where(["posts.id IN (?)", post_ids])
      end
    end

    relation
  end

  def build(relation = nil)
    unless query_string.is_a?(Hash)
      q = Tag.parse_query(query_string)
    end

    if relation.nil?
      relation = Post.where("true")
    end

    if q[:tag_count].to_i > Danbooru.config.tag_query_limit
      raise ::Post::SearchError.new("You cannot search for more than #{Danbooru.config.tag_query_limit} tags at a time")
    end

    if CurrentUser.safe_mode?
      relation = relation.where("posts.rating = 's'")
    end

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
    relation = add_range_relation(q[:general_tag_count], "posts.tag_count_general", relation)
    relation = add_range_relation(q[:artist_tag_count], "posts.tag_count_artist", relation)
    relation = add_range_relation(q[:copyright_tag_count], "posts.tag_count_copyright", relation)
    relation = add_range_relation(q[:character_tag_count], "posts.tag_count_character", relation)
    relation = add_range_relation(q[:post_tag_count], "posts.tag_count", relation)
    relation = add_range_relation(q[:pixiv_id], "posts.pixiv_id", relation)

    if q[:md5]
      relation = relation.where(["posts.md5 IN (?)", q[:md5]])
      has_constraints!
    end

    if q[:status] == "pending"
      relation = relation.where("posts.is_pending = TRUE")
    elsif q[:status] == "flagged"
      relation = relation.where("posts.is_flagged = TRUE")
    elsif q[:status] == "deleted"
      relation = relation.where("posts.is_deleted = TRUE")
    elsif q[:status] == "banned"
      relation = relation.where("posts.is_banned = TRUE")
    elsif q[:status] == "active"
      relation = relation.where("posts.is_pending = FALSE AND posts.is_deleted = FALSE AND posts.is_banned = FALSE")
    elsif q[:status] == "all" || q[:status] == "any"
      # do nothing
    elsif q[:status_neg] == "pending"
      relation = relation.where("posts.is_pending = FALSE")
    elsif q[:status_neg] == "flagged"
      relation = relation.where("posts.is_flagged = FALSE")
    elsif q[:status_neg] == "deleted"
      relation = relation.where("posts.is_deleted = FALSE")
    elsif q[:status_neg] == "banned"
      relation = relation.where("posts.is_banned = FALSE")
    elsif q[:status_neg] == "active"
      relation = relation.where("posts.is_pending = TRUE OR posts.is_deleted = TRUE OR posts.is_banned = TRUE")
    elsif CurrentUser.user.hide_deleted_posts? && !CurrentUser.admin_mode?
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
        relation = relation.where("(posts.source = '' OR posts.source IS NULL)")
      elsif q[:source] == "http%"
        relation = relation.where("(lower(posts.source) like ?)", "http%")
      elsif q[:source] =~ /^(?:https?:\/\/)?%\.?pixiv(?:\.net(?:\/img)?)?(?:%\/img\/|%\/|(?=%$))(.+)$/i
        relation = relation.where("SourcePattern(lower(posts.source)) LIKE lower(?) ESCAPE E'\\\\'", "pixiv/" + $1)
        has_constraints!
      else
        relation = relation.where("SourcePattern(lower(posts.source)) LIKE SourcePattern(lower(?)) ESCAPE E'\\\\'", q[:source])
        has_constraints!
      end
    end

    if q[:source_neg]
      if q[:source_neg] == "none%"
        relation = relation.where("(posts.source != '' AND posts.source IS NOT NULL)")
      elsif q[:source_neg] == "http%"
        relation = relation.where("(lower(posts.source) not like ?)", "http%")
      elsif q[:source_neg] =~ /^(?:https?:\/\/)?%\.?pixiv(?:\.net(?:\/img)?)?(?:%\/img\/|%\/|(?=%$))(.+)$/i
        relation = relation.where("SourcePattern(lower(posts.source)) NOT LIKE lower(?) ESCAPE E'\\\\'", "pixiv/" + $1)
        has_constraints!
      else
        relation = relation.where("SourcePattern(lower(posts.source)) NOT LIKE SourcePattern(lower(?)) ESCAPE E'\\\\'", q[:source_neg])
        has_constraints!
      end
    end

    if q[:pool] == "none"
      relation = relation.where("posts.pool_string = ''")
    elsif q[:pool] == "any"
      relation = relation.where("posts.pool_string != ''")
    end

    if q[:saved_searches]
      relation = add_saved_search_relation(q[:saved_searches], relation)
      has_constraints!
    end

    if q[:uploader_id_neg]
      relation = relation.where("posts.uploader_id not in (?)", q[:uploader_id_neg])
    end

    if q[:uploader_id]
      relation = relation.where("posts.uploader_id = ?", q[:uploader_id])
      has_constraints!
    end

    if q[:approver_id_neg]
      relation = relation.where("posts.approver_id not in (?)", q[:approver_id_neg])
    end

    if q[:approver_id]
      if q[:approver_id] == "any"
        relation = relation.where("posts.approver_id is not null")
      elsif q[:approver_id] == "none"
        relation = relation.where("posts.approver_id is null")
      else
        relation = relation.where("posts.approver_id = ?", q[:approver_id])
      end
      has_constraints!
    end

    if q[:commenter_ids]
      q[:commenter_ids].each do |commenter_id|
        if commenter_id == "any"
          relation = relation.where("posts.last_commented_at is not null")
        elsif commenter_id == "none"
          relation = relation.where("posts.last_commented_at is null")
        else
          relation = relation.where("posts.id":  Comment.unscoped.where(creator_id: commenter_id).select(:post_id).distinct)
        end
      end
      has_constraints!
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
      has_constraints!
    end

    if q[:note_updater_ids]
      q[:note_updater_ids].each do |note_updater_id|
        relation = relation.where("posts.id IN (?)", NoteVersion.unscoped.where("updater_id = ?", note_updater_id).select("post_id").uniq)
      end
      has_constraints!
    end

    if q[:artcomm_ids]
      q[:artcomm_ids].each do |artcomm_id|
        relation = relation.where("posts.id IN (?)", ArtistCommentaryVersion.unscoped.where("updater_id = ?", artcomm_id).select("post_id").uniq)
      end
      has_constraints!
    end

    if q[:post_id_negated]
      relation = relation.where("posts.id <> ?", q[:post_id_negated])
    end

    if q[:parent] == "none"
      relation = relation.where("posts.parent_id IS NULL")
    elsif q[:parent_neg] == "none" || q[:parent] == "any"
      relation = relation.where("posts.parent_id IS NOT NULL")
    elsif q[:parent]
      relation = relation.where("(posts.id = ? or posts.parent_id = ?)", q[:parent].to_i, q[:parent].to_i)
      has_constraints!
    end

    if q[:child] == "none"
      relation = relation.where("posts.has_children = FALSE")
    elsif q[:child] == "any"
      relation = relation.where("posts.has_children = TRUE")
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
      relation = relation.order("position(' '||posts.id||' ' in ' '||(select post_ids from pools where id = #{pool_id})||' ')")
    end

    if q[:favgroups_neg].present?
      q[:favgroups_neg].each do |favgroup_rec|
        favgroup_id = favgroup_rec.to_i
        favgroup = FavoriteGroup.where("favorite_groups.id = ?", favgroup_id).first
        if favgroup
          relation = relation.where("posts.id NOT in (?)", favgroup.post_id_array)
        end
      end
    end

    if q[:favgroups].present?
      q[:favgroups].each do |favgroup_rec|
        favgroup_id = favgroup_rec.to_i
        favgroup = FavoriteGroup.where("favorite_groups.id = ?", favgroup_id).first
        if favgroup
          relation = relation.where("posts.id in (?)", favgroup.post_id_array)
        end
      end
    end

    if q[:upvote].present?
      user_id = q[:upvote]
      post_ids = PostVote.where(:user_id => user_id).where("score > 0").limit(400).pluck(:post_id)
      relation = relation.where("posts.id in (?)", post_ids)
    end

    if q[:downvote].present?
      user_id = q[:downvote]
      post_ids = PostVote.where(:user_id => user_id).where("score < 0").limit(400).pluck(:post_id)
      relation = relation.where("posts.id in (?)", post_ids)
    end

    if q[:ordfav].present?
      user_id = q[:ordfav].to_i
      user = User.find(user_id)

      if user.hide_favorites?
        raise User::PrivilegeError.new
      end

      relation = relation.joins("INNER JOIN favorites ON favorites.post_id = posts.id")
      relation = relation.where("favorites.user_id % 100 = ? and favorites.user_id = ?", user_id % 100, user_id).order("favorites.id DESC")
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
      relation = relation.order("posts.score DESC")

    when "score_asc"
      relation = relation.order("posts.score ASC")

    when "favcount"
      relation = relation.order("posts.fav_count DESC")

    when "favcount_asc"
      relation = relation.order("posts.fav_count ASC")

    when "change", "change_desc"
      relation = relation.order("posts.updated_at DESC")

    when "change_asc"
      relation = relation.order("posts.updated_at ASC")

    when "comment", "comm"
      relation = relation.order("posts.last_commented_at DESC NULLS LAST")

    when "comment_asc", "comm_asc"
      relation = relation.order("posts.last_commented_at ASC NULLS LAST")

    when "comment_bumped"
      relation = relation.order("posts.last_comment_bumped_at DESC NULLS LAST")

    when "comment_bumped_asc"
      relation = relation.order("posts.last_comment_bumped_at ASC NULLS LAST")

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
      relation = relation.where("posts.image_width is not null and posts.image_height is not null")
      # Use "w*h/1000000", even though "w*h" would give the same result, so this can use
      # the posts_mpixels index.
      relation = relation.order("posts.image_width * posts.image_height / 1000000.0 DESC")

    when "mpixels_asc"
      relation = relation.where("posts.image_width is not null and posts.image_height is not null")
      relation = relation.order("posts.image_width * posts.image_height / 1000000.0 ASC")

    when "portrait"
      relation = relation.order("1.0 * posts.image_width / GREATEST(1, posts.image_height) ASC")

    when "landscape"
      relation = relation.order("1.0 * posts.image_width / GREATEST(1, posts.image_height) DESC")

    when "filesize", "filesize_desc"
      relation = relation.order("posts.file_size DESC")

    when "filesize_asc"
      relation = relation.order("posts.file_size ASC")

    when "rank"
      relation = relation.order("log(3, posts.score) + (extract(epoch from posts.created_at) - extract(epoch from timestamp '2005-05-24')) / 35000 DESC")

    else
      relation = relation.order("posts.id DESC")
    end

    relation
  end
end
