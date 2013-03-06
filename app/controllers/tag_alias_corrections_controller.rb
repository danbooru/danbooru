class TagAliasCorrectionsController < ApplicationController
  before_filter :moderator_only
  
  def new
    @correction = TagAliasCorrection.new(params[:tag_alias_id])
  end
  
  def create
    @correction = TagAliasCorrection.new(params[:tag_alias_id])

    if params[:commit] == "Fix"
      @correction.fix!
    end
    
    redirect_to tag_alias_correction_path(:id => params[:tag_alias_id])
  end
  
  def show
    @correction = TagAliasCorrection.new(params[:tag_alias_id])
  end
end
