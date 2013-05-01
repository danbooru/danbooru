module PostSets
  class PostRelationship < PostSets::Post
    attr_reader :parent, :children

    def initialize(parent_id, options = {})
      @parent = ::Post.where("id = ?", parent_id)
      @children = ::Post.where("parent_id = ?", parent_id).order("id ASC")
      if options[:include_deleted]
        super("parent:#{parent_id} status:any")
      else
        @children = @children.where("is_deleted = ?", false)
        super("parent:#{parent_id}")
      end
    end

    def posts
      @parent + @children
    end

    def presenter
      ::PostSetPresenters::Post.new(self)
    end
  end
end
