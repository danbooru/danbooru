class IqdbClient
  class Error < StandardError; end
  attr_reader :iqdb_url, :http

  def initialize(iqdb_url: Danbooru.config.iqdb_url.to_s, http: Danbooru::Http.new)
    @iqdb_url = iqdb_url.chomp("/")
    @http = http
  end

  concerning :QueryMethods do
    def search(post_id: nil, file: nil, url: nil, image_url: nil, file_url: nil, similarity: 0.0, high_similarity: 65.0, limit: 20)
      limit = limit.to_i.clamp(1, 1000)
      similarity = similarity.to_f.clamp(0.0, 100.0)
      high_similarity = high_similarity.to_f.clamp(0.0, 100.0)

      if file.blank?
        if url.present?
          file = download(url, :preview_url)
        elsif image_url.present?
          file = download(image_url, :url)
        elsif file_url.present?
          file = download(file_url, :image_url)
        elsif post_id.present?
          file = Post.find(post_id).file(:preview)
        else
          return [[], [], []]
        end
      end

      results = query(file, limit: limit)
      results = results.select { |result| result["score"] >= similarity }.take(limit)
      matches = decorate_posts(results)
      high_similarity_matches, low_similarity_matches = matches.partition { |match| match["score"] >= high_similarity }

      [high_similarity_matches, low_similarity_matches, matches]
    ensure
      file.try(:close)
    end

    def download(url, type)
      strategy = Sources::Strategies.find(url)
      download_url = strategy.send(type)
      file = strategy.download_file!(download_url)
      file
    end

    def decorate_posts(json)
      post_ids = json.map { |match| match["post_id"] }
      posts = Post.where(id: post_ids).group_by(&:id).transform_values(&:first)

      json.map do |match|
        post = posts.fetch(match["post_id"], nil)
        match.with_indifferent_access.merge(post: post) if post
      end.compact
    end
  end

  def add_post(post)
    return unless post.has_preview?
    preview_file = post.file(:preview)
    add(post.id, preview_file)
  end

  concerning :HttpMethods do
    def query(file, limit: 20)
      file = HTTP::FormData::File.new(file)
      request(:post, "query", form: { file: file }, params: { limit: limit })
    end

    def add(post_id, file)
      file = HTTP::FormData::File.new(file)
      request(:post, "images/#{post_id}", form: { file: file })
    end

    def remove(post_id)
      request(:delete, "images/#{post_id}")
    end

    def request(method, url, **options)
      return [] if iqdb_url.blank? # do nothing if iqdb isn't configured
      response = http.timeout(30).send(method, "#{iqdb_url}/#{url}", **options)
      raise Error, "IQDB error: #{response.parse}" if response.status != 200
      response.parse
    end
  end
end
