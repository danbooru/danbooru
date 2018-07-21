module PostSets
  class Recommended < PostSets::Post
    attr_reader :posts
    
    def initialize(posts)
      super("")
      @posts = posts
    end

    def presenter
      ::PostSetPresenters::Post.new(self)
    end
  end
end
