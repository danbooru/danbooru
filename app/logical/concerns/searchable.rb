# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  def negate_relation
    relation = unscoped
    relation = relation.from(all.from_clause.value) if all.from_clause.value.present?
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
  # @param field [String, Arel::Nodes::Node] the name of a table column, an
  #   Arel node, or raw SQL
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
    where_operator(attr, :matches, value.to_escaped_for_sql_like, nil, true)
  end

  def where_not_like(attr, value)
    where_operator(attr, :does_not_match, value.to_escaped_for_sql_like, nil, true)
  end

  def where_ilike(attr, value)
    where_operator(attr, :matches, value.to_escaped_for_sql_like, nil, false)
  end

  def where_not_ilike(attr, value)
    where_operator(attr, :does_not_match, value.to_escaped_for_sql_like, nil, false)
  end

  def where_iequals(attr, value)
    where_ilike(attr, value.escape_wildcards)
  end

  # https://www.postgresql.org/docs/current/static/functions-matching.html#FUNCTIONS-POSIX-REGEXP
  # "(?e)" means force use of ERE syntax; see sections 9.7.3.1 and 9.7.3.4.
  def where_regex(attr, value, flags: "e")
    where_operator(attr, :matches_regexp, "(?#{flags})" + value)
  end

  def where_not_regex(attr, value, flags: "e")
    where_operator(attr, :does_not_match_regexp, "(?#{flags})" + value)
  end

  def where_inet_matches(attr, value)
    if value.match?(/[, ]/)
      ips = value.split(/[, ]+/).map { |ip| Danbooru::IpAddress.parse(ip).to_s }
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
    where("lower(#{qualified_column_for(attr)}::text)::text[] && ARRAY[?]", values.map(&:downcase))
  end

  def where_array_includes_all_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}::text)::text[] @> ARRAY[?]", values.map(&:downcase))
  end

  # `~<<` is a custom Postgres operator. It's the `~` regex operator with reversed arguments.
  def where_any_in_array_matches_regex(attr, regex, flags: "e")
    where("? ~<< ANY(#{qualified_column_for(attr)})", "(?#{flags})#{regex}")
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

  def where_text_includes_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}) IN (?)", values.map(&:downcase))
  end

  def where_array_count(attr, value)
    qualified_column = "cardinality(#{qualified_column_for(attr)})"
    where_numeric_matches(qualified_column, value)
  end

  # where_union(A, B, C) is like `WHERE A OR B OR C`, except it may be faster if the conditions are disjoint.
  # where_union(A, B) does `SELECT * FROM table WHERE id IN (SELECT id FROM table WHERE A UNION ALL SELECT id FROM table WHERE B)`
  def where_union(*relations, primary_key: :id, foreign_key: :id)
    arels = relations.map { |relation| relation.select(foreign_key).arel }
    union = arels.reduce do |left, right|
      Arel::Nodes::UnionAll.new(left, right)
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
    tsvectors = Array.wrap(columns).map do |column|
      to_tsvector("pg_catalog.english", arel_table[column])
    end.reduce(:concat)

    where("(#{tsvectors.to_sql}) @@ websearch_to_tsquery('pg_catalog.english', :query)", query: query)
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
      raise ArgumentError, "value must be truthy or falsy"
    end
  end

  def where_text_matches(columns, query)
    columns = Array.wrap(columns)

    if query.nil?
      all
    elsif query =~ /\*/
      columns.map do |column|
        where_ilike(column, query)
      end.reduce(:or)
    else
      where_tsvector_matches(columns, query)
    end
  end

  def attribute_matches(value, field, type = :integer)
    operator, arg = RangeParser.parse(value, type)

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
    if (operator in :eq | :not_eq) && arg != nil && has_attribute?(field) && column_for_attribute(field).null
      relation = relation.where.not(field => nil)
    end

    relation
  rescue RangeParser::ParseError
    none
  end

  def search_attributes(params, attributes, current_user:)
    SearchContext.new(all, params, current_user).search_attributes(attributes)
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

    def search_attributes(attributes)
      raise ArgumentError, "max parameter depth of 10 exceeded" if parameter_depth(params) > 10

      attributes.reduce(relation) do |relation, attribute|
        search_context(relation).search_attribute(attribute)
      end
    end

    def search_attribute(name)
      if relation.has_attribute?(name)
        search_basic_attribute(name)
      elsif relation.reflections.has_key?(name.to_s)
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
      elsif relation.defined_enums.has_key?(name.to_s)
        type = :enum
      else
        type = column.type
      end

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

    def search_numeric_attribute(attr, key: attr, type: :integer)
      relation = self.relation

      if params[key].present?
        relation = visible(relation, attr).where_numeric_matches(attr, params[key], type)
      end

      if params[:"#{key}_not"].present?
        relation = visible(relation, attr).where.not(id: visible(relation, attr).where_numeric_matches(attr, params[:"#{key}_not"], type))
      end

      if params[:"#{key}_eq"].present?
        relation = visible(relation, attr).where_operator(attr, :eq, params[:"#{key}_eq"])
      end

      if params[:"#{key}_not_eq"].present?
        relation = visible(relation, attr).where_operator(attr, :not_eq, params[:"#{key}_not_eq"])
      end

      if params[:"#{key}_gt"].present?
        relation = visible(relation, attr).where_operator(attr, :gt, params[:"#{key}_gt"])
      end

      if params[:"#{key}_gteq"].present?
        relation = visible(relation, attr).where_operator(attr, :gteq, params[:"#{key}_gteq"])
      end

      if params[:"#{key}_lt"].present?
        relation = visible(relation, attr).where_operator(attr, :lt, params[:"#{key}_lt"])
      end

      if params[:"#{key}_lteq"].present?
        relation = visible(relation, attr).where_operator(attr, :lteq, params[:"#{key}_lteq"])
      end

      relation
    end

    def search_string_attribute(attr)
      relation = self.relation

      if params[attr].present?
        relation = visible(relation, attr).where(attr => params[attr])
      end

      if params[:"#{attr}_present"].present? && params[:"#{attr}_present"].truthy?
        relation = visible(relation, attr).where.not(attr => "")
      end

      if params[:"#{attr}_present"].present? && params[:"#{attr}_present"].falsy?
        relation = visible(relation, attr).where(attr => "")
      end

      if params[:"#{attr}_eq"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_eq"])
      end

      if params[:"#{attr}_not_eq"].present?
        relation = visible(relation, attr).where.not(attr => params[:"#{attr}_not_eq"])
      end

      if params[:"#{attr}_like"].present?
        relation = visible(relation, attr).where_like(attr, params[:"#{attr}_like"])
      end

      if params[:"#{attr}_ilike"].present?
        relation = visible(relation, attr).where_ilike(attr, params[:"#{attr}_ilike"])
      end

      if params[:"#{attr}_not_like"].present?
        relation = visible(relation, attr).where_not_like(attr, params[:"#{attr}_not_like"])
      end

      if params[:"#{attr}_not_ilike"].present?
        relation = visible(relation, attr).where_not_ilike(attr, params[:"#{attr}_not_ilike"])
      end

      if params[:"#{attr}_regex"].present?
        relation = visible(relation, attr).where_regex(attr, params[:"#{attr}_regex"])
      end

      if params[:"#{attr}_not_regex"].present?
        relation = visible(relation, attr).where_not_regex(attr, params[:"#{attr}_not_regex"])
      end

      if params[:"#{attr}_array"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_array"])
      end

      if params[:"#{attr}_comma"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_comma"].split(','))
      end

      if params[:"#{attr}_space"].present?
        relation = visible(relation, attr).where(attr => params[:"#{attr}_space"].split(' '))
      end

      if params[:"#{attr}_lower_array"].present?
        relation = visible(relation, attr).where_text_includes_lower(attr, params[:"#{attr}_lower_array"])
      end

      if params[:"#{attr}_lower_comma"].present?
        relation = visible(relation, attr).where_text_includes_lower(attr, params[:"#{attr}_lower_comma"].split(','))
      end

      if params[:"#{attr}_lower_space"].present?
        relation = visible(relation, attr).where_text_includes_lower(attr, params[:"#{attr}_lower_space"].split(' '))
      end

      relation
    end

    def search_text_attribute(attr)
      relation = search_string_attribute(attr)

      if params[:"#{attr}_matches"].present?
        relation = visible(relation, attr).where_text_matches(attr, params[:"#{attr}_matches"])
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

      if params[attr].present?
        relation = visible(relation, attr).where_boolean_matches(attr, params[attr])
      end

      relation
    end

    def search_inet_attribute(attr)
      relation = self.relation

      if params[attr].present?
        relation = visible(relation, attr).where_inet_matches(attr, params[attr])
      end

      relation
    end

    def search_jsonb_attribute(name)
      relation = self.relation

      if params[name].present?
        relation = visible(relation, name).where_json_contains(name, params[name])
      end

      if params["#{name}_has_key"]
        relation = visible(relation, name).where_json_has_key(name, params["#{name}_has_key"])
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

      if params[name].present?
        value = params[name].split(/[, ]+/).map(&:downcase)
        relation = visible(relation, name).where(name => value)
      end

      if params[:"#{name}_not"].present?
        value = params[:"#{name}_not"].split(/[, ]+/).map(&:downcase)
        relation = visible(relation, name).where.not(name => value)
      end

      relation = search_context(relation).search_numeric_attribute(name, key: :"#{name}_id")

      relation
    end

    def search_array_attribute(name, type)
      relation = self.relation
      singular_name = name.to_s.singularize

      if params[:"#{name}_include_any"]
        items = params[:"#{name}_include_any"].to_s.scan(/[^[:space:]]+/)
        items = items.map(&:to_i) if type == :integer

        relation = visible(relation, name).where_array_includes_any(name, items)
      end

      if params[:"#{name}_include_all"]
        items = params[:"#{name}_include_all"].to_s.scan(/[^[:space:]]+/)
        items = items.map(&:to_i) if type == :integer

        relation = visible(relation, name).where_array_includes_all(name, items)
      end

      if params[:"#{name}_include_any_array"]
        relation = visible(relation, name).where_array_includes_any(name, params[:"#{name}_include_any_array"])
      end

      if params[:"#{name}_include_all_array"]
        relation = visible(relation, name).where_array_includes_all(name, params[:"#{name}_include_all_array"])
      end

      if params[:"#{name}_include_any_lower"]
        items = params[:"#{name}_include_any_lower"].to_s.scan(/[^[:space:]]+/)
        items = items.map(&:to_i) if type == :integer

        relation = visible(relation, name).where_array_includes_any_lower(name, items)
      end

      if params[:"#{name}_include_all_lower"]
        items = params[:"#{name}_include_all_lower"].to_s.scan(/[^[:space:]]+/)
        items = items.map(&:to_i) if type == :integer

        relation = visible(relation, name).where_array_includes_all_lower(name, items)
      end

      if params[:"#{name}_include_any_lower_array"]
        relation = visible(relation, name).where_array_includes_any_lower(name, params[:"#{name}_include_any_lower_array"])
      end

      if params[:"#{name}_include_all_lower_array"]
        relation = visible(relation, name).where_array_includes_all_lower(name, params[:"#{name}_include_all_lower_array"])
      end

      if params[:"any_#{singular_name}_matches_regex"]
        relation = visible(relation, name).where_any_in_array_matches_regex(name, params[:"any_#{singular_name}_matches_regex"])
      end

      if params[:"#{singular_name}_count"]
        relation = visible(relation, name).where_array_count(name, params[:"#{singular_name}_count"])
      end

      relation
    end

    def search_association_attribute(attr)
      association = relation.reflect_on_association(attr)
      relation = self.relation

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
        relation = visible(relation, attr).includes(attr).references(attr).where(attr => model.visible(current_user).search(params[attr], current_user).reorder(nil))
      end

      relation
    end

    def search_polymorphic_attribute(attr)
      model_keys = ((relation.model_types || []) & params.keys)
      # The user can only logically specify one model at a time, so more than that should return no results
      return none if model_keys.length > 1

      relation = self.relation
      model_specified = false
      model_key = model_keys[0]
      if model_keys.length == 1 && parameter_hash?(params[model_key])
        # Returning none here for the same reason specified above
        return none if params["#{attr}_type"].present? && params["#{attr}_type"] != model_key
        model_specified = true
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

      self_table = relation.arel_table
      model_table = model.arel_table
      model_exists = model.model_restriction(model_table).where(model_table[foreign_key].eq(self_table[primary_key])).exists
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

  def qualified_column_for(attr)
    return attr if attr.to_s.include?(".")
    "#{table_name}.#{column_for_attribute(attr).name}"
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

  # Convert a column name or a raw SQL fragment to an Arel node.
  #
  # @param field [String, Arel::Nodes::Node] an Arel node, the name of a table
  #   column, or a raw SQL fragment
  # @return Arel::Expressions the Arel node
  def arel_node(field)
    if field.is_a?(Arel::Nodes::Node)
      field
    elsif has_attribute?(field)
      arel_table[field]
    else
      Arel.sql(field.to_s)
    end
  end

  def sql_value(value)
    if Arel.arel_node?(value)
      value
    elsif value.is_a?(String)
      Arel::Nodes.build_quoted(value)
    elsif value.is_a?(Symbol)
      arel_table[value]
    elsif value.is_a?(Array)
      sql_array(value)
    else
      raise ArgumentError
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
