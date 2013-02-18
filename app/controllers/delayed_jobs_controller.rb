class DelayedJobsController < ApplicationController
  def index
    @delayed_jobs = Delayed::Job.where("handler not like ? and handler not like ?", "%method_name: :update_related%", "%method_name: :process!%").order("created_at desc").paginate(params[:page])
  end
end
