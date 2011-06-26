module PostSets
  class Artist < Post
    attr_reader :artist
    
    def initialize(artist)
      super(:tags => artist.name)
      @artist = artist
    end
  end
end
