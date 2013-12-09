module PostSets
  class Post < Base
    attr_reader :tag_array, :page, :per_page, :raw

    def initialize(tags, page = 1, per_page = nil, raw = false)
      @tag_array = Tag.scan_query(tags)
      @page = page
      @per_page = (per_page || CurrentUser.per_page).to_i
      @per_page = 200 if @per_page > 200
      @raw = raw.present?
    end

    def tag_string
      @tag_string ||= tag_array.uniq.join(" ")
    end

    def humanized_tag_string
      tag_array.slice(0, 25).join(" ").tr("_", " ")
    end

    def has_wiki?
      is_single_tag? && ::WikiPage.titled(tag_string).exists?
    end

    def wiki_page
      if is_single_tag?
        ::WikiPage.titled(tag_string).first
      else
        nil
      end
    end

    def has_artist?
      is_single_tag? && ::Artist.named(tag_string).active.exists?
    end

    def artist
      ::Artist.named(tag_string).active.first
    end

    def pool_name
      tag_string.match(/^pool:(\S+)$/i).try(:[], 1)
    end

    def has_pool?
      is_single_tag? && pool_name && pool
    end

    def pool
      ::Pool.find_by_name(pool_name)
    end

    def has_deleted?
      CurrentUser.is_gold? && tag_string !~ /status/ && ::Post.tag_match("#{tag_string} status:deleted").exists?
    end

    def has_explicit?
      posts.any? {|x| x.rating == "e"}
    end

    def posts
      if tag_array.any? {|x| x =~ /^source:.*\*.*pixiv/} && !CurrentUser.user.is_builder?
        raise SearchError.new("Your search took too long to execute and was canceled")
      end

      @posts ||= begin
        if raw
          temp = ::Post.raw_tag_match(tag_string).order("posts.id DESC").paginate(page, :count => ::Post.fast_count(tag_string), :limit => per_page)
        else
          temp = ::Post.tag_match(tag_string).paginate(page, :count => ::Post.fast_count(tag_string), :limit => per_page)
        end
        temp.all
        temp
      end
    end

    def is_single_tag?
      tag_array.size == 1
    end

    def is_empty_tag?
      tag_array.size == 0
    end

    def is_pattern_search?
      is_single_tag? && tag_string =~ /\*/
    end

    def current_page
      [page.to_i, 1].max
    end

    def is_tag_subscription?
      tag_subscription.present?
    end

    def tag_subscription
      @tag_subscription ||= tag_array.select {|x| x =~ /^sub:/}.map {|x| x.sub(/^sub:/, "")}.first
    end

    def tag_subscription_tags
      @tag_subscription_tags ||= TagSubscription.find_tags(tag_subscription)
    end

    def presenter
      @presenter ||= ::PostSetPresenters::Post.new(self)
    end
  end
end
