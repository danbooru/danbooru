module PostSets
  class WikiPage < Base
    attr_reader :tag_name
    
    def initialize(tag_name)
      @tag_name = tag_name
    end
    
    def load_posts
      @posts = ::Post.tag_match(tag_name).all(:order => "posts.id desc", :limit => limit, :offset => offset)
    end
    
    def limit
      8
    end
    
    def offset
      0
    end

    def use_sequential_paginator?
      false
    end
  
    def use_numbered_paginator?
      false
    end
  end  
end
