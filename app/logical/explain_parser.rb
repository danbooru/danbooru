class ExplainParser < Struct.new(:sql)
  extend Memoist

  def query_plan
    result = ApplicationRecord.connection.select_one("EXPLAIN (FORMAT JSON) #{sql}")
    json = JSON.parse(result["QUERY PLAN"])
    json.first["Plan"]
  end

  def row_count
    query_plan["Plan Rows"]
  end

  memoize :query_plan
end
