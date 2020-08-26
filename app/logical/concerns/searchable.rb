module Searchable
  extend ActiveSupport::Concern

  def parameter_hash?(params)
    params.present? && params.respond_to?(:each_value)
  end

  def parameter_depth(params)
    return 0 if params.values.empty?
    1 + params.values.map { |v| parameter_hash?(v) ? parameter_depth(v) : 1 }.max
  end

  def negate(kind = :nand)
    unscoped.where(all.where_clause.invert(kind).ast)
  end

  # XXX hacky method to AND two relations together.
  def and(relation)
    q = all
    q = q.where(relation.where_clause.ast) if relation.where_clause.present?
    q = q.joins(relation.joins_values + q.joins_values) if relation.joins_values.present?
    q = q.order(relation.order_values) if relation.order_values.present?
    q
  end

  # `operator` is an Arel::Predications method: :eq, :gt, :lt, :between, :in, etc.
  # https://github.com/rails/rails/blob/master/activerecord/lib/arel/predications.rb
  def where_operator(field, operator, *args)
    if field.is_a?(Symbol)
      attribute = arel_table[field]
    else
      attribute = Arel.sql(field)
    end

    where(attribute.send(operator, *args))
  end

  def where_like(attr, value)
    where("#{qualified_column_for(attr)} LIKE ? ESCAPE E'\\\\'", value.to_escaped_for_sql_like)
  end

  def where_not_like(attr, value)
    where.not("#{qualified_column_for(attr)} LIKE ? ESCAPE E'\\\\'", value.to_escaped_for_sql_like)
  end

  def where_ilike(attr, value)
    where("#{qualified_column_for(attr)} ILIKE ? ESCAPE E'\\\\'", value.mb_chars.to_escaped_for_sql_like)
  end

  def where_not_ilike(attr, value)
    where.not("#{qualified_column_for(attr)} ILIKE ? ESCAPE E'\\\\'", value.mb_chars.to_escaped_for_sql_like)
  end

  def where_iequals(attr, value)
    where_ilike(attr, value.gsub(/\\/, '\\\\').gsub(/\*/, '\*'))
  end

  # https://www.postgresql.org/docs/current/static/functions-matching.html#FUNCTIONS-POSIX-REGEXP
  # "(?e)" means force use of ERE syntax; see sections 9.7.3.1 and 9.7.3.4.
  def where_regex(attr, value, flags: "e")
    where("#{qualified_column_for(attr)} ~ ?", "(?#{flags})" + value)
  end

  def where_not_regex(attr, value, flags: "e")
    where.not("#{qualified_column_for(attr)} ~ ?", "(?#{flags})" + value)
  end

  def where_inet_matches(attr, value)
    if value.match?(/[, ]/)
      ips = value.split(/[, ]+/).map { |ip| IPAddress.parse(ip).to_string }
      where("#{qualified_column_for(attr)} = ANY(ARRAY[?]::inet[])", ips)
    else
      ip = IPAddress.parse(value)
      where("#{qualified_column_for(attr)} <<= ?", ip.to_string)
    end
  end

  def where_array_includes_any(attr, values)
    where("#{qualified_column_for(attr)} && ARRAY[?]", values)
  end

  def where_array_includes_all(attr, values)
    where("#{qualified_column_for(attr)} @> ARRAY[?]", values)
  end

  def where_array_includes_any_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}::text)::text[] && ARRAY[?]", values.map(&:downcase))
  end

  def where_array_includes_all_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}::text)::text[] @> ARRAY[?]", values.map(&:downcase))
  end

  def where_text_includes_lower(attr, values)
    where("lower(#{qualified_column_for(attr)}) IN (?)", values.map(&:downcase))
  end

  def where_array_count(attr, value)
    qualified_column = "cardinality(#{qualified_column_for(attr)})"
    range = PostQueryBuilder.new(nil).parse_range(value, :integer)
    where_operator(qualified_column, *range)
  end

  def search_boolean_attribute(attribute, params)
    return all unless params.key?(attribute)

    value = params[attribute].to_s
    if value.truthy?
      where(attribute => true)
    elsif value.falsy?
      where(attribute => false)
    else
      raise ArgumentError, "value must be truthy or falsy"
    end
  end

  def search_inet_attribute(attr, params)
    if params[attr].present?
      where_inet_matches(attr, params[attr])
    else
      all
    end
  end

  # range: "5", ">5", "<5", ">=5", "<=5", "5..10", "5,6,7"
  def numeric_attribute_matches(attribute, value)
    return all unless value.present?

    column = column_for_attribute(attribute)
    qualified_column = "#{table_name}.#{column.name}"
    range = PostQueryBuilder.new(nil).parse_range(value, column.type)
    where_operator(qualified_column, *range)
  end

  def text_attribute_matches(attribute, value, index_column: nil, ts_config: "english")
    return all unless value.present?

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
    column = column_for_attribute(name)
    type = column.type || reflect_on_association(name)&.class_name

    if column.try(:array?)
      subtype = type
      type = :array
    elsif defined_enums.has_key?(name.to_s)
      type = :enum
    end

    case type
    when "User"
      search_user_attribute(name, params, current_user)
    when "Post"
      search_post_attribute(name, params, current_user)
    when "Model"
      search_polymorphic_attribute(name, params, current_user)
    when :string, :text
      search_text_attribute(name, params)
    when :boolean
      search_boolean_attribute(name, params)
    when :integer, :datetime
      numeric_attribute_matches(name, params[name])
    when :inet
      search_inet_attribute(name, params)
    when :enum
      search_enum_attribute(name, params)
    when :array
      search_array_attribute(name, subtype, params)
    else
      raise NotImplementedError, "unhandled attribute type: #{name}" if type.blank?
      search_includes(name, params, type, current_user)
    end
  end

  def search_text_attribute(attr, params)
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
    elsif params[:"#{attr}_array"].present?
      where(attr => params[:"#{attr}_array"])
    elsif params[:"#{attr}_comma"].present?
      where(attr => params[:"#{attr}_comma"].split(','))
    elsif params[:"#{attr}_space"].present?
      where(attr => params[:"#{attr}_space"].split(' '))
    elsif params[:"#{attr}_lower_array"].present?
      where_text_includes_lower(attr, params[:"#{attr}_lower_array"])
    elsif params[:"#{attr}_lower_comma"].present?
      where_text_includes_lower(attr, params[:"#{attr}_lower_comma"].split(','))
    elsif params[:"#{attr}_lower_space"].present?
      where_text_includes_lower(attr, params[:"#{attr}_lower_space"].split(' '))
    else
      all
    end
  end

  def search_user_attribute(attr, params, current_user)
    if params["#{attr}_name"].present?
      where(attr => User.search(name_matches: params["#{attr}_name"]).reorder(nil))
    else
      search_includes(attr, params, "User", current_user)
    end
  end

  def search_post_attribute(attr, params, current_user)
    if params["#{attr}_tags_match"]
      where(attr => Post.user_tag_match(params["#{attr}_tags_match"], current_user).reorder(nil))
    else
      search_includes(attr, params, "Post", current_user)
    end
  end

  def search_includes(attr, params, type, current_user)
    model = Kernel.const_get(type)
    if params["#{attr}_id"].present?
      search_attribute("#{attr}_id", params, current_user)
    elsif params["has_#{attr}"].to_s.truthy? || params["has_#{attr}"].to_s.falsy?
      search_has_include(attr, params["has_#{attr}"].to_s.truthy?, model)
    elsif parameter_hash?(params[attr])
      where(attr => model.visible(current_user).search(params[attr]).reorder(nil))
    else
      all
    end
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
    elsif params["#{name}_id"].present?
      relation = relation.numeric_attribute_matches(name, params["#{name}_id"])
    end

    relation
  end

  def search_array_attribute(name, type, params)
    relation = all

    if params[:"#{name}_include_any"]
      items = params[:"#{name}_include_any"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_any(name, items)
    elsif params[:"#{name}_include_all"]
      items = params[:"#{name}_include_all"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_all(name, items)
    elsif params[:"#{name}_include_any_array"]
      relation = relation.where_array_includes_any(name, params[:"#{name}_include_any_array"])
    elsif params[:"#{name}_include_all_array"]
      relation = relation.where_array_includes_all(name, params[:"#{name}_include_all_array"])
    elsif params[:"#{name}_include_any_lower"]
      items = params[:"#{name}_include_any_lower"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_any_lower(name, items)
    elsif params[:"#{name}_include_all_lower"]
      items = params[:"#{name}_include_all_lower"].to_s.scan(/[^[:space:]]+/)
      items = items.map(&:to_i) if type == :integer

      relation = relation.where_array_includes_all_lower(name, items)
    elsif params[:"#{name}_include_any_lower_array"]
      relation = relation.where_array_includes_any_lower(name, params[:"#{name}_include_any_lower_array"])
    elsif params[:"#{name}_include_all_lower_array"]
      relation = relation.where_array_includes_all_lower(name, params[:"#{name}_include_all_lower_array"])
    end

    if params[:"#{name.to_s.singularize}_count"]
      relation = relation.where_array_count(name, params[:"#{name.to_s.singularize}_count"])
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
      parse_ids = PostQueryBuilder.new(nil).parse_range(params[:id], :integer)
      if parse_ids[0] == :in
        return find_ordered(parse_ids[1])
      end
    end

    default_order
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

    default_attributes = (attribute_names.map(&:to_sym) & %i[id created_at updated_at])
    all_attributes = default_attributes + searchable_includes
    search_attributes(params, *all_attributes)
  end

  private

  def qualified_column_for(attr)
    if attr.is_a?(Symbol)
      "#{table_name}.#{column_for_attribute(attr).name}"
    else
      attr.to_s
    end
  end
end
