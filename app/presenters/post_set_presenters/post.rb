module PostSetPresenters
  class Post < Base
    attr_accessor :post_set, :tag_set_presenter
    delegate :posts, :to => :post_set

    def initialize(post_set)
      @post_set = post_set
      @tag_set_presenter = TagSetPresenter.new(related_tags)
    end

    def related_tags
      if post_set.is_pattern_search?
        pattern_tags
      elsif post_set.is_tag_subscription?
        post_set.tag_subscription_tags
      elsif post_set.is_single_tag?
        related_tags_for_single
      elsif post_set.is_empty_tag?
        popular_tags
      else
        related_tags_for_group
      end
    end

    def popular_tags
      n = 1
      results = []

      while results.empty? && n < 256
        query = n.days.ago.strftime("date:>%Y-%m-%d")
        results = RelatedTagCalculator.calculate_from_sample_to_array(query).map(&:first)
        n *= 2
      end

      results
    end

    def pattern_tags
      Tag.name_matches(post_set.tag_string).all(:select => "name", :limit => Danbooru.config.tag_query_limit, :order => "post_count DESC").map(&:name)
    end

    def related_tags_for_group
      RelatedTagCalculator.calculate_from_sample_to_array(post_set.tag_string).map(&:first)
    end

    def related_tags_for_single
      tag = Tag.find_by_name(post_set.tag_string.downcase)

      if tag
        tag.related_tag_array.map(&:first)
      else
        []
      end
    end

    def tag_list_html(template)
      tag_set_presenter.tag_list_html(template)
    end
  end
end
