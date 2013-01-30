module PostSetPresenters
  class Base
    def posts
      raise NotImplementedError
    end
    
    def post_previews_html(template)
      html = ""
      is_empty = Post.with_timeout(500, false) do
        posts.empty?
      end

      if is_empty?
        return template.render("post_sets/blank")
      end

      posts.each do |post|
        html << PostPresenter.preview(post)
      end

      html.html_safe
    end
  end
end
