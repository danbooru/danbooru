module PostSets
  class SearchError < Exception
  end

  class WikiPage < Post
    def presenter
      @presenter ||= ::PostSetPresenters::WikiPage.new(self)
    end
  end
end
