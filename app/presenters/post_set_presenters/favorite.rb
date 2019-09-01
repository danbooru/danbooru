module PostSetPresenters
  class Favorite < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :favorites, :posts, :to => :post_set
    delegate :tag_list_html, to: :tag_set_presenter

    def initialize(post_set)
      @post_set = post_set
      @tag_set_presenter = TagSetPresenter.new(RelatedTagCalculator.frequent_tags_for_posts(post_set.posts).take(25))
    end
  end
end
