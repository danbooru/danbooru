module PostSets
  class SearchError < StandardError
  end

  class WikiPage < PostSets::Post
    def presenter
      @presenter ||= ::PostSetPresenters::WikiPage.new(self)
    end
  end
end
