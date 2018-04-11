class WikiPageVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @wiki_page_versions = WikiPageVersion.search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@wiki_page_versions) do |format|
      format.xml do
        render :xml => @wiki_page_versions.to_xml(:root => "wiki-page-versions")
      end
    end
  end

  def show
    @wiki_page_version = WikiPageVersion.find(params[:id])
    respond_with(@wiki_page_version)
  end

  def diff
    if params[:thispage].blank? || params[:otherpage].blank?
      redirect_to :back, :notice => "You must select two versions to diff"
      return
    end

    @thispage = WikiPageVersion.find(params[:thispage])
    @otherpage = WikiPageVersion.find(params[:otherpage])
  end
end
