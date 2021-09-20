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

      def policy(current_user)
        Pundit.policy(current_user, self)
      end
    end

    def policy(current_user)
      Pundit.policy(current_user, self)
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
      policy = Pundit.policy(user, self) || ApplicationPolicy.new(user, self)
      policy.api_attributes
    end

    # XXX deprecated, shouldn't expose this as an instance method.
    def html_data_attributes(user: CurrentUser.user)
      policy = Pundit.policy(user, self) || ApplicationPolicy.new(user, self)
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

  concerning :ConcurrencyMethods do
    class_methods do
      def parallel_each(batch_size: 1000, in_processes: 4, in_threads: nil, &block)
        # XXX Use threads in testing because processes can't see each other's
        # database transactions.
        if Rails.env.test?
          in_processes = nil
          in_threads = 2
        end

        # XXX Threads deadlock during tests if a transaction is open; do a non-parallel each.
        return find_each(&block) if Rails.env.test? && connection.transaction_open?

        current_user = CurrentUser.user
        current_ip = CurrentUser.ip_addr

        find_in_batches(batch_size: batch_size, error_on_ignore: true) do |batch|
          Parallel.each(batch, in_processes: in_processes, in_threads: in_threads) do |record|
            # XXX In threaded mode, the current user isn't inherited from the
            # parent thread because the current user is a thread-local
            # variable. Hence, we have to set it explicitly in the child thread.
            CurrentUser.scoped(current_user, current_ip) do
              yield record
            end
          end
        end
      end
    end
  end

  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end
end
