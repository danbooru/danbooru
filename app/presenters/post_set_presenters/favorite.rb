module PostSetPresenters
  class Favorite
    attr_accessor :favorite_set, :tag_set_presenter
    delegate :favorites, :posts, :to => :favorite_set

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

    def post_previews_html(template)
      html = ""

      if favorites.empty?
        return template.render(:partial => "post_sets/blank")
      end

      favorites.each do |favorite|
        html << PostPresenter.preview(favorite.post)
      end

      html.html_safe
    end
  end
end
