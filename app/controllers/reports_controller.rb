class ReportsController < ApplicationController
  before_action :member_only, :except => [:upload_tags]
  respond_to :html, :xml, :json, only: [:upload_tags]

  def uploads
    @report = Reports::Uploads.new(params[:min_date], params[:max_date], params[:queries])
  end

  def upload_tags
    @user = User.find(params[:user_id])
    @upload_reports = Reports::UploadTags.includes(versions: { post: :versions }).for_user(params[:user_id]).order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@upload_reports)
  end
end
