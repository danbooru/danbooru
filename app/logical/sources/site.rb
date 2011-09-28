module Sources
  class Site
    attr_reader :url, :strategy
    delegate :get, :site_name, :artist_name, :artist_alias, :profile_url, :image_url, :tags, :artist_record, :unique_id, :to => :strategy
    
    def self.strategies
      [Strategies::Fc2, Strategies::NicoSeiga, Strategies::Pixa, Strategies::Pixiv, Strategies::Tinami, Strategies::Default]
    end
    
    def initialize(url)
      @url = url
      
      Site.strategies.each do |strategy|
        if strategy.url_match?(url)
          @strategy = strategy.new(url)
          break
        end
      end
    end
    
    def to_json
      return {
        :artist_name => artist_name,
        :profile_url => profile_url,
        :image_url => image_url,
        :tags => tags,
        :danbooru_name => artist_record.first.try(:name),
        :danbooru_id => artist_record.first.try(:id),
        :unique_id => unique_id
      }.to_json
    end
    
    def available?
      strategy.present?
    end
  end
end
