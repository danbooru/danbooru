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
    end

    module String
      def to_escaped_for_sql_like
        return self.gsub(/\\/, '\0\0').gsub(/%/, '\\%').gsub(/_/, '\\_').gsub(/\*/, '%')
      end

      def to_escaped_js
        return self.gsub(/\\/, '\0\0').gsub(/['"]/) {|m| "\\#{m}"}.gsub(/\r\n|\r|\n/, '\\n')
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

class String
  include Danbooru::Extensions::String
end
