# frozen_string_literal: true

# Parse the output of the Postgres EXPLAIN command to get how many rows Postgres
# *thinks* a SQL query will return. This is an estimate, and only accurate for
# queries that have a single condition. If the query has multiple conditions,
# then Postgres will assume they're independent (have no overlap), which is not
# always the case.
#
# Used by {PostQueryBuilder#fast_count} to get a fast post count estimate for
# certain single metatag searches.
#
# ExplainParser.new(Post.all).query_plan
# => EXPLAIN (FORMAT JSON) SELECT "posts".* FROM "posts"
# => {
#    "Node Type"=>"Seq Scan",
#    "Parallel Aware"=>false,
#    "Relation Name"=>"posts",
#    "Alias"=>"posts",
#    "Startup Cost"=>0.0,
#    "Total Cost"=>780900.02,
#    "Plan Rows"=>4413102,
#    "Plan Width"=>1268
#  }
#
# @see https://www.postgresql.org/docs/current/sql-explain.html
class ExplainParser
  extend Memoist
  attr_reader :relation

  # @param the ActiveRecord relation
  def initialize(relation)
    @relation = relation
  end

  # @return [Hash] the Postgres query plan
  def query_plan
    result = ApplicationRecord.connection.select_one("EXPLAIN (FORMAT JSON) #{sql}")
    json = JSON.parse(result["QUERY PLAN"])
    json.first["Plan"]
  end

  # @return [Integer] the number of rows Postgres *thinks* the query will return
  def row_count
    query_plan["Plan Rows"]
  end

  # @return [String] the query's SQL
  def sql
    relation.reorder(nil).to_sql
  end

  memoize :query_plan
end
