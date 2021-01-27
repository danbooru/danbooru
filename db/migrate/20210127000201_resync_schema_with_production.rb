class ResyncSchemaWithProduction < ActiveRecord::Migration[6.1]
  def change
    enable_extension :pgstattuple

    add_index :schema_migrations, :version, name: "unique_schema_migrations", unique: true, if_not_exists: true

    reversible do |dir|
      dir.up do
        change_column :tags, :category, :integer

        if index_exists?(:posts, :tag_index, name: :index_posts_on_tags_index)
          rename_index :posts, :index_posts_on_tags_index, :index_posts_on_tag_index
        end

        remove_index :posts, name: "index_posts_on_source", if_exists: true
        execute "ALTER TABLE posts ALTER column tag_index SET STATISTICS 3000"

        fix_id_sequences
      end

      dir.down do
        change_column :tags, :category, :smallint

        if index_exists?(:posts, :tag_index, name: :index_posts_on_tag_index)
          rename_index :posts, :index_posts_on_tag_index, :index_posts_on_tags_index
        end

        remove_index :posts, name: "index_posts_on_source", if_exists: true
        add_index :posts, "lower(source)", name: "index_posts_on_source", if_not_exists: true
        execute "ALTER TABLE posts ALTER column tag_index SET STATISTICS -1"
      end
    end
  end

  def fix_id_sequences
    tables = %w[
      api_keys
      artist_commentaries
      artist_commentary_versions
      artist_urls
      artist_versions
      artists
      bans
      bulk_update_requests
      comment_votes
      comments
      delayed_jobs
      dmails
      favorite_groups
      favorites
      forum_posts
      forum_topic_visits
      forum_topics
      ip_bans
      mod_actions
      news_updates
      note_versions
      notes
      pixiv_ugoira_frame_data
      pools
      post_appeals
      post_approvals
      post_disapprovals
      post_flags
      post_replacements
      post_votes
      posts
      saved_searches
      tag_aliases
      tag_implications
      tags
      uploads
      user_feedback
      user_name_change_requests
      users
      wiki_pages
      wiki_page_versions
    ]

    tables.each do |table|
      execute "ALTER SEQUENCE #{table}_id_seq AS integer"
    end
  end
end
