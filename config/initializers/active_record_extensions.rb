module Danbooru
  module Extensions
    module ActiveRecord
      %w(execute select_value select_values select_all).each do |method_name|
        define_method("#{method_name}_sql") do |sql, *params|
          connection.__send__(method_name, self.class.sanitize_sql_array([sql, *params]))
        end

        self.class.__send__(:define_method, "#{method_name}_sql") do |sql, *params|
          connection.__send__(method_name, sanitize_sql_array([sql, *params]))
        end
      end
      
      def arbitrary_sql_order_clause(ids, table_name = nil)
        table_name = self.class.table_name if table_name.nil?
        
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
end

class ActiveRecord::Base
  class << self    
    public :sanitize_sql_array
  end

  include Danbooru::Extensions::ActiveRecord
end
