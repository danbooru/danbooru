# frozen_string_literal: true

module Aggregatable
  extend ActiveSupport::Concern

  def timeseries(period: "day", date_column: :created_at, from: first[date_column], to: Time.now.utc, columns: { count: "COUNT(*)" })
    raise ArgumentError, "invalid period: #{period}" if !period.in?(%w[second minute hour day week month quarter year])

    from = from.to_date
    to = to.to_date

    # SELECT
    #   date_trunc('day', posts.created_at) AS date
    #   COUNT(*) AS count
    # FROM posts
    # WHERE posts.created_at BETWEEN from AND to
    # GROUP BY date
    subquery = select(date_trunc(period, date_column).as("date")).where(date_column => (from..to)).group("date").reorder(nil)
    columns.each do |name, sql|
      # SELECT COUNT(*) AS count
      subquery = subquery.select(Arel.sql(sql).as(name.to_s).to_sql)
    end

    # SELECT date_trunc('day', dates) AS date FROM generate_series('2022-01-01', '2022-02-15', '1 day'::interval) AS dates
    dates = "SELECT #{date_trunc(period, Arel.sql("dates")).to_sql} AS date FROM #{generate_timeseries(from, to, period).to_sql} AS dates"

    # SELECT
    #   date_trunc('day', dates.date) AS date,
    #   COALESCE(subquery.count, 0) AS count
    # FROM (
    #   SELECT date_trunc('day', dates) AS date
    #   FROM generate_series(from, to, '1 day'::interval) AS dates
    # ) AS dates
    # LEFT OUTER JOIN (
    #   SELECT
    #     date_trunc('day', posts.created_at) AS date,
    #     COUNT(*) AS count
    #   FROM posts
    #   WHERE posts.created_at BETWEEN from AND to
    #   GROUP BY date
    # ) AS subquery
    # ORDER BY date DESC
    query =
      unscoped.
      select(date_trunc(period, Arel.sql("dates.date")).as("date")).
      from("(#{dates}) AS dates").
      joins("LEFT OUTER JOIN (#{subquery.to_sql}) AS subquery ON subquery.date = dates.date").
      order("date DESC")

    columns.each do |name, sql|
      # SELECT COALESCE(subquery.count, 0) AS count
      query = query.select(coalesce(Arel.sql("subquery.#{connection.quote_column_name(name)}"), 0).as(name.to_s))
    end

    query.select_all
  end

  def group_by_period(period = "day", column = :created_at)
    select(date_trunc(period, column).as("date")).group("date").order(Arel.sql("date DESC"))
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
