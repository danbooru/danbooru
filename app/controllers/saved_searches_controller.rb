class SavedSearchesController < ApplicationController
  respond_to :html, :js
  
  def index
    @saved_searches = saved_searches.order("name")
  end

  def create
    @saved_search = saved_searches.create(:tag_query => params[:tags])
  end

  def destroy
    @saved_search = saved_searches.find(params[:id])
    @saved_search.destroy
  end

  def edit
    @saved_search = saved_searches.find(params[:id])
  end

  def update
    @saved_search = saved_searches.find(params[:id])
    @saved_search.update_attributes(params[:saved_search])
    flash[:notice] = "Saved search updated"
    respond_with(@saved_search, :location => saved_searches_path)
  end

private

  def saved_searches
    CurrentUser.user.saved_searches
  end
end
