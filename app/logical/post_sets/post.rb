# A PostSet is a set of posts returned by a search.  This contains helper
# methods used on the post index page.
#
# @see PostsController#index
module PostSets
  class Post
    MAX_PER_PAGE = 200
    MAX_SIDEBAR_TAGS = 25

    attr_reader :page, :post_count, :format, :tag_string, :query, :normalized_query

    def initialize(tags, page = 1, per_page = nil, user: CurrentUser.user, format: "html")
      @query = PostQueryBuilder.new(tags, user, tag_limit: user.tag_query_limit, safe_mode: CurrentUser.safe_mode?, hide_deleted_posts: user.hide_deleted_posts?)
      @normalized_query = query.normalized_query
      @tag_string = tags
      @page = page
      @per_page = per_page
      @format = format.to_s
    end

    def humanized_tag_string
      query.split_query.map { |tag| tag.tr("_", " ").titleize }.to_sentence
    end

    def has_blank_wiki?
      tag.present? && wiki_page.nil?
    end

    def wiki_page
      return nil unless normalized_query.has_single_tag?
      @wiki_page ||= WikiPage.undeleted.find_by(title: normalized_query.tags.first.name)
    end

    def tag
      return nil unless normalized_query.has_single_tag?
      @tag ||= Tag.find_by(name: normalized_query.tags.first.name)
    end

    def artist
      return nil unless tag.present? && tag.artist?
      return nil unless tag.artist.present? && !tag.artist.is_deleted?
      tag.artist
    end

    def pool
      pool_names = normalized_query.select_metatags(:pool, :ordpool).map(&:value)
      name = pool_names.first
      return nil unless pool_names.size == 1

      @pool ||= Pool.find_by_name(name)
    end

    def favgroup
      favgroup_names = normalized_query.select_metatags(:favgroup, :ordfavgroup).map(&:value)
      name = favgroup_names.first
      return nil unless favgroup_names.size == 1

      @favgroup ||= FavoriteGroup.visible(CurrentUser.user).find_by_name_or_id(name, CurrentUser.user)
    end

    def has_explicit?
      posts.any? {|x| x.rating == "e"}
    end

    def shown_posts
      shown_posts = posts.select(&:visible?)
      shown_posts = shown_posts.reject(&:is_deleted?) unless show_deleted?
      shown_posts
    end

    def hidden_posts
      posts.reject(&:visible?)
    end

    def banned_posts
      posts.select(&:banblocked?)
    end

    def censored_posts
      posts.select { |p| p.levelblocked? && !p.banblocked? }
    end

    def safe_posts
      posts.select { |p| p.safeblocked? && !p.levelblocked? && !p.banblocked? }
    end

    def per_page
      (@per_page || query.find_metatag(:limit) || CurrentUser.user.per_page).to_i.clamp(0, max_per_page)
    end

    def max_per_page
      (format == "sitemap") ? 10_000 : MAX_PER_PAGE
    end

    def is_random?
      query.find_metatag(:order) == "random"
    end

    def get_post_count
      if %w[json atom xml].include?(format.downcase)
        # no need to get counts for formats that don't use a paginator
        nil
      else
        normalized_query.fast_count
      end
    end

    def get_random_posts
      ::Post.user_tag_match(tag_string).random(per_page)
    end

    def posts
      @posts ||= begin
        @post_count = get_post_count

        if is_random?
          get_random_posts.paginate(page, search_count: false, limit: per_page, max_limit: max_per_page).load
        else
          normalized_query.build.paginate(page, count: post_count, search_count: !post_count.nil?, limit: per_page, max_limit: max_per_page).load
        end
      end
    end

    def hide_from_crawler?
      return true if current_page > 50
      return true if artist.present? && artist.is_banned?
      return false if query.is_empty_search? || query.is_simple_tag? || query.is_metatag?(:order, :rank)
      true
    end

    def current_page
      [page.to_i, 1].max
    end

    def best_post
      # be smarter about this in the future
      posts.reject(&:is_deleted).select(&:visible?).max_by(&:fav_count)
    end

    def pending_bulk_update_requests
      return BulkUpdateRequest.none unless tag.present?
      @pending_bulk_update_requests ||= BulkUpdateRequest.pending.where_array_includes_any(:tags, tag.name)
    end

    def show_deleted?
      query.select_metatags("status").any? do |metatag|
        metatag.value.in?(%w[all any active unmoderated modqueue deleted appealed])
      end
    end

    def search_stats
      {
        query: normalized_query.to_s,
        count: post_count,
        page: current_page,
        limit: per_page,
        term_count: normalized_query.terms.count,
        tag_count: normalized_query.tags.count,
        metatag_count: normalized_query.metatags.count,
        censored_posts: censored_posts.count,
        hidden_posts: hidden_posts.count,
      }
    end

    def log!
      DanbooruLogger.add_attributes("search", search_stats)
    end

    concerning :TagListMethods do
      def related_tags
        if query.is_wildcard_search?
          wildcard_tags
        elsif query.is_metatag?(:search)
          saved_search_tags
        elsif query.is_empty_search? || query.is_metatag?(:order, :rank)
          popular_tags.presence || frequent_tags
        elsif query.is_single_term?
          similar_tags.presence || frequent_tags
        else
          frequent_tags
        end
      end

      def popular_tags
        ReportbooruService.new.popular_searches(Date.today, limit: MAX_SIDEBAR_TAGS)
      end

      def similar_tags
        RelatedTagCalculator.cached_similar_tags_for_search(query.normalized_query(implicit: false), MAX_SIDEBAR_TAGS)
      end

      def frequent_tags
        RelatedTagCalculator.frequent_tags_for_post_array(posts).take(MAX_SIDEBAR_TAGS)
      end

      # Wildcard searches can show up to 100 tags in the sidebar, not 25,
      # because that's how many tags the search itself will use.
      def wildcard_tags
        Tag.wildcard_matches(tag_string).limit(PostQueryBuilder::MAX_WILDCARD_TAGS).pluck(:name)
      end

      def saved_search_tags
        searches = ["search:all"] + SavedSearch.labels_for(CurrentUser.user.id).map {|x| "search:#{x}"}
        searches.take(MAX_SIDEBAR_TAGS)
      end
    end
  end
end
