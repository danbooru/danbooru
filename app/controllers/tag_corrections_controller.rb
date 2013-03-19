class TagCorrectionsController < ApplicationController
  before_filter :member_only

  def new
    @correction = TagCorrection.new(params[:tag_id])
  end

  def create
    if params[:commit] == "Fix"
      @correction = TagCorrection.new(params[:tag_id])
      @correction.fix!
    end

    redirect_to tags_path(:search => {:name_matches => @correction.tag.name}), :notice => "Tag will be fixed in a few seconds"
  end
end
