module PostSetPresenters
  class WikiPage < PostSetPresenters::Post
    def posts
      @post_set.posts
    rescue ActiveRecord::StatementInvalid, PG::Error
      []
    end

    def post_previews_html(template)
      result = super(template)
      if result =~ /Nobody here but us chickens/
        result = ""
      end
      result.html_safe
    end
  end
end
