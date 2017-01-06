class CreateTokenBuckets < ActiveRecord::Migration
  def up
  	execute "create unlogged table token_buckets (user_id integer, last_touched_at timestamp not null, token_count real not null)"
  	add_index :token_buckets, :user_id, :unique => true
  end

  def down
  	raise NotImplementedError
  end
end
