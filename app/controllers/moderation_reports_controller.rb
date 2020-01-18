class ModerationReportsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :builder_only, only: [:new, :create]
  before_action :moderator_only, only: [:index]

  def new
    check_privilege
    @moderation_report = ModerationReport.new(moderation_report_params)
    respond_with(@moderation_report)
  end

  def index
    @moderation_reports = ModerationReport.paginated_search(params).includes(:creator, :model)
    respond_with(@moderation_reports)
  end

  def create
    check_privilege
    @moderation_report = ModerationReport.create(moderation_report_params)
    @moderation_report.create_forum_post!
    respond_with(@moderation_report)
  end

  private

  def model_type
    params.fetch(:moderation_report, {}).fetch(:model_type)
  end

  def model_id
    params.fetch(:moderation_report, {}).fetch(:model_id)
  end

  def check_privilege
    case model_type
    when "User"
      return if User.find(model_id).reportable_by?(CurrentUser.user)
    when "Comment"
      return if Comment.find(model_id).reportable_by?(CurrentUser.user)
    when "ForumPost"
      return if ForumPost.find(model_id).reportable_by?(CurrentUser.user)
    end
    raise User::PrivilegeError
  end

  def moderation_report_params
    params.fetch(:moderation_report, {}).permit(%i[model_type model_id reason])
  end
end
