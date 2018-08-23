module PostSets
  class Artist < PostSets::Post
    attr_reader :artist

    def initialize(artist)
      super(artist.name)
      @artist = artist
    end

    def posts
      @posts ||= begin
        query = ::Post.tag_match(@artist.name).where("true /* PostSets::Artist#posts */").limit(10)
        query.each # hack to force rails to eager load
        query
      end
    rescue ::Post::SearchError
      ::Post.none
    end

    def presenter
      ::PostSetPresenters::Post.new(self)
    end
  end
end
