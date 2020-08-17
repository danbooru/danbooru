# Page URLs:
#
# * https://www.artstation.com/artwork/04XA4
# * https://www.artstation.com/artwork/cody-from-sf
# * https://sa-dui.artstation.com/projects/DVERn
# * https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041
#
# Profile URLs:
#
# * https://www.artstation.com/artist/sa-dui
# * https://www.artstation.com/sa-dui
# * https://sa-dui.artstation.com/
# * https://hosi_na.artstation.com
#
# Image URLs
#
# * https://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236
# * https://cdnb.artstation.com/p/assets/images/images/014/410/217/smaller_square/bart-osz-bartosz1812041.jpg?1543866276
# * https://cdna.artstation.com/p/assets/images/images/007/253/680/4k/ina-wong-demon-girl-done-ttd-comp.jpg?1504793833
#
# * https://cdna.artstation.com/p/assets/covers/images/007/262/828/small/monica-kyrie-1.jpg?1504865060

module Sources::Strategies
  class ArtStation < Base
    PROJECT1 = %r{\Ahttps?://www\.artstation\.com/artwork/(?<project_id>[a-z0-9-]+)/?\z}i
    PROJECT2 = %r{\Ahttps?://(?<artist_name>[\w-]+)\.artstation\.com/projects/(?<project_id>[a-z0-9-]+)(?:/|\?[\w=-]+)?\z}i
    PROJECT = Regexp.union(PROJECT1, PROJECT2)
    ARTIST1 = %r{\Ahttps?://(?<artist_name>[\w-]+)(?<!www)\.artstation\.com/?\z}i
    ARTIST2 = %r{\Ahttps?://www\.artstation\.com/artist/(?<artist_name>[\w-]+)/?\z}i
    ARTIST3 = %r{\Ahttps?://www\.artstation\.com/(?<artist_name>[\w-]+)/?\z}i
    ARTIST = Regexp.union(ARTIST1, ARTIST2, ARTIST3)

    ASSET = %r{\Ahttps?://cdn\w*\.artstation\.com/p/assets/(?<type>images|covers)/images/(?<id>\d+/\d+/\d+)/(?<size>[^/]+)/(?<filename>.+)\z}i

    attr_reader :json

    def domains
      ["artstation.com"]
    end

    def site_name
      "ArtStation"
    end

    def image_urls
      @image_urls ||= image_urls_sub.map { |asset| asset_url(asset, :largest) }
    end

    def preview_urls
      @preview_urls ||= image_urls_sub.map { |asset| asset_url(asset, :smallest) }
    end

    def page_url
      return nil if project_id.blank?

      if artist_name.present?
        "https://#{artist_name}.artstation.com/projects/#{project_id}"
      else
        "https://www.artstation.com/artwork/#{project_id}"
      end
    end

    def profile_url
      return nil if artist_name.blank?
      "https://www.artstation.com/#{artist_name}"
    end

    def artist_name
      artist_name_from_url || api_response.dig(:user, :username)
    end

    def artist_commentary_title
      api_response[:title]
    end

    def artist_commentary_desc
      api_response[:description]
    end

    def dtext_artist_commentary_desc
      ActionView::Base.full_sanitizer.sanitize(artist_commentary_desc)
    end

    def tags
      api_response[:tags].to_a.map do |tag|
        [tag, "https://www.artstation.com/search?q=" + CGI.escape(tag)]
      end
    end

    def normalize_for_source
      return if project_id.blank?

      if artist_name_from_url.present?
        "https://#{artist_name_from_url}.artstation.com/projects/#{project_id}"
      else
        "https://www.artstation.com/artwork/#{project_id}"
      end
    end

    def image_urls_sub
      if url.match?(ASSET)
        return [url]
      end

      api_response[:assets]
        .to_a
        .select { |asset| asset[:asset_type] == "image" }
        .map { |asset| asset[:image_url] }
    end

    # these are de facto private methods but are public for testing
    # purposes

    def artist_name_from_url
      urls.map { |url| url[PROJECT, :artist_name] || url[ARTIST, :artist_name] }.compact.first
    end

    def project_id
      urls.map { |url| url[PROJECT, :project_id]  }.compact.first
    end

    def api_response
      return {} if project_id.blank?

      resp = http.cache(1.minute).get("https://www.artstation.com/projects/#{project_id}.json")
      return {} if resp.code != 200

      resp.parse.with_indifferent_access
    end
    memoize :api_response

    def image_url_sizes(type, id, filename)
      [
        "https://cdn.artstation.com/p/assets/#{type}/images/#{id}/original/#{filename}",
        "https://cdn.artstation.com/p/assets/#{type}/images/#{id}/4k/#{filename}",
        "https://cdn.artstation.com/p/assets/#{type}/images/#{id}/large/#{filename}",
        "https://cdn.artstation.com/p/assets/#{type}/images/#{id}/medium/#{filename}",
        "https://cdn.artstation.com/p/assets/#{type}/images/#{id}/small/#{filename}",
      ]
    end

    def asset_url(url, size)
      return url unless url =~ ASSET

      urls = image_url_sizes($~[:type], $~[:id], $~[:filename])
      if size == :smallest
        urls = urls.reverse
      end

      chosen_url = urls.find { |url| http_exists?(url) }
      chosen_url || url
    end
  end
end
