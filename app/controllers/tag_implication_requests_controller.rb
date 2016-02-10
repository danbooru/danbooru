class TagImplicationRequestsController < ApplicationController
  before_filter :member_only

  def new
  end

  def create
    @tag_implication_request = TagImplicationRequest.new(params[:tag_implication_request])
    @tag_implication_request.create

    if @tag_implication_request.invalid?
      render :action => "new"
    else
      redirect_to forum_topic_path(@tag_implication_request.forum_topic)
    end
  end
end
