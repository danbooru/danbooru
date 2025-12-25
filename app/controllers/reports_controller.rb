# frozen_string_literal: true

class ReportsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    authorize nil, policy_class: ReportPolicy
  end

  def show
    @report = params[:id]
    @mode = params.dig(:search, :mode) || "chart"
    @period = params.dig(:search, :period)&.downcase
    @from = params.dig(:search, :from) || 1.month.ago
    @to = params.dig(:search, :to) || Time.zone.now
    @columns = params.dig(:search, :columns).to_s.split(/[[:space:],]/).map(&:to_sym)
    @group = params.dig(:search, :group)&.downcase&.tr(" ", "_")
    @group_limit = params.dig(:search, :group_limit)&.to_i || 10
    authorize nil, policy_class: ReportPolicy

    case @report
    when "posts"
      @model = Post
      @title = "Posts Report"
      @available_columns = { posts: "COUNT(*)", uploaders: "COUNT(distinct uploader_id)" }
      @available_groups = %w[uploader uploader.level approver rating is_deleted]
    when "post_approvals"
      @model = PostApproval
      @title = "Post Approvals Report"
      @available_columns = { approvals: "COUNT(*)", approvers: "COUNT(distinct user_id)" }
      @available_groups = %w[user]
    when "post_appeals"
      @model = PostAppeal
      @title = "Post Appeals Report"
      @available_columns = { appeals: "COUNT(*)", appealers: "COUNT(distinct creator_id)" }
      @available_groups = %w[creator status]
    when "post_flags"
      @model = PostFlag
      @title = "Post Flags Report"
      @available_columns = { flags: "COUNT(*)", flaggers: "COUNT(distinct creator_id)" }
      @available_groups = %w[status]
    when "post_replacements"
      @model = PostReplacement
      @title = "Post Replacements Report"
      @available_columns = { replacements: "COUNT(*)", replacers: "COUNT(distinct creator_id)" }
      @available_groups = %w[creator]
    when "post_votes"
      @model = PostVote
      @title = "Post Votes Report"
      @available_columns = { votes: "COUNT(*)", posts: "COUNT(distinct post_id)", voters: "COUNT(distinct user_id)" }
      @available_groups = %w[]
    when "media_assets"
      @model = MediaAsset
      @title = "Media Assets Report"
      @available_columns = { assets: "COUNT(*)", size: "SUM(file_size)", duration: "SUM(duration)" }
      @available_groups = %w[file_ext status]
    when "pools"
      @model = Pool
      @title = "Pools Report"
      @available_columns = { pools: "COUNT(*)" }
      @available_groups = %w[category is_deleted]
    when "comments"
      @model = Comment
      @title = "Comments Report"
      @available_columns = { comments: "COUNT(*)", commenters: "COUNT(distinct creator_id)" }
      @available_groups = %w[creator do_not_bump_post is_deleted is_sticky]
    when "comment_votes"
      @model = CommentVote
      @title = "Comment Votes Report"
      @available_columns = { votes: "COUNT(*)", comments: "COUNT(distinct comment_id)", voters: "COUNT(distinct user_id)" }
      @available_groups = %w[]
    when "forum_posts"
      @model = ForumPost
      @title = "Forum Posts Report"
      @available_columns = { forum_posts: "COUNT(*)", posters: "COUNT(distinct creator_id)" }
      @available_groups = %w[creator is_deleted]
    when "bulk_update_requests"
      @model = BulkUpdateRequest
      @title = "Bulk Update Requests Report"
      @available_columns = { requests: "COUNT(*)", requestors: "COUNT(distinct user_id)" }
      @available_groups = %w[user approver status]
    when "tag_aliases"
      @model = TagAlias
      @title = "Tag Aliases Report"
      @available_columns = { aliases: "COUNT(*)" }
      @available_groups = %w[status approver]
    when "tag_implications"
      @model = TagImplication
      @title = "Tag Implications Report"
      @available_columns = { implications: "COUNT(*)" }
      @available_groups = %w[status approver]
    when "artist_versions"
      @model = ArtistVersion
      @title = "Artist Edits Report"
      @available_columns = { artist_edits: "COUNT(*)", artists: "COUNT(distinct artist_id)", editors: "COUNT(distinct updater_id)" }
      @available_groups = %w[updater]
    when "artist_commentary_versions"
      @model = ArtistCommentaryVersion
      @title = "Artist Commentary Edits Report"
      @available_columns = { commentary_edits: "COUNT(*)", editors: "COUNT(distinct updater_id)" }
      @available_groups = %w[updater]
    when "note_versions"
      @model = NoteVersion
      @title = "Note Edits Report"
      @available_columns = { note_edits: "COUNT(*)", posts: "COUNT(distinct post_id)", editors: "COUNT(distinct updater_id)" }
      @available_groups = %w[updater]
    when "wiki_page_versions"
      @model = WikiPageVersion
      @title = "Wiki Edits Report"
      @available_columns = { wiki_edits: "COUNT(*)", editors: "COUNT(distinct updater_id)" }
      @available_groups = %w[updater]
    when "mod_actions"
      @model = ModAction
      @title = "Mod Actions Report"
      @available_columns = { mod_actions: "COUNT(*)", creators: "COUNT(distinct creator_id)" }
      @available_groups = %w[creator category subject_type]
    when "bans"
      @model = Ban
      @title = "Bans Report"
      @available_columns = { bans: "COUNT(*)", banners: "COUNT(DISTINCT banner_id)" }
      @available_groups = %w[banner duration]
    when "users"
      @model = User
      @title = "New Users Report"
      @available_columns = { users: "COUNT(*)" }
      @available_groups = %w[level]
    else
      raise ActiveRecord::RecordNotFound
    end

    if CurrentUser.user.is_member? && CurrentUser.user.statement_timeout < 10_000
      @statement_timeout = 10_000
    else
      @statement_timeout = CurrentUser.user.statement_timeout
    end

    ApplicationRecord.set_timeout(@statement_timeout) do
      @group = nil unless @group&.in?(@available_groups)
      @group_column = @group.to_s.split(".").second || @group
      @columns = @available_columns.slice(*@columns)
      @columns = [@available_columns.first].to_h if @columns.blank?

      if @period.present?
        @dataframe = @model.search(params[:search], CurrentUser.user).timeseries(period: @period, from: @from, to: @to, groups: [@group].compact_blank, group_limit: @group_limit, columns: @columns)
        @x_axis = "date"
      else
        @dataframe = @model.search(params[:search], CurrentUser.user).aggregate(from: @from, to: @to, groups: [@group].compact_blank, limit: @group_limit, columns: @columns)
        @x_axis = @group_column
      end

      @dataframe[@group] = @dataframe[@group].map(&:pretty_name) if @group.in?(%w[creator updater uploader banner approver user]) && @dataframe.names.include?(@group)
      @dataframe["level"] = @dataframe["level"].map { |level| User.level_string(level) } if @dataframe["level"] # XXX hack
      @dataframe["date"] = @dataframe["date"].map(&:to_date) if @dataframe["date"]
      @dataframe = @dataframe.crosstab("date", @group_column) if @group_column && @period.present?
    end

    respond_with(@dataframe)
  end
end
