# frozen_string_literal: true

# Calculates global application-level metrics for /metrics. This mostly consists of counts of the size of various tables, plus app version info.
#
# @see app/logical/danbooru/metric.rb
# @see app/controllers/metrics_controller.rb
class ApplicationMetrics
  attr_reader :metrics

  def initialize
    @metrics = [
      [:danbooru_info,                                :counter, "Information about the current build of the application."],
      [:danbooru_artists_total,                       :gauge,   "The total number of artists."],
      [:danbooru_artist_urls_total,                   :gauge,   "The total number of artist URLs."],
      [:danbooru_artist_versions_total,               :counter, "The total number of artist versions."],
      [:danbooru_background_jobs_total,               :gauge,   "The total number of background jobs."],
      [:danbooru_bans_total,                          :gauge,   "The total number of bans."],
      [:danbooru_bulk_update_requests_total,          :gauge,   "The total number of bulk update requests."],
      [:danbooru_comments_total,                      :gauge,   "The total number of comments."],
      [:danbooru_comment_votes_total,                 :gauge,   "The total number of comment votes."],
      [:danbooru_favorites_total,                     :gauge,   "The total number of favorites."],
      [:danbooru_favorite_groups_total,               :gauge,   "The total number of favorite groups."],
      [:danbooru_forum_posts_total,                   :gauge,   "The total number of forum posts."],
      [:danbooru_forum_topics_total,                  :gauge,   "The total number of forum topics."],
      [:danbooru_media_assets_total,                  :gauge,   "The total number of media assets. Excludes processing or failed assets."],
      [:danbooru_media_assets_file_size_bytes_total,  :gauge,   "The total file size of all active media assets. Does not include thumbnails."],
      [:danbooru_media_assets_pixels_total,           :gauge,   "The total number of pixels in all active media assets (that is, the sum of width * height for all images). Does not account for animated images."],
      [:danbooru_media_assets_duration_seconds_total, :gauge,   "The total runtime of all active media assets. Includes videos, animated GIFs and PNGs, and ugoiras."],
      [:danbooru_post_votes_total,                    :gauge,   "The total number of post votes."],
      [:danbooru_posts_total,                         :gauge,   "The total number of posts."],
      [:danbooru_post_appeals_total,                  :gauge,   "The total number of post appeals."],
      [:danbooru_post_flags_total,                    :gauge,   "The total number of post flags."],
      [:danbooru_notes_total,                         :gauge,   "The total number of notes."],
      [:danbooru_note_versions_total,                 :counter, "The total number of note versions."],
      [:danbooru_pools_total,                         :gauge,   "The total number of pools."],
      [:danbooru_pools_post_count_total,              :gauge,   "The total number of posts in pools."],
      [:danbooru_tags_total,                          :gauge,   "The total number of tags (excluding empty tags)."],
      [:danbooru_tags_post_count_total,               :gauge,   "The total number of tags on posts."],
      [:danbooru_uploads_total,                       :gauge,   "The total number of uploads."],
      [:danbooru_users_total,                         :counter, "The total number of users."],
      [:danbooru_user_feedbacks_total,                :gauge,   "The total number of user feedbacks (excluding deleted feedbacks)."],
      [:danbooru_wiki_pages_total,                    :gauge,   "The total number of wiki pages."],
      [:danbooru_wiki_page_versions_total,            :counter, "The total number of wiki page versions."],
    ].map do |name, type, help|
      [name, Danbooru::Metric.new(name, type: type, help: help)]
    end.to_h
  end

  # @return [Array<Danbooru::Metric>] The set of application metrics.
  def calculate
    status = ServerStatus.new
    versions = {
      ruby_version: status.ruby_version,
      danbooru_version: status.danbooru_version,
      distro_version: status.distro_version,
      libvips_version: status.libvips_version,
      ffmpeg_version: status.ffmpeg_version,
      exiftool_version: status.exiftool_version,
    }
    metrics[:danbooru_info][versions].set(1)

    Artist.group(:is_deleted).pluck(Arel.sql("is_deleted, COUNT(*)")).each do |deleted, count|
      metrics[:danbooru_artists_total][deleted: deleted].set(count)
    end

    ArtistURL.group(:is_active).pluck(Arel.sql("is_active, COUNT(*)")).each do |active, count|
      metrics[:danbooru_artist_urls_total][active: active].set(count)
    end

    ArtistVersion.pluck(Arel.sql("COUNT(*)")).each do |count|
      metrics[:danbooru_artist_versions_total].set(count)
    end

    metrics[:danbooru_background_jobs_total][status: "queued"].set(BackgroundJob.queued.count)
    metrics[:danbooru_background_jobs_total][status: "running"].set(BackgroundJob.running.count)
    metrics[:danbooru_background_jobs_total][status: "finished"].set(BackgroundJob.finished.count)
    metrics[:danbooru_background_jobs_total][status: "discarded"].set(BackgroundJob.discarded.count)

    Ban.pluck(Arel.sql("COUNT(*)")).each do |count|
      metrics[:danbooru_bans_total].set(count)
    end

    BulkUpdateRequest.group(:status).pluck(Arel.sql("status, COUNT(*)")).each do |status, count|
      metrics[:danbooru_bulk_update_requests_total][status: status].set(count)
    end

    Comment.group(:is_deleted).pluck(Arel.sql("is_deleted, COUNT(*)")).each do |deleted, count|
      metrics[:danbooru_comments_total][deleted: deleted].set(count)
    end

    CommentVote.group(:score).active.pluck(Arel.sql("score, COUNT(*)")).each do |score, count, score_sum|
      metrics[:danbooru_comment_votes_total][type: score > 0 ? "up" : "down"].set(count)
    end

    FavoriteGroup.group(:is_public).pluck(Arel.sql("is_public, COUNT(*)")).each do |is_public, count|
      metrics[:danbooru_favorite_groups_total][public: is_public].set(count)
    end

    ForumPost.group(:is_deleted).pluck(Arel.sql("is_deleted, COUNT(*)")).each do |deleted, count|
      metrics[:danbooru_forum_posts_total][deleted: deleted].set(count)
    end

    ForumTopic.group(:is_deleted).pluck(Arel.sql("is_deleted, COUNT(*)")).each do |deleted, count|
      metrics[:danbooru_forum_topics_total][deleted: deleted].set(count)
    end

    MediaAsset.active.group(:file_ext).pluck(Arel.sql("file_ext, COUNT(*), SUM(file_size), SUM(image_width*image_height), COALESCE(SUM(duration), 0)")).each do |file_ext, count, file_size, pixels, duration|
      metrics[:danbooru_media_assets_total][file_ext: file_ext].set(count)
      metrics[:danbooru_media_assets_file_size_bytes_total][file_ext: file_ext].set(file_size)
      metrics[:danbooru_media_assets_pixels_total][file_ext: file_ext].set(pixels)
      metrics[:danbooru_media_assets_duration_seconds_total][file_ext: file_ext].set(duration.round(4))
    end

    Post.pluck(Arel.sql("SUM(up_score), ABS(SUM(down_score)), SUM(fav_count), COUNT(*) FILTER (WHERE is_pending), COUNT(*) FILTER (WHERE is_flagged), COUNT(*) FILTER (WHERE is_deleted), COUNT(*)")).each do |upvote_count, downvote_count, favorite_count, pending_count, flagged_count, deleted_count, total_count|
      metrics[:danbooru_post_votes_total][type: "up"].set(upvote_count)
      metrics[:danbooru_post_votes_total][type: "down"].set(downvote_count)
      metrics[:danbooru_favorites_total].set(favorite_count)

      metrics[:danbooru_posts_total][status: "pending"].set(pending_count)
      metrics[:danbooru_posts_total][status: "flagged"].set(flagged_count)
      metrics[:danbooru_posts_total][status: "deleted"].set(deleted_count)
      metrics[:danbooru_posts_total][status: "active"].set(total_count - pending_count - deleted_count - flagged_count)
    end

    PostAppeal.group(:status).pluck(Arel.sql("status, COUNT(*)")).each do |status, count|
      metrics[:danbooru_post_appeals_total][status: status].set(count)
      metrics[:danbooru_posts_total][status: "appealed"].set(count) if status == "pending"
    end

    PostFlag.group(:status).pluck(Arel.sql("status, COUNT(*)")).each do |status, count|
      metrics[:danbooru_post_flags_total][status: status].set(count)
    end

    Note.group(:is_active).pluck(Arel.sql("is_active, COUNT(*)")).each do |active, count|
      metrics[:danbooru_notes_total][deleted: !active].set(count)
    end

    NoteVersion.pluck(Arel.sql("COUNT(*)")).each do |count|
      metrics[:danbooru_note_versions_total].set(count)
    end

    Pool.group(:category).pluck(Arel.sql("category, COUNT(*), SUM(cardinality(post_ids))")).each do |category, count, post_count|
      metrics[:danbooru_pools_total][category: category].set(count)
      metrics[:danbooru_pools_post_count_total][category: category].set(post_count)
    end

    Tag.nonempty.group(:category).pluck(Arel.sql("category, COUNT(*), SUM(post_count)")).each do |category, count, post_count|
      metrics[:danbooru_tags_total][category: TagCategory.reverse_mapping[category]].set(count)
      metrics[:danbooru_tags_post_count_total][category: TagCategory.reverse_mapping[category]].set(post_count)
    end

    Upload.group(:status).pluck(Arel.sql("status, COUNT(*)")).each do |status, count|
      metrics[:danbooru_uploads_total][status: status].set(count)
    end

    User.pluck(Arel.sql("COUNT(*)")).each do |count|
      metrics[:danbooru_users_total].set(count)
    end

    UserFeedback.active.group(:category).pluck(Arel.sql("category, COUNT(*)")).each do |category, count|
      metrics[:danbooru_user_feedbacks_total][category: category].set(count)
    end

    WikiPage.group(:is_deleted).pluck(Arel.sql("is_deleted, COUNT(*)")).each do |deleted, count|
      metrics[:danbooru_wiki_pages_total][deleted: deleted].set(count)
    end

    WikiPageVersion.pluck(Arel.sql("COUNT(*)")).each do |count|
      metrics[:danbooru_wiki_page_versions_total].set(count)
    end

    metrics.values
  end
end
