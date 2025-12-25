# frozen_string_literal: true

# A PostSet is a set of posts returned by a search.  This contains helper
# methods used on the post index page.
#
# @see PostsController#index
module PostSets
  class Post
    extend Memoist

    MAX_PER_PAGE = 200
    MAX_SIDEBAR_TAGS = 25
    MAX_WILDCARD_TAGS = PostQueryBuilder::MAX_WILDCARD_TAGS

    attr_reader :current_user, :page, :format, :tag_string, :post_query, :normalized_query, :show_votes
    delegate :tag, to: :post_query
    alias_method :show_votes?, :show_votes

    def initialize(tags, page = 1, per_page = nil, user: CurrentUser.user, format: "html", show_votes: false)
      @current_user = user
      @post_query = PostQuery.normalize(tags, current_user: user, tag_limit: user.tag_query_limit, safe_mode: CurrentUser.safe_mode?)
      @normalized_query = post_query.with_implicit_metatags
      @tag_string = tags
      @page = page
      @per_page = per_page
      @format = format.to_s
      @show_votes = show_votes
    end

    # The title of the page for the <title> tag.
    def page_title
      post_query.to_pretty_string
    end

    # The description of the page for the <meta name="description"> tag.
    def meta_description
      # XXX post_count may be nil if the search times out because of safe mode
      if post_query.is_simple_tag? && post_count.present?
        humanized_count = ApplicationController.helpers.humanized_number(post_count, million: " million", thousand: " thousand")
        humanized_count = "over #{humanized_count}" if post_count >= 1_000

        "See #{humanized_count} #{page_title} images on #{Danbooru.config.app_name}. #{DText.new(wiki_page&.body).excerpt}"
      else
        Danbooru.config.site_description
      end
    end

    def has_blank_wiki?
      tag.present? && wiki_page.nil?
    end

    def wiki_page
      return nil unless post_query.has_single_tag?
      @wiki_page ||= WikiPage.undeleted.find_by(title: post_query.tag_name)
    end

    def artist
      return nil unless tag.present? && tag.artist?
      return nil unless tag.artist.present? && !tag.artist.is_deleted?
      tag.artist
    end

    def pool
      pool_names = post_query.select_metatags(:pool, :ordpool).map(&:value)
      name = pool_names.first
      return nil unless pool_names.size == 1

      @pool ||= Pool.find_by_name(name)
    end

    def favgroup
      favgroup_names = post_query.select_metatags(:favgroup, :ordfavgroup).map(&:value)
      name = favgroup_names.first
      return nil unless favgroup_names.size == 1

      @favgroup ||= FavoriteGroup.visible(CurrentUser.user).find_by_name_or_id(name, CurrentUser.user)
    end

    def has_explicit?
      posts.any? {|x| x.rating == "e"}
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
      (@per_page || post_query.find_metatag(:limit) || CurrentUser.user.per_page).to_i.clamp(0, max_per_page)
    end

    def max_per_page
      (format.to_sym == :sitemap) ? 10_000 : MAX_PER_PAGE
    end

    def posts
      post_query.validate_tag_limit!
      normalized_query.paginated_posts(page, includes: includes, count: post_count, search_count: !post_count.nil?, limit: per_page, max_limit: max_per_page).load
    end

    # @return [Integer, nil] The number of posts returned by the search, or nil if unknown.
    def post_count
      return 0 if artist.present? && artist.is_banned? && !current_user.is_approver?
      normalized_query.post_count
    end

    def hide_from_crawler?
      return true if current_page > 50
      return true if show_votes?
      return true if artist.present? && artist.is_banned?
      return false if post_query.is_empty_search? || post_query.is_simple_tag? || post_query.is_metatag?(:order, :rank)
      true
    end

    def current_page
      [page.to_i, 1].max
    end

    def best_post
      posts.reject(&:is_deleted).select(&:visible?).max_by { |post| [-post.rating_id, post.score] }
    end

    def show_deleted?
      current_user.show_deleted_posts? || has_status_metatag?
    end

    def has_status_metatag?
      post_query.select_metatags("is", "status").any? do |metatag|
        metatag.value.downcase.in?(%w[all any active unmoderated modqueue deleted appealed])
      end
    end

    def banned_artist?
      artist.present? && artist.is_banned? && !current_user.is_approver?
    end

    def includes
      if show_votes?
        [:media_asset, :vote_by_current_user]
      else
        [:media_asset]
      end
    end

    concerning :TagListMethods do
      # @return [Array<Tag>] The list of tags for the sidebar on the post index page.
      def sidebar_tags
        if artist.present? && artist.is_banned? && !current_user.is_approver?
          []
        elsif normalized_query.wildcards.one? && normalized_query.tags.none?
          wildcard_tags
        elsif normalized_query.is_metatag?(:search)
          saved_search_tags
        elsif normalized_query.is_empty_search? || normalized_query.is_metatag?(:order, :rank)
          tags = popular_tags.presence || frequent_tags
          tags.sort_by.with_index { |tag, i| [TagCategory.category_ids.index(tag.category), i] }
        elsif normalized_query.is_simple_tag? && tag.present?
          categories = TagCategory.search_sidebar_tag_categories[tag.category]
          tags = similar_tags(categories).presence || frequent_tags(categories)
          tags = [tag] + tags if !tag.in?(tags)
          sort_sidebar_tags(tags, categories)
        elsif normalized_query.is_single_term?
          sort_sidebar_tags(similar_tags.presence || frequent_tags)
        else
          sort_sidebar_tags(frequent_tags)
        end
      end

      # Sort the list of tags by category. For artist, character, and copyright tags, subsort them by post count. For
      # general and meta tags, leave them in the same order they were given in (similarity or frequency order).
      #
      # @param tags [Array<Tag>] the list of tags to sort
      # @param categories [Array<Integer>] the category order in which tags should be sorted by
      def sort_sidebar_tags(tags, categories = TagCategory.category_ids)
        tags.sort_by.with_index do |tag, i|
          [categories.index(tag.category) || -1, (tag.category == TagCategory::GENERAL || tag.category == TagCategory::META ? i : -tag.post_count)]
        end
      end

      # @return [Array<Tag>] the list of most frequently searched tags for the day.
      def popular_tags
        tag_names = ReportbooruService.new.popular_searches(Date.today, limit: MAX_SIDEBAR_TAGS)
        Tag.where(name: tag_names).to_a.in_order_of(:name, tag_names)
      end

      # @return [Array<Tag>] the list of tags most related to the current search.
      def similar_tags(categories = TagCategory.category_ids)
        RelatedTagCalculator.new(post_query).cached_similar_tags_for_search(MAX_SIDEBAR_TAGS, categories: categories)
      end

      # @return [Array<Tag>] the list of tags most frequently appearing in the current page of search results.
      def frequent_tags(categories = TagCategory.category_ids)
        RelatedTagCalculator.frequent_tags_for_post_array(posts, categories: categories, max_tags: MAX_SIDEBAR_TAGS)
      end

      # Wildcard searches can show up to 100 tags in the sidebar, not 25,
      # because that's how many tags the search itself will use.
      def wildcard_tags
        Tag.wildcard_matches(post_query.wildcards.first).limit(MAX_WILDCARD_TAGS).to_a
      end

      def saved_search_tags
        searches = ["search:all"] + SavedSearch.labels_for(CurrentUser.user.id).map {|x| "search:#{x}"}
        searches.take(MAX_SIDEBAR_TAGS).map do |search|
          Tag.new(name: search).freeze
        end
      end
    end

    memoize :page_title, :posts
  end
end
