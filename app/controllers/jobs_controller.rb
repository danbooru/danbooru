# frozen_string_literal: true

class JobsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @jobs = authorize BackgroundJob.unscoped.paginated_search(params)
    respond_with(@jobs)
  end

  def cancel
    @job = authorize BackgroundJob.find_by!(active_job_id: params[:id])
    @job.discard_job("Canceled")
    respond_with(@job)
  end

  def retry
    @job = authorize BackgroundJob.find_by!(active_job_id: params[:id])
    @job.retry_job
    respond_with(@job)
  end

  def run
    @job = authorize BackgroundJob.find_by!(active_job_id: params[:id])
    @job.reschedule_job
    respond_with(@job)
  end

  def destroy
    @job = authorize BackgroundJob.find_by!(active_job_id: params[:id])
    @job.destroy
    respond_with(@job)
  end
end
