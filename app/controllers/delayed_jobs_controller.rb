class DelayedJobsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @delayed_jobs = authorize Delayed::Job.order("run_at asc").extending(PaginationExtension).paginate(params[:page], :limit => params[:limit]), policy_class: DelayedJobPolicy
    respond_with(@delayed_jobs)
  end

  def cancel
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    if !@job.locked_at?
      @job.fail!
    end
    respond_with(@job)
  end

  def retry
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    if !@job.locked_at?
      @job.update(failed_at: nil, attempts: 0)
    end
    respond_with(@job)
  end

  def run
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    if !@job.locked_at?
      @job.update(run_at: Time.now)
    end
    respond_with(@job)
  end

  def destroy
    @job = authorize Delayed::Job.find(params[:id]), policy_class: DelayedJobPolicy
    if !@job.locked_at?
      @job.destroy
    end
    respond_with(@job)
  end
end
