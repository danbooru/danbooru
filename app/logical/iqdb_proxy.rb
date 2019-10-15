class IqdbProxy
  def self.search(params)
    raise NotImplementedError unless Danbooru.config.iqdbs_server.present?

    limit = params[:limit].presence || 20
    limit = limit.to_i.clamp(1, 100)
    similarity = params[:similarity].to_f.clamp(0.0, 100.0)

    if params[:file].present?
      results = query_file(params[:file], limit)
    elsif params[:url].present?
      url = Sources::Strategies.find(params[:url]).image_url
      results = query_url(url, limit)
    elsif params[:post_id].present?
      url = Post.find(params[:post_id]).preview_file_url
      results = query_url(url, limit)
    else
      results = []
    end

    results = results.select { |result| result["score"] >= similarity }.take(limit)
    decorate_posts(results)
  end

  def self.query_url(url, limit)
    query = { url: url, limit: limit }
    response = HTTParty.get("#{Danbooru.config.iqdbs_server}/similar", query: query, **Danbooru.config.httparty_options)
    response.parsed_response
  end

  def self.query_file(file, limit)
    body = { file: file, limit: limit }
    response = HTTParty.post("#{Danbooru.config.iqdbs_server}/similar", body: body, **Danbooru.config.httparty_options)
    response.parsed_response
  end

  def self.decorate_posts(json)
    json.map do |x|
      begin
        x["post"] = Post.find(x["post_id"])
        x
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end.compact
  end
end
