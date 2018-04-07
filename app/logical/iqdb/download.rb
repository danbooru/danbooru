module Iqdb
  class Download
    def self.enabled?
      Danbooru.config.iqdbs_server.present? && Danbooru.config.iqdbs_auth_key.present?
    end

    def self.get_referer(url)
      headers = {}
      datums = {}

      Downloads::RewriteStrategies::Base.strategies.each do |strategy|
        url, headers, datums = strategy.new(url).rewrite(url, headers, datums)
      end

      [url, headers["Referer"]]
    end

    def self.find_similar(source)
      raise NotImplementedError, "the IQDBs service isn't configured. Similarity searches are not available." unless enabled?

      url, ref = get_referer(source)
      params = {
        "key" => Danbooru.config.iqdbs_auth_key,
        "url" => url,
        "ref" => ref
      }
      uri = URI.parse("#{Danbooru.config.iqdbs_server}/similar")
      uri.query = URI.encode_www_form(params)

      resp = HTTParty.get(uri, Danbooru.config.httparty_options)
      raise "HTTP error code: #{resp.code} #{resp.message}" unless resp.success?

      json = JSON.parse(resp.body)
      if json.is_a?(Array)
        post_ids = json.map { |match| match["post_id"] }
        posts = Post.find(post_ids)

        json.map do |match|
          post = posts.find { |post| post.id == match["post_id"] }
          match.with_indifferent_access.merge({ post: post })
        end
      else
        []
      end
    end
  end
end
