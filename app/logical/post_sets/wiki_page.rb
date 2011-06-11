module PostSets
  module WikiPage
    def wiki_page
      @wiki_page ||= begin
        if params[:id]
          ::WikiPage.find(params[:id])
        elsif params[:tags]
          ::WikiPage.titled(params[:tags]).first
        end
      end
    end
    
    def has_wiki?
      true
    end
    
    def tags
      @tags ||= ::Tag.scan_query(wiki_page.title)
    end
    
    def posts
      @posts ||= slice(::Post.tag_match(tag_string))
    end
    
    def count
      @count ||= ::Post.fast_count(tag_string)
    end
  end  
end
