class TumblrApiClient < Struct.new(:api_key)
  def posts(blog_name, post_id)
    body, code = HttpartyCache.get("/#{blog_name}/posts", 
      params: { id: post_id, api_key: api_key },
      base_uri: "https://api.tumblr.com/v2/blog/"
    )

    if code == 200
      return JSON.parse(body)["response"].with_indifferent_access
    end

    raise "TumblrApiClient call failed (code=#{code}, body=#{body}, blog_name=#{blog_name}, post_id=#{post_id})"
  end
end
