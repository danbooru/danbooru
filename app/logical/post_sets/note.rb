module PostSets
  class Note < Post
    def initialize(params)
      # don't call super because we don't want to repeat these queries
      @tag_array = Tag.scan_query(params[:tags])
      @page = params[:page] || 1
      @posts = ::Post.tag_match(tag_string).has_notes.paginate(page).reorder("last_noted_at desc")
    end
  end
end
