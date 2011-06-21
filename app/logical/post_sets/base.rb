module PostSets
  class Base
    def has_wiki?
      false
    end
    
    def wiki_page
      nil
    end
    
    def presenter
      @presenter ||= PostSetPresenter.new(self)
    end
    
    def is_single_tag?
      false
    end
    
    def tag
      tag_string
    end
    
    def arbitrary_sql_order_clause(ids, table_name)
      if ids.empty?
        return "#{table_name}.id desc"
      end
      
      conditions = []
      
      ids.each_with_index do |x, n|
        conditions << "when #{x} then #{n}"
      end
      
      "case #{table_name}.id " + conditions.join(" ") + " end"
    end
  end
end
