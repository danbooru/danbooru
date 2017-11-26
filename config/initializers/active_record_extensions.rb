module Danbooru
  module Extensions
    module ActiveRecord
      extend ActiveSupport::Concern

      %w(execute select_value select_values select_all).each do |method_name|
        define_method("#{method_name}_sql") do |sql, *params|
          self.class.connection.__send__(method_name, self.class.sanitize_sql_array([sql, *params]))
        end

        self.class.__send__(:define_method, "#{method_name}_sql") do |sql, *params|
          connection.__send__(method_name, sanitize_sql_array([sql, *params]))
        end
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
