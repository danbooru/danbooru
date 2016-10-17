class DelayedJobsController < ApplicationController
  respond_to :html, :xml, :json
  def index
    @delayed_jobs = Delayed::Job.order("created_at desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@delayed_jobs)
  end
end
