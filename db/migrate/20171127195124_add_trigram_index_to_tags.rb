class AddTrigramIndexToTags < ActiveRecord::Migration
  def up
    execute "create index index_tags_on_name_trgm on tags using gin (name gin_trgm_ops)"
  end

  def down
    execute "drop index index_tags_on_name_trgm"
  end
end
