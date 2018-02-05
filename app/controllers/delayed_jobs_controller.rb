class DelayedJobsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :admin_only, except: [:index]

  def index
    @delayed_jobs = Delayed::Job.order("run_at asc").paginate(params[:page], :limit => params[:limit])
    respond_with(@delayed_jobs)
  end

  def cancel
    @job = Delayed::Job.find(params[:id])
    if !@job.locked_at?
      @job.fail!
    end
    respond_with(@job)
  end

  def retry
    @job = Delayed::Job.find(params[:id])
    if !@job.locked_at?
      @job.update(failed_at: nil, attempts: 0)
    end
    respond_with(@job)
  end

  def run
    @job = Delayed::Job.find(params[:id])
    if !@job.locked_at?
      @job.update(run_at: Time.now)
    end
    respond_with(@job)
  end

  def destroy
    @job = Delayed::Job.find(params[:id])
    if !@job.locked_at?
      @job.destroy
    end
    respond_with(@job)
  end
end
