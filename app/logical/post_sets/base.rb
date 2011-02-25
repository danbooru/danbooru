module PostSets
  class Base
    attr_accessor :page, :before_id, :count, :posts
  
    def initialize(options = {})
      @page = options[:page] ? options[:page].to_i : 1
      @before_id = options[:before_id]
      load_posts
    end
    
    def has_wiki?
      false
    end
  
    def use_sequential_paginator?
      !use_numbered_paginator?
    end
  
    def use_numbered_paginator?
      before_id.nil?
    end
  
    def load_posts
      raise NotImplementedError
    end
  
    def to_xml
      posts.to_xml
    end
  
    def to_json
      posts.to_json
    end
  
    def presenter
      @presenter ||= PostSetPresenter.new(self)
    end
    
    def offset
      ((page < 1) ? 0 : (page - 1)) * count
    end

    def limit
      Danbooru.config.posts_per_page
    end
  end
end
