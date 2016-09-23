class AddIndexToUsersBitPrefs < ActiveRecord::Migration
  def up
    execute "set statement_timeout = 0"
    execute <<-'SQL'
      CREATE OR REPLACE FUNCTION bit_position_array(x bigint)
      RETURNS integer[] AS $BODY$
      select array_agg(i) 
        from generate_series(0, floor(log(2, x))::integer) i
       where (x & (1::bigint << i)) > 0;
      $BODY$ LANGUAGE sql IMMUTABLE
    SQL
    
    execute <<-'SQL'
      CREATE INDEX index_users_on_bit_prefs_array
       ON users USING gin (bit_position_array(bit_prefs) _int4_ops)
    SQL
  end

  def down
    execute "set statement_timeout = 0"
    execute "DROP INDEX index_users_on_bit_prefs_array"
    execute "DROP FUNCTION bit_position_array(x bigint)"
  end
end
