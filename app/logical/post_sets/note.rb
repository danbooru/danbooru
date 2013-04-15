module PostSets
  class Note < Post
    attr_reader :params
    
    def initialize(params)
      # don't call super because we don't want to repeat these queries
      @params = params
      @tag_array = Tag.scan_query(params[:tags])
      @page = params[:page] || 1
      @posts = ::Post.tag_match(tag_string).has_notes.paginate(page, :limit => limit).reorder("last_noted_at desc")
    end
    
    def limit
     [(params[:limit] || CurrentUser.user.per_page).to_i, 1_000].min
    end
  end
end
