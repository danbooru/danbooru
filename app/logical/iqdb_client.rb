# frozen_string_literal: true

# An API client for Danbooru's internal IQDB instance. Can add images, remove
# images, and search for images in IQDB.
#
# @see https://github.com/danbooru/iqdb
class IqdbClient
  LOW_SIMILARITY_THRESHOLD = 0.0
  HIGH_SIMILARITY_THRESHOLD = 65.0
  DUPLICATE_THRESHOLD = 92.0

  class Error < StandardError; end
  attr_reader :iqdb_url, :http

  # Create a new IQDB API client.
  # @param iqdb_url [String] the base URL of the IQDB server
  # @param http [Danbooru::Http] the HTTP client to use
  def initialize(iqdb_url: Danbooru.config.iqdb_url.to_s, http: Danbooru::Http.internal)
    @iqdb_url = iqdb_url.chomp("/")
    @http = http
  end

  def enabled?
    iqdb_url.present?
  end

  concerning :QueryMethods do
    # Search for an image by file, URL, hash, or post ID.
    def search(post_id: nil, media_asset_id: nil, file: nil, hash: nil, url: nil, image_url: nil, file_url: nil, similarity: LOW_SIMILARITY_THRESHOLD, high_similarity: HIGH_SIMILARITY_THRESHOLD, limit: 20)
      limit = limit.to_i.clamp(1, 1000)
      similarity = similarity.to_f.clamp(0.0, 100.0)
      high_similarity = high_similarity.to_f.clamp(0.0, 100.0)
      target_url = url.presence || file_url.presence || image_url.presence

      if file.present?
        file = file.tempfile
      elsif target_url.present?
        extractor = Source::Extractor.find(target_url)

        if extractor.parsed_url.image_url?
          download_url = target_url
        else
          raise Error, "#{url} has multiple images. Enter the URL of a single image" if extractor.image_urls.size > 1
          raise Error, "#{url} has no images" if extractor.image_urls.empty?

          download_url = extractor.image_urls.first
        end

        file = Source::Extractor.find(download_url).download_file!(download_url)
      elsif post_id.present?
        file = Post.find(post_id).file(:"180x180")
      elsif media_asset_id.present?
        file = MediaAsset.find(media_asset_id).variant("360x360").open_file
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

    # Transform the JSON returned by IQDB to add the full post data for each match.
    #
    # @param matches [Array<Hash>] the array of IQDB matches
    # @param low_similarity [Float] the threshold for a result to be considered low similarity
    # @param high_similarity [Float] the threshold for a result to be considered high similarity
    # @return [(Array, Array, Array)] the set of high similarity, low similarity, and all matches
    def process_results(matches, low_similarity, high_similarity)
      matches = matches.select { |match| match["score"] >= low_similarity }.sort_by { |match| -match["score"] }
      posts = Post.includes(:media_asset).where(id: matches.pluck("post_id")).group_by(&:id).transform_values(&:first)

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
    return unless enabled? && post.has_preview?
    preview_file = post.file(:"180x180")
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
      preview = media_file.preview!(180, 180)
      file = HTTP::FormData::File.new(preview)
      request(:post, "query", form: { file: file }, params: { limit: limit })
    ensure
      preview&.close
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
      return [] if !enabled?
      response = http.timeout(30).send(method, "#{iqdb_url}/#{url}", **options)
      raise Error, "IQDB error: #{response.parse[:message]}" if response.status != 200
      response.parse
    end
  end
end
