# frozen_string_literal: true

# An API client for Danbooru's internal IQDB instance. Can add images, remove
# images, and search for images in IQDB.
#
# @see https://github.com/danbooru/iqdb
class IqdbClient
  class Error < StandardError; end
  attr_reader :iqdb_url, :http

  # Create a new IQDB API client.
  # @param iqdb_url [String] the base URL of the IQDB server
  # @param http [Danbooru::Http] the HTTP client to use
  def initialize(iqdb_url: Danbooru.config.iqdb_url.to_s, http: Danbooru::Http.new)
    @iqdb_url = iqdb_url.chomp("/")
    @http = http
  end

  concerning :QueryMethods do
    # Search for an image by file, URL, hash, or post ID.
    def search(post_id: nil, file: nil, hash: nil, url: nil, image_url: nil, file_url: nil, similarity: 0.0, high_similarity: 65.0, limit: 20)
      limit = limit.to_i.clamp(1, 1000)
      similarity = similarity.to_f.clamp(0.0, 100.0)
      high_similarity = high_similarity.to_f.clamp(0.0, 100.0)

      if file.present?
        file = file.tempfile
      elsif url.present?
        file = download(url, :preview_url)
      elsif image_url.present?
        file = download(image_url, :url)
      elsif file_url.present?
        file = download(file_url, :image_url)
      elsif post_id.present?
        file = Post.find(post_id).file(:preview)
      end

      if hash.present?
        results = query_hash(hash, limit: limit)
      elsif file.present?
        results = query_file(file, limit: limit)
      else
        results = []
      end

      process_results(results, similarity, high_similarity)
    ensure
      file.try(:close)
    end

    # Download an URL to a file.
    # @param url [String] the URL to download
    # @param type [Symbol] the type of URL to download (:preview_url or full :image_url)
    # @return [MediaFile] the downloaded file
    def download(url, type)
      strategy = Sources::Strategies.find(url)
      download_url = strategy.send(type)
      file = strategy.download_file!(download_url)
      file
    end

    # Transform the JSON returned by IQDB to add the full post data for each
    # match.
    # @param matches [Array<Hash>] the array of IQDB matches
    # @param low_similarity [Float] the threshold for a result to be considered low similarity
    # @param high_similarity [Float] the threshold for a result to be considered high similarity
    # @return [(Array, Array, Array)] the set of high similarity, low similarity, and all matches
    def process_results(matches, low_similarity, high_similarity)
      matches = matches.select { |result| result["score"] >= low_similarity }
      post_ids = matches.map { |match| match["post_id"] }
      posts = Post.includes(:media_asset).where(id: post_ids).group_by(&:id).transform_values(&:first)

      matches = matches.map do |match|
        post = posts.fetch(match["post_id"], nil)
        match.with_indifferent_access.merge(post: post) if post
      end.compact

      high_similarity_matches, low_similarity_matches = matches.partition { |match| match["score"] >= high_similarity }
      [high_similarity_matches, low_similarity_matches, matches]
    end
  end

  # Add a post to IQDB.
  # @param post [Post] the post to add
  def add_post(post)
    return unless post.has_preview?
    preview_file = post.file(:preview)
    add(post.id, preview_file)
  end

  concerning :HttpMethods do
    # Search for an image in IQDB by hash.
    # @param hash [String] the IQDB hash to search
    def query_hash(hash, limit: 20)
      request(:post, "query", params: { hash: hash, limit: limit })
    end

    # Search for an image file in IQDB.
    # @param file [File] the image to search
    def query_file(file, limit: 20)
      media_file = MediaFile.open(file)
      preview = media_file.preview(Danbooru.config.small_image_width, Danbooru.config.small_image_width)
      file = HTTP::FormData::File.new(preview)
      request(:post, "query", form: { file: file }, params: { limit: limit })
    end

    # Add a post to IQDB.
    # @param post_id [Integer] the post to add
    # @param file [File] the image to add
    def add(post_id, file)
      file = HTTP::FormData::File.new(file)
      request(:post, "images/#{post_id}", form: { file: file })
    end

    # Remove an image from IQDB.
    # @param post_id [Integer] the post to remove
    def remove(post_id)
      request(:delete, "images/#{post_id}")
    end

    # Send a request to IQDB.
    # @param method [String] the HTTP method
    # @param url [String] the IQDB url
    # @param options [Hash] the URL params to send
    def request(method, url, **options)
      return [] if iqdb_url.blank? # do nothing if iqdb isn't configured
      response = http.timeout(30).send(method, "#{iqdb_url}/#{url}", **options)
      raise Error, "IQDB error: #{response.parse}" if response.status != 200
      response.parse
    end
  end
end
