class AddAntecedentNamePatternIndexAndPostCountToTagAliases < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    execute "create index index_tag_aliases_on_antecedent_name_pattern on tag_aliases (antecedent_name text_pattern_ops)"
    add_column :tag_aliases, :post_count, :integer, :null => false, :default => 0
    add_index :tag_aliases, :post_count
  end

  def down
    execute "set statement_timeout = 0"
    execute "drop index index_tag_aliases_on_antecedent_name_pattern"
    remove_column :tag_aliases, :post_count
  end
end
