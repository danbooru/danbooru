module Sources
  class Site
    attr_reader :url, :strategy
    delegate :artist_name, :profile_url, :image_url, :tags, :to => :strategy
    
    def initialize(url)
      @url = url
      
      case url
      when /pixiv\.net/
        @strategy = Strategies::Pixiv.new(url)
        
      else
        @strategy = Strategies::Default.new(url)
      end
    end
  end
end
