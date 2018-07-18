module PostSets
  class Similar < PostSets::Post
    def initialize(post)
      super(tags)
    end

    def posts
      @posts ||= begin
        post_ids, scores = RecommenderService.similar(post)
        post_ids = post_ids.reject {|x| x == post.id}.slice(0, 5)
        Post.find(post_ids)
      end
    end

    def presenter
      ::Presenters::PostSetPresenters::Post.new(self)
    end
  end
end
