module PostSetPresenters
  class Favorite < Base
    attr_accessor :favorite_set, :tag_set_presenter
    delegate :favorites, :to => :favorite_set

    def initialize(favorite_set)
      @favorite_set = favorite_set
      @tag_set_presenter = TagSetPresenter.new(
        RelatedTagCalculator.calculate_from_sample_to_array(
          favorite_set.tag_string
        ).map {|x| x[0]}
      )
    end
    
    def tag_list_html(template)
      tag_set_presenter.tag_list_html(template)
    end
    
    def posts
      @posts ||= favorite_set.posts
    end
  end
end
