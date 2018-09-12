module HttpartyCache
  extend self

  def get(url, headers: {}, params: {}, base_uri: nil, format: :html, expiry: 60)
    key = Cache.hash({url: url, headers: headers, params: params, base_uri: base_uri, format: format}.to_s)
    Cache.get("cachedget:#{key}", expiry) do
      resp = HTTParty.get(url, Danbooru.config.httparty_options.deep_merge(query: params, headers: headers, base_uri: base_uri, format: format))
      body = resp.body.force_encoding("utf-8")
      [body, resp.code]
    end
  end
end
