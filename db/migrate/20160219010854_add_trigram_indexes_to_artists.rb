class AddTrigramIndexesToArtists < ActiveRecord::Migration[4.2]
  def up
    execute "create index index_artists_on_name_trgm on artists using gin (name gin_trgm_ops)"
    execute "create index index_artists_on_group_name_trgm on artists using gin (group_name gin_trgm_ops)"
    execute "create index index_artists_on_other_names_trgm on artists using gin (other_names gin_trgm_ops)"
  end

  def down
    execute "drop index index_artists_on_other_names_trgm"
    execute "drop index index_artists_on_group_name_trgm"
    execute "drop index index_artists_on_name_trgm"
  end
end
