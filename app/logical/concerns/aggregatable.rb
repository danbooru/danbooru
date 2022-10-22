# frozen_string_literal: true

module Aggregatable
  extend ActiveSupport::Concern

  def timeseries(period: "day", date_column: :created_at, from: first[date_column], to: Time.now.utc, groups: [], group_limit: 10, columns: { count: "COUNT(*)" })
    raise ArgumentError, "invalid period: #{period}" if !period.in?(%w[second minute hour day week month quarter year])
    raise ArgumentError if all.group_values.present?

    from = from.to_date
    to = to.to_date

    group_associations = groups.map { |name| reflections[name.to_s] }.compact_blank
    group_fields = groups.map { |name| reflections[name.to_s]&.foreign_key || name }

    # SELECT date_trunc('day', posts.created_at) AS date FROM posts WHERE created_at BETWEEN from AND to GROUP BY date
    subquery = select(date_trunc(period, date_column).as("date")).where(date_column => (from..to)).group("date").reorder(nil)

    group_fields.each do |name|
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

      # SELECT dates.date, uploader_ids.uploader_id
      # FROM (SELECT date_trunc('day', dates) AS date FROM generate_series('2022-01-01', '2022-02-15', '1 day'::interval) AS dates) AS dates
      # CROSS JOIN (SELECT uploader_id FROM posts WHERE created_at BETWEEN from AND to GROUP BY uploader_ids ORDER BY COUNT(*) DESC LIMIT 10) AS uploader_ids.uploader_id
      query = query.select("#{connection.quote_table_name(field.to_s.pluralize)}.#{connection.quote_column_name(field)}")
      query = query.joins("CROSS JOIN (#{join.to_sql}) AS #{connection.quote_column_name(field.to_s.pluralize)}")
    end

    # on_clause = "subquery.date = dates.date AND subquery.uploader_id = uploader_ids.uploader_id"
    on_clause = ["date", *group_fields].map { |group| "subquery.#{connection.quote_column_name(group)} = #{connection.quote_table_name(group.to_s.pluralize)}.#{connection.quote_column_name(group)}" }.join(" AND ")
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

    results = query.select_all
    types = results.columns.map { |column| [column, :object] }.to_h

    dataframe = Danbooru::DataFrame.new(results.to_a, types: types)
    dataframe = dataframe.preload_associations(group_associations)
    dataframe
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
end
