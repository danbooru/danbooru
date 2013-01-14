module PostSetPresenters
  class WikiPage < Post
    def posts
      @post_set.posts
    end
  end
end
