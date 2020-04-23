module PostSetPresenters
  class Post < Base
    MAX_TAGS = 25

    attr_accessor :post_set
    delegate :posts, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
    end

    def tag_set_presenter
      @tag_set_presenter ||= TagSetPresenter.new(related_tags.take(MAX_TAGS))
    end

    def post_previews_html(template, options = {})
      super(template, options.merge(show_cropped: true))
    end

    def related_tags
      if post_set.query.is_wildcard_search?
        wildcard_tags
      elsif post_set.query.is_metatag?(:search)
        saved_search_tags
      elsif post_set.query.is_empty_search? || post_set.query.is_metatag?(:order, :rank)
        popular_tags
      elsif post_set.query.is_single_term?
        similar_tags
      else
        frequent_tags
      end
    end

    def popular_tags
      if PopularSearchService.enabled?
        PopularSearchService.new(Date.today).tags
      else
        frequent_tags
      end
    end

    def similar_tags
      RelatedTagCalculator.cached_similar_tags_for_search(post_set.tag_string, MAX_TAGS)
    end

    def frequent_tags
      RelatedTagCalculator.frequent_tags_for_post_array(post_set.posts).take(MAX_TAGS)
    end

    def wildcard_tags
      Tag.wildcard_matches(post_set.tag_string)
    end

    def saved_search_tags
      ["search:all"] + SavedSearch.labels_for(CurrentUser.user.id).map {|x| "search:#{x}"}
    end

    def tag_list_html(**options)
      tag_set_presenter.tag_list_html(name_only: post_set.query.is_metatag?(:search), **options)
    end
  end
end
