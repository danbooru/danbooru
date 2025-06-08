# frozen_string_literal: true

class ModerationReportsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @moderation_report = authorize ModerationReport.new(permitted_attributes(ModerationReport))
    respond_with(@moderation_report)
  end

  def index
    @moderation_reports = authorize ModerationReport.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @moderation_reports = @moderation_reports.includes(:creator, :model) if request.format.html?

    respond_with(@moderation_reports)
  end

  def show
    authorize ModerationReport
    redirect_to moderation_reports_path(search: { id: params[:id] })
  end

  def create
    @moderation_report = authorize ModerationReport.new(creator: CurrentUser.user, **permitted_attributes(ModerationReport))
    @moderation_report.save

    respond_with(@moderation_report, notice: "Report submitted")
  end

  def update
    @moderation_report = authorize ModerationReport.find(params[:id])
    @moderation_report.update(updater: CurrentUser.user, **permitted_attributes(@moderation_report))

    respond_with(@moderation_report, notice: "Report updated")
  end
end
