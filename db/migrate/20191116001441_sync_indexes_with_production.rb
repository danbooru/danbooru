class SyncIndexesWithProduction < ActiveRecord::Migration[6.0]
  def change
    execute "set statement_timeout = 0"

    # these indexes already existed in the production db but were undeclared.
    add_index :wiki_page_versions, :updater_id
    add_index :users, :inviter_id, where: "inviter_id IS NOT NULL"
    add_index :tags, :post_count
    add_index :posts, :approver_id, where: "approver_id IS NOT NULL"
    add_index :post_votes, :created_at
    add_index :mod_actions, :creator_id
    add_index :mod_actions, :created_at
    add_index :forum_posts, :updated_at

    # these indexes already existed but had different where clauses or
    # uniqueness clauses in the production db.
    remove_index :posts, column: :uploader_id
    add_index :posts, :uploader_id, where: "uploader_id IS NOT NULL"
    remove_index :posts, column: :parent_id
    add_index :posts, :parent_id, where: "parent_id IS NOT NULL"
    remove_index :ip_bans, column: :ip_addr
    add_index :ip_bans, :ip_addr
    remove_index :users, column: :email
    add_index :users, :email, where: "email IS NOT NULL"

    reversible do |dir|
      dir.up do
        remove_index :tag_aliases, name: "index_tag_aliases_on_antecedent_name"
        add_index :tag_aliases, :antecedent_name
      end

      dir.down do
        remove_index :tag_aliases, name: "index_tag_aliases_on_antecedent_name"
        add_index :tag_aliases, :antecedent_name
      end
    end

    # this index was redundant with index_pools_on_lower_name.
    remove_index :pools, column: :name, name: "index_pools_on_name"
  end
end
