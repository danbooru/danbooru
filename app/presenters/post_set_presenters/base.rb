module PostSetPresenters
  class Base
    def posts
      raise NotImplementedError
    end

    def post_previews_html(template, options = {})
      html = ""
      if none_shown(options)
        return template.render("post_sets/blank")
      end

      posts.each do |post|
        html << PostPresenter.preview(post, options.merge(:tags => @post_set.tag_string))
        html << "\n"
      end

      html.html_safe
    end

    def not_shown(post, options)
      !options[:show_deleted] && post.is_deleted? && @post_set.tag_string !~ /status:(?:all|any|deleted|banned)/
    end

    def none_shown(options)
      posts.reject {|post| not_shown(post, options) }.empty?
    end
  end
end
