module Iqdb
  class Download
    attr_reader :source, :download, :matches

    def initialize(source)
      @source = source
    end

    def get_referer(url)
      headers = {}
      datums = {}

      Downloads::RewriteStrategies::Base.strategies.each do |strategy|
        url, headers, datums = strategy.new(url).rewrite(url, headers, datums)
      end

      [url, headers["Referer"]]
    end

    def find_similar
      if Danbooru.config.iqdbs_server
        url, ref = get_referer(source)
        params = {
          "key" => Danbooru.config.iqdbs_auth_key,
          "url" => url,
          "ref" => ref
        }
        uri = URI.parse("#{Danbooru.config.iqdbs_server}/similar")
        uri.query = URI.encode_www_form(params)

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
          resp = http.request_get(uri.request_uri)
          if resp.is_a?(Net::HTTPSuccess)
            json = JSON.parse(resp.body)
            if json.is_a?(Array)
              post_ids = json.map { |match| match["post_id"] }
              posts = Post.find(post_ids)

              @matches = json.map do |match|
                post = posts.find { |post| post.id == match["post_id"] }
                match.with_indifferent_access.merge({ post: post })
              end
            else
              @matches = []
            end
          else
            raise "HTTP error code: #{resp.code} #{resp.message}"
          end
        end
      else
        raise NotImplementedError
      end
    end
  end
end
