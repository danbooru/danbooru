class TagCorrectionsController < ApplicationController
  respond_to :html, :json, :xml
  before_action :builder_only, only: [:new, :create]

  def new
    @correction = TagCorrection.new(params[:tag_id])
    respond_with(@correction)
  end
  
  def show
    @correction = TagCorrection.new(params[:tag_id])
    respond_with(@correction)
  end

  def create
    @correction = TagCorrection.new(params[:tag_id])

    if params[:commit] == "Fix"
      @correction.fix!
      redirect_to tags_path(:search => {:name_matches => @correction.tag.name, :hide_empty => "no"}), :notice => "Tag will be fixed in a few seconds"
    else
      redirect_to tags_path(:search => {:name_matches => @correction.tag.name})
    end
  end
end
