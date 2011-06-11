module PostSets
  module Post
    def tag_string
      @tag_string ||= params[:tags].to_s.downcase
    end
    
    def count
      @count ||= ::Post.fast_count(tag_string)
    end
    
    def posts
      @posts ||= slice(::Post.tag_match(tag_string))
    end

    def reload
      super
      @tag_array = nil
      @tag_string = nil
      @count = nil
      @wiki_page = nil
      @artist = nil
    end
    
    def wiki_page
      @wiki_page ||= ::WikiPage.titled(tag_string).first
    end
    
    def artist
      @artist ||= ::Artist.find_by_name(tag_string)
    end
    
    def has_wiki?
      is_single_tag?
    end
    
    def is_single_tag?
      tag_array.size == 1
    end
        
    def tag_array
      @tag_array ||= ::Tag.scan_query(tag_string)
    end
    
    def validate
      super
      validate_query_count
    end
    
    def validate_query_count
      if !CurrentUser.is_privileged? && tag_array.size > 2
        raise Error.new("You can only search up to two tags at once with a basic account")
      end
    
      if tag_array.size > 6
        raise Error.new("You can only search up to six tags at once")
      end
    end
  end
end
