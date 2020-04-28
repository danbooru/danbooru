module Searchable
  extend ActiveSupport::Concern

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
  def where_regex(attr, value)
    where("#{qualified_column_for(attr)} ~ ?", "(?e)" + value)
  end

  def where_not_regex(attr, value)
    where.not("#{qualified_column_for(attr)} ~ ?", "(?e)" + value)
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
    where_operator("cardinality(#{qualified_column_for(attr)})", *range)
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
    attributes.reduce(all) do |relation, attribute|
      relation.search_attribute(attribute, params)
    end
  end

  def search_attribute(name, params)
    column = column_for_attribute(name)
    type = column.type || reflect_on_association(name)&.class_name

    if column.try(:array?)
      return search_array_attribute(name, type, params)
    end

    case type
    when "User"
      search_user_attribute(name, params)
    when "Post"
      search_post_id_attribute(params)
    when :string, :text
      search_text_attribute(name, params)
    when :boolean
      search_boolean_attribute(name, params)
    when :integer, :datetime
      numeric_attribute_matches(name, params[name])
    when :inet
      search_inet_attribute(name, params)
    else
      raise NotImplementedError, "unhandled attribute type: #{name}"
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

  def search_user_attribute(attr, params)
    if params["#{attr}_id"]
      search_attribute("#{attr}_id", params)
    elsif params["#{attr}_name"]
      where(attr => User.search(name_matches: params["#{attr}_name"]).reorder(nil))
    elsif params[attr]
      where(attr => User.search(params[attr]).reorder(nil))
    else
      all
    end
  end

  def search_post_id_attribute(params)
    relation = all

    if params[:post_id].present?
      relation = relation.search_attribute(:post_id, params)
    end

    if params[:post_tags_match].present?
      relation = relation.where(post_id: Post.tag_match(params[:post_tags_match]).reorder(nil))
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

  def apply_default_order(params)
    if params[:order] == "custom"
      parse_ids = PostQueryBuilder.new(nil).parse_range(params[:id], :integer)
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

    default_attributes = (attribute_names.map(&:to_sym) & %i[id created_at updated_at])
    search_attributes(params, *default_attributes)
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
