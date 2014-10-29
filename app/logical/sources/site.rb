# encoding: UTF-8

module Sources
  class Site
    attr_reader :url, :strategy
    delegate :get, :referer_url, :site_name, :artist_name, :profile_url, :image_url, :tags, :artist_record, :unique_id, :page_count, :file_url, :ugoira_frame_data, :ugoira_width, :ugoira_height, :normalize_for_dupe_search, :to => :strategy

    def self.strategies
      [Strategies::Pixiv, Strategies::NicoSeiga, Strategies::DeviantArt, Strategies::Nijie, Strategies::FC2]
    end

    def initialize(url)
      @url = url

      Site.strategies.each do |strategy|
        if strategy.url_match?(url)
          @strategy = strategy.new(url)
          break
        end
      end

      # Default to the base strategy if no other strategy was found.
      @strategy ||= Sources::Strategies::Base.new(url)
    end

    def normalize_for_artist_finder!
      return strategy.normalize_for_artist_finder!
    rescue Sources::Error
      return url
    end

    def translated_tags
      untranslated_tags = tags
      untranslated_tags = untranslated_tags.map(&:first)
      untranslated_tags = untranslated_tags.map do |tag|
        if tag =~ /\A(\S+?)_?\d+users入り\Z/
          $1
        else
          tag
        end
      end
      WikiPage.other_names_match(untranslated_tags).map{|wiki_page| [wiki_page.title, wiki_page.category_name]}
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
        :unique_id => unique_id,
        :page_count => page_count
      }.to_json
    end

    # When a strategy is available, the upload form will fetch source data automatically.
    def available?
      !strategy.instance_of?(Sources::Strategies::Base)
    end
  end
end
