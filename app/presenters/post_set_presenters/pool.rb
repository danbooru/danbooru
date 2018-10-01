module PostSetPresenters
  class Pool < Base
    attr_reader :tag_set_presenter, :post_set
    delegate :posts, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
      @tag_set_presenter = TagSetPresenter.new(
        RelatedTagCalculator.calculate_from_sample_to_array(
          post_set.tag_string
        ).map {|x| x[0]}
      )
    end

    def post_previews_html(template)
      html = ""

      if posts.empty?
        return template.render("post_sets/blank")
      end

      posts.each do |post|
        html << PostPresenter.preview(post, :pool_id => post_set.pool.id)
      end

      html.html_safe
    end
  end
end
