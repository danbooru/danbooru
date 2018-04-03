class AddTrigramIndexToTags < ActiveRecord::Migration[4.2]
  def up
  	Tag.without_timeout do
	    execute "create index index_tags_on_name_trgm on tags using gin (name gin_trgm_ops)"
	  end
  end

  def down
  	Tag.without_timeout do
	    execute "drop index index_tags_on_name_trgm"
	  end
  end
end
