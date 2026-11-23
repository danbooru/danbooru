# frozen_string_literal: true

# A report on the /reports page, like the number of uploads or comments per day. Each report counts the records of a
# model the user can see, grouped by date or by an attribute like the creator.
#
# Public API:
#
#   Report.new(name, search_params, user) - Build a new report.
#   #name - The name of the model to report on (e.g. "posts").
#   #title - The title of the report (e.g. "Posts Report").
#   #params - The report's options (e.g. `{ period: "day" }`).
#   #mode - How to show the results, "chart" or "table".
#   #from - The start date of the report (default: one month ago).
#   #to - The end date of the report (default: now).
#   #period - The time period to group by (e.g. "day"), or nil to not group by time.
#   #group - The attribute to group by (e.g. "uploader" or "uploader.level"), or nil if not grouping.
#   #group_limit - The number of groups to show (e.g. the top 10 uploaders).
#   #available_groups - The attributes the report can be grouped by (e.g. `["uploader", "rating"]`).
#   #x_axis - The column to use as the chart's x-axis (e.g. "date").
#   #dataframe - Get the report's results, as a Danbooru::DataFrame.
#
# @see ReportsController
# @see Aggregatable
class Report
  extend Memoist

  # Each report has a model, the columns it can show, and the attributes it can be grouped by. Columns are aggregate
  # functions for `Aggregatable#aggregate_function`.
  DEFINITIONS = {
    posts: { model: Post, columns: { posts: :count, uploaders: [:count_distinct, :uploader_id] }, groups: %w[uploader uploader.level approver rating is_deleted] },
    post_approvals: { model: PostApproval, columns: { approvals: :count, approvers: [:count_distinct, :user_id] }, groups: %w[user] },
    post_appeals: { model: PostAppeal, columns: { appeals: :count, appealers: [:count_distinct, :creator_id] }, groups: %w[creator status] },
    post_flags: { model: PostFlag, columns: { flags: :count, flaggers: [:count_distinct, :creator_id] }, groups: %w[status] },
    post_replacements: { model: PostReplacement, columns: { replacements: :count, replacers: [:count_distinct, :creator_id] }, groups: %w[creator] },
    post_votes: { model: PostVote, columns: { votes: :count, posts: [:count_distinct, :post_id], voters: [:count_distinct, :user_id] }, groups: %w[] },
    media_assets: { model: MediaAsset, columns: { assets: :count, size: [:sum, :file_size], duration: [:sum, :duration] }, groups: %w[file_ext status] },
    pools: { model: Pool, columns: { pools: :count }, groups: %w[category is_deleted] },
    comments: { model: Comment, columns: { comments: :count, commenters: [:count_distinct, :creator_id] }, groups: %w[creator do_not_bump_post is_deleted is_sticky] },
    comment_votes: { model: CommentVote, columns: { votes: :count, comments: [:count_distinct, :comment_id], voters: [:count_distinct, :user_id] }, groups: %w[] },
    forum_posts: { model: ForumPost, columns: { forum_posts: :count, posters: [:count_distinct, :creator_id] }, groups: %w[creator is_deleted] },
    bulk_update_requests: { model: BulkUpdateRequest, columns: { requests: :count, requestors: [:count_distinct, :user_id] }, groups: %w[user approver status] },
    tag_aliases: { model: TagAlias, columns: { aliases: :count }, groups: %w[status approver] },
    tag_implications: { model: TagImplication, columns: { implications: :count }, groups: %w[status approver] },
    artist_versions: { model: ArtistVersion, title: "Artist Edits Report", columns: { artist_edits: :count, artists: [:count_distinct, :artist_id], editors: [:count_distinct, :updater_id] }, groups: %w[updater] },
    artist_commentary_versions: { model: ArtistCommentaryVersion, title: "Artist Commentary Edits Report", columns: { commentary_edits: :count, editors: [:count_distinct, :updater_id] }, groups: %w[updater] },
    note_versions: { model: NoteVersion, title: "Note Edits Report", columns: { note_edits: :count, posts: [:count_distinct, :post_id], editors: [:count_distinct, :updater_id] }, groups: %w[updater] },
    wiki_page_versions: { model: WikiPageVersion, title: "Wiki Edits Report", columns: { wiki_edits: :count, editors: [:count_distinct, :updater_id] }, groups: %w[updater] },
    mod_actions: { model: ModAction, columns: { mod_actions: :count, creators: [:count_distinct, :creator_id] }, groups: %w[creator category subject_type] },
    bans: { model: Ban, columns: { bans: :count, banners: [:count_distinct, :banner_id] }, groups: %w[banner duration] },
    users: { model: User, title: "New Users Report", columns: { users: :count }, groups: %w[level] },
  }.with_indifferent_access.freeze

  # Groups that are users, which are shown by name.
  USER_GROUPS = %w[creator updater uploader banner approver user]

  attr_reader :name, :title, :model, :available_columns, :available_groups, :search_params, :params, :user

  # @param name [String] The name of the report, e.g. "posts". Must be a key in DEFINITIONS.
  # @param search_params [Hash] The `search` params, used to filter the records and to choose the report's options.
  # @param user [User] The user viewing the report. Only records and attributes this user can see are counted.
  # @raise [ActiveRecord::RecordNotFound] If the report doesn't exist.
  def initialize(name, search_params, user)
    definition = DEFINITIONS.fetch(name) { raise ActiveRecord::RecordNotFound }

    @name = name
    @model = definition[:model]
    @title = definition[:title] || "#{name.titleize} Report"
    @available_columns = definition[:columns]
    @available_groups = definition[:groups]
    @search_params = search_params.to_h
    # Ignore options that aren't strings, like `search[period][]=day`.
    @params = @search_params.select { |_key, value| value.is_a?(String) }.with_indifferent_access
    @user = user
  end

  # @return [String] "chart" or "table".
  def mode
    params[:mode] || "chart"
  end

  # @return [String, nil] The time period to group by ("day", "week", etc), or nil to not group by time.
  def period
    params[:period]&.downcase
  end

  # @return [Date, ActiveSupport::TimeWithZone] The start date of the report, or one month ago by default.
  # @raise [Date::Error] If the date is invalid.
  memoize def from
    params[:from].presence&.parse_date! || 1.month.ago
  end

  # @return [Date, ActiveSupport::TimeWithZone] The end date of the report, or now by default.
  # @raise [Date::Error] If the date is invalid.
  memoize def to
    params[:to].presence&.parse_date! || Time.zone.now
  end

  # @return [Integer] The number of groups to show, e.g. the top 10 uploaders.
  def group_limit
    params[:group_limit]&.to_i || 10
  end

  # @return [String, nil] The attribute to group by (e.g. "uploader" or "uploader.level"), or nil if not grouping.
  def group
    group = params[:group]&.downcase&.tr(" ", "_")
    group if group.in?(available_groups)
  end

  # @return [String, nil] The column to use as the x-axis of the chart, or nil if not grouping by time or an attribute.
  def x_axis
    period.present? ? "date" : group_column
  end

  # @return [Danbooru::DataFrame] The report's results.
  memoize def dataframe
    groups = [group].compact

    if period.present?
      dataframe = relation.timeseries(period: period, from: from, to: to, groups: groups, group_limit: group_limit, columns: columns)
    else
      dataframe = relation.aggregate(from: from, to: to, groups: groups, limit: group_limit, columns: columns)
    end

    dataframe[group] = dataframe[group].map(&:pretty_name) if group.in?(USER_GROUPS) && dataframe.names.include?(group)
    dataframe["level"] = dataframe["level"].map { |level| User.level_string(level) } if dataframe["level"] # XXX hack
    dataframe["date"] = dataframe["date"].map(&:to_date) if dataframe["date"]
    dataframe = dataframe.crosstab("date", group_column) if group_column && period.present?
    dataframe
  end

  private

  # @return [String, nil] The name of the group's column in the results, e.g. "level" for "uploader.level".
  def group_column
    group.to_s.split(".").second || group
  end

  # @return [Hash{String => Symbol, Array}] The selected columns, or the first column if none are selected.
  def columns
    selected = available_columns.slice(*params[:columns].to_s.split(/[[:space:],]/))
    selected.presence || available_columns.first(1).to_h
  end

  # @return [ActiveRecord::Relation] The records the user can see. When grouping by or aggregating an attribute,
  #   records whose attribute the user can't see are excluded, so that e.g. grouping comments by creator doesn't
  #   reveal who wrote deleted comments.
  def relation
    attributes = [group&.split(".")&.first, *columns.values.grep(Array).map(&:second)].compact.map(&:to_sym).uniq
    initial = model.visible(user).search(search_params, user)
    attributes.reduce(initial) { |relation, attribute| relation.visible_for_search(attribute, user) }
  end
end
