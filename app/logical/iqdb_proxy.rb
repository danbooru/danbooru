class IqdbProxy
  class Error < StandardError; end
  attr_reader :http, :iqdbs_server

  def initialize(http: Danbooru::Http.new, iqdbs_server: Danbooru.config.iqdbs_server)
    @iqdbs_server = iqdbs_server
    @http = http
  end

  def enabled?
    iqdbs_server.present?
  end

  def download(url, type)
    strategy = Sources::Strategies.find(url)
    download_url = strategy.send(type)
    file = strategy.download_file!(download_url)
    file
  end

  def search(params)
    limit = params[:limit]&.to_i&.clamp(1, 1000) || 20
    similarity = params[:similarity]&.to_f&.clamp(0.0, 100.0) || 0.0
    high_similarity = params[:high_similarity]&.to_f&.clamp(0.0, 100.0) || 65.0

    if params[:file].present?
      file = params[:file]
      results = query(file: file, limit: limit)
    elsif params[:url].present?
      file = download(params[:url], :preview_url)
      results = query(file: file, limit: limit)
    elsif params[:image_url].present?
      file = download(params[:image_url], :url)
      results = query(file: file, limit: limit)
    elsif params[:file_url].present?
      file = download(params[:file_url], :image_url)
      results = query(file: file, limit: limit)
    elsif params[:post_id].present?
      url = Post.find(params[:post_id]).preview_file_url
      results = query(url: url, limit: limit)
    else
      results = []
    end

    results = results.select { |result| result["score"] >= similarity }.take(limit)
    matches = decorate_posts(results)
    high_similarity_matches, low_similarity_matches = matches.partition { |match| match["score"] >= high_similarity }

    [high_similarity_matches, low_similarity_matches, matches]
  ensure
    file.try(:close)
  end

  def query(file: nil, url: nil, limit: 20)
    raise NotImplementedError, "the IQDBs service isn't configured" unless enabled?

    file = HTTP::FormData::File.new(file) if file
    form = { file: file, url: url, limit: limit }.compact
    response = http.timeout(30).post("#{iqdbs_server}/similar", form: form)

    raise Error, "IQDB error: #{response.status}" if response.status != 200
    raise Error, "IQDB error: #{response.parse["error"]}" if response.parse.is_a?(Hash)
    raise Error, "IQDB error: #{response.parse.first}" if response.parse.try(:first).is_a?(String)

    response.parse
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
