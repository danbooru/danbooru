module Sources
  class Site
    attr_reader :url, :strategy
    delegate :get, :referer_url, :site_name, :artist_name, :profile_url, :image_url, :tags, :artist_record, :unique_id, :to => :strategy

    def self.strategies
      [Strategies::Pixiv, Strategies::NicoSeiga, Strategies::DeviantArt]
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

    def translated_tags
      WikiPage.other_names_match(tags.map(&:first)).map{|wiki_page| [wiki_page.title, wiki_page.category_name]}
    end

    def to_json
      return {
        :artist_name => artist_name,
        :profile_url => profile_url,
        :image_url => image_url,
        :tags => tags,
        :translated_tags => translated_tags,
        :danbooru_name => artist_record.try(:first).try(:name),
        :danbooru_id => artist_record.try(:first).try(:id),
        :unique_id => unique_id
      }.to_json
    end

    def available?
      strategy.present?
    end
  end
end
