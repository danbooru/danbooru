# encoding: UTF-8

module Sources
  class Site
    attr_reader :url, :strategy
    delegate :get, :get_size, :site_name, :artist_name, 
      :profile_url, :image_url, :tags, :artist_record, :unique_id, 
      :page_count, :file_url, :ugoira_frame_data, :ugoira_content_type, :image_urls,
      :artist_commentary_title, :artist_commentary_desc,
      :dtext_artist_commentary_title, :dtext_artist_commentary_desc,
      :rewrite_thumbnails, :illust_id_from_url, :to => :strategy

    def self.strategies
      [Strategies::PixivWhitecube, Strategies::Pixiv, Strategies::NicoSeiga, Strategies::DeviantArt, Strategies::ArtStation, Strategies::Nijie, Strategies::Twitter, Strategies::Tumblr, Strategies::Pawoo]
    end

    def initialize(url, options = {})
      @url = url

      Site.strategies.each do |strategy|
        if strategy.url_match?(url)
          @strategy = strategy.new(url, options[:referer_url])
          break
        end
      end
    end

    def referer_url
      strategy.try(:referer_url)
    end

    def normalized_for_artist_finder?
      available? && strategy.normalized_for_artist_finder?
    end

    def normalize_for_artist_finder!
      if available? && strategy.normalizable_for_artist_finder?
        strategy.normalize_for_artist_finder!
      else
        url
      end
    rescue
      url
    end

    def translated_tags
      untranslated_tags = tags
      untranslated_tags = untranslated_tags.map(&:first)
      untranslated_tags += untranslated_tags.grep(/\//).map {|x| x.split(/\//)}.flatten
      untranslated_tags = untranslated_tags.map do |tag|
        if tag =~ /\A(\S+?)_?\d+users入り\Z/
          $1
        else
          tag
        end
      end
      WikiPage.other_names_match(untranslated_tags).map{|wiki_page| [wiki_page.title, wiki_page.category_name]}
    end

    def to_h
      return {
        :artist_name => artist_name,
        :profile_url => profile_url,
        :image_url => image_url,
        :tags => tags,
        :translated_tags => translated_tags,
        :danbooru_name => artist_record.try(:first).try(:name),
        :danbooru_id => artist_record.try(:first).try(:id),
        :unique_id => unique_id,
        :page_count => page_count,
        :artist_commentary => {
          :title => artist_commentary_title,
          :description => artist_commentary_desc,
          :dtext_title => dtext_artist_commentary_title,
          :dtext_description => dtext_artist_commentary_desc,
        }
      }
    end

    def to_json
      to_h.to_json
    end

    def available?
      strategy.present?
    end
  end
end
