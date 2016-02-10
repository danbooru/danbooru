class TagAliasRequestsController < ApplicationController
  before_filter :member_only

  def new
  end

  def create
    @tag_alias_request = TagAliasRequest.new(params[:tag_alias_request])
    @tag_alias_request.create

    if @tag_alias_request.invalid?
      render :action => "new"
    else
      redirect_to forum_topic_path(@tag_alias_request.forum_topic)
    end
  end
end
