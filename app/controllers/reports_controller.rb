# frozen_string_literal: true

class ReportsController < ApplicationController
  respond_to :html, :json, :xml

  rate_limit :show, rate: 1.0/3.seconds, burst: 15

  def index
  end

  def show
    @report = params[:id]
    @mode = params.dig(:search, :mode) || "chart"

    case @report
    when "posts"
      @model = Post
      @title = "Posts Report"
      @columns = { posts: "COUNT(*)", uploaders: "COUNT(distinct uploader_id)" }
    when "post_votes"
      @model = PostVote
      @title = "Post Votes Report"
      @columns = { votes: "COUNT(*)", posts: "COUNT(distinct post_id)", voters: "COUNT(distinct user_id)" }
    when "pools"
      @model = Pool
      @title = "Pools Report"
      @columns = { series_pools: "COUNT(*) FILTER (WHERE category = 'series')", collection_pools: "COUNT(*) FILTER (WHERE category = 'collection')" }
    when "comments"
      @model = Comment
      @title = "Comments Report"
      @columns = { comments: "COUNT(*)", commenters: "COUNT(distinct creator_id)" }
    when "comment_votes"
      @model = CommentVote
      @title = "Comment Votes Report"
      @columns = { votes: "COUNT(*)", comments: "COUNT(distinct comment_id)", voters: "COUNT(distinct user_id)" }
    when "forum_posts"
      @model = ForumPost
      @title = "Forum Posts Report"
      @columns = { forum_posts: "COUNT(*)", posters: "COUNT(distinct creator_id)" }
    when "bulk_update_requests"
      @model = BulkUpdateRequest
      @title = "Bulk Update Requests Report"
      @columns = { requests: "COUNT(*)", requestors: "COUNT(distinct user_id)" }
    when "tag_aliases"
      @model = TagAlias
      @title = "Tag Aliases Report"
      @columns = { aliases: "COUNT(*)" }
    when "tag_implications"
      @model = TagImplication
      @title = "Tag Implications Report"
      @columns = { aliases: "COUNT(*)" }
    when "artist_versions"
      @model = ArtistVersion
      @title = "Artist Edits Report"
      @columns = { artist_edits: "COUNT(*)", artists: "COUNT(distinct artist_id)", editors: "COUNT(distinct updater_id)" }
    when "note_versions"
      @model = NoteVersion
      @title = "Note Edits Report"
      @columns = { note_edits: "COUNT(*)", posts: "COUNT(distinct post_id)", editors: "COUNT(distinct updater_id)" }
    when "wiki_page_versions"
      @model = WikiPageVersion
      @title = "Wiki Edits Report"
      @columns = { wiki_edits: "COUNT(*)", editors: "COUNT(distinct updater_id)" }
    when "users"
      @model = User
      @title = "New Users Report"
      @columns = { users: "COUNT(*)" }
    when "bans"
      @model = Ban
      @title = "Bans Report"
      @columns = { bans: "COUNT(*)", banners: "COUNT(DISTINCT banner_id)" }
    else
      raise ActiveRecord::RecordNotFound
    end

    @period = params.dig(:search, :period)&.downcase || "day"
    @from = params.dig(:search, :from) || 1.month.ago
    @to = params.dig(:search, :to) || Time.zone.now

    if CurrentUser.user.is_member? && CurrentUser.user.statement_timeout < 10_000
      @statement_timeout = 10_000
    else
      @statement_timeout = CurrentUser.user.statement_timeout
    end

    ApplicationRecord.set_timeout(@statement_timeout) do
      @results = @model.search(params[:search], CurrentUser.user).timeseries(period: @period, from: @from, to: @to, columns: @columns)
    end

    respond_with(@results)
  end
end
