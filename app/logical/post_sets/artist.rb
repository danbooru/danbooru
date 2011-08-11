module PostSets
  class Artist < PostSets::Post
    attr_reader :artist
    
    def initialize(artist)
      super(artist.name)
      @artist = artist
    end
    
    def posts
      ::Post.tag_match(@artist.name)
    end

    def presenter
      ::PostSetPresenters::Post.new(self)
    end
  end
end
