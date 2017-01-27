class UploadTagsReportController < ApplicationController
  respond_to :html, :xml, :json

  def show
    @user = User.find(params[:id])
    @upload_reports = UploadTagsReport.for_user(params[:id]).order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@upload_reports)
  end
end
