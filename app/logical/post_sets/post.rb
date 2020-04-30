module PostSets
  class Post
    MAX_PER_PAGE = 200
    attr_reader :page, :random, :post_count, :format, :tag_string, :query

    def initialize(tags, page = 1, per_page = nil, random: false, format: "html")
      @query = PostQueryBuilder.new(tags)
      @tag_string = tags
      @page = page
      @per_page = per_page
      @random = random.to_s.truthy?
      @format = format.to_s
    end

    def humanized_tag_string
      query.split_query.map { |tag| tag.tr("_", " ").titleize }.to_sentence
    end

    def has_blank_wiki?
      tag.present? && !wiki_page.present?
    end

    def wiki_page
      return nil unless tag.present? && tag.wiki_page.present?
      return nil unless !tag.wiki_page.is_deleted?
      tag.wiki_page
    end

    def tag
      return nil unless query.has_single_tag?
      @tag ||= Tag.find_by(name: query.tags.first.name)
    end

    def artist
      return nil unless tag.present? && tag.category == Tag.categories.artist
      return nil unless tag.artist.present? && !tag.artist.is_deleted?
      tag.artist
    end

    def pool
      pool_names = query.select_metatags(:pool, :ordpool).map(&:value)
      name = pool_names.first
      return nil unless pool_names.size == 1

      @pool ||= Pool.find_by_name(name)
    end

    def favgroup
      favgroup_names = query.select_metatags(:favgroup, :ordfavgroup).map(&:value)
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
      (@per_page || query.find_metatag(:limit) || CurrentUser.user.per_page).to_i.clamp(0, MAX_PER_PAGE)
    end

    def is_random?
      random || query.find_metatag(:order) == "random"
    end

    def get_post_count
      if %w(json atom xml).include?(format.downcase)
        # no need to get counts for formats that don't use a paginator
        return Danbooru.config.blank_tag_search_fast_count
      else
        ::Post.fast_count(tag_string)
      end
    end

    def get_random_posts
      per_page.times.inject([]) do |all, x|
        all << ::Post.tag_match(tag_string).random
      end.compact.uniq
    end

    def posts
      @posts ||= begin
        @post_count = get_post_count

        if is_random?
          temp = get_random_posts
        else
          temp = ::Post.tag_match(tag_string).where("true /* PostSets::Post#posts:2 */").paginate(page, :count => post_count, :limit => per_page)
        end
      end
    end

    def unknown_post_count?
      post_count == Danbooru.config.blank_tag_search_fast_count
    end

    def hide_from_crawler?
      return true if current_page > 1
      return false if query.is_empty_search? || query.is_simple_tag? || query.is_metatag?(:order, :rank)
      true
    end

    def current_page
      [page.to_i, 1].max
    end

    def presenter
      @presenter ||= ::PostSetPresenters::Post.new(self)
    end

    def best_post
      # be smarter about this in the future
      posts.reject(&:is_deleted).select(&:visible?).max_by(&:fav_count)
    end

    def pending_bulk_update_requests
      return BulkUpdateRequest.none unless query.is_simple_tag?
      @pending_bulk_update_requests ||= BulkUpdateRequest.pending.where_array_includes_any(:tags, query.tags.first.name)
    end
  end
end
