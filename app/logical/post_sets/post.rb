module PostSets
  class Post < Base
    attr_reader :tag_array, :page, :per_page
    
    def initialize(tags, page = 1, per_page = nil)
      @tag_array = Tag.scan_query(tags)
      @page = page
      @per_page = (per_page || Danbooru.config.posts_per_page).to_i
      @per_page = 200 if @per_page > 200
    end
    
    def tag_string
      @tag_string ||= tag_array.uniq.join(" ")
    end
    
    def humanized_tag_string
      tag_array.slice(0, 25).join(" ").tr("_", " ")
    end
    
    def has_wiki?
      tag_array.any? && ::WikiPage.titled(tag_string).exists?
    end

    def wiki_page
      if tag_array.any?
        ::WikiPage.titled(tag_string).first
      else
        nil
      end
    end
    
    def has_deleted?
      CurrentUser.is_privileged? && tag_string !~ /status/ && ::Post.tag_match("#{tag_string} status:deleted").exists?
    end
    
    def has_explicit?
      posts.any? {|x| x.rating == "e"}
    end
    
    def posts
      if tag_array.size > 2 && !CurrentUser.is_privileged?
        raise SearchError.new("Upgrade your account to search more than two tags at once")
      end

      timeout = 3000
      
      if tag_array.any? {|x| x =~ /^source:.*\*.*pixiv/}
        timeout = 300
      end
      
      @posts ||= begin
        temp = ::Post.with_timeout(500, nil) do
          ::Post.tag_match(tag_string).paginate(page, :count => ::Post.fast_count(tag_string), :limit => per_page)
        end
        
        if temp.nil?
          raise SearchError.new("Your search took too long to execute and was canceled")
        end

        temp.all
        temp
      end
    rescue ::Post::SearchError
      @posts = ::Post.where("false")
    end
    
    def has_artist?
      tag_array.any? && ::Artist.name_equals(tag_string).exists?
    end
    
    def artist
      ::Artist.name_matches(tag_string).first
    end
    
    def is_single_tag?
      tag_array.size == 1
    end
    
    def is_empty_tag?
      tag_array.size == 0
    end
    
    def is_pattern_search?
      tag_string =~ /\*/
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
