module PostSetPresenters
  class Favorite < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :favorites, :to => :post_set

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

    def posts
      @posts ||= post_set.posts
    end
  end
end
