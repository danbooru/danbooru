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
    
    def tag_list_html(template)
      tag_set_presenter.tag_list_html(template)
    end
  end
end
