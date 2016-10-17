class SavedSearchesController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  
  def index
    @saved_searches = saved_searches.order("tag_query")
    @categories = @saved_searches.group_by{|saved_search| saved_search.category.to_s}
    @categories = @categories.sort_by{|category, saved_searches| category.to_s}

    respond_with(@saved_searches) do |format|
      format.xml do
        render :xml => @saved_searches.to_xml(:root => "saved-searches")
      end
    end
  end

  def categories
    @categories = saved_searches.select(:category).distinct
    respond_with(@categories)
  end

  def create
    @saved_search = saved_searches.create(:tag_query => params[:saved_search_tags], :category => params[:saved_search_category])

    if params[:saved_search_disable_categories]
      CurrentUser.disable_categorized_saved_searches = true
      CurrentUser.save
    end
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
    @saved_search.update_attributes(params[:saved_search])
    respond_with(@saved_search, :location => saved_searches_path)
  end

private

  def saved_searches
    CurrentUser.user.saved_searches
  end
end
