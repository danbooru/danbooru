# This only works with the numbered paginator because of the way
# the association is stored.
module PostSets
  module Pool
    def pool
      @pool ||= Pool.find(params[:id])
    end
    
    def tags
      ["pool:#{pool.name}"]
    end
    
    def has_wiki?
      true
    end
    
    def count
      pool.post_count
    end

    def posts
      @posts ||= pool.posts(pagination_options)
    end
    
    def reload
      super
      @pool = nil
    end
  end  
end
