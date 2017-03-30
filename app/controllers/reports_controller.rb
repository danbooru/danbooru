class ReportsController < ApplicationController
  before_filter :member_only
  before_filter :gold_only, :only => [:similar_users]
  before_filter :moderator_only, :only => [:post_versions, :post_versions_create]

  def uploads
    @report = Reports::Uploads.new(params[:min_date], params[:max_date], params[:queries])
  end

  def similar_users
    @report = Reports::UserSimilarity.new(CurrentUser.id)
    @presenter = UserSimilarityPresenter.new(@report)
  end

  def post_versions
  end

  def post_versions_create
    @report = Reports::PostVersions.new(params[:tag], params[:type])
  end

  def upload_tags
    @user = User.find(params[:user_id])
    @upload_reports = Reports::UploadTags.includes(versions: { post: :versions }).for_user(params[:user_id]).order("id desc").paginate(params[:page], :limit => params[:limit])
  end
end
