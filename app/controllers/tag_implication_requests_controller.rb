class TagImplicationRequestsController < ApplicationController
  before_filter :member_only
  rescue_from TagImplicationRequest::ValidationError, :with => :rescue_exception

  def new
  end

  def create
    @tag_implication_request = TagImplicationRequest.new(
      params[:tag_implication_request][:antecedent_name],
      params[:tag_implication_request][:consequent_name],
      params[:tag_implication_request][:reason]
    )
    @tag_implication_request.create
    redirect_to(forum_topic_path(@tag_implication_request.forum_topic))
  end
end
