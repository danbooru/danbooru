module PostSetPresenters
  class Pool
    attr_reader :tag_set_presenter, :pool_set

    def initialize(pool_set)
      @pool_set = pool_set
      @tag_set_presenter = TagSetPresenter.new(
        RelatedTagCalculator.calculate_from_sample_to_array(
          pool_set.tag_string
        ).map {|x| x[0]}
      )
    end
    
    def tag_list_html(template)
      tag_set_presenter.tag_list_html(template)
    end

    def post_previews_html(template)
      html = ""

      if pool_set.posts.empty?
        return template.render(:partial => "post_sets/blank")
      end

      pool_set.posts.each do |post|
        html << PostPresenter.preview(post)
      end

      html.html_safe
    end
  end
end
