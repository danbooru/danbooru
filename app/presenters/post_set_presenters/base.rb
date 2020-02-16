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
        html << PostPresenter.preview(post, options.merge(:tags => @post_set.tag_string, :raw => @post_set.raw))
        html << "\n"
      end

      html.html_safe
    end

    def not_shown(post, options)
      CurrentUser.hide_deleted_posts && !options[:show_deleted] && post.is_deleted? && @post_set.tag_string !~ /status:(?:all|any|deleted|banned)/ && !@post_set.raw
    end

    def none_shown(options)
      posts.reject {|post| not_shown(post, options) }.empty?
    end
  end
end
