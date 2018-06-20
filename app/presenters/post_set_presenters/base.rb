module PostSetPresenters
  class Base
    def posts
      raise NotImplementedError
    end

    def post_previews_html(template, options = {})
      html = ""

      if posts.empty?
        return template.render("post_sets/blank")
      end

      posts.each do |post|
        html << PostPresenter.preview(post, options.merge(:show_cropped => true, :tags => @post_set.tag_string, :raw => @post_set.raw))
        html << "\n"
      end

      html.html_safe
    end
  end
end
