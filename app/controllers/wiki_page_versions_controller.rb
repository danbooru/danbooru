class WikiPageVersionsController < ApplicationController
  respond_to :html, :xml, :json
  layout "sidebar"

  def index
    set_version_comparison
    @wiki_page_versions = WikiPageVersion.paginated_search(params)
    @wiki_page_versions = @wiki_page_versions.includes(:updater) if request.format.html?

    respond_with(@wiki_page_versions)
  end

  def show
    @wiki_page_version = WikiPageVersion.find(params[:id])
    respond_with(@wiki_page_version)
  end

  def diff
    if params[:thispage].blank? || params[:otherpage].blank?
      page_id = params[:thispage] || params[:otherpage]
      if page_id.blank?
        redirect_back fallback_location: wiki_pages_path, notice: "You must select at least one version to diff"
        return
      end
      set_version_comparison
      @thispage = WikiPageVersion.find(page_id)
      @otherpage = @thispage.send(params[:type])
    else
      @thispage = WikiPageVersion.find(params[:thispage])
      @otherpage = WikiPageVersion.find(params[:otherpage])
      if @thispage.id < @otherpage.id
        @thispage, @otherpage = @otherpage, @thispage
      end
    end

    respond_with([@thispage, @otherpage])
  end
end
