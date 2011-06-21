module PostSets
  class Post < Base
    attr_reader :tags, :page, :posts
    
    def initialize(params)
      @tags = Tag.scan_query(params[:tags])
      @page = [params[:page].to_i, 1].max
      @posts = ::Post.tag_match(tag_string).paginate(page)
    end
    
    def tag_string
      @tag_string ||= tags.join(" ")
    end
    
    def has_wiki?
      if tags.any?
        ::WikiPage.titled(tag_string).exists?
      else
        false
      end
    end
    
    def wiki_page
      if tags.any?
        ::WikiPage.titled(tag_string).first
      else
        nil
      end
    end
    
    def is_single_tag?
      tags.size == 1
    end
  end
end
