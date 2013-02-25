module PostSetPresenters
  class Base
    def posts
      raise NotImplementedError
    end
    
    def post_previews_html(template)
      html = ""

      if posts.empty?
        return template.render("post_sets/blank")
      end

      posts.each do |post|
        html << PostPresenter.preview(post, :tags => template.params[:tags])
      end

      html.html_safe
    end
  end
end
