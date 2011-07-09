module PostSets
  class Pool < Base
    module ActiveRecordExtension
      attr_accessor :total_pages, :current_page
    end
    
    attr_reader :pool, :page, :posts
    
    def initialize(pool, page)
      @pool = pool
      @page = page
      @posts = pool.posts(:offset => offset, :limit => limit)
      @posts.extend(ActiveRecordExtension)
      @posts.total_pages = total_pages
      @posts.current_page = current_page
    end
    
    def offset
      (current_page - 1) * limit
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
    
    def total_pages
      (pool.post_count.to_f / limit).ceil
    end
    
    def current_page
      [page.to_i, 1].max
    end
  end
end
