class TagCorrectionsController < ApplicationController
  before_filter :member_only
  
  def new
    @tag = Tag.find(params[:tag_id])
  end
  
  def create
    if params[:commit] == "Fix"
      @tag = Tag.find(params[:tag_id])
      @tag.delay.fix_post_count
    end
    
    redirect_to tags_path(:search => {:name_matches => @tag.name})
  end
end
