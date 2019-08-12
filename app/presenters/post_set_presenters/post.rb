module PostSetPresenters
  class Post < Base
    attr_accessor :post_set
    delegate :posts, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
    end

    def tag_set_presenter
      @tag_set_presenter ||= TagSetPresenter.new(related_tags)
    end

    def post_previews_html(template, options = {})
      super(template, options.merge(show_cropped: true))
    end

    def related_tags
      if post_set.is_pattern_search?
        pattern_tags
      elsif post_set.is_saved_search?
        ["search:all"] + SavedSearch.labels_for(CurrentUser.user.id).map {|x| "search:#{x}"}
      elsif post_set.is_empty_tag? || post_set.tag_string == "order:rank"
        popular_tags
      elsif post_set.is_single_tag?
        related_tags_for_single(post_set.tag_string)
      elsif post_set.unordered_tag_array.size == 1
        related_tags_for_single(post_set.unordered_tag_array.first)
      elsif Tag.has_metatag?(post_set.tag_array, *Tag::SUBQUERY_METATAGS)
        calculate_related_tags_from_post_set
      else
        calculate_related_tags_from_post_set
      end
    end

    def popular_tags
      if PopularSearchService.enabled?
        PopularSearchService.new(Date.today).tags.slice(0, 25)
      else
        Tag.trending
      end
    end

    def pattern_tags
      Tag.name_matches(post_set.tag_string).select("name").limit(Danbooru.config.tag_query_limit).order("post_count DESC").map(&:name)
    end

    def related_tags_for_group
      normalized_tags = Tag.normalize_query(post_set.tag_string, normalize_aliases: false)
      Cache.get("PostSetPresenters::Post#related_tags_for_group(#{normalized_tags})", 5.minutes) do
        RelatedTagCalculator.calculate_from_sample_to_array(normalized_tags).map(&:first)
      end
    end

    def related_tags_for_single(tag_string)
      tag = Tag.find_by_name(tag_string.downcase)

      if tag
        tag.related_tag_array.map(&:first)
      else
        calculate_related_tags_from_post_set
      end
    end

    def calculate_related_tags_from_post_set
      RelatedTagCalculator.calculate_from_posts_to_array(post_set.posts).map(&:first)
    end

    def saved_search_labels
      SavedSearch.labels_for(CurrentUser.user.id).map {|x| "search:#{x}"}
    end

    def tag_list_html(**options)
      tag_set_presenter.tag_list_html(name_only: post_set.is_saved_search?, **options)
    end
  end
end
