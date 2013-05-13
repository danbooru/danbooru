module PostSets
  class SearchError < Exception
  end

  class WikiPage < PostSets::Post
    def presenter
      @presenter ||= ::PostSetPresenters::WikiPage.new(self)
    end
  end
end
