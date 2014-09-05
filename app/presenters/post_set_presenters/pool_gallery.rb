module PostSetPresenters
  class PoolGallery < Base
    attr_accessor :post_set
    delegate :pools, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
    end

    def post_previews_html(template, options = {})
      html = ""

      if pools.empty?
        return template.render("post_sets/blank")
      end

      posts = ::Post.where(id: pools.map(&:cover_post_id)).to_a.inject({}) {|h, x| h[x.id] = x; h}

      pools.each do |pool|
        if post = posts[pool.cover_post_id.to_i]
          html << PostPresenter.preview(post, options.merge(:tags => @post_set.tag_string, :raw => @post_set.raw, :pool => pool))
          html << "\n"
        end
      end

      html.html_safe
    end
  end
end
