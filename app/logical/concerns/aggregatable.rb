# frozen_string_literal: true

module Aggregatable
  extend ActiveSupport::Concern

  def timeseries(period: "day", date_column: :created_at, from: first[date_column], to: Time.now.utc, groups: [], group_limit: 10, columns: { count: "COUNT(*)" })
    raise ArgumentError, "invalid period: #{period}" if !period.in?(%w[second minute hour day week month quarter year])
    raise ArgumentError if all.group_values.present?

    from = from.to_date
    to = to.to_date

    group_fields = groups.map { |name| reflections[name.to_s]&.foreign_key || name }

    # SELECT date_trunc('day', posts.created_at) AS date FROM posts WHERE created_at BETWEEN from AND to GROUP BY date
    subquery = select(date_trunc(period, date_column).as("date")).where(date_column => (from..to)).group("date").reorder(nil)

    group_fields.each do |name|
      if name.include?(".")
        association = name.split(".").first.to_sym
        subquery = subquery.joins(association)
        subquery = subquery.where.associated(association) # XXX hack to force table alias to be used (e.g "INNER JOIN users AS uploader ...")
      end

      # SELECT date_trunc('day', posts.created_at) AS date, uploader_id FROM posts WHERE created_at BETWEEN from AND to GROUP BY date, uploader_id
      subquery = subquery.select(name).group(name)
    end

    columns.each do |name, sql|
      # SELECT date_trunc('day', posts.created_at) AS date, uploader_id, COUNT(*) AS count FROM posts WHERE created_at BETWEEN from AND to GROUP BY date, uploader_id
      subquery = subquery.select(Arel.sql(sql).as(name.to_s).to_sql)
    end

    # SELECT date_trunc('day', dates) AS date FROM generate_series(from, to, '1 day'::interval) AS dates
    dates = "SELECT #{date_trunc(period, Arel.sql("dates")).to_sql} AS date FROM #{generate_timeseries(from, to, period).to_sql} AS dates"

    # SELECT dates.date FROM (SELECT date_trunc('day', dates) AS date FROM generate_series(from, to, '1 day'::interval) AS dates) AS dates
    query = unscoped.select("dates.date").from("(#{dates}) AS dates")

    group_fields.each do |field|
      # CROSS JOIN (SELECT uploader_id FROM posts WHERE created_at BETWEEN from AND to AND uploader_id IS NOT NULL GROUP BY uploader_id ORDER BY COUNT(*) DESC LIMIT 10) AS uploader_ids.uploader_id
      join = select(field).where(date_column => (from..to)).where.not(field => nil).group(field).reorder(Arel.sql("COUNT(*) DESC")).limit(group_limit)
      join = join.joins(field.split(".").first.to_sym) if field.include?(".")

      # SELECT dates.date, uploader_ids.uploader_id
      # FROM (SELECT date_trunc('day', dates) AS date FROM generate_series('2022-01-01', '2022-02-15', '1 day'::interval) AS dates) AS dates
      # CROSS JOIN (SELECT uploader_id FROM posts WHERE created_at BETWEEN from AND to GROUP BY uploader_ids ORDER BY COUNT(*) DESC LIMIT 10) AS uploader_ids.uploader_id
      column_name = field.to_s.split(".").second || field.to_s
      query = query.select("#{connection.quote_table_name(column_name.pluralize)}.#{connection.quote_column_name(column_name)}")
      query = query.joins("CROSS JOIN (#{join.to_sql}) AS #{connection.quote_column_name(column_name.pluralize)}")
    end

    # on_clause = "subquery.date = dates.date AND subquery.uploader_id = uploader_ids.uploader_id"
    on_clause = ["date", *group_fields].map do |group|
      column_name = group.to_s.split(".").second || group.to_s
      "subquery.#{connection.quote_column_name(column_name)} = #{connection.quote_table_name(column_name.pluralize)}.#{connection.quote_column_name(column_name)}"
    end.join(" AND ")

    query = query.joins("LEFT OUTER JOIN (#{subquery.to_sql}) AS subquery ON #{on_clause}")
    query = query.reorder("date DESC")

    columns.each do |name, sql|
      # SELECT dates.date, uploader_ids.uploader_id, COALESCE(subquery.count, 0) AS count FROM ...
      query = query.select(coalesce(Arel.sql("subquery.#{connection.quote_column_name(name)}"), 0).as(name.to_s))
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
    #     SELECT uploader_id FROM posts WHERE created_at BETWEEN from AND to AND uploader_id IS NOT NULL GROUP BY uploader_id ORDER BY COUNT(*) DESC LIMIT 10
    #   ) AS uploader_ids.uploader_id
    #   LEFT OUTER JOIN (
    #     SELECT
    #       date_trunc('day', posts.created_at) AS date,
    #       uploader_id,
    #       COUNT(*) AS count
    #     FROM posts
    #     WHERE created_at BETWEEN from AND to
    #     GROUP BY date, uploader_id
    #   ) subquery ON subquery.date = dates.date AND subquery.uploader_id = uploader_ids.uploader_id
    #   ORDER BY date DESC

    build_dataframe(query, groups)
  end

  def aggregate(date_column: :created_at, from: first[date_column], to: Time.now.utc, groups: [], limit: 50, columns: { count: "COUNT(*)" }, order: Arel.sql("#{columns.first.second} DESC"))
    group_fields = groups.map { |name| reflections[name.to_s]&.foreign_key || name }

    query = where(date_column => (from..to)).reorder(order).limit(limit)

    group_fields.each do |name|
      query = query.joins(name.split(".").first.to_sym) if name.include?(".")
      query = query.select(name).group(name).where.not(name => nil)
    end

    columns.each do |name, sql|
      query = query.select(Arel.sql(sql).as(name.to_s).to_sql)
    end

    build_dataframe(query, groups)
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
    generate_series(from, to, Arel.sql("#{connection.quote("1 #{interval}")}::interval"))
  end

  private

  def build_dataframe(query, groups)
    results = query.select_all
    types = results.columns.map { |column| [column, :object] }.to_h

    associations = groups.map do |name|
      name = name.split(".").first if name.include?(".")
      reflections[name.to_s]
    end.compact_blank

    dataframe = Danbooru::DataFrame.new(results.to_a, types: types)
    dataframe = dataframe.preload_associations(associations)
    dataframe
  end
end
