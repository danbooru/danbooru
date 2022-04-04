# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  def parameter_hash?(params)
    params.present? && params.respond_to?(:each_value)
  end

  def parameter_depth(params)
    return 0 if params.values.empty?
    1 + params.values.map { |v| parameter_hash?(v) ? parameter_depth(v) : 1 }.max
  end

  def negate_relation
    relation = unscoped
    relation = relation.from(all.from_clause.value) if all.from_clause.value.present?
    relation.where(all.where_clause.invert.ast)
  end

  # XXX hacky method to AND two relations together.
  # XXX Replace with ActiveRecord#and (cf https://github.com/rails/rails/pull/39328)
  def and_relation(relation)
    q = all
    q = q.where(relation.where_clause.ast) if relation.where_clause.present?
    q = q.joins(relation.joins_values + q.joins_values) if relation.joins_values.present?
    q = q.order(relation.order_values) if relation.order_values.present?
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
      ips = value.split(/[, ]+/).map { |ip| Danbooru::IpAddress.new(ip).to_string }
      where("#{qualified_column_for(attr)} = ANY(ARRAY[?]::inet[])", ips)
    else
      ip = Danbooru::IpAddress.new(value)
      where("#{qualified_column_for(attr)} <<= ?", ip.to_string)
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

  # The column should have a `array_to_tsvector(column) using gin` index for best performance.
  def where_any_in_array_starts_with(attr, value)
    where("array_to_tsvector(#{qualified_column_for(attr)}) @@ ?", value.to_escaped_for_tsquery + ":*")
  end

  def where_text_includes_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}) IN (?)", values.map(&:downcase))
  end

  def where_array_count(attr, value)
    qualified_column = "cardinality(#{qualified_column_for(attr)})"
    range = PostQueryBuilder.parse_range(value, :integer)
    where_operator(qualified_column, *range)
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

  def search_boolean_attribute(attr, params)
    if params[attr].present?
      boolean_attribute_matches(attr, params[attr])
    else
      all
    end
  end

  def search_inet_attribute(attr, params)
    if params[attr].present?
      where_inet_matches(attr, params[attr])
    else
      all
    end
  end

  # value: "5", ">5", "<5", ">=5", "<=5", "5..10", "5,6,7"
  def where_numeric_matches(attribute, value, type = :integer)
    range = PostQueryBuilder.parse_range(value, type)
    where_operator(attribute, *range)
  end

  def boolean_attribute_matches(attribute, value)
    value = value.to_s

    if value.truthy?
      where(attribute => true)
    elsif value.falsy?
      where(attribute => false)
    else
      raise ArgumentError, "value must be truthy or falsy"
    end
  end

  def text_attribute_matches(columns, query)
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

  def search_attributes(params, *attributes)
    raise ArgumentError, "max parameter depth of 10 exceeded" if parameter_depth(params) > 10

    # This allows the hash keys to be either strings or symbols
    indifferent_params = params.try(:with_indifferent_access) || params.try(:to_unsafe_h)
    raise ArgumentError, "unable to process params" if indifferent_params.nil?

    attributes.reduce(all) do |relation, attribute|
      relation.search_attribute(attribute, indifferent_params, CurrentUser.user)
    end
  end

  def search_attribute(name, params, current_user)
    if has_attribute?(name)
      search_basic_attribute(name, params, current_user)
    elsif reflections.has_key?(name.to_s)
      search_association_attribute(name, params, current_user)
    else
      raise ArgumentError, "#{name} is not an attribute or association"
    end
  end

  def search_basic_attribute(name, params, current_user)
    column = column_for_attribute(name)
    type = column.type

    if column.try(:array?)
      subtype = type
      type = :array
    elsif defined_enums.has_key?(name.to_s)
      type = :enum
    end

    case type
    when :string, :text
      search_text_attribute(name, params)
    when :uuid
      search_uuid_attribute(name, params)
    when :boolean
      search_boolean_attribute(name, params)
    when :integer, :float, :datetime, :interval
      search_numeric_attribute(name, params, type: type)
    when :inet
      search_inet_attribute(name, params)
    when :enum
      search_enum_attribute(name, params)
    when :jsonb
      search_jsonb_attribute(name, params)
    when :array
      search_array_attribute(name, subtype, params)
    else
      raise NotImplementedError, "unhandled attribute type: #{name} (#{type})"
    end
  end

  def search_numeric_attribute(attr, params, key: attr, type: :integer)
    relation = all

    if params[key].present?
      relation = relation.where_numeric_matches(attr, params[key], type)
    end

    if params[:"#{key}_not"].present?
      relation = relation.where.not(id: relation.where_numeric_matches(attr, params[:"#{key}_not"], type))
    end

    if params[:"#{key}_eq"].present?
      relation = relation.where_operator(attr, :eq, params[:"#{key}_eq"])
    end

    if params[:"#{key}_not_eq"].present?
      relation = relation.where_operator(attr, :not_eq, params[:"#{key}_not_eq"])
    end

    if params[:"#{key}_gt"].present?
      relation = relation.where_operator(attr, :gt, params[:"#{key}_gt"])
    end

    if params[:"#{key}_gteq"].present?
      relation = relation.where_operator(attr, :gteq, params[:"#{key}_gteq"])
    end

    if params[:"#{key}_lt"].present?
      relation = relation.where_operator(attr, :lt, params[:"#{key}_lt"])
    end

    if params[:"#{key}_lteq"].present?
      relation = relation.where_operator(attr, :lteq, params[:"#{key}_lteq"])
    end

    relation
  end

  def search_text_attribute(attr, params)
    relation = all

    if params[attr].present?
      relation = relation.where(attr => params[attr])
    end

    if params[:"#{attr}_present"].present? && params[:"#{attr}_present"].truthy?
      relation = relation.where.not(attr => "")
    end

    if params[:"#{attr}_present"].present? && params[:"#{attr}_present"].falsy?
      relation = relation.where(attr => "")
    end

    if params[:"#{attr}_eq"].present?
      relation = relation.where(attr => params[:"#{attr}_eq"])
    end

    if params[:"#{attr}_not_eq"].present?
      relation = relation.where.not(attr => params[:"#{attr}_not_eq"])
    end

    if params[:"#{attr}_like"].present?
      relation = relation.where_like(attr, params[:"#{attr}_like"])
    end

    if params[:"#{attr}_ilike"].present?
      relation = relation.where_ilike(attr, params[:"#{attr}_ilike"])
    end

    if params[:"#{attr}_not_like"].present?
      relation = relation.where_not_like(attr, params[:"#{attr}_not_like"])
    end

    if params[:"#{attr}_not_ilike"].present?
      relation = relation.where_not_ilike(attr, params[:"#{attr}_not_ilike"])
    end

    if params[:"#{attr}_regex"].present?
      relation = relation.where_regex(attr, params[:"#{attr}_regex"])
    end

    if params[:"#{attr}_not_regex"].present?
      relation = relation.where_not_regex(attr, params[:"#{attr}_not_regex"])
    end

    if params[:"#{attr}_array"].present?
      relation = relation.where(attr => params[:"#{attr}_array"])
    end

    if params[:"#{attr}_comma"].present?
      relation = relation.where(attr => params[:"#{attr}_comma"].split(','))
    end

    if params[:"#{attr}_space"].present?
      relation = relation.where(attr => params[:"#{attr}_space"].split(' '))
    end

    if params[:"#{attr}_lower_array"].present?
      relation = relation.where_text_includes_lower(attr, params[:"#{attr}_lower_array"])
    end

    if params[:"#{attr}_lower_comma"].present?
      relation = relation.where_text_includes_lower(attr, params[:"#{attr}_lower_comma"].split(','))
    end

    if params[:"#{attr}_lower_space"].present?
      relation = relation.where_text_includes_lower(attr, params[:"#{attr}_lower_space"].split(' '))
    end

    relation
  end

  def search_uuid_attribute(attr, params)
    relation = all

    if params[attr].present?
      relation = relation.where(attr => params[attr])
    end

    if params[:"#{attr}_eq"].present?
      relation = relation.where(attr => params[:"#{attr}_eq"])
    end

    if params[:"#{attr}_not_eq"].present?
      relation = relation.where.not(attr => params[:"#{attr}_not_eq"])
    end

    relation
  end

  def search_association_attribute(attr, params, current_user)
    association = reflect_on_association(attr)
    relation = all

    if association.polymorphic?
      return search_polymorphic_attribute(attr, params, current_user)
    end

    if association.belongs_to?
      relation = relation.search_attribute(association.foreign_key, params, current_user)
    end

    model = association.klass
    if model == User && params["#{attr}_name"].present?
      name = params["#{attr}_name"]
      if name.include?("*")
        relation = relation.where(attr => User.search(name_matches: name).reorder(nil))
      else
        relation = relation.where(attr => User.find_by_name(name))
      end
    end

    if model == Post && params["#{attr}_tags_match"].present?
      relation = relation.where(attr => Post.user_tag_match(params["#{attr}_tags_match"], current_user).reorder(nil))
    end

    if params["has_#{attr}"].to_s.truthy? || params["has_#{attr}"].to_s.falsy?
      relation = relation.search_has_include(attr, params["has_#{attr}"].to_s.truthy?, model)
    end

    if parameter_hash?(params[attr])
      relation = relation.includes(attr).references(attr).where(attr => model.visible(current_user).search(params[attr]).reorder(nil))
    end

    relation
  end

  def search_polymorphic_attribute(attr, params, current_user)
    model_keys = ((model_types || []) & params.keys)
    # The user can only logically specify one model at a time, so more than that should return no results
    return none if model_keys.length > 1

    relation = all
    model_specified = false
    model_key = model_keys[0]
    if model_keys.length == 1 && parameter_hash?(params[model_key])
      # Returning none here for the same reason specified above
      return none if params["#{attr}_type"].present? && params["#{attr}_type"] != model_key
      model_specified = true
      model = Kernel.const_get(model_key)
      relation = relation.where(attr => model.visible(current_user).search(params[model_key]))
    end

    if params["#{attr}_id"].present?
      relation = relation.search_attribute("#{attr}_id", params, current_user)
    end

    if params["#{attr}_type"].present? && !model_specified
      relation = relation.search_attribute("#{attr}_type", params, current_user)
    end

    relation
  end

  def search_enum_attribute(name, params)
    relation = all

    if params[name].present?
      value = params[name].split(/[, ]+/).map(&:downcase)
      relation = relation.where(name => value)
    end

    if params[:"#{name}_not"].present?
      value = params[:"#{name}_not"].split(/[, ]+/).map(&:downcase)
      relation = relation.where.not(name => value)
    end

    relation = relation.search_numeric_attribute(name, params, key: :"#{name}_id")

    relation
  end

  def search_jsonb_attribute(name, params)
    relation = all

    if params[name].present?
      relation = relation.where_json_contains(:metadata, params[name])
    end

    if params["#{name}_has_key"]
      relation = relation.where_json_has_key(:metadata, params["#{name}_has_key"])
    end

    if params["has_#{name}"].to_s.truthy?
      relation = relation.where.not(name => "{}")
    elsif params["has_#{name}"].to_s.falsy?
      relation = relation.where(name => "{}")
    end

    relation
  end

  def search_array_attribute(name, type, params)
    relation = all
    singular_name = name.to_s.singularize

    if params[:"#{name}_include_any"]
      items = params[:"#{name}_include_any"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_any(name, items)
    end

    if params[:"#{name}_include_all"]
      items = params[:"#{name}_include_all"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_all(name, items)
    end

    if params[:"#{name}_include_any_array"]
      relation = relation.where_array_includes_any(name, params[:"#{name}_include_any_array"])
    end

    if params[:"#{name}_include_all_array"]
      relation = relation.where_array_includes_all(name, params[:"#{name}_include_all_array"])
    end

    if params[:"#{name}_include_any_lower"]
      items = params[:"#{name}_include_any_lower"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_any_lower(name, items)
    end

    if params[:"#{name}_include_all_lower"]
      items = params[:"#{name}_include_all_lower"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_all_lower(name, items)
    end

    if params[:"#{name}_include_any_lower_array"]
      relation = relation.where_array_includes_any_lower(name, params[:"#{name}_include_any_lower_array"])
    end

    if params[:"#{name}_include_all_lower_array"]
      relation = relation.where_array_includes_all_lower(name, params[:"#{name}_include_all_lower_array"])
    end

    if params[:"any_#{singular_name}_matches_regex"]
      relation = relation.where_any_in_array_matches_regex(name, params[:"any_#{singular_name}_matches_regex"])
    end

    if params[:"#{singular_name}_count"]
      relation = relation.where_array_count(name, params[:"#{singular_name}_count"])
    end

    relation
  end

  def search_has_include(name, exists, model)
    if column_names.include?("#{name}_id")
      return exists ? where.not("#{name}_id" => nil) : where("#{name}_id" => nil)
    end

    association = reflect_on_association(name)
    primary_key = association.active_record_primary_key
    foreign_key = association.foreign_key
    # The belongs_to macro has its primary and foreign keys reversed
    primary_key, foreign_key = foreign_key, primary_key if association.macro == :belongs_to
    return all if primary_key.nil? || foreign_key.nil?

    self_table = arel_table
    model_table = model.arel_table
    model_exists = model.model_restriction(model_table).where(model_table[foreign_key].eq(self_table[primary_key])).exists
    if exists
      attribute_restriction(name).where(model_exists)
    else
      attribute_restriction(name).where.not(model_exists)
    end
  end

  def apply_default_order(params)
    if params[:order] == "custom"
      parse_ids = PostQueryBuilder.parse_range(params[:id], :integer)
      if parse_ids[0] == :in
        return in_order_of(:id, parse_ids[1])
      end
    end

    default_order
  end

  def default_order
    order(id: :desc)
  end

  private

  def qualified_column_for(attr)
    "#{table_name}.#{column_for_attribute(attr).name}"
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
