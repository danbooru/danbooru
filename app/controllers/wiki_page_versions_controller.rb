class WikiPageVersionsController < ApplicationController
  respond_to :json, :html, :xml
  
  def index
    @wiki_page_versions = WikiPageVersion.search(params[:search]).order("id desc").paginate(params[:page], :search_count => params[:search])
    respond_with(@wiki_page_versions)
  end
  
  def show
    @wiki_page_version = WikiPageVersion.find(params[:id])
    respond_with(@wiki_page_version)
  end
  
  def diff
    @thispage = WikiPageVersion.find(params[:thispage])
    @otherpage = WikiPageVersion.find(params[:otherpage])
  end
end
