class IqdbProxy
  class Error < StandardError; end

  def self.enabled?
    Danbooru.config.iqdbs_server.present?
  end

  def self.download(url, type)
    download = Downloads::File.new(url)
    file, strategy = download.download!(url: download.send(type))
    file
  end

  def self.search(params)
    raise NotImplementedError, "the IQDBs service isn't configured" unless enabled?

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
      file = download(params[:image_url], :image_url)
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

  def self.query(params)
    response = HTTParty.post("#{Danbooru.config.iqdbs_server}/similar", body: params, **Danbooru.config.httparty_options)
    raise Error, "IQDB error: #{response.code} #{response.message}" unless response.success?
    raise Error, "IQDB error: #{response.parsed_response["error"]}" if response.parsed_response.is_a?(Hash)
    raise Error, "IQDB error: #{response.parsed_response.first}" if response.parsed_response.try(:first).is_a?(String)
    response.parsed_response
  end

  def self.decorate_posts(json)
    post_ids = json.map { |match| match["post_id"] }
    posts = Post.where(id: post_ids).group_by(&:id).transform_values(&:first)

    json.map do |match|
      post = posts.fetch(match["post_id"], nil)
      match.with_indifferent_access.merge(post: post) if post
    end.compact
  end
end
