module PostSets
  class PoolGallery < PostSets::Base
    attr_reader :page, :per_page, :pools

    def initialize(pools, page = 1, per_page = nil)
      @pools = pools
      @page = page
      @per_page = (per_page || CurrentUser.per_page).to_i
      @per_page = 200 if @per_page > 200
    end

    def current_page
      [page.to_i, 1].max
    end

    def presenter
      @presenter ||= ::PostSetPresenters::PoolGallery.new(self)
    end
  end
end
