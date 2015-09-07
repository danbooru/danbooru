module PostSetPresenters
  class FavoriteGroup < PostSetPresenters::Pool
    def post_previews_html(template)
      html = ""

      if posts.empty?
        return template.render("post_sets/blank")
      end

      posts.each do |post|
        html << PostPresenter.preview(post, :favgroup_id => post_set.pool.id, :show_deleted => true)
      end

      html.html_safe
    end
  end
end
