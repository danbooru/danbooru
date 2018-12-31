# Page URLs:
#
# * https://www.artstation.com/artwork/04XA4
# * https://www.artstation.com/artwork/cody-from-sf
# * https://sa-dui.artstation.com/projects/DVERn
#
# Profile URLs:
#
# * https://www.artstation.com/artist/sa-dui
# * https://www.artstation.com/sa-dui
# * https://sa-dui.artstation.com/
#
# Image URLs
#
# * https://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236
# * https://cdnb.artstation.com/p/assets/images/images/014/410/217/smaller_square/bart-osz-bartosz1812041.jpg?1543866276

module Sources::Strategies
  class ArtStation < Base
    PROJECT1 = %r!\Ahttps?://www\.artstation\.com/artwork/(?<project_id>[a-z0-9-]+)/?\z!i
    PROJECT2 = %r!\Ahttps?://(?<artist_name>[a-z0-9-]+)\.artstation\.com/projects/(?<project_id>[a-z0-9-]+)/?\z!i
    PROJECT = Regexp.union(PROJECT1, PROJECT2)
    ARTIST1 = %r{\Ahttps?://(?<artist_name>[a-z0-9-]+)(?<!www)\.artstation\.com/?\z}i
    ARTIST2 = %r{\Ahttps?://www\.artstation\.com/artist/(?<artist_name>[a-z0-9-]+)/?\z}i
    ARTIST3 = %r{\Ahttps?://www\.artstation\.com/(?<artist_name>[a-z0-9-]+)/?\z}i
    ARTIST = Regexp.union(ARTIST1, ARTIST2, ARTIST3)

    ASSET = %r!\Ahttps?://cdn\w*\.artstation\.com/p/assets/images/images/\d+/\d+/\d+/(?:medium|small|large)/!i

    attr_reader :json, :image_urls

    def domains
      ["artstation.com"]
    end

    def site_name
      "ArtStation"
    end

    def image_urls
      image_urls_sub
        .map { |asset| original_asset_url(asset) }
    end
    memoize :image_urls

    def page_url
      return nil unless project_id.present?

      if artist_name.present?
        "https://#{artist_name}.artstation.com/projects/#{project_id}"
      else
        "https://www.artstation.com/artwork/#{project_id}"
      end
    end

    def profile_url
      return nil unless artist_name.present?
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

    def normalized_for_artist_finder?
      profile_url.present? && url == profile_url
    end

  public

    def image_urls_sub
      if url.match?(ASSET)
        return [url]
      end

      api_response[:assets].to_a
        .select { |asset| asset[:asset_type] == "image" }
        .map { |asset| asset[:image_url] }
    end

    # these are de facto private methods but are public for testing
    # purposes

    def artist_name_from_url
      urls.map { |url| url[PROJECT, :artist_name] || url[ARTIST, :artist_name]  }.compact.first
    end

    def project_id
      urls.map { |url| url[PROJECT, :project_id]  }.compact.first
    end

    def api_response
      return {} unless project_id.present?

      resp, code = HttpartyCache.get("https://www.artstation.com/projects/#{project_id}.json")
      return {} if code != 200

      JSON.parse(resp, symbolize_names: true)
    end
    memoize :api_response

    # Returns the original representation of the asset, if it exists. Otherwise
    # return the url.
    def original_asset_url(x)
      if x =~ ASSET
        # example: https://cdnb3.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974
        original_url = x.sub(%r!/(?:medium|small|large)/!, "/original/")

        if http_exists?(original_url, headers)
          return original_url
        end

        if x =~ /medium|small/
          large_url = x.sub(%r!/(?:medium|small)/!, "/large/")

          if http_exists?(large_url, headers)
            return large_url
          end
        end
      end

      return x
    end
  end
end
