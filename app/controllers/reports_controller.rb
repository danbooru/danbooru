class ReportsController < ApplicationController
  respond_to :html, :xml, :json

  def upload_tags
    @user = User.find(params[:user_id])
    @upload_reports = Reports::UploadTags.includes(versions: { post: :versions }).for_user(params[:user_id]).order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@upload_reports)
  end
end
