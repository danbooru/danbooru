# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Deletable
  include Mentionable
  include Normalizable
  include DTextAttribute
  include ArrayAttribute
  include HasDtextLinks
  extend HasBitFlags
  extend Searchable
  extend Aggregatable

  concerning :PaginationMethods do
    class_methods do
      def paginate(*args, **options)
        extending(PaginationExtension).paginate(*args, **options)
      end

      # Perform a search using the model's `search` method, then paginate the results.
      #
      # @param params [Hash] The URL request params from the user
      # @param page [Integer] The page number
      # @param limit [Integer] The number of posts per page
      # @param count_pages [Boolean] If true, calculate the exact number of pages of
      #   results. If false (the default), don't calculate the exact number of pages
      #   of results; assume there are too many pages to count.
      # @param count [Integer] the precalculated number of search results, or nil to calculate it
      # @param defaults [Hash] The default params for the search
      # @param current_user [User] The user performing the search
      def paginated_search(params, page: params[:page], limit: params[:limit], count_pages: params[:search].present?, count: nil, defaults: {}, current_user: CurrentUser.user)
        search_params = params.fetch(:search, {}).permit!
        search_params = defaults.merge(search_params).with_indifferent_access

        max_limit = (params[:format] == "sitemap") ? 10_000 : 1_000
        search(search_params, current_user).paginate(page, limit: limit, max_limit: max_limit, count: count, search_count: count_pages)
      end
    end
  end

  concerning :PrivilegeMethods do
    class_methods do
      def visible(_user)
        all
      end

      def visible_for_search(attribute, current_user)
        policy(current_user).visible_for_search(all, attribute)
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
        reflections.select { |_, v| v.macro == :has_many }.keys.map(&:to_sym)
      end

      def associated_models(name)
        if reflections[name].options[:polymorphic]
          reflections[name].active_record.try(:model_types) || []
        else
          [reflections[name].class_name]
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
      if options[:only].is_a?(String)
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
      def set_timeout(n)
        connection.execute("SET statement_timeout = #{n}") unless Rails.env.test?
        yield
      ensure
        connection.execute("SET statement_timeout = #{CurrentUser.user.statement_timeout}") unless Rails.env.test?
      end

      def without_timeout
        connection.execute("SET statement_timeout = 0") unless Rails.env.test?
        yield
      ensure
        connection.execute("SET statement_timeout = #{CurrentUser.user.try(:statement_timeout) || 3_000}") unless Rails.env.test?
      end

      def with_timeout(n, default_value = nil, new_relic_params = {})
        connection.execute("SET statement_timeout = #{n}") unless Rails.env.test?
        yield
      rescue ::ActiveRecord::StatementInvalid => e
        DanbooruLogger.log(e, expected: true, **new_relic_params)
        default_value
      ensure
        connection.execute("SET statement_timeout = #{CurrentUser.user.try(:statement_timeout) || 3_000}") unless Rails.env.test?
      end

      def update!(*args)
        all.each { |record| record.update!(*args) }
      end

      def each_duplicate(*columns)
        return enum_for(:each_duplicate, *columns) unless block_given?

        group(columns).having("count(*) > 1").count.each do |values, count|
          hash = columns.zip(Array.wrap(values)).to_h
          yield count: count, **hash
        end
      end

      def destroy_duplicates!(*columns, log: true)
        each_duplicate(*columns) do |count:, **columns_with_values|
          records = where(columns_with_values).order(:id)
          dupes = records.drop(1)

          if log
            data = { keep: records.first.id, destroy: dupes.map(&:id), count: count, **columns_with_values }
            DanbooruLogger.info("Destroying duplicate #{self.name} #{dupes.map(&:id).join(", ")}", data)
          end

          dupes.each(&:destroy!)
        end
      end
    end

    # Save the record, but convert RecordNotUnique exceptions thrown by the database into
    # Rails validation errors. This way duplicate records only return one type of error.
    # This assumes the table only has one uniqueness constraint in the database.
    def save_if_unique(column)
      save
    rescue ActiveRecord::RecordNotUnique => e
      self.errors.add(column, :taken)
      false
    end
  end

  concerning :UserMethods do
    class_methods do
      def belongs_to_updater(**options)
        class_eval do
          belongs_to :updater, class_name: "User", **options
          before_validation do |rec|
            rec.updater_id = CurrentUser.id
          end
        end
      end
    end
  end

  concerning :DtextMethods do
    def dtext_shortlink(**_options)
      "#{self.class.name.underscore.tr("_", " ")} ##{id}"
    end
  end

  concerning :ConcurrencyMethods do
    class_methods do
      def parallel_find_each(**options, &block)
        # XXX We may deadlock if a transaction is open; do a non-parallel each.
        return find_each(&block) if connection.transaction_open?

        current_user = CurrentUser.user

        find_in_batches(error_on_ignore: true, **options) do |batch|
          batch.parallel_each do |record|
            # XXX The current user isn't inherited from the parent thread because the current user is a thread-local
            # variable. Hence, we have to set it explicitly in the child thread.
            CurrentUser.scoped(current_user) do
              yield record
            end
          end
        end
      end
    end
  end

  def revised?
    updated_at > created_at
  end

  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end
end
