class DelayedJobsController < ApplicationController
  def index
    @delayed_jobs = Delayed::Job.order("created_at desc").paginate(params[:page])
  end
end
