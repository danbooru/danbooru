# frozen_string_literal: true

# Calculates metrics for the /metrics and /metrics/instance endpoints.
#
# @see app/logical/danbooru/metric.rb
# @see app/controllers/metrics_controller.rb
class ApplicationMetrics
  extend Memoist

  delegate :[], to: :process_metrics

  # The Puma worker ID identifies the current Puma process. Each worker gets an ID from 0 to num_workers-1. Every time a
  # worker is killed, a new worker is started with a new PID but the same worker ID.
  #
  # Set in config/puma.rb.
  attr_accessor :puma_worker_id

  # @param [ApplicationMetrics] The singleton instance. Class methods are delegated to this.
  def self.instance
    @instance ||= new
  end

  # Returns metrics related to the site as a whole. This mostly consists of the sizes of various database tables.
  #
  # @return [Danbooru::Metric::Set] The set of application metrics.
  def application_metrics
    metrics = Danbooru::Metric::Set.new([
      { name: :danbooru_info,                                type: :counter, help: "Information about the current application build." },
      { name: :danbooru_artists_total,                       type: :gauge,   help: "The total number of artists." },
      { name: :danbooru_artist_commentaries_total,           type: :counter, help: "The total number of artist commentaries." },
      { name: :danbooru_artist_commentary_versions_total,    type: :counter, help: "The total number of artist commentary versions." },
      { name: :danbooru_artist_urls_total,                   type: :gauge,   help: "The total number of artist URLs." },
      { name: :danbooru_artist_versions_total,               type: :counter, help: "The total number of artist versions." },
      { name: :danbooru_background_jobs_total,               type: :gauge,   help: "The total number of background jobs." },
      { name: :danbooru_bans_total,                          type: :gauge,   help: "The total number of user bans." },
      { name: :danbooru_bulk_update_requests_total,          type: :gauge,   help: "The total number of bulk update requests." },
      { name: :danbooru_comments_total,                      type: :gauge,   help: "The total number of comments." },
      { name: :danbooru_comment_votes_total,                 type: :gauge,   help: "The total number of comment votes." },
      { name: :danbooru_dtext_links_total,                   type: :gauge,   help: "The total number of DText links in wikis, forum posts, etc." },
      { name: :danbooru_favorites_total,                     type: :gauge,   help: "The total number of favorites." },
      { name: :danbooru_favorite_groups_total,               type: :gauge,   help: "The total number of favorite groups." },
      { name: :danbooru_forum_posts_total,                   type: :gauge,   help: "The total number of forum posts." },
      { name: :danbooru_forum_post_votes_total,              type: :counter, help: "The total number of forum post votes." },
      { name: :danbooru_forum_topics_total,                  type: :gauge,   help: "The total number of forum topics." },
      { name: :danbooru_media_assets_total,                  type: :gauge,   help: "The total number of media assets. Excludes processing or failed assets." },
      { name: :danbooru_media_assets_file_size_bytes_total,  type: :gauge,   help: "The total file size of all active media assets. Does not include thumbnails." },
      { name: :danbooru_media_assets_pixels_total,           type: :gauge,   help: "The total number of pixels in all active media assets (that is, the sum of width * height for all images). Does not account for animated images." },
      { name: :danbooru_media_assets_duration_seconds_total, type: :gauge,   help: "The total runtime of all active media assets. Includes videos, animated GIFs and PNGs, and ugoiras." },
      { name: :danbooru_mod_actions_total,                   type: :counter, help: "The total number of moderation actions." },
      { name: :danbooru_post_votes_total,                    type: :gauge,   help: "The total number of post votes." },
      { name: :danbooru_posts_total,                         type: :gauge,   help: "The total number of posts." },
      { name: :danbooru_post_appeals_total,                  type: :gauge,   help: "The total number of post appeals." },
      { name: :danbooru_post_approvals_total,                type: :counter, help: "The total number of post approvals." },
      { name: :danbooru_post_flags_total,                    type: :gauge,   help: "The total number of post flags." },
      { name: :danbooru_post_replacements_total,             type: :counter, help: "The total number of post replacements." },
      { name: :danbooru_notes_total,                         type: :gauge,   help: "The total number of notes." },
      { name: :danbooru_note_versions_total,                 type: :counter, help: "The total number of note versions." },
      { name: :danbooru_pools_total,                         type: :gauge,   help: "The total number of pools." },
      { name: :danbooru_pools_post_count_total,              type: :gauge,   help: "The total number of posts in pools." },
      { name: :danbooru_pool_versions_total,                 type: :counter, help: "The total number of pool versions." },
      { name: :danbooru_saved_searches_total,                type: :gauge,   help: "The total number of saved searches." },
      { name: :danbooru_tags_total,                          type: :gauge,   help: "The total number of tags (excluding empty tags)." },
      { name: :danbooru_tags_post_count_total,               type: :gauge,   help: "The total number of tags on posts." },
      { name: :danbooru_tag_aliases_total,                   type: :gauge,   help: "The total number of tag aliases." },
      { name: :danbooru_tag_implications_total,              type: :gauge,   help: "The total number of tag implications." },
      { name: :danbooru_tag_versions_total,                  type: :counter, help: "The total number of tag versions." },
      { name: :danbooru_uploads_total,                       type: :gauge,   help: "The total number of uploads." },
      { name: :danbooru_users_total,                         type: :counter, help: "The total number of user accounts." },
      { name: :danbooru_active_users_total,                  type: :gauge,   help: "The total number of logged-in users who have visited the site in the last hour/day/week/month/year." },
      { name: :danbooru_user_feedbacks_total,                type: :gauge,   help: "The total number of user feedbacks (excluding deleted feedbacks and ban messages)." },
      { name: :danbooru_wiki_pages_total,                    type: :gauge,   help: "The total number of wiki pages." },
      { name: :danbooru_wiki_page_versions_total,            type: :counter, help: "The total number of wiki page versions." },
    ])

    artists = Artist.group(:is_deleted).async_pluck(Arel.sql("is_deleted, COUNT(*)"))
    artist_commentaries = ArtistCommentary.async_pluck(Arel.sql("COUNT(*), COUNT(*) FILTER (WHERE translated_title != '' OR translated_description != '')"))
    artist_commentary_versions = ArtistCommentaryVersion.async_pluck(Arel.sql("COUNT(*)"))
    artist_urls = ArtistURL.group(:is_active).async_pluck(Arel.sql("is_active, COUNT(*)"))
    artist_versions = ArtistVersion.async_pluck(Arel.sql("COUNT(*)"))
    background_job_queued_count = BackgroundJob.queued.async_count
    background_job_running_count = BackgroundJob.running.async_count
    background_job_finished_count = BackgroundJob.finished.async_count
    background_job_discarded_count = BackgroundJob.discarded.async_count
    bans = Ban.async_pluck(Arel.sql("COUNT(*) FILTER (WHERE duration <= '1 year' AND created_at + duration > now()), COUNT(*) FILTER (WHERE duration > '1 year' AND created_at + duration > now()), COUNT(*) FILTER (WHERE created_at + duration <= now())"))
    bulk_update_requests = BulkUpdateRequest.group(:status).async_pluck(Arel.sql("status, COUNT(*)"))
    comments = Comment.group(:is_deleted).async_pluck(Arel.sql("is_deleted, COUNT(*)"))
    comment_votes = CommentVote.group(:score).active.async_pluck(Arel.sql("score, COUNT(*)"))
    dtext_links = DtextLink.group(:link_type).async_pluck(Arel.sql("link_type, COUNT(*)"))
    favorite_groups = FavoriteGroup.group(:is_public).async_pluck(Arel.sql("is_public, COUNT(*)"))
    forum_posts = ForumPost.group(:is_deleted).async_pluck(Arel.sql("is_deleted, COUNT(*)"))
    forum_post_votes = ForumPostVote.group(:score).async_pluck(Arel.sql("score, COUNT(*)"))
    forum_topics = ForumTopic.group(:is_deleted).async_pluck(Arel.sql("is_deleted, COUNT(*)"))
    media_assets = MediaAsset.active.group(:file_ext).async_pluck(Arel.sql("file_ext, COUNT(*), SUM(file_size), SUM(image_width*image_height), COALESCE(SUM(duration), 0)"))
    mod_actions = ModAction.visible(User.anonymous).group(:category).async_pluck(Arel.sql("category, COUNT(*)"))
    posts = Post.async_pluck(Arel.sql("SUM(up_score), ABS(SUM(down_score)), SUM(fav_count), COUNT(*) FILTER (WHERE is_pending), COUNT(*) FILTER (WHERE is_flagged), COUNT(*) FILTER (WHERE is_deleted), COUNT(*)"))
    post_approvals = PostApproval.async_pluck(Arel.sql("COUNT(*)"))
    post_appeals = PostAppeal.group(:status).async_pluck(Arel.sql("status, COUNT(*)"))
    post_flags = PostFlag.category_matches("normal").group(:status).async_pluck(Arel.sql("status, COUNT(*)"))
    post_replacements = PostReplacement.async_pluck(Arel.sql("COUNT(*)"))
    notes = Note.group(:is_active).async_pluck(Arel.sql("is_active, COUNT(*)"))
    note_versions = NoteVersion.async_pluck(Arel.sql("COUNT(*)"))
    pools = Pool.group(:is_deleted, :category).async_pluck(Arel.sql("is_deleted, category, COUNT(*), SUM(cardinality(post_ids))"))
    pool_versions = PoolVersion.async_pluck(Arel.sql("COUNT(*)"))
    saved_searches = SavedSearch.async_pluck(Arel.sql("COUNT(*)"))
    tags = Tag.nonempty.group(:category).async_pluck(Arel.sql("category, COUNT(*), SUM(post_count)"))
    tag_aliases = TagAlias.group(:status).async_pluck(Arel.sql("status, COUNT(*)"))
    tag_implications = TagImplication.group(:status).async_pluck(Arel.sql("status, COUNT(*)"))
    tag_versions = TagVersion.async_pluck(Arel.sql("COUNT(*)"))
    uploads = Upload.group(:status).async_pluck(Arel.sql("status, COUNT(*)"))
    users = User.async_pluck(Arel.sql("COUNT(*), COUNT(*) FILTER (WHERE last_logged_in_at > now() - interval '1 hour'), COUNT(*) FILTER (WHERE last_logged_in_at > now() - interval '1 day'), COUNT(*) FILTER (WHERE last_logged_in_at > now() - interval '1 week'), COUNT(*) FILTER (WHERE last_logged_in_at > now() - interval '1 month'), COUNT(*) FILTER (WHERE last_logged_in_at > now() - interval '1 year')"))
    user_feedbacks = UserFeedback.undeleted.not_ban.group(:category).async_pluck(Arel.sql("category, COUNT(*)"))
    wiki_pages = WikiPage.group(:is_deleted).async_pluck(Arel.sql("is_deleted, COUNT(*)"))
    wiki_page_versions = WikiPageVersion.async_pluck(Arel.sql("COUNT(*)"))

    status = ServerStatus.new
    versions = {
      danbooru_version: status.danbooru_version,
      ruby_version: status.ruby_version,
      rails_version: status.rails_version,
      puma_version: status.puma_version,
      distro_version: status.distro_version,
      libvips_version: status.libvips_version,
      ffmpeg_version: status.ffmpeg_version,
      exiftool_version: status.exiftool_version,
      jemalloc_version: status.jemalloc_version,
      docker_image_build_date: status.docker_image_build_date.utc.to_s,
    }
    metrics[:danbooru_info][versions].set(1)

    artists.value.each do |deleted, count|
      status = deleted ? "deleted" : "active"
      metrics[:danbooru_artists_total][status: status].set(count)
    end

    artist_commentaries.value.each do |count, translated|
      metrics[:danbooru_artist_commentaries_total][status: "translated"].set(translated)
      metrics[:danbooru_artist_commentaries_total][status: "untranslated"].set(count - translated)
    end

    artist_commentary_versions.value.each do |count|
      metrics[:danbooru_artist_commentary_versions_total].set(count)
    end

    artist_urls.value.each do |active, count|
      status = active ? "active" : "dead"
      metrics[:danbooru_artist_urls_total][status: status].set(count)
    end

    artist_versions.value.each do |count|
      metrics[:danbooru_artist_versions_total].set(count)
    end

    metrics[:danbooru_background_jobs_total][status: "queued"].set(background_job_queued_count.value)
    metrics[:danbooru_background_jobs_total][status: "running"].set(background_job_running_count.value)
    metrics[:danbooru_background_jobs_total][status: "finished"].set(background_job_finished_count.value)
    metrics[:danbooru_background_jobs_total][status: "discarded"].set(background_job_discarded_count.value)

    bans.value.each do |active, permanent, expired|
      metrics[:danbooru_bans_total][status: "active"].set(active)
      metrics[:danbooru_bans_total][status: "permanent"].set(permanent)
      metrics[:danbooru_bans_total][status: "expired"].set(expired)
    end

    bulk_update_requests.value.each do |status, count|
      metrics[:danbooru_bulk_update_requests_total][status: status].set(count)
    end

    comments.value.each do |deleted, count|
      status = deleted ? "deleted" : "active"
      metrics[:danbooru_comments_total][status: status].set(count)
    end

    comment_votes.value.each do |score, count|
      type = (score > 0) ? "up" : "down"
      metrics[:danbooru_comment_votes_total][type: type].set(count)
    end

    dtext_links.value.each do |link_type, count|
      metrics[:danbooru_dtext_links_total][link_type: link_type].set(count)
    end

    favorite_groups.value.each do |is_public, count|
      status = is_public ? "public" : "private"
      metrics[:danbooru_favorite_groups_total][status: status].set(count)
    end

    forum_posts.value.each do |deleted, count|
      status = deleted ? "deleted" : "active"
      metrics[:danbooru_forum_posts_total][status: status].set(count)
    end

    forum_post_votes.value.each do |score, count|
      type = { 1 => "up", 0 => "meh", -1 => "down" }.fetch(score)
      metrics[:danbooru_forum_post_votes_total][type: type].set(count)
    end

    forum_topics.value.each do |deleted, count|
      status = deleted ? "deleted" : "active"
      metrics[:danbooru_forum_topics_total][status: status].set(count)
    end

    media_assets.value.each do |file_ext, count, file_size, pixels, duration|
      metrics[:danbooru_media_assets_total][file_ext: file_ext].set(count)
      metrics[:danbooru_media_assets_file_size_bytes_total][file_ext: file_ext].set(file_size)
      metrics[:danbooru_media_assets_pixels_total][file_ext: file_ext].set(pixels)
      metrics[:danbooru_media_assets_duration_seconds_total][file_ext: file_ext].set(duration.round(4)) if duration > 0
    end

    mod_actions.value.each do |category, count|
      metrics[:danbooru_mod_actions_total][category: category].set(count)
    end

    posts.value.each do |upvote_count, downvote_count, favorite_count, pending_count, flagged_count, deleted_count, total_count|
      metrics[:danbooru_post_votes_total][type: "up"].set(upvote_count)
      metrics[:danbooru_post_votes_total][type: "down"].set(downvote_count)
      metrics[:danbooru_favorites_total].set(favorite_count)

      metrics[:danbooru_posts_total][status: "pending"].set(pending_count)
      metrics[:danbooru_posts_total][status: "flagged"].set(flagged_count)
      metrics[:danbooru_posts_total][status: "deleted"].set(deleted_count)
      metrics[:danbooru_posts_total][status: "active"].set(total_count - pending_count - deleted_count - flagged_count)
    end

    post_appeals.value.each do |status, count|
      metrics[:danbooru_post_appeals_total][status: status].set(count)
      metrics[:danbooru_posts_total][status: "appealed"].set(count) if status == "pending"
    end

    post_approvals.value.each do |count|
      metrics[:danbooru_post_approvals_total].set(count)
    end

    post_flags.value.each do |status, count|
      metrics[:danbooru_post_flags_total][status: status].set(count)
    end

    post_replacements.value.each do |count|
      metrics[:danbooru_post_replacements_total].set(count)
    end

    notes.value.each do |active, count|
      status = active ? "active" : "deleted"
      metrics[:danbooru_notes_total][status: status].set(count)
    end

    note_versions.value.each do |count|
      metrics[:danbooru_note_versions_total].set(count)
    end

    pools.value.each do |is_deleted, category, count, post_count|
      status = is_deleted ? "deleted" : "active"
      metrics[:danbooru_pools_total][status: status, category: category].set(count)
      metrics[:danbooru_pools_post_count_total][status: status, category: category].set(post_count)
    end

    pool_versions.value.each do |count|
      metrics[:danbooru_pool_versions_total].set(count)
    end

    saved_searches.value.each do |count|
      metrics[:danbooru_saved_searches_total].set(count)
    end

    tags.value.each do |category, count, post_count|
      metrics[:danbooru_tags_total][category: TagCategory.reverse_mapping[category]].set(count)
      metrics[:danbooru_tags_post_count_total][category: TagCategory.reverse_mapping[category]].set(post_count)
    end

    tag_aliases.value.each do |status, count|
      metrics[:danbooru_tag_aliases_total][status: status].set(count)
    end

    tag_implications.value.each do |status, count|
      metrics[:danbooru_tag_implications_total][status: status].set(count)
    end

    tag_versions.value.each do |count|
      metrics[:danbooru_tag_versions_total].set(count)
    end

    uploads.value.each do |status, count|
      metrics[:danbooru_uploads_total][status: status].set(count)
    end

    users.value.each do |count, hourly_count, daily_count, weekly_count, monthly_count, yearly_count|
      metrics[:danbooru_users_total].set(count)
      metrics[:danbooru_active_users_total][last: "hour"].set(hourly_count)
      metrics[:danbooru_active_users_total][last: "day"].set(daily_count)
      metrics[:danbooru_active_users_total][last: "week"].set(weekly_count)
      metrics[:danbooru_active_users_total][last: "month"].set(monthly_count)
      metrics[:danbooru_active_users_total][last: "year"].set(yearly_count)
    end

    user_feedbacks.value.each do |category, count|
      metrics[:danbooru_user_feedbacks_total][category: category].set(count)
    end

    wiki_pages.value.each do |deleted, count|
      status = deleted ? "deleted" : "active"
      metrics[:danbooru_wiki_pages_total][status: status].set(count)
    end

    wiki_page_versions.value.each do |count|
      metrics[:danbooru_wiki_page_versions_total].set(count)
    end

    metrics.updated_at = Time.zone.now.utc
    metrics
  end

  def cached_application_metrics(expires_in = 1.minute)
    Cache.get("application-metrics", expires_in, race_condition_ttl: 1.minute) do
      application_metrics
    end
  end

  # Returns metrics related to the current Ruby process. A Danbooru instance normally consists of a Puma server running
  # several worker processes. Metrics from each process are combined together below in `#instance_metrics`.
  #
  # @return [Danbooru::Metric::Set] The set of metrics for this process.
  memoize def process_metrics
    metrics = Danbooru::Metric::Set.new([
      { name: :target_info, type: :gauge, help: "Information about the current application instance." },
    ])

    status = ServerStatus.new
    metrics[:target_info][{
      pod_name:         status.container_name,
      node_name:        status.node_name,
      danbooru_version: status.danbooru_version,
      ruby_version:     status.ruby_version,
      rails_version:    status.rails_version,
      puma_version:     status.puma_version,
      distro_version:   status.distro_version,
      libvips_version:  status.libvips_version,
      ffmpeg_version:   status.ffmpeg_version,
      exiftool_version: status.exiftool_version,
      jemalloc_version: status.jemalloc_version,
    }].set(1)

    if puma_running?
      metrics.register([
        # Global Puma metrics (not tied to the current process)
        { name: :puma_workers,                                    type: :gauge,   help: "Number of configured worker processes." },

        # Worker-specific Puma metrics (tied to a single Puma worker process)
        { name: :puma_started_at,                                 type: :gauge,   help: "When the process started. Worker processes are periodically restarted to prevent memory bloat." },
        { name: :puma_last_checkin,                               type: :gauge,   help: "When the worker last checked in with the master process." },
        { name: :puma_restarts_total,                             type: :counter, help: "Total number of times this worker has restarted (including initial start)." },
        { name: :puma_max_threads,                                type: :gauge,   help: "Maximum number of worker threads." },
        { name: :puma_threads,                                    type: :gauge,   help: "Current number of worker threads. May be less than max threads because idle threads are periodically reaped." },
        { name: :puma_thread_backlog,                             type: :gauge,   help: "Current number of accepted connections waiting for an idle worker thread (thread pool queue length)." },
        { name: :puma_socket_backlog,                             type: :gauge,   help: "Current number of unaccepted connections (socket queue length)." },
        { name: :puma_http_requests_total,                        type: :counter, help: "Total number of HTTP requests processed by Puma since the worker started." },
      ])
    end

    metrics.register([
      { name: :rails_http_requests_total,                         type: :counter, help: "Total number of HTTP requests processed by Rails. Does not include requests processed by Rack middleware or by the Rails router before they got to Rails, such as redirects." },
      { name: :rails_http_request_duration_seconds,               type: :counter, help: "Time spent processing HTTP requests. Total time is CPU time plus idle time. View time is a subset of CPU time. DB time is a subset of idle time." },
      { name: :rails_view_renders_total,                          type: :counter, help: "Total number of view templates rendered." },
      { name: :rails_view_render_duration_seconds,                type: :counter, help: "Time spent rendering view templates." },
      { name: :rails_cache_operations_total,                      type: :counter, help: "Total number of Redis cache operations." },
      { name: :rails_cache_operation_duration_seconds,            type: :counter, help: "Time spent performing Redis cache operations." },
      { name: :rails_cache_reads_total,                           type: :counter, help: "Total number of hits and misses in single-key read operations." },
      { name: :rails_cache_read_multi_keys_total,                 type: :counter, help: "Total number of hits and misses in multi-key read operations." },
      { name: :rails_cache_write_multi_keys_total,                type: :counter, help: "Total number of keys written in multi-key write operations." },
      { name: :rails_sql_queries_total,                           type: :counter, help: "Total number of SQL queries executed." },
      { name: :rails_sql_query_duration_seconds,                  type: :counter, help: "Time spent processing SQL queries." },
      { name: :rails_active_record_instantiations_total,          type: :counter, help: "Total number of Active Record objects instantiated." },

      { name: :puma_exceptions_total,                             type: :counter, help: "Total number of exceptions caught by Puma. These are errors not caught by the normal Rails error handler, usually errors in middleware or in the error handler itself." },
      { name: :rails_exceptions_total,                            type: :counter, help: "Total number of exceptions caught by Rails. These are errors caught by the error handler in ApplicationController." },

      { name: :rails_jobs_enqueued_total,                         type: :counter, help: "Total number of background jobs successfully enqueued. Does not include foreground jobs." },
      { name: :rails_jobs_attempts_total,                         type: :counter, help: "Total number of jobs attempted to be worked. Includes successful jobs, failed jobs, and retried jobs." },
      { name: :rails_jobs_worked_total,                           type: :counter, help: "Total number of jobs successfully worked." },
      { name: :rails_jobs_retries_total,                          type: :counter, help: "Total number of jobs retried after a failure." },
      { name: :rails_jobs_exceptions_total,                       type: :counter, help: "Total number of jobs failed due to an exception." },
      { name: :rails_jobs_duration_seconds,                       type: :counter, help: "Time spent working jobs. Does not include time spent enqueuing jobs, or waiting for queued jobs to be worked." },
      { name: :rails_jobs_queue_duration_seconds,                 type: :counter, help: "Time spent waiting on jobs to be worked. Does not include time spent enqueuing jobs." },
      { name: :rails_jobs_enqueue_duration_seconds,               type: :counter, help: "Time spent adding jobs to the queue." },

      { name: :rails_connection_pool_size,                        type: :gauge,   help: "Maximum number of database connections in the pool." },
      { name: :rails_connection_pool_connections,                 type: :gauge,   help: "Current number of database connections by state." },
      { name: :rails_connection_pool_waiting,                     type: :gauge,   help: "Current number of threads blocked waiting to checkout a database connection." },
      { name: :rails_connection_pool_checkout_timeout,            type: :gauge,   help: "Maxmimum amount of time to wait on checking out a database connection." },

      { name: :concurrent_ruby_thread_pool_completed_task_count,  type: :counter, help: "Total number of tasks completed by this thread pool (not including tasks executed by the caller)." },
      { name: :concurrent_ruby_thread_pool_scheduled_task_count,  type: :counter, help: "Total number of tasks scheduled on this thread pool (not including tasks executed by the caller)." },
      { name: :concurrent_ruby_thread_pool_active_task_count,     type: :gauge,   help: "Current number of threads in this pool actively executing tasks." },
      { name: :concurrent_ruby_thread_pool_thread_count,          type: :gauge,   help: "Current number of threads in this pool. Every time a task is executed, idle threads may be pruned." },
      { name: :concurrent_ruby_thread_pool_spawned_thread_count,  type: :counter, help: "Total number of threads spawned by this pool." },

      { name: :ruby_pid,                                          type: :gauge,   help: "Current process ID." },
      { name: :ruby_thread_count,                                 type: :gauge,   help: "Current number of threads." },
      { name: :ruby_vm_constant_cache_invalidations,              type: :counter, help: "Total number of constant cache invalidations." },
      { name: :ruby_vm_constant_cache_misses,                     type: :counter, help: "Total number of constant cache misses." },
      { name: :ruby_objects_count,                                type: :gauge,   help: "Current number of Ruby objects by type." },
      { name: :ruby_objects_size_bytes,                           type: :gauge,   help: "Current approximate size of all Ruby objects." },
      { name: :ruby_objects_symbols_count,                        type: :gauge,   help: "Current number of symbol objects. Immortal symbols aren't garbage collected." },
      { name: :ruby_objects_tdata_count,                          type: :gauge,   help: "Current number of T_DATA objects. TypedData objects are Ruby wrappers around C structs." },
      { name: :ruby_objects_imemo_count,                          type: :gauge,   help: "Current number of T_IMEMO objects." },

      { name: :ruby_gc_total,                                     type: :counter, help: "Total number of garbage collections since process start." },
      { name: :ruby_gc_duration_seconds,                          type: :counter, help: "Time spent in garbage collection since process start." },
      { name: :ruby_gc_heap_pages_allocated_total,                type: :counter, help: "Total number of heap pages allocated from the OS since process start." },
      { name: :ruby_gc_heap_pages_freed_total,                    type: :counter, help: "Total number of heap pages freed back to the OS since process start." },
      { name: :ruby_gc_objects_allocated_total,                   type: :counter, help: "Total number of objects allocated since process start." },
      { name: :ruby_gc_objects_freed_total,                       type: :counter, help: "Total number of objects freed since process start." },
      { name: :ruby_gc_heap_pages,                                type: :gauge,   help: "Current number of heap pages. Each page is #{GC::INTERNAL_CONSTANTS[:HEAP_PAGE_SIZE] / 1024}kb. Pages are divided into live or free object slots. Eden pages contain at least one live object. Tomb and allocatable pages are empty." },
      { name: :ruby_gc_heap_live_slots,                           type: :gauge,   help: "Current number of heap page slots containing live objects." },
      { name: :ruby_gc_heap_free_slots,                           type: :gauge,   help: "Current number of heap page slots not containing live objects." },
      { name: :ruby_gc_heap_final_slots,                          type: :gauge,   help: "Current number of objects with finalizers attached to them." },
      { name: :ruby_gc_heap_marked_slots,                         type: :gauge,   help: "Number of objects marked in the last GC." },
      { name: :ruby_gc_malloc_increase_bytes,                     type: :gauge,   help: "Current amount of off-heap memory allocated for objects by malloc. Decreased by major or minor GC." },
      { name: :ruby_gc_malloc_increase_bytes_limit,               type: :gauge,   help: "When malloc_increase_bytes crosses this limit, a major GC is triggered." },
      { name: :ruby_gc_compact_total,                             type: :counter, help: "Total number of heap compactions." },
      { name: :ruby_gc_read_barrier_faults,                       type: :counter, help: "Total number of times the read barrier was triggered during compaction." },
      { name: :ruby_gc_moved_objects_total,                       type: :counter, help: "Total number of objects moved by heap compaction." },
      { name: :ruby_gc_remembered_wb_unprotected_objects,         type: :gauge,   help: "Current number of objects without write barriers in the remembered set." },
      { name: :ruby_gc_remembered_wb_unprotected_objects_limit,   type: :gauge,   help: "When remembered_wb_unprotected_objects crosses this limit, major GC is triggered." },
      { name: :ruby_gc_old_objects,                               type: :gauge,   help: "Current number of live objects that have survived at least 3 garbage collections. Decreased by major GC." },
      { name: :ruby_gc_old_objects_limit,                         type: :gauge,   help: "When old_objects crosses this limit, a major GC is triggered." },
      { name: :ruby_gc_oldmalloc_increase_bytes,                  type: :gauge,   help: "Current amount of off-heap memory allocated for old objects by malloc. Decreased by major GC." },
      { name: :ruby_gc_oldmalloc_increase_bytes_limit,            type: :gauge,   help: "When old_malloc_increase_bytes crosses this limit, major GC is triggered." },

      { name: :ruby_gc_pool_heap_pages,                           type: :gauge,   help: "Current number of heap pages. Eden pages contain at least one object. Tomb and allocatable pages are empty." },
      { name: :ruby_gc_pool_heap_slots,                           type: :gauge,   help: "Current number of object slots in eden or tomb pages." },
      { name: :ruby_gc_pool_heap_pages_allocated_total,           type: :counter, help: "Total number of pages allocated per pool since process start." },
      { name: :ruby_gc_pool_heap_pages_freed_total,               type: :counter, help: "Total number of pages freed per pool since process start." },
      { name: :ruby_gc_pool_force_major_gc_count,                 type: :counter, help: "Total number of times a major GC was caused by running out of free object slots." },

      { name: :ruby_yjit_enabled,                                 type: :gauge,   help: "Whether YJIT is enabled." },
      { name: :ruby_yjit_inline_code_size,                        type: :gauge,   help: "Inlined code size." },
      { name: :ruby_yjit_outlined_code_size,                      type: :gauge,   help: "Outlined code size." },
      { name: :ruby_yjit_freed_page_count,                        type: :counter, help: "Total number of garbage collected pages." },
      { name: :ruby_yjit_freed_code_size,                         type: :gauge,   help: "Total size of garbage collected code." },
      { name: :ruby_yjit_live_page_count,                         type: :counter, help: "Current number of live pages." },
      { name: :ruby_yjit_code_gc_count,                           type: :counter, help: "Total number of code garbage collections." },
      { name: :ruby_yjit_code_region_size,                        type: :gauge,   help: "Size in bytes of memory region allocated for JIT code." },
      { name: :ruby_yjit_object_shape_count,                      type: :gauge,   help: "Current number of object shapes." },

      { name: :vips_memory_bytes,                                 type: :gauge,   help: "Current amount of memory allocated by libvips." },
      { name: :vips_allocations,                                  type: :gauge,   help: "Current number of active memory allocations by libvips." },
      { name: :vips_files,                                        type: :gauge,   help: "Current number of files opened by libvips." },
    ], labels: { worker: puma_worker_id })

    if Jemalloc.enabled?
      metrics.register([
        { name: :jemalloc_thread_count,                           type: :gauge,   help: "Current number of background threads used by jemalloc." },
        { name: :jemalloc_allocated_bytes,                        type: :gauge,   help: "Current number of bytes requested by the application itself." },
        { name: :jemalloc_mapped_bytes,                           type: :gauge,   help: "Current number of bytes in active extents mapped by the allocator." },
        { name: :jemalloc_resident_bytes,                         type: :gauge,   help: "Current number of bytes in physically resident data pages mapped by the allocator." },
        { name: :jemalloc_active_bytes,                           type: :gauge,   help: "Current number of bytes in active pages allocated by the application." },
        { name: :jemalloc_metadata_bytes,                         type: :gauge,   help: "Current number of bytes dedicated to metadata by the allocator." },
      ], labels: { worker: puma_worker_id })
    end

    metrics
  end

  # Updates metrics related to the current running Ruby process.
  #
  # @return [Danbooru::Metric::Set] The set of metrics for this process.
  def update_process_metrics
    metrics = process_metrics

    conn_pool_stats = ApplicationRecord.connection_pool.stat
    metrics[:rails_connection_pool_size][{}].set(conn_pool_stats[:size])
    metrics[:rails_connection_pool_connections][state: "busy"].set(conn_pool_stats[:busy])
    metrics[:rails_connection_pool_connections][state: "idle"].set(conn_pool_stats[:idle])
    metrics[:rails_connection_pool_connections][state: "dead"].set(conn_pool_stats[:dead])
    metrics[:rails_connection_pool_waiting][{}].set(conn_pool_stats[:waiting])
    metrics[:rails_connection_pool_checkout_timeout][{}].set(conn_pool_stats[:checkout_timeout])

    if puma_running?
      resp = Danbooru::Http.internal.timeout(1).get("http://localhost:9293/stats")
      puma_stats = resp.code == 200 ? resp.parse.with_indifferent_access : {}

      metrics.set({
        puma_started_at: Time.zone.parse(puma_stats[:started_at].to_s).to_i,
        puma_workers:    puma_stats[:workers],
      }, { worker: "master" })

      puma_stats[:worker_status].to_a.each do |worker|
        max_threads = worker.dig(:last_status, :max_threads)
        cur_threads = worker.dig(:last_status, :running)
        idle_threads = worker.dig(:last_status, :pool_capacity) - (max_threads - cur_threads)
        busy_threads = cur_threads - idle_threads

        metrics.set({
          puma_started_at:          Time.parse(worker[:started_at]).to_i,
          puma_last_checkin:        Time.parse(worker[:last_checkin]).to_i,
          puma_max_threads:         max_threads,
          puma_thread_backlog:      worker.dig(:last_status, :backlog),
          puma_http_requests_total: worker.dig(:last_status, :requests_count),
        }, { worker: worker[:index] })

        metrics[:puma_threads][worker: worker[:index], state: "idle"].set(idle_threads)
        metrics[:puma_threads][worker: worker[:index], state: "busy"].set(busy_threads)
      end

      # XXX The Puma server object is in a thread local variable, which may be in another thread, so we have to search for it.
      puma_socket = Thread.list.filter_map { |thread| thread[:puma_server] }.first&.binder&.ios&.first
      puma_socket_backlog = puma_socket&.getsockopt(Socket::SOL_TCP, Socket::TCP_INFO)&.inspect.to_s[/unacked=(\d+)/, 1].to_i
      metrics[:puma_socket_backlog][worker: puma_worker_id].set(puma_socket_backlog)
    end

    ruby_stats = RubyVM.stat
    metrics.set({
      ruby_vm_constant_cache_invalidations: ruby_stats[:constant_cache_invalidations],
      ruby_vm_constant_cache_misses:        ruby_stats[:constant_cache_misses],
      ruby_thread_count:                    Thread.list.count,
      ruby_pid:                             Process.pid,
    })

    ObjectSpace.count_objects.each do |type, count|
      next if type == :TOTAL
      metrics[:ruby_objects_count][type: type.to_s.delete_prefix("T_").downcase].set(count)
    end

    ObjectSpace.count_objects_size.each do |type, size|
      next if type == :TOTAL
      metrics[:ruby_objects_size_bytes][type: type.to_s.delete_prefix("T_").downcase].set(size)
    end

    ObjectSpace.count_tdata_objects.each do |type, count|
      metrics[:ruby_objects_tdata_count][type: type.to_s].set(count)
    end

    ObjectSpace.count_symbols.each do |type, count|
      metrics[:ruby_objects_symbols_count][type: type].set(count)
    end

    ObjectSpace.count_imemo_objects.each do |type, count|
      metrics[:ruby_objects_imemo_count][type: type].set(count)
    end

    ruby_yjit_stats = defined?(RubyVM::YJIT) ? RubyVM::YJIT.runtime_stats : Hash.new { 0 }
    metrics.set({
      ruby_yjit_enabled:            ruby_yjit_stats.present?,
      ruby_yjit_inline_code_size:   ruby_yjit_stats[:inline_code_size],
      ruby_yjit_outlined_code_size: ruby_yjit_stats[:outlined_code_size],
      ruby_yjit_freed_page_count:   ruby_yjit_stats[:freed_page_count],
      ruby_yjit_freed_code_size:    ruby_yjit_stats[:freed_code_size],
      ruby_yjit_live_page_count:    ruby_yjit_stats[:live_page_count],
      ruby_yjit_code_gc_count:      ruby_yjit_stats[:code_gc_count],
      ruby_yjit_code_region_size:   ruby_yjit_stats[:code_region_size],
      ruby_yjit_object_shape_count: ruby_yjit_stats[:object_shape_count],
    })

    gc_stats = GC.stat
    metrics.set({
      ruby_gc_duration_seconds:                        gc_stats[:time] / 1000.0,
      ruby_gc_heap_live_slots:                         gc_stats[:heap_live_slots],
      ruby_gc_heap_free_slots:                         gc_stats[:heap_free_slots],
      ruby_gc_heap_final_slots:                        gc_stats[:heap_final_slots],
      ruby_gc_heap_marked_slots:                       gc_stats[:heap_marked_slots],
      ruby_gc_heap_pages_allocated_total:              gc_stats[:total_allocated_pages],
      ruby_gc_heap_pages_freed_total:                  gc_stats[:total_freed_pages],
      ruby_gc_objects_allocated_total:                 gc_stats[:total_allocated_objects],
      ruby_gc_objects_freed_total:                     gc_stats[:total_freed_objects],
      ruby_gc_malloc_increase_bytes:                   gc_stats[:malloc_increase_bytes],
      ruby_gc_malloc_increase_bytes_limit:             gc_stats[:malloc_increase_bytes_limit],
      ruby_gc_compact_total:                           gc_stats[:compact_count],
      ruby_gc_read_barrier_faults:                     gc_stats[:read_barrier_faults],
      ruby_gc_moved_objects_total:                     gc_stats[:total_moved_objects],
      ruby_gc_remembered_wb_unprotected_objects:       gc_stats[:remembered_wb_unprotected_objects],
      ruby_gc_remembered_wb_unprotected_objects_limit: gc_stats[:remembered_wb_unprotected_objects_limit],
      ruby_gc_old_objects:                             gc_stats[:old_objects],
      ruby_gc_old_objects_limit:                       gc_stats[:old_objects_limit],
      ruby_gc_oldmalloc_increase_bytes:                gc_stats[:oldmalloc_increase_bytes],
      ruby_gc_oldmalloc_increase_bytes_limit:          gc_stats[:oldmalloc_increase_bytes_limit],
    })

    metrics[:ruby_gc_total][type: :major].set(gc_stats[:major_gc_count])
    metrics[:ruby_gc_total][type: :minor].set(gc_stats[:minor_gc_count])

    metrics[:ruby_gc_heap_pages][type: :eden].set(gc_stats[:heap_eden_pages])
    metrics[:ruby_gc_heap_pages][type: :tomb].set(gc_stats[:heap_tomb_pages])
    metrics[:ruby_gc_heap_pages][type: :allocatable].set(gc_stats[:heap_allocatable_pages])

    gc_object_pool_stats = GC.stat_heap
    gc_object_pool_stats.each do |pool_id, pool_stats|
      metrics.set({
        ruby_gc_pool_heap_pages_allocated_total: pool_stats[:total_allocated_pages],
        ruby_gc_pool_heap_pages_freed_total:     pool_stats[:total_freed_pages],
        ruby_gc_pool_force_major_gc_count:       pool_stats[:force_major_gc_count],
      }, { slot_size: pool_stats[:slot_size] })

      metrics[:ruby_gc_pool_heap_pages][slot_size: pool_stats[:slot_size], type: :eden].set(pool_stats[:heap_eden_pages])
      metrics[:ruby_gc_pool_heap_pages][slot_size: pool_stats[:slot_size], type: :tomb].set(pool_stats[:heap_tomb_pages])
      metrics[:ruby_gc_pool_heap_pages][slot_size: pool_stats[:slot_size], type: :allocatable].set(pool_stats[:heap_allocatable_pages])

      metrics[:ruby_gc_pool_heap_slots][slot_size: pool_stats[:slot_size], type: :eden].set(pool_stats[:heap_eden_slots])
      metrics[:ruby_gc_pool_heap_slots][slot_size: pool_stats[:slot_size], type: :tomb].set(pool_stats[:heap_tomb_slots])
    end

    metrics.set({
      vips_memory_bytes: Vips.tracked_mem,
      vips_allocations:  Vips.tracked_allocs,
      vips_files:        Vips.tracked_files,
    })

    %i[io fast].each do |name|
      pool = Concurrent.executor(name)

      metrics.set({
        concurrent_ruby_thread_pool_completed_task_count: pool.completed_task_count,
        concurrent_ruby_thread_pool_scheduled_task_count: pool.scheduled_task_count,
        concurrent_ruby_thread_pool_active_task_count:    pool.active_count,
        concurrent_ruby_thread_pool_thread_count:         pool.length,
        concurrent_ruby_thread_pool_spawned_thread_count: pool.instance_eval { @workers_counter },
      }, { pool: name, max_threads: pool.max_length })
    end

    if Jemalloc.enabled?
      Jemalloc.update_stats!
      metrics.set({
        jemalloc_thread_count:    Jemalloc.thread_count,
        jemalloc_allocated_bytes: Jemalloc.allocated,
        jemalloc_active_bytes:    Jemalloc.active,
        jemalloc_metadata_bytes:  Jemalloc.metadata,
        jemalloc_resident_bytes:  Jemalloc.resident,
        jemalloc_mapped_bytes:    Jemalloc.mapped,
      })
    end

    metrics
  end

  def puma_running?
    puma_worker_id.present?
  end

  # Resets the process metrics (by flushing the memoize cache).
  def reset_metrics
    flush_cache
    process_metrics
    self
  end

  def capture_rails_metrics!
    @subscribers ||= []

    @subscribers << ActiveSupport::Notifications.monotonic_subscribe("process_action.action_controller") do |event|
      labels = {
        method:     event.payload[:method],
        controller: event.payload.dig(:params, :controller),
        action:     event.payload[:action],
        format:     event.payload[:response]&.media_type || "none",
        status:     event.payload[:status],
      }

      ApplicationMetrics[:rails_http_requests_total][labels].increment
      ApplicationMetrics[:rails_http_request_duration_seconds][**labels, duration: :cpu].increment(event.cpu_time / 1000.0)
      ApplicationMetrics[:rails_http_request_duration_seconds][**labels, duration: :idle].increment(event.idle_time / 1000.0)
      ApplicationMetrics[:rails_http_request_duration_seconds][**labels, duration: :view].increment(event.payload[:view_runtime].to_f / 1000.0)
      ApplicationMetrics[:rails_http_request_duration_seconds][**labels, duration: :db].increment(event.payload[:db_runtime].to_f / 1000.0)
    end

    @subscribers << ActiveSupport::Notifications.monotonic_subscribe("sql.active_record") do |event|
      next if event.payload[:cached]

      sql = event.payload[:sql]
      statement_type = sql[0..sql.index(" ")&.pred] # extract first word up to the first space, e.g. "SELECT ..." -> "SELECT"
      labels = {
        statement: statement_type || "UNKNOWN",
        type: event.payload[:name] || "RAW",
      }

      ApplicationMetrics[:rails_sql_queries_total][labels].increment
      ApplicationMetrics[:rails_sql_query_duration_seconds][**labels, duration: :cpu].increment(event.cpu_time / 1000.0)
      ApplicationMetrics[:rails_sql_query_duration_seconds][**labels, duration: :db].increment(event.idle_time / 1000.0)
    end

    @subscribers << ActiveSupport::Notifications.monotonic_subscribe(/\Arender_(template|layout|partial|collection)\.action_view/) do |event|
      labels = { template: event.payload[:identifier] }

      ApplicationMetrics[:rails_view_renders_total][labels].increment
      ApplicationMetrics[:rails_view_render_duration_seconds][**labels, duration: :cpu].increment(event.cpu_time / 1000.0)
      ApplicationMetrics[:rails_view_render_duration_seconds][**labels, duration: :idle].increment(event.idle_time / 1000.0)
    end

    @subscribers << ActiveSupport::Notifications.monotonic_subscribe("instantiation.active_record") do |event|
      labels = { class: event.payload[:class_name] }

      ApplicationMetrics[:rails_active_record_instantiations_total][labels].increment(event.payload[:record_count])
    end

    @subscribers << ActiveSupport::Notifications.monotonic_subscribe(/\Acache_(read|write)\.active_support/) do |event|
      key = event.payload[:key]
      key = key.last if key.is_a?(Array)
      category = key[0..key.index(":")&.pred] # extract first word up to the first ":", e.g. "pfc:1girl solo" -> "pfc"

      case event.name
      when "cache_read.active_support"
        labels = { category: category, operation: "read" }

        ApplicationMetrics[:rails_cache_reads_total][**labels, hit: "true"].increment if event.payload[:hit]
        ApplicationMetrics[:rails_cache_reads_total][**labels, hit: "false"].increment if !event.payload[:hit]
      when "cache_write.active_support"
        labels = { category: category, operation: "write" }
      end

      ApplicationMetrics[:rails_cache_operations_total][labels].increment
      ApplicationMetrics[:rails_cache_operation_duration_seconds][**labels, duration: :cpu].increment(event.cpu_time / 1000.0)
      ApplicationMetrics[:rails_cache_operation_duration_seconds][**labels, duration: :idle].increment(event.idle_time / 1000.0)
    end

    @subscribers << ActiveSupport::Notifications.monotonic_subscribe(/\Acache_(read_multi|write_multi)\.active_support/) do |event|
      next if event.payload[:key].empty?

      case event.name
      when "cache_read_multi.active_support"
        key = event.payload[:key].first
        hits = event.payload[:hits].size
        misses = event.payload[:key].size - hits
        category = key[0..key.index(":")&.pred]
        labels = { category: category, operation: "read_multi" }

        ApplicationMetrics[:rails_cache_read_multi_keys_total][**labels, hit: "true"].increment(hits)
        ApplicationMetrics[:rails_cache_read_multi_keys_total][**labels, hit: "false"].increment(misses)
      when "cache_write_multi.active_support"
        key = event.payload[:key].first[0]
        keys = event.payload[:key].size
        category = key[0..key.index(":")&.pred]
        labels = { category: category, operation: "write_multi" }

        ApplicationMetrics[:rails_cache_write_multi_keys_total][labels].increment(keys)
      end

      ApplicationMetrics[:rails_cache_operations_total][labels].increment
      ApplicationMetrics[:rails_cache_operation_duration_seconds][**labels, duration: :cpu].increment(event.cpu_time / 1000.0)
      ApplicationMetrics[:rails_cache_operation_duration_seconds][**labels, duration: :idle].increment(event.idle_time / 1000.0)
    end
  end

  # Collects metrics from each Puma worker process and combines them into a single set of metrics for /metrics/instance.
  #
  # @return [Danbooru::Metric::Set] The combined set of metrics from each Puma worker process.
  def instance_metrics
    metrics = Dir.glob("tmp/drb-process-metrics-*.sock").map do |filename|
      application_metrics = DRbObject.new_with_uri("drbunix:#{filename}")
      application_metrics.update_process_metrics
    rescue IOError, DRb::DRbConnError
      # XXX Ignore any errors we may receive when fetching metrics from a remote process that has shut down (usually by the Puma worker killer)
      Danbooru::Metric::Set.new
    end

    metrics.reduce(&:merge) || Danbooru::Metric::Set.new
  end

  # Makes metrics for the current process available to other Puma worker processes. Starts a background thread serving process
  # metrics on a Unix domain socket under tmp/. Called by each process on startup in config/puma.rb.
  def serve_process_metrics
    filename = "tmp/drb-process-metrics-#{puma_worker_id}.sock"
    FileUtils.rm_f(filename)
    DRb.start_service("drbunix:#{filename}", ApplicationMetrics.instance)
  end

  class << self
    # For each instance method, define a class method that delegates to the singleton instance.
    delegate *ApplicationMetrics.instance_methods(false), to: :instance
  end
end
