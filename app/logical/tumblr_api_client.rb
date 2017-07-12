class TumblrApiClient < Struct.new(:api_key)
  include HTTParty
  base_uri "https://api.tumblr.com/v2/blog/"

  def posts(blog_name, post_id)
    response = self.class.get("/#{blog_name}/posts", Danbooru.config.httparty_options.merge(query: { id: post_id, api_key: api_key }))
    response.parsed_response.with_indifferent_access[:response]
  end
end
