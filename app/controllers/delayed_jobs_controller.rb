# frozen_string_literal: true

class DelayedJobsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @delayed_jobs = authorize Delayed::Job.order("run_at asc").extending(PaginationExtension).paginate(params[:page], :limit => params[:limit]), policy_class: DelayedJobPolicy
    respond_with(@delayed_jobs)
  end

  def cancel
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    @job.fail! unless @job.locked_at?
    respond_with(@job)
  end

  def retry
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    @job.update(failed_at: nil, attempts: 0) unless @job.locked_at?
    respond_with(@job)
  end

  def run
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    @job.update(run_at: Time.zone.now) unless @job.locked_at?
    respond_with(@job)
  end

  def destroy
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    @job.destroy unless @job.locked_at?
    respond_with(@job)
  end
end
