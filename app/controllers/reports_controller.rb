class ReportsController < ApplicationController
  before_action :member_only, :except => [:upload_tags]
  before_action :moderator_only, :only => [:down_voting_post_report, :down_voting_post_report_create]
  respond_to :html, :xml, :json, only: [:upload_tags]

  def uploads
    @report = Reports::Uploads.new(params[:min_date], params[:max_date], params[:queries])
  end

  def upload_tags
    @user = User.find(params[:user_id])
    @upload_reports = Reports::UploadTags.includes(versions: { post: :versions }).for_user(params[:user_id]).order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@upload_reports)
  end

  def down_voting_post
  end

  def down_voting_post_create
    user_id = CurrentUser.id
    post_id = params[:post_id].to_i
    sqs = SqsService.new(Danbooru.config.aws_sqs_async_reports)
    sqs.send_message("targetedpostdownvoting-#{user_id}-#{post_id}")
    flash[:notice] = "You will be messaged when the report has finished generating"
    redirect_to reports_down_voting_post_path
  end
end
