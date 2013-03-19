class TagAliasRequestsController < ApplicationController
  before_filter :member_only
  rescue_from TagAliasRequest::ValidationError, :with => :rescue_exception

  def new
  end

  def create
    @tag_alias_request = TagAliasRequest.new(
      params[:tag_alias_request][:antecedent_name],
      params[:tag_alias_request][:consequent_name],
      params[:tag_alias_request][:reason]
    )
    @tag_alias_request.create
    redirect_to(forum_topic_path(@tag_alias_request.forum_topic))
  end
end
