module Downloads
  module RewriteStrategies
    class ArtStation < Base
      def rewrite(url, headers, data = {})
        # example: https://cdnb3.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974
        if url =~ %r!^https?://cdn\w*\.artstation\.com/p/assets/images/images/\d+/\d+/\d+/(?:medium|small|large)/!
          original_url, headers = rewrite_large_url(url, headers)
          if test_original(original_url)
            url = original_url
          end
        else
          url, headers = rewrite_html_url(url, headers)
        end

        return [url, headers, data]
      end

    protected
      def test_original(url)
        res = http_head_request(url, {})
        res.is_a?(Net::HTTPSuccess)
      end

      def rewrite_html_url(url, headers)
        return [url, headers] unless Sources::Strategies::ArtStation.url_match?(url)

        source = Sources::Site.new(url)
        source.get
        [source.image_url, headers]
      end

      def rewrite_large_url(url, headers)
        # example: https://cdnb3.artstation.com/p/assets/images/images/003/716/071/original/aoi-ogata-hate-city.jpg?1476754974
        url = url.sub(%r!/(?:medium|small|large)/!, "/original/")
        return [url, headers]
      end
    end
  end
end
