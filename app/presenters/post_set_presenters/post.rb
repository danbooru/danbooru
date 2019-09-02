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
      if post_set.is_pattern_search?
        pattern_tags
      elsif post_set.is_saved_search?
        saved_search_tags
      elsif post_set.is_empty_tag? || post_set.tag_string == "order:rank"
        popular_tags
      elsif post_set.is_single_tag?
        similar_tags
      else
        frequent_tags
      end
    end

    def popular_tags
      if PopularSearchService.enabled?
        PopularSearchService.new(Date.today).tags
      else
        Tag.trending
      end
    end

    def similar_tags
      RelatedTagCalculator.cached_similar_tags_for_search(post_set.tag_string, MAX_TAGS)
    end

    def frequent_tags
      RelatedTagCalculator.frequent_tags_for_posts(post_set.posts).take(MAX_TAGS)
    end

    def pattern_tags
      Tag.name_matches(post_set.tag_string).order(post_count: :desc).limit(MAX_TAGS).pluck(:name)
    end

    def saved_search_tags
      ["search:all"] + SavedSearch.labels_for(CurrentUser.user.id).map {|x| "search:#{x}"}
    end

    def tag_list_html(**options)
      tag_set_presenter.tag_list_html(name_only: post_set.is_saved_search?, **options)
    end
  end
end
