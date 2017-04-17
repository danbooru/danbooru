class AddReasonTsVectorIndexToPostFlagsAndAppeals < ActiveRecord::Migration
  def up
    execute "SET statement_timeout = 0"
    execute "CREATE INDEX index_post_flags_on_reason_tsvector ON post_flags USING gin (to_tsvector('pg_catalog.english', reason))"
    execute "CREATE INDEX index_post_appeals_on_reason_tsvector ON post_appeals USING gin (to_tsvector('pg_catalog.english', reason))"
  end

  def down
    execute "SET statement_timeout = 0"
    remove_index :post_flags, name: "index_post_flags_on_reason_tsvector"
    remove_index :post_appeals, name: "index_post_appeals_on_reason_tsvector"
  end
end
