module PostSets
  module Sequential
    def before_id
      params[:before_id]
    end
    
    def after_id
      params[:after_id]
    end
    
    def slice(relation)
      if before_id
        relation.where("id < ?", before_id).order("id desc").limit(limit).all
      elsif after_id
        relation.where("id > ?", after_id).order("id asc").limit(limit).all.reverse
      else
        relation.limit(limit).all
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
