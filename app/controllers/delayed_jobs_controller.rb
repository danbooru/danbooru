# frozen_string_literal: true

class DelayedJobsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @jobs = authorize GoodJob::ActiveJobJob.order(created_at: :desc).extending(PaginationExtension).paginate(params[:page], limit: params[:limit]), policy_class: GoodJobPolicy
    respond_with(@jobs)
  end

  def cancel
    @job = authorize GoodJob::ActiveJobJob.find(params[:id]), policy_class: GoodJobPolicy
    @job.discard_job("Canceled")
    respond_with(@job)
  end

  def retry
    @job = authorize GoodJob::ActiveJobJob.find(params[:id]), policy_class: GoodJobPolicy
    @job.retry_job
    respond_with(@job)
  end

  def run
    @job = authorize GoodJob::ActiveJobJob.find(params[:id]), policy_class: GoodJobPolicy
    @job.reschedule_job
    respond_with(@job)
  end

  def destroy
    @job = authorize GoodJob::ActiveJobJob.find(params[:id]), policy_class: GoodJobPolicy
    @job.destroy
    respond_with(@job)
  end
end
