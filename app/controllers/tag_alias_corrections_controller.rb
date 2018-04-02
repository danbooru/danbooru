class TagAliasCorrectionsController < ApplicationController
  before_action :builder_only

  def create
    @correction = TagAliasCorrection.new(params[:tag_alias_id])

    if params[:commit] == "Fix"
      @correction.fix!
      flash[:notice] = "The fix has been queued and will be processed"
    end

    redirect_to tag_alias_correction_path(:tag_alias_id => params[:tag_alias_id])
  end

  def show
    @correction = TagAliasCorrection.new(params[:tag_alias_id])
  end
end
