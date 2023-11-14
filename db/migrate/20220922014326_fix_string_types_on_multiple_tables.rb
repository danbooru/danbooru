class FixStringTypesOnMultipleTables < ActiveRecord::Migration[7.0]
  def up
    change_column :artist_urls, :url, :string
    change_column :saved_searches, :query, :string
    change_column :tag_aliases, :status, :string
    change_column :tag_implications, :status, :string
    change_column :uploads, :source, :string
    change_column :uploads, :status, :string
    change_column :uploads, :referer_url, :string
    change_column :post_replacements, :original_url, :string
    change_column :post_replacements, :replacement_url, :string

    change_column :forum_topics, :title, :text
    change_column :pools, :name, :text
  end

  def down
    change_column :artist_urls, :url, :text
    change_column :saved_searches, :query, :text
    change_column :tag_aliases, :status, :text
    change_column :tag_implications, :status, :text
    change_column :uploads, :source, :text
    change_column :uploads, :status, :text
    change_column :uploads, :referer_url, :text
    change_column :post_replacements, :original_url, :text
    change_column :post_replacements, :replacement_url, :text

    change_column :forum_topics, :title, :string
    change_column :pools, :name, :string
  end
end
