class ExplainParser
  extend Memoist
  attr_reader :relation

  def initialize(relation)
    @relation = relation
  end

  def query_plan
    result = ApplicationRecord.connection.select_one("EXPLAIN (FORMAT JSON) #{sql}")
    json = JSON.parse(result["QUERY PLAN"])
    json.first["Plan"]
  end

  def row_count
    query_plan["Plan Rows"]
  end

  def sql
    relation.reorder(nil).to_sql
  end

  memoize :query_plan
end
