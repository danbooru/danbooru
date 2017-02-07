module Danbooru
  module Extensions
    module ActiveRecord
      extend ActiveSupport::Concern

      module ClassMethods
        def without_timeout
          connection.execute("SET STATEMENT_TIMEOUT = 0") unless Rails.env == "test"
          yield
        ensure
          connection.execute("SET STATEMENT_TIMEOUT = #{CurrentUser.user.try(:statement_timeout) || 3_000}") unless Rails.env == "test"
        end

        def with_timeout(n, default_value = nil, new_relic_params = {})
          connection.execute("SET STATEMENT_TIMEOUT = #{n}") unless Rails.env == "test"
          yield
        rescue ::ActiveRecord::StatementInvalid => x
          if Rails.env.production?
            NewRelic::Agent.notice_error(x, :custom_params => new_relic_params.merge(:user_id => CurrentUser.user.id, :user_ip_addr => CurrentUser.ip_addr))
          end
          return default_value
        ensure
          connection.execute("SET STATEMENT_TIMEOUT = #{CurrentUser.user.try(:statement_timeout) || 3_000}") unless Rails.env == "test"
        end
      end

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
