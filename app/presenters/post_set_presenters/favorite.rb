module PostSetPresenters
  class Favorite < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :favorites, :posts, :to => :post_set
    delegate :tag_list_html, to: :tag_set_presenter

    def initialize(post_set)
      @post_set = post_set
      @tag_set_presenter = TagSetPresenter.new(
        RelatedTagCalculator.calculate_from_sample_to_array(
          post_set.tag_string
        ).map {|x| x[0]}
      )
    end
  end
end
