class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Deletable
  include Mentionable
  include Normalizable
  include ArrayAttribute
  extend HasBitFlags
  extend Searchable

  concerning :PaginationMethods do
    class_methods do
      def paginate(*args, **options)
        extending(PaginationExtension).paginate(*args, **options)
      end

      def paginated_search(params, count_pages: params[:search].present?, **defaults)
        search_params = params.fetch(:search, {}).permit!
        search_params = defaults.merge(search_params).with_indifferent_access

        max_limit = (params[:format] == "sitemap") ? 10_000 : 1_000
        search(search_params).paginate(params[:page], limit: params[:limit], max_limit: max_limit, search_count: count_pages)
      end
    end
  end

  concerning :PrivilegeMethods do
    class_methods do
      def visible(user)
        all
      end
    end
  end

  concerning :ApiMethods do
    class_methods do
      def available_includes
        []
      end

      def multiple_includes
        reflections.reject { |k,v| v.macro != :has_many }.keys.map(&:to_sym)
      end

      def associated_models(name)
        if reflections[name].options[:polymorphic]
          associated_models = reflections[name].active_record.try(:model_types) || []
        else
          associated_models = [reflections[name].class_name]
        end
      end
    end

    def available_includes
      self.class.available_includes
    end

    # XXX deprecated, shouldn't expose this as an instance method.
    def api_attributes(user: CurrentUser.user)
      policy = Pundit.policy([user, nil], self) || ApplicationPolicy.new([user, nil], self)
      policy.api_attributes
    end

    # XXX deprecated, shouldn't expose this as an instance method.
    def html_data_attributes(user: CurrentUser.user)
      policy = Pundit.policy([user, nil], self) || ApplicationPolicy.new([user, nil], self)
      policy.html_data_attributes
    end

    def serializable_hash(options = {})
      options ||= {}
      if options[:only] && options[:only].is_a?(String)
        options.delete(:methods)
        options.delete(:include)
        options.merge!(ParameterBuilder.serial_parameters(options[:only], self))
      else
        options[:methods] ||= []
        attributes, methods = api_attributes.partition { |attr| has_attribute?(attr) }
        methods += options[:methods]
        options[:only] ||= attributes + methods

        attributes &= options[:only]
        methods &= options[:only]

        options[:only] = attributes
        options[:methods] = methods

        options.delete(:methods) if options[:methods].empty?
      end

      hash = super(options)
      hash.transform_keys { |key| key.delete("?") }
    end
  end

  concerning :SearchMethods do
    class_methods do
      def model_restriction(table)
        table.project(1)
      end

      def attribute_restriction(*)
        all
      end
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
        DanbooruLogger.log(x, expected: false, **new_relic_params)
        return default_value
      ensure
        connection.execute("SET STATEMENT_TIMEOUT = #{CurrentUser.user.try(:statement_timeout) || 3_000}") unless Rails.env == "test"
      end

      def update!(*args)
        all.each { |record| record.update!(*args) }
      end
    end
  end

  concerning :PostgresExtensions do
    class_methods do
      def columns(*params)
        super.reject {|x| x.sql_type == "tsvector"}
      end
    end
  end

  concerning :UserMethods do
    class_methods do
      def belongs_to_updater(**options)
        class_eval do
          belongs_to :updater, class_name: "User", **options
          before_validation do |rec|
            rec.updater_id = CurrentUser.id
            rec.updater_ip_addr = CurrentUser.ip_addr if rec.respond_to?(:updater_ip_addr=)
          end
        end
      end
    end
  end

  concerning :DtextMethods do
    def dtext_shortlink(**options)
      "#{self.class.name.underscore.tr("_", " ")} ##{id}"
    end
  end

  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end
end
