module PostSetPresenters
  class WikiPage < Post
    def posts
      Thread.current["records_per_page"] = 8
      @post_set.posts
    ensure
      Thread.current["records_per_page"] = nil
    end
  end
end
