module PostSets
  class Similar < PostSets::Post
    def initialize(post)
      super("")
      @post = post
    end

    def posts
      @posts ||= begin
        response = RecommenderService.similar(@post)
        post_ids = response.reject {|x| x[0] == @post.id}.slice(0, 6).map {|x| x[0]}
        ::Post.find(post_ids)
      end
    end

    def presenter
      ::PostSetPresenters::Post.new(self)
    end
  end
end
