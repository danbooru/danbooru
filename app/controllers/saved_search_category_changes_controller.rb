class SavedSearchCategoryChangesController < ApplicationController
  before_filter :member_only
  before_filter :check_availabililty
  respond_to :html

  def new
    @category = params[:old]
  end

  def create
    SavedSearch.rename(CurrentUser.user.id, params[:old], params[:new])
    flash[:notice] = "Saved searches will be renamed"
    redirect_to saved_searches_path
  end

private
  
  def check_availabililty
    if !SavedSearch.enabled?
      respond_to do |format|
        format.html do
          flash[:notice] = "Listbooru service is not configured. Saved searches are not available."
          redirect_to :back
        end
        format.json do
          render json: {success: false, reason: "Listbooru service is not configured"}.to_json, status: 501
        end
      end

      return false
    end
  end
end
