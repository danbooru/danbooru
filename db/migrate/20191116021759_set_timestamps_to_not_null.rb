class SetTimestampsToNotNull < ActiveRecord::Migration[6.0]
  def change
    execute "set statement_timeout = 0"

    tables = %i[
      api_keys artist_commentaries artist_commentary_versions artist_urls
      artist_versions artists bans bulk_update_requests comment_votes comments
      delayed_jobs dmail_filters dmails favorite_groups forum_posts
      forum_topic_visits forum_topics ip_bans janitor_trials mod_actions
      news_updates notes note_versions pools posts post_appeals post_flags
      post_votes saved_searches tag_aliases tag_implications uploads
      user_feedback user_name_change_requests user_password_reset_nonces
      wiki_pages wiki_page_versions
    ]

    tables.each do |t|
      change_column_null t, :created_at, false
      change_column_null t, :updated_at, false
    end

    # note: users.updated_at can be null.
    change_column_null :users, :created_at, false
  end
end
