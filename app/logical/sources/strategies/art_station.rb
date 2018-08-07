module Sources::Strategies
  class ArtStation < Base
    PROJECT = %r!\Ahttps?://[a-z0-9-]+\.artstation\.com/(?:artwork|projects)/(?<project_id>[a-z0-9-]+)/?\z!i
    ASSET = %r!\Ahttps?://cdn\w*\.artstation\.com/p/assets/images/images/\d+/\d+/\d+/(?:medium|small|large)/!i
    PROFILE1 = %r!\Ahttps?://(\w+)\.artstation\.com!i
    PROFILE2 = %r!\Ahttps?://www.artstation.com/artist/(\w+)!i
    PROFILE3 = %r!\Ahttps?://www.artstation.com/(\w+)!i
    PROFILE = %r!#{PROFILE2}|#{PROFILE3}|#{PROFILE1}!

    attr_reader :json, :image_urls

    def self.match?(*urls)
      urls.compact.any? { |x| x.match?(PROJECT) || x.match?(ASSET) || x.match?(PROFILE)}
    end

    # https://www.artstation.com/artwork/04XA4
    # https://www.artstation.com/artwork/cody-from-sf
    # https://sa-dui.artstation.com/projects/DVERn
    def self.project_id(url)
      if url =~ PROJECT
        $~[:project_id]
      else
        nil
      end
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
      [url, referer_url].each do |x|
        if x =~ PROJECT
          return "https://www.artstation.com/artwork/#{$~[:project_id]}"
        end
      end

      return super
    end

    def profile_url
      if url =~ PROFILE1 && $1 != "www"
        return "https://www.artstation.com/#{$1}"
      end

      if url =~ PROFILE2
        return "https://www.artstation.com/#{$1}"
      end

      if url =~ PROFILE3 && url !~ PROJECT
        return url
      end

      api_json["user"]["permalink"]
    end

    def artist_name
      api_json["user"]["username"]
    end

    def artist_commentary_title
      api_json["title"]
    end

    def artist_commentary_desc
      ActionView::Base.full_sanitizer.sanitize(api_json["description"])
    end
    memoize :artist_commentary_desc

    def tags
      return nil if !api_json.has_key?("tags")

      api_json["tags"].
        map { |tag| [tag.downcase.tr(" ", "_"), tag_url(tag)]}
    end
    memoize :tags

    def normalized_for_artist_finder?
      url =~ PROFILE3 && url !~ PROFILE2 && url !~ PROJECT
    end

    def normalizable_for_artist_finder?
      url =~ PROFILE || url =~ PROJECT
    end

    def normalize_for_artist_finder
      profile_url
    end

  public

    def image_urls_sub
      if url.match?(ASSET)
        return [url]
      end

      api_json["assets"]
        .select { |asset| asset["asset_type"] == "image" }
        .map { |asset| asset["image_url"] }
    end

    # these are de facto private methods but are public for testing
    # purposes

    def project_id
      self.class.project_id(url) || self.class.project_id(referer_url)
    end
    memoize :project_id

    def api_url
      "https://www.artstation.com/projects/#{project_id}.json"
    end

    def api_json
      if project_id.nil?
        raise ::Sources::Error.new("Project id could not be determined from (#{url}, #{referer_url})")
      end

      resp = HTTParty.get(api_url, Danbooru.config.httparty_options)

      if resp.success?
        json = JSON.parse(resp.body)
      else
        raise HTTParty::ResponseError.new(resp)
      end

      return json
    end
    memoize :api_json

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

    def tag_url(name)
      "https://www.artstation.com/search?q=" + CGI.escape(name)
    end

  end
end
