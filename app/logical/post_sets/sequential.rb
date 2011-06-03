module PostSets
  module Sequential
    attr_reader :before_id, :after_id
    
    def initialize(params)
      super
      @before_id = params[:before_id]
      @after_id = params[:after_id]
    end
    
    def slice(relation)
      if before_id
        relation.where("id < ?", before_id).all
      elsif after_id
        relation.where("id > ?", after_id).order("id asc").all.reverse
      else
        relation.all
      end
    end
    
    def pagination_options
      {:before_id => before_id, :after_id => after_id}
    end
    
    def is_first_page?
      before_id.nil?
    end
  end
end
