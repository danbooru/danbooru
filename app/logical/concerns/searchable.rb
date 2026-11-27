# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  # Raised when a search param has an invalid value, e.g. `search[is_deleted]=abc` or `search[name][x]=1`.
  class SearchError < StandardError; end

  # Helpers for English full-text searches (`websearch_to_tsquery`), used by `where_tsvector_matches`.
  module FullTextSearch
    # From Postgres's `tsearch_data/english.stop`. Recheck when upgrading Postgres to a new major version.
    STOPWORDS = %w[
      i me my myself we our ours ourselves you your yours yourself yourselves he him his himself she her hers herself
      it its itself they them their theirs themselves what which who whom this that these those am is are was were be
      been being have has had having do does did doing a an the and but if or because as until while of at by for with
      about against between into through during before after above below to from up down in out on off over under
      again further then once here there when where why how all any both each few more most other some such no nor not
      only own same so than too very s t can will just don should now
    ].to_set.freeze

    # True if Postgres would remove every word, leaving an empty search that matches nothing.
    #
    # @example
    #   stopwords_only?("don't") # => true
    #   stopwords_only?("the 2") # => false
    #
    # @param query [String]
    # @return [Boolean]
    def self.stopwords_only?(query)
      tokens = tokenize(query)
      tokens.present? && tokens.all? { |token| stopword?(token) }
    end

    # Split on whitespace, apostrophes, and quotes only, so words with other characters never count as stopwords.
    #
    # @example
    #   tokenize(%q{I don't "a-the" 3rd}) # => ["I", "don", "t", "a-the", "3rd"]
    #
    # @param query [String]
    # @return [Array<String>]
    def self.tokenize(query)
      query.to_s.split(/['’"[:space:]]+/).compact_blank
    end

    # @param word [String]
    # @return [Boolean]
    def self.stopword?(word)
      STOPWORDS.include?(word.downcase(:ascii))
    end
  end

  # The maximum number of items in a list search param, like `search[name_comma]=a,b,c` or `search[name][]=a`. Postgres
  # stops using indexes for long lists, which makes the search slow.
  MAX_SEARCH_LIST_ITEMS = 500

  # Raise an error if a list search param has too many items.
  #
  # @param name [String, Symbol] The name of the param, for the error message.
  # @param items [Array] The items in the list.
  # @return [Array] The items.
  # @raise [SearchError] If there are more than MAX_SEARCH_LIST_ITEMS items.
  def limit_search_list!(name, items)
    raise SearchError, "#{name} can't have more than #{MAX_SEARCH_LIST_ITEMS} items" if items.size > MAX_SEARCH_LIST_ITEMS
    items
  end

  def negate_relation
    relation = unscoped
    relation = relation.from(all.from_clause.value) if all.from_clause.value.present?
    relation = relation.joins(all.joins_values) if all.joins_values.present?
    relation.where(all.where_clause.invert.ast)
  end

  # Combine two relations like `ActiveRecord::Relation#and`, but allow structurally incompatible relations.
  def and_relation(relation)
    q = all
    raise "incompatible FROM clauses: #{q.to_sql}; #{relation.to_sql}" if !q.from_clause.empty? && q.from_clause != relation.from_clause
    raise "incompatible GROUP BY clauses: #{q.to_sql}; #{relation.to_sql}" if !q.group_values.empty? && q.group_values != relation.group_values

    q = q.select(q.select_values + relation.select_values) if !relation.select_values.empty?
    q = q.from(relation.from_clause.value) if !relation.from_clause.empty?
    q = q.joins(relation.joins_values + q.joins_values) if relation.joins_values.present?
    q = q.left_outer_joins(relation.left_outer_joins_values + q.left_outer_joins_values) if relation.left_outer_joins_values.present?
    q = q.where(relation.where_clause.ast) if relation.where_clause.present?
    q = q.group(relation.group_values) if relation.group_values.present?
    q = q.order(relation.order_values) if relation.order_values.present? && !relation.reordering_value
    q = q.reorder(relation.order_values) if relation.order_values.present? && relation.reordering_value
    q
  end

  # Search a table column by an Arel operator.
  #
  # @see https://github.com/rails/rails/blob/master/activerecord/lib/arel/predications.rb
  #
  # @example SELECT * FROM posts WHERE id <= 42
  #   Post.where_operator(:id, :lteq, 42)
  #
  # @param field [Symbol, String, Arel::Nodes::Node] the name of a table column, an
  #   Arel node, or an `Arel.sql` fragment (see #arel_node)
  # @param operator [Symbol] the name of an Arel::Predications method (:eq,
  #   :gt, :lt, :between, :in, :matches (LIKE), etc).
  # @return ActiveRecord::Relation
  def where_operator(field, operator, *args, **options)
    arel = arel_node(field).send(operator, *args, **options)
    where(arel)
  end

  def where_not_operator(field, operator, *args, **options)
    arel = arel_node(field).send(operator, *args, **options)
    where.not(arel)
  end

  def where_array_operator(attr, operator, values)
    where_operator(attr, operator, sql_array(values))
  end

  def where_not_array_operator(attr, operator, values)
    where_not_operator(attr, operator, sql_array(values))
  end

  def where_like(attr, value)
    value = value.escape_wildcards if value.exclude?("*")
    where_operator(attr, :matches, sql_value(value.to_escaped_for_sql_like), nil, true)
  end

  def where_not_like(attr, value)
    value = value.escape_wildcards if value.exclude?("*")
    where_operator(attr, :does_not_match, sql_value(value.to_escaped_for_sql_like), nil, true)
  end

  def where_ilike(attr, value)
    value = value.escape_wildcards if value.exclude?("*")
    where_operator(attr, :matches, sql_value(value.to_escaped_for_sql_like), nil, false)
  end

  def where_not_ilike(attr, value)
    value = value.escape_wildcards if value.exclude?("*")
    where_operator(attr, :does_not_match, sql_value(value.to_escaped_for_sql_like), nil, false)
  end

  def where_iequals(attr, value)
    value = value.escape_wildcards
    where_operator(attr, :matches, sql_value(value.to_escaped_for_sql_like), nil, false)
  end

  # https://www.postgresql.org/docs/current/static/functions-matching.html#FUNCTIONS-POSIX-REGEXP
  # "(?e)" means force use of ERE syntax; see sections 9.7.3.1 and 9.7.3.4.
  def where_regex(attr, value, flags: "e")
    where_operator(attr, :matches_regexp, sql_value("(?#{flags})" + value))
  end

  def where_not_regex(attr, value, flags: "e")
    where_operator(attr, :does_not_match_regexp, sql_value("(?#{flags})" + value))
  end

  def where_inet_matches(attr, value)
    if value.match?(/[, ]/)
      ips = limit_search_list!(attr, value.split(/[, ]+/)).map { |ip| Danbooru::IpAddress.parse(ip).to_s }
      return none if ips.any?(&:blank?)
      where("#{qualified_column_for(attr)} <<= ANY(ARRAY[?]::inet[])", ips)
    else
      ip = Danbooru::IpAddress.parse(value)
      return none if ip.nil?
      where("#{qualified_column_for(attr)} <<= ?", ip.to_s)
    end
  end

  # The && operator
  def where_array_includes_any(attr, values)
    where_array_operator(attr, :overlaps, values)
  end

  # The @> operator
  def where_array_includes_all(attr, values)
    where_array_operator(attr, :contains, values)
  end

  def where_array_includes_none(attr, values)
    where_not_array_operator(attr, :overlaps, values)
  end

  def where_array_includes_any_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}::text)::text[] && ARRAY[?]", values.map { it.to_s.downcase })
  end

  def where_array_includes_all_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}::text)::text[] @> ARRAY[?]", values.map { it.to_s.downcase })
  end

  # `~<<` is a custom Postgres operator. It's the `~` regex operator with reversed arguments.
  def where_any_in_array_matches_regex(attr, regex, flags: "e")
    where("? ~<< ANY(#{qualified_column_for(attr)}::text[])", "(?#{flags})#{regex}")
  end

  # Perform a Postgres full-text search on an array of strings. Assumes the query is already escaped.
  # The column should have a `array_to_tsvector(column) using gin` index for best performance.
  #
  # @see https://www.postgresql.org/docs/current/datatype-textsearch.html#DATATYPE-TSQUERY
  def where_array_to_tsvector_matches(attr, query)
    where("array_to_tsvector(#{qualified_column_for(attr)}) @@ ?::tsquery", query)
  end

  def where_any_in_array_starts_with(attr, value)
    where_array_to_tsvector_matches(attr, value.to_escaped_for_tsquery + ":*")
  end

  def where_all_in_array_like(attr, patterns)
    where_array_to_tsvector_matches(attr, escape_patterns_for_tsquery(patterns).join(" & "))
  end

  def where_any_in_array_like(attr, patterns)
    where_array_to_tsvector_matches(attr, escape_patterns_for_tsquery(patterns).join(" | "))
  end

  # Match if the array contains any of these values, ignoring case.
  #
  # This builds a tsquery like `'foo' | 'bar'` and matches it against `array_to_tsvector(lower(attr))`, because that
  # can use a GIN index on `array_to_tsvector(lower(attr))`. A simpler `lower(attr) && ARRAY[...]` can't use an index
  # and scans the whole table. Each value is quoted by `to_escaped_for_tsquery`, so tsquery operators inside values
  # are matched literally.
  #
  # @param values [String, Array<String>] The values to match.
  def where_any_in_array_iequals(attr, values)
    # Empty strings are invalid inside a tsquery like `'a' | ''`.
    values = Array.wrap(values).compact_blank
    return none if values.empty?

    query = values.map { it.downcase.to_escaped_for_tsquery }.join(" | ")
    where_array_to_tsvector_matches(Arel.sql("lower(#{qualified_column_for(attr)})"), query)
  end

  def where_text_includes_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}) IN (?)", values.map { it.to_s.downcase })
  end

  def where_array_count(attr, value)
    qualified_column = Arel.sql("cardinality(#{qualified_column_for(attr)})")
    where_numeric_matches(qualified_column, value)
  end

  # where_union_all(A, B, C) is like `WHERE A OR B OR C`, except it may be faster if the conditions are disjoint.
  # where_union_all(A, B) does `SELECT * FROM table WHERE id IN (SELECT id FROM table WHERE A UNION ALL SELECT id FROM table WHERE B)`
  def where_union_all(*, **)
    where_union(*, **, union_type: Arel::Nodes::UnionAll)
  end

  # where_union removes duplicate rows, where_union_all does not.
  def where_union(*relations, primary_key: :id, foreign_key: :id, union_type: Arel::Nodes::Union)
    arels = relations.map { |relation| relation.select(foreign_key).arel }
    union = arels.reduce do |left, right|
      union_type.new(left, right)
    end

    where(arel_table[primary_key].in(union))
  end

  # @param attr [String] the name of the JSON field
  # @param hash [Hash] the hash of values it should contain
  def where_json_contains(attr, hash)
    # XXX Hack to transform strings to numbers. Needed to match numeric JSON
    # values when given string input values from an URL.
    hash = hash.transform_values do |value|
      if Integer(value, exception: false)
        value.to_i
      elsif Float(value, exception: false)
        value.to_f
      else
        value
      end
    end

    where("#{qualified_column_for(attr)} @> :hash", hash: hash.to_json)
  end

  # @param attr [String] the name of the JSON field
  # @param hash [String] the key it should contain
  def where_json_has_key(attr, key)
    where("#{qualified_column_for(attr)} ? :key", key: key)
  end

  # https://www.postgresql.org/docs/current/textsearch-controls.html#TEXTSEARCH-PARSING-DOCUMENTS
  # https://www.postgresql.org/docs/current/textsearch-controls.html#TEXTSEARCH-PARSING-QUERIES
  def where_tsvector_matches(columns, query)
    # Queries containing only stopwords (e.g. "don't" or "a") turn into an empty query that matches nothing, so do a
    # substring search instead.
    if FullTextSearch.stopwords_only?(query)
      return Array.wrap(columns).map { |column| where_ilike(column, "*#{query.to_s.escape_wildcards}*") }.reduce(:or)
    end

    Array.wrap(columns).map do |column|
      where("(#{to_tsvector("english", arel_table[column]).to_sql}) @@ websearch_to_tsquery('pg_catalog.english', :query)", query: query)
    end.reduce(:or)
  end

  # value: "5", ">5", "<5", ">=5", "<=5", "5..10", "5,6,7"
  def where_numeric_matches(attribute, value, type = :integer)
    attribute_matches(value, attribute, type)
  end

  def where_boolean_matches(attribute, value)
    value = value.to_s

    if value.truthy?
      where(attribute => true)
    elsif value.falsy?
      where(attribute => false)
    else
      raise SearchError, "#{attribute} must be true or false"
    end
  end

  def where_text_matches(columns, query)
    columns = Array.wrap(columns)

    if query.nil?
      all
    elsif query.include?("*")
      columns.map do |column|
        where_ilike(column, query)
      end.reduce(:or)
    else
      where_tsvector_matches(columns, query)
    end
  end

  # @param exact [Boolean] If true, only allow exact matches, not ranges. Used for hashes, so they can't be guessed one
  #   character at a time with range searches.
  def attribute_matches(value, field, type = :integer, exact: false)
    operator, arg = RangeParser.parse(value, type)
    return none if exact && !(operator in :eq | :in)
    arg = clamp_to_column_range(arg, field) if type == :integer

    if operator == :union
      # operator = :union, arg = [[:eq, 5], [:gt, 7], [:lt, 3]]
      relation = arg.map do |sub_operator, sub_value|
        where_operator(field, sub_operator, sub_value)
      end.reduce(:or)
    else
      relation = where_operator(field, operator, arg)
    end

    # XXX Hack to make negating the equality operator work correctly on nullable columns.
    #
    # This makes `Post.attribute_matches(1, :approver_id)` produce `WHERE approver_id = 1 AND approver_id IS NOT NULL`.
    # This way if the relation is negated with `Post.attribute_matches(1, :approver_id).negate_relation`, it will
    # produce `WHERE approver_id != 1 OR approver_id IS NULL`. This is so the search includes NULL values; if it
    # was just `approver_id != 1`, then it would not include when approver_id is NULL.
    if (operator in :eq | :not_eq) && !arg.nil? && has_attribute?(field) && column_for_attribute(field).null
      relation = relation.where.not(field => nil)
    end

    relation
  rescue RangeParser::ParseError
    none
  end

  # Clamp integers to the range of the column's type, so that numbers that are too large for the column don't raise an
  # error. E.g. `id:99999999999999999999` becomes `id:2147483647` for integer columns.
  def clamp_to_column_range(arg, field)
    column = columns_hash[field.to_s]
    return arg unless column&.type == :integer

    max = (2**((8 * (column.limit || 8)) - 1)) - 1
    clamp = ->(value) { value.is_a?(Integer) ? value.clamp(-max - 1, max) : value }

    case arg
    when Range then Range.new(clamp[arg.begin], clamp[arg.end], arg.exclude_end?)
    when Array then arg.map { |value| clamp_to_column_range(value, field) }
    else clamp[arg]
    end
  end

  # Search the attributes listed in the policy's `searchable_attributes`.
  #
  # @see ApplicationPolicy#searchable_attributes
  def search_attributes(params, current_user:)
    SearchContext.new(all, params, current_user).search_attributes(policy(current_user).search_modes)
  end

  # Parse search params that aren't handled by `search_attributes`, like `search[min_level]=20`.
  #
  # @param params [Hash] The search params.
  # @param types [Hash{Symbol => Symbol, Array<Symbol>}] The type of each param: `:string`, `:integer`, or a list like
  #   `[:integer]`, which can be an array (`search[category][]=1`) or a space-separated string (`search[category]=1 4`).
  # @return [Hash{Symbol => Object}] The parsed value of each param, or nil if the param is missing or blank. Integers are
  #   clamped to the 64-bit range, so that numbers that are too large match nothing instead of raising a database error.
  # @raise [SearchError] If a param doesn't have the right type, like `search[min_level][]=20` or `search[min_level]=abc`.
  def parse_search_params!(params, **types)
    parse = lambda do |value, type|
      case [type, value]
      in [:string, String | Integer] then value.to_s
      in [:integer, Integer] then value.clamp(-(2**63), (2**63) - 1)
      in [:integer, String] then Integer(value, 10, exception: false)&.clamp(-(2**63), (2**63) - 1)
      else nil
      end
    end

    types.to_h do |name, type|
      value = params[name]
      next [name, nil] if value.blank?

      if type.is_a?(Array)
        items = limit_search_list!(name, value.is_a?(String) ? value.split : Array.wrap(value))
        parsed = items.map { |item| parse[item, type.first] }
        raise SearchError, "#{name} must be a list of #{type.first}s" if parsed.any?(nil)
      else
        parsed = parse[value, type]
        raise SearchError, "#{name} must be #{(type == :integer) ? "an integer" : "a string"}" if parsed.nil?
      end

      [name, parsed]
    end
  end

  # Order according to the list of IDs in the given string.
  #
  # Post.order_custom("1,2,3") => [post #1, post #2, post #3]
  def order_custom(string)
    operator, ids = RangeParser.parse(string, :integer)
    return none unless operator in :in | :eq

    ids = Array.wrap(ids)
    in_order_of(:id, ids)
  rescue RangeParser::ParseError
    none
  end

  def apply_default_order(params)
    if params[:order] == "custom"
      order_custom(params[:id])
    else
      default_order
    end
  end

  def default_order
    order(id: :desc)
  end

  private

  # A SearchContext contains private helper methods for `search_attributes`.
  class SearchContext
    attr_reader :relation, :params, :current_user

    def initialize(relation, params, current_user)
      @relation = relation
      @params = params.try(:with_indifferent_access) || params.try(:to_unsafe_h)
      @current_user = current_user
    end

    # @param search_modes [Hash<Symbol, Symbol>] The attributes to search and their search modes (see ApplicationPolicy#search_modes).
    def search_attributes(search_modes)
      raise ArgumentError, "max parameter depth of 10 exceeded" if parameter_depth(params) > 10
      validate_array_sizes!(params)

      search_modes.reduce(relation) do |relation, (attribute, mode)|
        search_context(relation).search_attribute(attribute, mode)
      end
    end

    def search_attribute(name, mode = :all)
      if mode == :exact && relation.has_attribute?(name)
        search_exact_attribute(name)
      elsif mode != :all
        raise ArgumentError, "#{name} has an invalid search mode: #{mode}"
      elsif relation.has_attribute?(name)
        search_basic_attribute(name)
      elsif relation.reflections.key?(name.to_s)
        search_association_attribute(name)
      else
        raise ArgumentError, "#{name} is not an attribute or association"
      end
    end

    def search_basic_attribute(name)
      column = relation.column_for_attribute(name)

      if column.try(:array?)
        type = :array
        subtype = column.type
      elsif relation.defined_enums.key?(name.to_s)
        type = :enum
      else
        type = column.type
      end

      validate_value_types!(name, type)

      case type
      when :string # :string is for columns of type `character varying` in the database
        search_string_attribute(name)
      when :text   # :text is for columns of type `text` in the database
        search_text_attribute(name)
      when :uuid
        search_uuid_attribute(name)
      when :boolean
        search_boolean_attribute(name)
      when :integer, :float, :datetime, :interval
        search_numeric_attribute(name, type: type)
      when :inet
        search_inet_attribute(name)
      when :enum
        search_enum_attribute(name)
      when :jsonb
        search_jsonb_attribute(name)
      when :array
        search_array_attribute(name, subtype)
      else
        raise NotImplementedError, "unhandled attribute type: #{name} (#{type})"
      end
    end

    # Only allow exact matches, so the attribute can't be discovered one character at a time with wildcard or range searches.
    def search_exact_attribute(attr)
      relation = self.relation
      relation = visible(relation, attr).where(attr => params[attr].to_s) if params[attr].present?
      relation = visible(relation, attr).where(attr => params[:"#{attr}_eq"].to_s) if params[:"#{attr}_eq"].present?
      relation = visible(relation, attr).where.not(attr => params[:"#{attr}_not_eq"].to_s) if params[:"#{attr}_not_eq"].present?
      relation = visible(relation, attr).where(attr => Array.wrap(params[:"#{attr}_array"]).map(&:to_s)) if params[:"#{attr}_array"].present?
      relation = visible(relation, attr).where(attr => list_param(:"#{attr}_comma", params[:"#{attr}_comma"].to_s.split(","))) if params[:"#{attr}_comma"].present?
      relation = visible(relation, attr).where(attr => list_param(:"#{attr}_space", params[:"#{attr}_space"].to_s.split)) if params[:"#{attr}_space"].present?
      relation
    end

    # Raise an error for search params with the wrong type, like `search[name][x]=1` or `search[name_like][]=a`. Most
    # operators take a single value, and some take either a single value or a list of values.
    def validate_value_types!(name, type)
      numeric_operators = ["", "_not", "_present", "_eq", "_not_eq", "_gt", "_gteq", "_lt", "_lteq"]
      singular_name = name.to_s.singularize

      case type
      when :string, :text
        list_keys = ["", "_eq", "_not_eq", "_array", "_lower_array"].map { "#{name}#{it}" }
        single_keys = %w[_present _like _ilike _not_like _not_ilike _regex _not_regex _comma _space _lower_comma _lower_space].map { "#{name}#{it}" }
        single_keys << "#{name}_matches" if type == :text
      when :uuid
        list_keys = ["", "_eq", "_not_eq"].map { "#{name}#{it}" }
      when :boolean, :inet
        single_keys = [name.to_s]
      when :integer, :float, :datetime, :interval
        single_keys = numeric_operators.map { "#{name}#{it}" }
      when :enum
        single_keys = [name.to_s, "#{name}_not", *numeric_operators.map { "#{name}_id#{it}" }]
      when :jsonb
        raise SearchError, "#{name} has an invalid value" if params[name].present? && !params[name].is_a?(Hash)
        single_keys = ["#{name}_has_key", "has_#{name}"]
      when :array
        list_keys = %w[_include_any_array _include_all_array _include_any_lower_array _include_all_lower_array].map { "#{name}#{it}" }
        single_keys = [*%w[_include_any _include_all _include_any_lower _include_all_lower].map { "#{name}#{it}" }, "any_#{singular_name}_matches_regex", "#{singular_name}_count"]
      end

      # JSON request bodies can contain numbers and booleans, which are converted to strings where needed.
      single_value = ->(value) { value in String | Integer | Float | true | false }

      Array(single_keys).each do |key|
        raise SearchError, "#{key} must be a string or integer" unless params[key].nil? || single_value.call(params[key])
      end

      Array(list_keys).each do |key|
        value = params[key]
        next if value.nil? || single_value.call(value) || (value.is_a?(Array) && value.all?(&single_value))
        raise SearchError, "#{key} must be a string or integer, or a list of them"
      end
    end

    def search_numeric_attribute(attr, key: attr, type: :integer)
      relation = self.relation

      if params[key].present?
        if type == :datetime
          # Try to parse dates as relative (like <1w) first,
          # and it that fails then try again as date strings.
          relation = visible(relation, attr).where_numeric_matches(attr, params[key], :age)
          if relation.none?
            relation = visible(self.relation, attr).where_numeric_matches(attr, params[key], type)
          end
        else
          relation = visible(relation, attr).where_numeric_matches(attr, params[key], type)
        end
      end

      if params[:"#{key}_not"].present?
        # WHERE NOT (score = 1) OR score IS NULL. Not `id NOT IN (...)`, which doesn't work for composite primary keys.
        matches = relation.unscoped.where_numeric_matches(attr, params[:"#{key}_not"], type)
        relation = visible(relation, attr).where(matches.where_clause.ast.not.or(relation.arel_table[attr].eq(nil)))
      end

      if params[:"#{key}_present"].to_s.truthy?
        relation = visible(relation, attr).where.not(attr => nil)
      end

      if params[:"#{key}_present"].to_s.falsy?
        relation = visible(relation, attr).where(attr => nil)
      end

      if params[:"#{key}_eq"].present?
        relation = visible(relation, attr).where_operator(attr, :eq, comparison_value(:"#{key}_eq", type))
      end

      if params[:"#{key}_not_eq"].present?
        relation = visible(relation, attr).where_operator(attr, :not_eq, comparison_value(:"#{key}_not_eq", type))
      end

      if params[:"#{key}_gt"].present?
        relation = visible(relation, attr).where_operator(attr, :gt, comparison_value(:"#{key}_gt", type))
      end

      if params[:"#{key}_gteq"].present?
        relation = visible(relation, attr).where_operator(attr, :gteq, comparison_value(:"#{key}_gteq", type))
      end

      if params[:"#{key}_lt"].present?
        relation = visible(relation, attr).where_operator(attr, :lt, comparison_value(:"#{key}_lt", type))
      end

      if params[:"#{key}_lteq"].present?
        relation = visible(relation, attr).where_operator(attr, :lteq, comparison_value(:"#{key}_lteq", type))
      end

      relation
    end

    # Parse the value of a comparison operator like `search[duration_gt]=1d`. Intervals are parsed here because Postgres
    # raises an error for intervals it can't parse.
    def comparison_value(key, type)
      return params[key] unless type == :interval

      DurationParser.parse_duration(params[key].to_s)
    rescue ArgumentError
      raise SearchError, "#{key} must be a duration, like 1d or 2 weeks"
    end

    def search_string_attribute(attr)
      relation = self.relation

      if params[attr].present?
        relation = visible(relation, attr).where(attr => params[attr])
      end

      if params[:"#{attr}_present"].to_s.truthy?
        relation = visible(relation, attr).where.not(attr => "")
      end

      if params[:"#{attr}_present"].to_s.falsy?
        relation = visible(relation, attr).where(attr => "")
      end

      if params[:"#{attr}_eq"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_eq"])
      end

      if params[:"#{attr}_not_eq"].present?
        relation = visible(relation, attr).where.not(attr => params[:"#{attr}_not_eq"])
      end

      if params[:"#{attr}_like"].present?
        relation = visible(relation, attr).where_like(attr, params[:"#{attr}_like"].to_s)
      end

      if params[:"#{attr}_ilike"].present?
        relation = visible(relation, attr).where_ilike(attr, params[:"#{attr}_ilike"].to_s)
      end

      if params[:"#{attr}_not_like"].present?
        relation = visible(relation, attr).where_not_like(attr, params[:"#{attr}_not_like"].to_s)
      end

      if params[:"#{attr}_not_ilike"].present?
        relation = visible(relation, attr).where_not_ilike(attr, params[:"#{attr}_not_ilike"].to_s)
      end

      if params[:"#{attr}_regex"].present?
        relation = visible(relation, attr).where_regex(attr, params[:"#{attr}_regex"].to_s)
      end

      if params[:"#{attr}_not_regex"].present?
        relation = visible(relation, attr).where_not_regex(attr, params[:"#{attr}_not_regex"].to_s)
      end

      if params[:"#{attr}_array"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_array"])
      end

      if params[:"#{attr}_comma"].present?
        relation = visible(relation, attr).where(attr => list_param(:"#{attr}_comma", params[:"#{attr}_comma"].to_s.split(",")))
      end

      if params[:"#{attr}_space"].present?
        relation = visible(relation, attr).where(attr => list_param(:"#{attr}_space", params[:"#{attr}_space"].to_s.split))
      end

      if params[:"#{attr}_lower_array"].present?
        relation = visible(relation, attr).where_text_includes_lower(attr, Array.wrap(params[:"#{attr}_lower_array"]))
      end

      if params[:"#{attr}_lower_comma"].present?
        relation = visible(relation, attr).where_text_includes_lower(attr, list_param(:"#{attr}_lower_comma", params[:"#{attr}_lower_comma"].to_s.split(",")))
      end

      if params[:"#{attr}_lower_space"].present?
        relation = visible(relation, attr).where_text_includes_lower(attr, list_param(:"#{attr}_lower_space", params[:"#{attr}_lower_space"].to_s.split))
      end

      relation
    end

    def search_text_attribute(attr)
      relation = search_string_attribute(attr)

      if params[:"#{attr}_matches"].present?
        relation = visible(relation, attr).where_text_matches(attr, params[:"#{attr}_matches"].to_s)
      end

      relation
    end

    def search_uuid_attribute(attr)
      relation = self.relation

      if params[attr].present?
        relation = visible(relation, attr).where(attr => params[attr])
      end

      if params[:"#{attr}_eq"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_eq"])
      end

      if params[:"#{attr}_not_eq"].present?
        relation = visible(relation, attr).where.not(attr => params[:"#{attr}_not_eq"])
      end

      relation
    end

    def search_boolean_attribute(attr)
      relation = self.relation

      if params[attr].present? || params[attr] == false
        relation = visible(relation, attr).where_boolean_matches(attr, params[attr])
      end

      relation
    end

    def search_inet_attribute(attr)
      relation = self.relation

      if params[attr].present?
        relation = visible(relation, attr).where_inet_matches(attr, params[attr].to_s)
      end

      relation
    end

    def search_jsonb_attribute(name)
      relation = self.relation

      if params[name].present?
        relation = visible(relation, name).where_json_contains(name, params[name])
      end

      if params["#{name}_has_key"]
        relation = visible(relation, name).where_json_has_key(name, params["#{name}_has_key"].to_s)
      end

      if params["has_#{name}"].to_s.truthy?
        relation = visible(relation, name).where.not(name => "{}")
      elsif params["has_#{name}"].to_s.falsy?
        relation = visible(relation, name).where(name => "{}")
      end

      relation
    end

    def search_enum_attribute(name)
      relation = self.relation

      # Split on commas, then on spaces unless the value is an enum name containing spaces (e.g. "Bugs & Features").
      enum_names = relation.defined_enums[name.to_s].keys.map(&:downcase)
      parse_values = ->(value) { value.split(",").map(&:strip).flat_map { |v| v.downcase.in?(enum_names) ? [v] : v.split } }

      if params[name].present?
        relation = visible(relation, name).where(name => list_param(name, parse_values.call(params[name].to_s)))
      end

      if params[:"#{name}_not"].present?
        relation = visible(relation, name).where.not(name => list_param(:"#{name}_not", parse_values.call(params[:"#{name}_not"].to_s)))
      end

      relation = search_context(relation).search_numeric_attribute(name, key: :"#{name}_id")

      relation
    end

    def search_array_attribute(name, type)
      relation = self.relation
      singular_name = name.to_s.singularize

      if params[:"#{name}_include_any"].present?
        relation = visible(relation, name).where_array_includes_any(name, array_items(name, :"#{name}_include_any", type))
      end

      if params[:"#{name}_include_all"].present?
        relation = visible(relation, name).where_array_includes_all(name, array_items(name, :"#{name}_include_all", type))
      end

      if params[:"#{name}_include_any_array"].present?
        relation = visible(relation, name).where_array_includes_any(name, array_items(name, :"#{name}_include_any_array", type))
      end

      if params[:"#{name}_include_all_array"].present?
        relation = visible(relation, name).where_array_includes_all(name, array_items(name, :"#{name}_include_all_array", type))
      end

      if params[:"#{name}_include_any_lower"].present?
        relation = visible(relation, name).where_array_includes_any_lower(name, list_param(:"#{name}_include_any_lower", params[:"#{name}_include_any_lower"].to_s.scan(/[^[:space:]]+/)))
      end

      if params[:"#{name}_include_all_lower"].present?
        relation = visible(relation, name).where_array_includes_all_lower(name, list_param(:"#{name}_include_all_lower", params[:"#{name}_include_all_lower"].to_s.scan(/[^[:space:]]+/)))
      end

      if params[:"#{name}_include_any_lower_array"].present?
        relation = visible(relation, name).where_array_includes_any_lower(name, Array.wrap(params[:"#{name}_include_any_lower_array"]))
      end

      if params[:"#{name}_include_all_lower_array"].present?
        relation = visible(relation, name).where_array_includes_all_lower(name, Array.wrap(params[:"#{name}_include_all_lower_array"]))
      end

      if params[:"any_#{singular_name}_matches_regex"].present?
        relation = visible(relation, name).where_any_in_array_matches_regex(name, params[:"any_#{singular_name}_matches_regex"].to_s)
      end

      if params[:"#{singular_name}_count"].present?
        relation = visible(relation, name).where_array_count(name, params[:"#{singular_name}_count"])
      end

      relation
    end

    # Parse the items of an array search, like `search[post_ids_include_any]=1 2` (a space-separated list) or
    # `search[post_ids_include_any_array][]=1` (an array). Integer lists may also be comma-separated, like
    # `search[post_ids_include_any]=1,2`. The items are converted to the column's type, because Postgres can't
    # compare arrays of different types.
    def array_items(name, key, type)
      item = (type == :integer) ? /[^[:space:],]+/ : /[^[:space:]]+/
      items = key.end_with?("_array") ? Array.wrap(params[key]) : list_param(key, params[key].to_s.scan(item))
      return items.map(&:to_s) unless type == :integer

      items = items.map { Integer(it.to_s, 10, exception: false) || raise(SearchError, "#{key} must be a list of integers") }
      relation.clamp_to_column_range(items, name)
    end

    def search_association_attribute(attr)
      association = relation.reflect_on_association(attr)
      relation = self.relation
      raise SearchError, "#{attr} has an invalid value" if params[attr].present? && !parameter_hash?(params[attr])

      if association.polymorphic?
        return search_polymorphic_attribute(attr)
      end

      if association.belongs_to?
        relation = search_attribute(association.foreign_key)
      end

      model = association.klass
      if model == User && params["#{attr}_name"].present?
        name = params["#{attr}_name"]
        if name.include?("*")
          relation = visible(relation, attr).where(attr => User.visible(current_user).search({ name_matches: name }, current_user).reorder(nil))
        else
          relation = visible(relation, attr).where(attr => User.visible(current_user).find_by_name(name))
        end
      end

      if model == Post && params["#{attr}_tags_match"].present?
        posts = Post.user_tag_match(params["#{attr}_tags_match"], current_user).reorder(nil)

        if association.through_reflection?
          relation = visible(relation, attr).includes(association.through_reflection.name).where(association.through_reflection.name => { attr => posts })
        else
          relation = visible(relation, attr).where(attr => posts)
        end
      end

      if params["has_#{attr}"].to_s.truthy? || params["has_#{attr}"].to_s.falsy?
        relation = search_context(relation).search_has_include(attr, params["has_#{attr}"].to_s.truthy?, model)
      end

      if parameter_hash?(params[attr])
        if association.through_reflection?
          source_association = association.source_reflection
          through_association = association.through_reflection

          source_subquery = source_association.klass.visible(current_user).search(params[attr], current_user).reorder(nil)
          through_subquery = through_association.klass.visible(current_user).where(source_association.name => source_subquery)
          relation = visible(relation, attr).where(through_association.name => through_subquery)
        else
          relation = visible(relation, attr).where(attr => model.visible(current_user).search(params[attr], current_user).reorder(nil))
        end
      end

      relation
    end

    def search_polymorphic_attribute(attr)
      model_keys = ((relation.model_types || []) & params.keys)
      # The user can only logically specify one model at a time, so more than that should return no results
      return none if model_keys.length > 1

      relation = self.relation
      model_key = model_keys[0]
      raise SearchError, "#{model_key} has an invalid value" if model_key && params[model_key].present? && !parameter_hash?(params[model_key])

      if model_keys.length == 1 && parameter_hash?(params[model_key])
        # Returning none here for the same reason specified above
        return none if params["#{attr}_type"].present? && params["#{attr}_type"] != model_key
        model = Kernel.const_get(model_key)
        relation = visible(relation, attr).where(attr => model.visible(current_user).search(params[model_key], current_user))
      end

      relation = search_context(relation).search_attribute("#{attr}_id")
      relation = search_context(relation).search_attribute("#{attr}_type")

      relation
    end

    def search_has_include(name, exists, model)
      if relation.column_names.include?("#{name}_id")
        return exists ? visible(relation, name).where.not("#{name}_id" => nil) : visible(relation, name).where("#{name}_id" => nil)
      end

      association = relation.reflect_on_association(name)
      primary_key = association.active_record_primary_key
      foreign_key = association.foreign_key
      # The belongs_to macro has its primary and foreign keys reversed
      primary_key, foreign_key = foreign_key, primary_key if association.macro == :belongs_to
      return relation if primary_key.nil? || foreign_key.nil?

      model_exists = model.visible(current_user).model_restriction.where(model.arel_table[foreign_key].eq(relation.arel_table[primary_key])).arel.exists
      if exists
        visible(relation, name).attribute_restriction(name).where(model_exists)
      else
        visible(relation, name).attribute_restriction(name).where.not(model_exists)
      end
    end

    # Restrict the results that are visible to the user based on what they're searching for.
    def visible(relation, attr)
      relation.policy(current_user).visible_for_search(relation, attr.to_sym)
    end

    # Raise an error for array params with too many items, like `search[name][]=a&search[name][]=b&...`.
    def validate_array_sizes!(params)
      params.each do |key, value|
        if value.is_a?(Array)
          list_param(key, value.flatten)
        elsif parameter_hash?(value)
          validate_array_sizes!(value)
        end
      end
    end

    def list_param(name, items)
      relation.limit_search_list!(name, items)
    end

    def parameter_depth(params)
      return 0 if params.values.empty?
      1 + params.values.map { |v| parameter_hash?(v) ? parameter_depth(v) : 1 }.max
    end

    def parameter_hash?(params)
      params.present? && params.respond_to?(:each_value)
    end

    def search_context(relation)
      SearchContext.new(relation, params, current_user)
    end
  end

  # @param attr [Symbol, String, Arel::Attributes::Attribute, Arel::Nodes::SqlLiteral] The name of a column, an Arel
  #   attribute like `Tag.arel_table[:words]`, or an `Arel.sql` fragment.
  # @return [String] The column name qualified with the table name, like `"posts"."id"`, or the SQL fragment as is.
  # @raise [ArgumentError] If `attr` is a string that isn't the name of a column.
  def qualified_column_for(attr)
    case attr
    when Arel::Nodes::SqlLiteral
      attr
    when Arel::Attributes::Attribute
      "#{connection.quote_table_name(attr.relation.table_alias || attr.relation.name)}.#{connection.quote_column_name(attr.name)}"
    else
      raise ArgumentError, "#{attr.inspect} is not a column of #{table_name}; use Arel.sql for raw SQL" unless has_attribute?(attr)

      "#{quoted_table_name}.#{connection.quote_column_name(column_for_attribute(attr).name)}"
    end
  end

  # @param patterns [Array<String>] An array of wildcard patterns to escape for a tsquery search.
  def escape_patterns_for_tsquery(patterns)
    patterns.map do |pattern|
      if pattern.ends_with?("*")
        pattern.delete_suffix("*").to_escaped_for_tsquery + ":*"
      else
        pattern.to_escaped_for_tsquery
      end
    end
  end

  # Convert a column name to an Arel node.
  #
  # @param field [Symbol, String, Arel::Nodes::Node, Arel::Attributes::Attribute, Arel::Nodes::SqlLiteral] The name of a
  #   column, an Arel node, or an `Arel.sql` fragment.
  # @return [Arel::Expressions] The Arel node.
  # @raise [ArgumentError] If `field` is a string that isn't the name of a column.
  def arel_node(field)
    if Arel.arel_node?(field)
      field
    elsif has_attribute?(field)
      arel_table[field]
    else
      raise ArgumentError, "#{field.inspect} is not a column of #{table_name}; use Arel.sql for raw SQL"
    end
  end

  def sql_value(value)
    case value
    in _ if Arel.arel_node?(value)
      value
    in Symbol
      arel_table[value]
    in Array
      sql_array(value)
    else
      Arel::Nodes.build_quoted(value)
    end
  end

  # Convert a Ruby array to an SQL array.
  #
  # @param values [Array]
  # @return Arel::Nodes::SqlLiteral
  def sql_array(array)
    Arel.sql(ActiveRecord::Base.sanitize_sql(["ARRAY[?]", array]))
  end

  # @example Tag.sql_function(:sum, Tag.arel_table[:post_count]).to_sql == "SUM(tags.post_count)"
  def sql_function(name, *args)
    Arel::Nodes::NamedFunction.new(name.to_s, args.map { |arg| sql_value(arg) })
  end

  # @example Note.to_tsvector("pg_catalog.english", :body).to_sql == "to_tsvector('pg_catalog.english', notes.body)"
  # https://www.postgresql.org/docs/current/textsearch-controls.html#TEXTSEARCH-PARSING-DOCUMENTS
  def to_tsvector(config, column)
    sql_function(:to_tsvector, config, column)
  end
end
