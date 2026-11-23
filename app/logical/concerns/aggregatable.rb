# frozen_string_literal: true

module Aggregatable
  extend ActiveSupport::Concern

  MAX_GROUP_LIMIT = 200
  MAX_TIMESERIES_BUCKETS = 2_000
  PERIODS = %w[second minute hour day week month year]

  class Error < StandardError; end

  # @param columns [Hash{Symbol => Symbol, Array, Arel::Nodes::Node}] The aggregate columns to select, e.g. `{ posts: :count, uploaders: [:count_distinct, :uploader_id] }`. See `aggregate_function`.
  # @param groups [Array<String>] The columns or associations to group by, e.g. `["uploader", "uploader.level", "rating"]`.
  def timeseries(period: "day", date_column: :created_at, from: first[date_column], to: Time.now.utc, groups: [], group_limit: 10, columns: { count: :count })
    raise Error, "The period must be one of: #{PERIODS.join(", ")}." if !period.in?(PERIODS)
    raise Error, "The group limit can't be more than #{MAX_GROUP_LIMIT}." if !group_limit.to_i.in?(0..MAX_GROUP_LIMIT)
    raise ArgumentError if all.group_values.present?

    if (to.to_time - from.to_time).abs > MAX_TIMESERIES_BUCKETS.send(period.pluralize)
      raise Error, "The date range can't be longer than #{MAX_TIMESERIES_BUCKETS} #{period.pluralize}. Choose a longer period or a shorter date range."
    end

    date_range = date_range(from, to)
    from = from.to_date
    to = to.to_date

    group_fields = groups.map { |name| reflections[name.to_s]&.foreign_key || name.to_s }
    dates_table = Arel::Table.new("dates")
    subquery_table = Arel::Table.new("subquery")

    # SELECT date_trunc('day', posts.created_at) AS date FROM posts WHERE created_at >= from AND created_at < to + 1 day GROUP BY date
    subquery = select(date_trunc(period, date_column).as("date")).where(date_column => date_range).group(Arel.sql("date")).reorder(nil)

    group_fields.each do |name|
      subquery = join_group_association(subquery, name)

      # SELECT date_trunc('day', posts.created_at) AS date, uploader_id FROM posts WHERE created_at >= from AND created_at < to + 1 day GROUP BY date, uploader_id
      column = group_column(name)
      subquery = subquery.select(column).group(column)
    end

    columns.each do |name, function|
      # SELECT date_trunc('day', posts.created_at) AS date, uploader_id, COUNT(*) AS count FROM posts WHERE created_at >= from AND created_at < to + 1 day GROUP BY date, uploader_id
      subquery = subquery.select(column_alias(aggregate_function(function), name))
    end

    # SELECT date_trunc('day', dates) AS date FROM generate_series(from, to, '1 day'::interval) AS dates
    dates = Arel::SelectManager.new.project(date_trunc(period, Arel.sql("dates")).as("date")).from(generate_timeseries(from, to, period).as("dates"))

    # SELECT dates.date FROM (SELECT date_trunc('day', dates) AS date FROM generate_series(from, to, '1 day'::interval) AS dates) AS dates
    query = unscoped.select(dates_table[:date]).from(dates.as(dates_table.name))

    # ON subquery.date = dates.date
    on_clause = subquery_table[:date].eq(dates_table[:date])

    group_fields.each do |field|
      column = group_column(field)
      groups_table = Arel::Table.new(column.name.to_s.pluralize)

      # CROSS JOIN (SELECT uploader_id FROM posts WHERE created_at >= from AND created_at < to + 1 day AND uploader_id IS NOT NULL GROUP BY uploader_id ORDER BY COUNT(*) DESC LIMIT 10) AS uploader_ids
      join = select(column).where(date_column => date_range).where(column.not_eq(nil)).group(column).reorder(Arel.sql("COUNT(*) DESC")).limit(group_limit)
      join = join_group_association(join, field)

      # SELECT dates.date, uploader_ids.uploader_id
      # FROM (SELECT date_trunc('day', dates) AS date FROM generate_series('2022-01-01', '2022-02-15', '1 day'::interval) AS dates) AS dates
      # CROSS JOIN (SELECT uploader_id FROM posts WHERE created_at >= from AND created_at < to + 1 day GROUP BY uploader_ids ORDER BY COUNT(*) DESC LIMIT 10) AS uploader_ids
      query = query.select(groups_table[column.name])
      query = query.joins(Arel::Nodes::StringJoin.new(Arel.sql("CROSS JOIN ?", join.arel.as(groups_table.name))))

      # ON subquery.date = dates.date AND subquery.uploader_id = uploader_ids.uploader_id
      on_clause = on_clause.and(subquery_table[column.name].eq(groups_table[column.name]))
    end

    query = query.joins(Arel::Nodes::OuterJoin.new(subquery.arel.as(subquery_table.name), Arel::Nodes::On.new(on_clause)))
    query = query.reorder(Arel.sql("date DESC"))

    columns.each_key do |name|
      # SELECT dates.date, uploader_ids.uploader_id, COALESCE(subquery.count, 0) AS count FROM ...
      query = query.select(column_alias(coalesce(subquery_table[name], 0), name))
    end

    # query =
    #   SELECT
    #     dates.date,
    #     uploader_ids.uploader_id,
    #     COALESCE(subquery.count, 0) AS count
    #   FROM (
    #     SELECT date_trunc('day', dates) AS date FROM generate_series(from, to, '1 day'::interval) AS dates
    #   ) AS dates
    #   CROSS JOIN (
    #     SELECT uploader_id FROM posts WHERE created_at >= from AND created_at < to + 1 day AND uploader_id IS NOT NULL GROUP BY uploader_id ORDER BY COUNT(*) DESC LIMIT 10
    #   ) AS uploader_ids
    #   LEFT OUTER JOIN (
    #     SELECT
    #       date_trunc('day', posts.created_at) AS date,
    #       uploader_id,
    #       COUNT(*) AS count
    #     FROM posts
    #     WHERE created_at >= from AND created_at < to + 1 day
    #     GROUP BY date, uploader_id
    #   ) subquery ON subquery.date = dates.date AND subquery.uploader_id = uploader_ids.uploader_id
    #   ORDER BY date DESC

    build_dataframe(query, groups)
  end

  # @param columns [Hash{Symbol => Symbol, Array, Arel::Nodes::Node}] The aggregate columns to select, e.g. `{ posts: :count, uploaders: [:count_distinct, :uploader_id] }`. See `aggregate_function`.
  # @param groups [Array<String>] The columns or associations to group by, e.g. `["uploader", "uploader.level", "rating"]`.
  def aggregate(date_column: :created_at, from: first[date_column], to: Time.now.utc, groups: [], limit: 50, columns: { count: :count }, order: aggregate_function(columns.first.second).desc)
    raise Error, "The group limit can't be more than #{MAX_GROUP_LIMIT}." if !limit.to_i.in?(0..MAX_GROUP_LIMIT)

    group_fields = groups.map { |name| reflections[name.to_s]&.foreign_key || name.to_s }

    query = where(date_column => date_range(from, to)).reorder(order).limit(limit)

    group_fields.each do |name|
      column = group_column(name)
      query = join_group_association(query, name)
      query = query.select(column).group(column).where(column.not_eq(nil))
    end

    columns.each do |name, function|
      query = query.select(column_alias(aggregate_function(function), name))
    end

    build_dataframe(query, groups)
  end

  # Build an aggregate function for a column passed to `timeseries` or `aggregate`.
  #
  # @param function [Symbol, Array, Arel::Nodes::Node] `:count`, `[:count_distinct, column]`, `[:sum, column]`, or an Arel node.
  # @return [Arel::Nodes::Node] `COUNT(*)`, `COUNT(DISTINCT posts.uploader_id)`, `SUM(media_assets.file_size)`, or the node itself.
  def aggregate_function(function)
    case function
    in :count
      Arel.star.count
    in [:count_distinct, Symbol => column] if has_attribute?(column)
      arel_table[column].count(true)
    in [:sum, Symbol => column] if has_attribute?(column)
      arel_table[column].sum
    in _ if Arel.arel_node?(function)
      function
    else
      raise ArgumentError, "Unknown aggregate function: #{function.inspect}"
    end
  end

  def group_by_period(period = "day", column = :created_at)
    select(date_trunc(period, column).as("date")).group("date").reorder(Arel.sql("date DESC"))
  end

  def select_all
    connection.select_all(all)
  end

  def date_trunc(field, column)
    sql_function(:date_trunc, field, column)
  end

  def coalesce(column, value)
    sql_function(:coalesce, column, value)
  end

  def generate_series(from, to, interval)
    sql_function(:generate_series, from, to, interval)
  end

  def generate_timeseries(from, to, interval)
    from = Arel.sql("?::timestamp", from)
    to = Arel.sql("?::timestamp", to)
    step = Arel.sql("?::interval", "1 #{interval}")

    generate_series(date_trunc(interval, from), date_trunc(interval, to), step)
  end

  private

  # @param name [String] A column name (e.g. "uploader_id"), or an association and a column on it (e.g. "uploader.level").
  # @return [Arel::Attributes::Attribute] The column, qualified with the table name or the association's table alias.
  def group_column(name)
    association, column = name.split(".", 2)

    if column.nil? && has_attribute?(association)
      arel_table[association]
    elsif column.present? && reflect_on_association(association)&.klass&.has_attribute?(column)
      Arel::Table.new(association)[column]
    else
      raise ArgumentError, "#{name.inspect} is not a column of #{table_name}"
    end
  end

  # @return [Range] The range from `from` to `to`. If `to` is a date, the range includes the whole day, not only midnight.
  def date_range(from, to)
    to.instance_of?(Date) ? (from...to.next_day) : (from..to)
  end

  # Join the association for a group like "uploader.level", aliased by the association's name (e.g. "INNER JOIN users uploader ...").
  def join_group_association(relation, name)
    return relation unless name.include?(".")

    association = name.split(".").first.to_sym
    relation.joins(association).where.associated(association) # XXX hack to force the table alias to be used
  end

  # @return [Arel::Nodes::As] `node AS "name"`, with the name quoted.
  def column_alias(node, name)
    node.as(connection.quote_column_name(name))
  end

  def build_dataframe(query, groups)
    results = query.select_all
    types = results.columns.index_with { :object }

    associations = groups.map do |name|
      name = name.split(".").first if name.include?(".")
      reflections[name.to_s]
    end.compact_blank

    dataframe = Danbooru::DataFrame.new(results.to_a, types: types)
    dataframe = dataframe.preload_associations(associations)
    dataframe
  end
end
