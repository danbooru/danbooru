module PostSets
  class Pool < Base
    attr_reader :pool, :page, :posts
    
    def initailize(pool, page)
      @pool = pool
      @page = page
      @posts = pool.posts(:offset => offset, :limit => limit)
    end
    
    def offset
      ([page.to_i, 1].max - 1) * limit
    end
    
    def limit
      Danbooru.config.posts_per_page
    end
    
    def tag_array
      ["pool:#{pool.id}"]
    end
    
    def tag_string
      tag_array.join("")
    end
    
    def presenter
      @presenter ||= PostSetPresenters::Pool.new(self)
    end
  end
end
