module PostSets
  class Pool < Base
    attr_reader :pool
    
    def initialize(pool, options = {})
      @pool = pool
      @count = pool.post_id_array.size
      super(options)
    end
    
    def tags
      "pool:#{pool.name}"
    end

    def load_posts
      @posts = pool.posts(:limit => limit, :offset => offset).order("posts.id")
    end
    
    def sorted_posts
      sort_posts(@posts)
    end
    
  private
    def sort_posts(posts)
      posts_by_id = posts.inject({}) do |hash, post|
        hash[post.id] = post
        hash
      end
      
      @pool.post_id_array.map {|x| posts_by_id[x]}
    end
  end  
end
