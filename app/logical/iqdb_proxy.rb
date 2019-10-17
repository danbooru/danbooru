class IqdbProxy
  class Error < StandardError; end

  def self.enabled?
    Danbooru.config.iqdbs_server.present?
  end

  def self.search(params)
    raise NotImplementedError, "the IQDBs service isn't configured" unless enabled?

    limit = params[:limit]&.to_i&.clamp(1, 1000) || 20
    similarity = params[:similarity]&.to_f&.clamp(0.0, 100.0) || 0.0
    high_similarity = params[:high_similarity]&.to_f&.clamp(0.0, 100.0) || 65.0

    if params[:file].present?
      results = query(file: params[:file], limit: limit)
    elsif params[:url].present?
      url = Sources::Strategies.find(params[:url]).image_url
      results = query(url: url, limit: limit)
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
  end

  def self.query(params)
    response = HTTParty.post("#{Danbooru.config.iqdbs_server}/similar", body: params, **Danbooru.config.httparty_options)
    raise Error, "HTTP error: #{response.code} #{response.message}" unless response.success?
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
