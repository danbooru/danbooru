class SavedSearchesController < ApplicationController
  before_action :check_availability
  respond_to :html, :xml, :json, :js
  
  def index
    @saved_searches = saved_searches.order("id")

    if params[:label]
      @saved_searches = saved_searches.labeled(params[:label])
    end

    respond_with(@saved_searches) do |format|
      format.xml do
        render :xml => @saved_searches.to_xml(:root => "saved-searches")
      end
    end
  end

  def labels
    @labels = SavedSearch.search_labels(CurrentUser.id, params[:search])
    respond_with(@labels)
  end

  def create
    @saved_search = saved_searches.create(saved_search_params)
    respond_with(@saved_search)
  end

  def destroy
    @saved_search = saved_searches.find(params[:id])
    @saved_search.destroy
    respond_with(@saved_search)
  end

  def edit
    @saved_search = saved_searches.find(params[:id])
  end

  def update
    @saved_search = saved_searches.find(params[:id])
    @saved_search.update(saved_search_params)
    respond_with(@saved_search, :location => saved_searches_path)
  end

  private

  def saved_searches
    CurrentUser.user.saved_searches
  end

  def check_availability
    if !SavedSearch.enabled?
      raise NotImplementedError.new("Listbooru service is not configured. Saved searches are not available.")
    end
  end

  def saved_search_params
    params.require(:saved_search).permit(%i[query label_string disable_labels])
  end
end
