module Iqdb
  class Download
    class Error < StandardError; end

    def self.enabled?
      Danbooru.config.iqdbs_server.present? && Danbooru.config.iqdbs_auth_key.present?
    end

    def self.get_referer(url)
      headers = {}
      datums = {}

      strategy = Sources::Strategies.find(url)

      [strategy.image_url, strategy.headers["Referer"]]
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
      raise "IQDB error: #{json["error"]}" unless json.is_a?(Array)

      post_ids = json.map { |match| match["post_id"] }
      posts = Post.find(post_ids)

      json.map do |match|
        post = posts.find { |post| post.id == match["post_id"] }
        match.with_indifferent_access.merge({ post: post })
      end
    rescue => e
      raise Error, { message: e.message, iqdb_response: json }
    end
  end
end
