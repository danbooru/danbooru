class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Danbooru::Paginator::ActiveRecordExtension

  concerning :SearchMethods do
    class_methods do
      def qualified_column_for(attr)
        "#{table_name}.#{column_for_attribute(attr).name}"
      end

      def where_like(attr, value)
        where("#{qualified_column_for(attr)} LIKE ? ESCAPE E'\\\\'", value.to_escaped_for_sql_like)
      end

      def where_not_like(attr, value)
        where.not("#{qualified_column_for(attr)} LIKE ? ESCAPE E'\\\\'", value.to_escaped_for_sql_like)
      end

      def where_ilike(attr, value)
        where("lower(#{qualified_column_for(attr)}) LIKE ? ESCAPE E'\\\\'", value.mb_chars.downcase.to_escaped_for_sql_like)
      end

      def where_not_ilike(attr, value)
        where.not("lower(#{qualified_column_for(attr)}) LIKE ? ESCAPE E'\\\\'", value.mb_chars.downcase.to_escaped_for_sql_like)
      end

      # https://www.postgresql.org/docs/current/static/functions-matching.html#FUNCTIONS-POSIX-REGEXP
      # "(?e)" means force use of ERE syntax; see sections 9.7.3.1 and 9.7.3.4.
      def where_regex(attr, value)
        where("#{qualified_column_for(attr)} ~ ?", "(?e)" + value)
      end

      def where_not_regex(attr, value)
        where.not("#{qualified_column_for(attr)} ~ ?", "(?e)" + value)
      end

      def attribute_matches(attribute, value, **options)
        return all if value.nil?

        column = column_for_attribute(attribute)
        case column.sql_type_metadata.type
        when :boolean
          boolean_attribute_matches(attribute, value, **options)
        when :integer, :datetime
          numeric_attribute_matches(attribute, value, **options)
        when :string, :text
          text_attribute_matches(attribute, value, **options)
        else
          raise ArgumentError, "unhandled attribute type"
        end
      end

      def boolean_attribute_matches(attribute, value)
        if value.to_s.truthy?
          value = true
        elsif value.to_s.falsy?
          value = false
        else
          raise ArgumentError, "value must be truthy or falsy"
        end

        where(attribute => value)
      end

      # range: "5", ">5", "<5", ">=5", "<=5", "5..10", "5,6,7"
      def numeric_attribute_matches(attribute, range)
        column = column_for_attribute(attribute)
        qualified_column = "#{table_name}.#{column.name}"
        parsed_range = Tag.parse_helper(range, column.type)

        PostQueryBuilder.new(nil).add_range_relation(parsed_range, qualified_column, self)
      end

      def text_attribute_matches(attribute, value, index_column: nil, ts_config: "english")
        column = column_for_attribute(attribute)
        qualified_column = "#{table_name}.#{column.name}"

        if value =~ /\*/
          where("lower(#{qualified_column}) LIKE :value ESCAPE E'\\\\'", value: value.mb_chars.downcase.to_escaped_for_sql_like)
        elsif index_column.present?
          where("#{table_name}.#{index_column} @@ plainto_tsquery(:ts_config, :value)", ts_config: ts_config, value: value)
        else
          where("to_tsvector(:ts_config, #{qualified_column}) @@ plainto_tsquery(:ts_config, :value)", ts_config: ts_config, value: value)
        end
      end

      def search_text_attribute(attr, params, **options)
        if params[attr].present?
          where(attr => params[attr])
        elsif params[:"#{attr}_eq"].present?
          where(attr => params[:"#{attr}_eq"])
        elsif params[:"#{attr}_not_eq"].present?
          where.not(attr => params[:"#{attr}_not_eq"])
        elsif params[:"#{attr}_like"].present?
          where_like(attr, params[:"#{attr}_like"])
        elsif params[:"#{attr}_ilike"].present?
          where_ilike(attr, params[:"#{attr}_ilike"])
        elsif params[:"#{attr}_not_like"].present?
          where_not_like(attr, params[:"#{attr}_not_like"])
        elsif params[:"#{attr}_not_ilike"].present?
          where_not_ilike(attr, params[:"#{attr}_not_ilike"])
        elsif params[:"#{attr}_regex"].present?
          where_regex(attr, params[:"#{attr}_regex"])
        elsif params[:"#{attr}_not_regex"].present?
          where_not_regex(attr, params[:"#{attr}_not_regex"])
        else
          all
        end
      end

      def apply_default_order(params)
        if params[:order] == "custom"
          parse_ids = Tag.parse_helper(params[:id])
          if parse_ids[0] == :in
            return find_ordered(parse_ids[1])
          end
        end
        return default_order
      end

      def default_order
        order(id: :desc)
      end

      def find_ordered(ids)
        order_clause = []
        ids.each do |id|
          order_clause << sanitize_sql_array(["ID=? DESC", id])
        end
        where(id: ids).order(Arel.sql(order_clause.join(', ')))
      end

      def search(params = {})
        params ||= {}

        q = all
        q = q.attribute_matches(:id, params[:id])
        q = q.attribute_matches(:created_at, params[:created_at]) if attribute_names.include?("created_at")
        q = q.attribute_matches(:updated_at, params[:updated_at]) if attribute_names.include?("updated_at")

        q
      end
    end
  end

  module ApiMethods
    extend ActiveSupport::Concern

    def as_json(options = {})
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes

      options[:methods] ||= []
      options[:methods] += method_attributes

      super(options)
    end

    def to_xml(options = {}, &block)
      options ||= {}

      options[:except] ||= []
      options[:except] += hidden_attributes

      options[:methods] ||= []
      options[:methods] += method_attributes

      super(options, &block)
    end

    def serializable_hash(*args)
      hash = super(*args)
      hash.transform_keys { |key| key.delete("?") }
    end

    protected

    def hidden_attributes
      [:uploader_ip_addr, :updater_ip_addr, :creator_ip_addr, :ip_addr]
    end

    def method_attributes
      []
    end
  end

  concerning :ActiveRecordExtensions do
    class_methods do
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
          NewRelic::Agent.notice_error(x, :custom_params => new_relic_params.merge(:user_id => CurrentUser.id, :user_ip_addr => CurrentUser.ip_addr))
        end
        return default_value
      ensure
        connection.execute("SET STATEMENT_TIMEOUT = #{CurrentUser.user.try(:statement_timeout) || 3_000}") unless Rails.env == "test"
      end
    end

    %w(execute select_value select_values select_all).each do |method_name|
      define_method("#{method_name}_sql") do |sql, *params|
        self.class.connection.__send__(method_name, self.class.send(:sanitize_sql_array, [sql, *params]))
      end

      self.class.__send__(:define_method, "#{method_name}_sql") do |sql, *params|
        connection.__send__(method_name, send(:sanitize_sql_array, [sql, *params]))
      end
    end
  end

  concerning :PostgresExtensions do
    class_methods do
      def columns(*params)
        super.reject {|x| x.sql_type == "tsvector"}
      end

      def test_connection
        limit(1).select(:id)
        return true
      rescue PG::Error
        return false
      end
    end
  end

  concerning :UserMethods do
    class_methods do
      def belongs_to_creator(options = {})
        class_eval do
          belongs_to :creator, options.merge(class_name: "User")
          before_validation(on: :create) do |rec| 
            if rec.creator_id.nil?
              rec.creator_id = CurrentUser.id
              rec.creator_ip_addr = CurrentUser.ip_addr if rec.respond_to?(:creator_ip_addr=)
              rec.ip_addr = CurrentUser.ip_addr if rec.respond_to?(:ip_addr=)
            end
          end

          define_method :creator_name do
            User.id_to_name(creator_id)
          end
        end
      end

      def belongs_to_updater(options = {})
        class_eval do
          belongs_to :updater, options.merge(class_name: "User")
          before_validation do |rec|
            rec.updater_id = CurrentUser.id
            rec.updater_ip_addr = CurrentUser.ip_addr if rec.respond_to?(:updater_ip_addr=)
          end

          define_method :updater_name do
            User.id_to_name(updater_id)
          end
        end
      end
    end
  end

  concerning :AttributeMethods do
    class_methods do
      # Defines `<attribute>_string`, `<attribute>_string=`, and `<attribute>=`
      # methods for converting an array attribute to or from a string.
      #
      # The `<attribute>=` setter parses strings into an array using the
      # `parse` regex. The resulting strings can be converted to another type
      # with the `cast` option.
      def array_attribute(name, parse: /[^[:space:]]+/, cast: :itself)
        define_method "#{name}_string" do
          send(name).join(" ")
        end

        define_method "#{name}_string=" do |value|
          raise ArgumentError, "#{name} must be a String" unless value.respond_to?(:to_str)
          send("#{name}=", value)
        end

        define_method "#{name}=" do |value|
          if value.respond_to?(:to_str)
            super value.to_str.scan(parse).map(&cast)
          elsif value.respond_to?(:to_a)
            super value.to_a
          else
            raise ArgumentError, "#{name} must be a String or an Array"
          end
        end
      end
    end
  end

  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end

  include ApiMethods
end
